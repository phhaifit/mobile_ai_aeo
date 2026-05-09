import os
import requests
import json
from langchain_google_genai import ChatGoogleGenerativeAI
from langchain.agents import AgentExecutor, create_tool_calling_agent
from langchain_core.prompts import ChatPromptTemplate, MessagesPlaceholder
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_community.chat_message_histories import ChatMessageHistory
from langchain_core.tools import tool
from langchain_core.messages import SystemMessage

# Biến toàn cục để lưu trữ schema
AEO_OPENAPI_SCHEMA = None

# In-memory session store (thay thế MongoDB)
_session_store = {}

def fetch_openapi_schema():
    """Tải và tối ưu hóa OpenAPI Schema từ server để đưa vào System Prompt."""
    global AEO_OPENAPI_SCHEMA
    if AEO_OPENAPI_SCHEMA:
        return AEO_OPENAPI_SCHEMA
        
    try:
        url = os.getenv("API_BASE_URL", "https://api.aeo.how") + "/api-json"
        response = requests.get(url)
        response.raise_for_status()
        data = response.json()
        
        # Tối ưu hóa JSON để tiết kiệm context (giữ lại paths, methods, requestBody, parameters)
        optimized_schema = {"paths": {}}
        for path, methods in data.get("paths", {}).items():
            optimized_schema["paths"][path] = {}
            for method, details in methods.items():
                if method.lower() in ["get", "post", "put", "delete", "patch"]:
                    optimized_schema["paths"][path][method] = {
                        "summary": details.get("summary", ""),
                        "parameters": details.get("parameters", []),
                        "requestBody": details.get("requestBody", {})
                    }
        
        # Lưu trữ các schema models nếu cần
        optimized_schema["components"] = data.get("components", {})
        
        AEO_OPENAPI_SCHEMA = json.dumps(optimized_schema, ensure_ascii=False)
        return AEO_OPENAPI_SCHEMA
    except Exception as e:
        print(f"Lỗi khi tải OpenAPI Schema: {e}")
        return "Không thể tải OpenAPI Schema. Hãy báo cho người dùng."

@tool
def execute_api_request(method: str, path: str, access_token: str, query_params: dict = None, body_json: dict = None) -> str:
    """
    Công cụ DUY NHẤT để gọi API tới hệ thống AEO.
    - method: 'GET', 'POST', 'PUT', 'DELETE', v.v.
    - path: Đường dẫn API (ví dụ: '/api/topics').
    - access_token: Token xác thực của user.
    - query_params: (Tùy chọn) Dictionary chứa các tham số trên URL.
    - body_json: (Tùy chọn) Dictionary chứa payload JSON gửi trong body (dùng cho POST/PUT).
    """
    base_url = os.getenv("API_BASE_URL", "https://api.aeo.how")
    url = f"{base_url}{path}"
    
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }
    
    try:
        response = requests.request(
            method=method.upper(),
            url=url,
            headers=headers,
            params=query_params or {},
            json=body_json
        )
        response.raise_for_status()
        
        try:
            return json.dumps(response.json(), ensure_ascii=False)
        except:
            return response.text
            
    except requests.exceptions.RequestException as e:
        error_msg = f"API Request Failed: {e}"
        if e.response is not None:
            error_msg += f"\nResponse Body: {e.response.text}"
        return error_msg

def get_session_history(session_id: str):
    """Lấy hoặc tạo chat history in-memory cho session."""
    if session_id not in _session_store:
        _session_store[session_id] = ChatMessageHistory()
    return _session_store[session_id]

def get_agent_executor():
    schema_context = fetch_openapi_schema()
    
    llm = ChatGoogleGenerativeAI(
        model="gemini-2.5-flash",
        temperature=0.2,
        google_api_key=os.getenv("GEMINI_API_KEY")
    )
    
    tools = [execute_api_request]
    
    system_prompt = f"""Bạn là trợ lý AI thông minh của ứng dụng AEO.
Nhiệm vụ của bạn là lắng nghe yêu cầu của người dùng, đọc TÀI LIỆU API (OpenAPI Schema) dưới đây để tìm ra API phù hợp, và dùng công cụ 'execute_api_request' để gọi API đó.
LUÔN LUÔN truyền 'access_token' (được cung cấp trong câu hỏi) vào công cụ.
Nếu không chắc chắn tham số nào bắt buộc (ví dụ payload của POST), hãy hỏi lại người dùng hoặc suy luận từ ngữ cảnh.

--- TÀI LIỆU API (OPENAPI SCHEMA) ---
{schema_context}
--- HẾT TÀI LIỆU ---

Khi gọi API thành công, hãy lấy kết quả từ JSON để trả lời người dùng một cách thân thiện bằng tiếng Việt.
"""
    
    prompt = ChatPromptTemplate.from_messages([
        SystemMessage(content=system_prompt),
        MessagesPlaceholder(variable_name="chat_history"),
        ("human", "{input}"),
        MessagesPlaceholder(variable_name="agent_scratchpad"),
    ])
    
    agent = create_tool_calling_agent(llm, tools, prompt)
    agent_executor = AgentExecutor(agent=agent, tools=tools, verbose=True)
    
    agent_with_chat_history = RunnableWithMessageHistory(
        agent_executor,
        get_session_history,
        input_messages_key="input",
        history_messages_key="chat_history",
    )
    
    return agent_with_chat_history
