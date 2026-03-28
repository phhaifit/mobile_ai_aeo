"""Jarvis AEO Backend — Content Enhancement API powered by Google Gemini."""

import os
from typing import Optional, Dict
from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
import google.generativeai as genai

# Config
GEMINI_API_KEY = os.getenv("GEMINI_API_KEY", "")
genai.configure(api_key=GEMINI_API_KEY)
model = genai.GenerativeModel(os.getenv("GEMINI_MODEL", "gemini-2.5-flash"))

app = FastAPI(title="Jarvis AEO API", version="1.0.0")

# Allow Flutter app to connect from any origin
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# Prompt templates for each content operation
PROMPTS = {
    "enhance": (
        "You are a professional content editor. "
        "Improve the following text to be more professional, clear, and engaging. "
        "Keep the same meaning but enhance the quality:\n\n"
    ),
    "rewrite": (
        "Rewrite the following text using completely different wording "
        "while preserving the exact same meaning:\n\n"
    ),
    "humanize": (
        "The following text was written by AI and sounds robotic. "
        "Rewrite it to sound natural, conversational, and human. "
        "Add personality and vary sentence structure:\n\n"
    ),
    "summarize": (
        "Summarize the following text concisely. "
        "Keep only the key points and main ideas:\n\n"
    ),
}


class ContentRequest(BaseModel):
    text: str
    operation: str = "enhance"
    options: Optional[Dict] = None


@app.get("/health")
async def health():
    return {"status": "ok"}


@app.post("/api/v1/content/{operation}")
async def process_content(operation: str, body: ContentRequest):
    if operation not in PROMPTS:
        raise HTTPException(400, f"Unknown operation: {operation}")

    if not body.text.strip():
        raise HTTPException(400, "Text cannot be empty")

    if len(body.text) > 10000:
        raise HTTPException(400, "Text exceeds 10,000 character limit")

    try:
        prompt = PROMPTS[operation] + body.text
        response = model.generate_content(prompt)
        return {
            "result": response.text,
            "operation": operation,
            "tokens_used": response.usage_metadata.total_token_count
            if response.usage_metadata
            else None,
        }
    except Exception as e:
        raise HTTPException(500, f"AI processing failed: {str(e)}")
