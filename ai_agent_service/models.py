from pydantic import BaseModel
from typing import List, Dict, Any

class ChatRequest(BaseModel):
    message: str
    access_token: str
    session_id: str

class ChatResponse(BaseModel):
    response: str
    session_id: str
    status: str = "success"

class ChatSessionResponse(BaseModel):
    session_id: str
    title: str
    updated_at: str

class SessionListResponse(BaseModel):
    sessions: List[ChatSessionResponse]

class SessionMessagesResponse(BaseModel):
    messages: List[Dict[str, Any]]
