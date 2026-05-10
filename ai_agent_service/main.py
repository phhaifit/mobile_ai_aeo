import os
import re
from datetime import datetime
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv
from pymongo import MongoClient

# Load biến môi trường từ file .env
load_dotenv()

from models import ChatRequest, ChatResponse, SessionListResponse, SessionMessagesResponse, ChatSessionResponse
from agent import get_agent_executor, get_session_history

# Setup MongoDB for session metadata
mongo_client = MongoClient(os.getenv("MONGODB_URI", "mongodb://localhost:27017/"))
db = mongo_client["aeo_agent_db"]
chat_sessions_collection = db["chat_sessions"]

app = FastAPI(title="AI Agent Service for AEO (OpenAPI)", version="1.1.0")

# Cấu hình CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Khởi tạo agent
agent_executor = get_agent_executor()

@app.post("/api/v1/chat", response_model=ChatResponse)
async def chat(request: ChatRequest):
    try:
        # Lưu/cập nhật session metadata vào MongoDB
        existing_session = chat_sessions_collection.find_one({"session_id": request.session_id})
        if not existing_session:
            title = request.message[:50] + ("..." if len(request.message) > 50 else "")
            chat_sessions_collection.insert_one({
                "session_id": request.session_id,
                "access_token": request.access_token,
                "title": title,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            })
        else:
            chat_sessions_collection.update_one(
                {"session_id": request.session_id},
                {"$set": {"updated_at": datetime.utcnow()}}
            )

        user_input_with_token = f"[Hệ thống: Truyền vào access_token của user: {request.access_token}]\n\nCâu hỏi của User: {request.message}"
        
        response = agent_executor.invoke(
            {"input": user_input_with_token},
            config={"configurable": {"session_id": request.session_id}}
        )
        
        return ChatResponse(
            response=response["output"],
            session_id=request.session_id,
            status="success"
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/chat/sessions", response_model=SessionListResponse)
async def get_sessions(access_token: str):
    try:
        cursor = chat_sessions_collection.find({"access_token": access_token}).sort("updated_at", -1)
        sessions = []
        for doc in cursor:
            sessions.append(ChatSessionResponse(
                session_id=doc["session_id"],
                title=doc.get("title", "Hội thoại mới"),
                updated_at=doc["updated_at"].isoformat()
            ))
        return SessionListResponse(sessions=sessions)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

def _clean_human_message(content: str) -> str:
    """Loại bỏ prefix hệ thống khỏi tin nhắn user để hiển thị sạch."""
    # Pattern: [Hệ thống: ...access_token...]\n\nCâu hỏi của User: <nội dung thực>
    match = re.search(r'Câu hỏi của User:\s*(.*)', content, re.DOTALL)
    if match:
        return match.group(1).strip()
    return content

@app.get("/api/v1/chat/sessions/{session_id}/messages", response_model=SessionMessagesResponse)
async def get_session_messages(session_id: str):
    try:
        history = get_session_history(session_id)
        messages = []
        for msg in history.messages:
            content = msg.content
            if msg.type == "human":
                content = _clean_human_message(content)
            messages.append({
                "type": msg.type,  # "human" or "ai"
                "content": content
            })
        return SessionMessagesResponse(messages=messages)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/api/v1/chat/sessions/{session_id}")
async def delete_session(session_id: str):
    try:
        # Xóa session metadata
        chat_sessions_collection.delete_one({"session_id": session_id})
        # Xóa chat history từ MongoDB
        history = get_session_history(session_id)
        history.clear()
        return {"status": "success", "message": "Session đã được xóa"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
