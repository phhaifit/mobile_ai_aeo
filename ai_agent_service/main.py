import os
from datetime import datetime
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from dotenv import load_dotenv

# Load biến môi trường từ file .env
load_dotenv()

from models import ChatRequest, ChatResponse, SessionListResponse, SessionMessagesResponse, ChatSessionResponse
from agent import get_agent_executor, get_session_history

# In-memory session metadata store (thay thế MongoDB)
_sessions_metadata = {}

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
        # Lưu session metadata in-memory
        if request.session_id not in _sessions_metadata:
            title = request.message[:50] + ("..." if len(request.message) > 50 else "")
            _sessions_metadata[request.session_id] = {
                "session_id": request.session_id,
                "access_token": request.access_token,
                "title": title,
                "created_at": datetime.utcnow(),
                "updated_at": datetime.utcnow()
            }
        else:
            _sessions_metadata[request.session_id]["updated_at"] = datetime.utcnow()

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
        sessions = []
        for sid, meta in sorted(_sessions_metadata.items(), key=lambda x: x[1]["updated_at"], reverse=True):
            if meta["access_token"] == access_token:
                sessions.append(ChatSessionResponse(
                    session_id=meta["session_id"],
                    title=meta.get("title", "Hội thoại mới"),
                    updated_at=meta["updated_at"].isoformat()
                ))
        return SessionListResponse(sessions=sessions)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/v1/chat/sessions/{session_id}/messages", response_model=SessionMessagesResponse)
async def get_session_messages(session_id: str):
    try:
        history = get_session_history(session_id)
        messages = []
        for msg in history.messages:
            messages.append({
                "type": msg.type, # "human" or "ai"
                "content": msg.content
            })
        return SessionMessagesResponse(messages=messages)
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "ok"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
