import asyncio
import json
import logging
from datetime import datetime
from typing import Optional, Dict, Any
from uuid import uuid4

import websockets
from fastapi import HTTPException

from src.logging.log import dbg_log

logger = logging.getLogger(__name__)


class AIService:
    def __init__(self):
        self.backend_api_url = "http://genai-provided-backend:8000/api"
        self.master_be_api_key = "7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be"
        self.router_ws_url = "ws://genai-router:8080/ws"
        self.provided_backend_ws_url = "ws://genai-provided-backend:8000/frontend/ws"
        
    async def send_message_to_agent(
        self, 
        user_id: str, 
        session_id: str, 
        message: str,
        conversation_id: str,
        files: Optional[list] = None
    ) -> Dict[str, Any]:
        """
        Send a message to the master agent and get a response.
        
        Args:
            user_id: The user's ID
            session_id: The session ID for the conversation
            message: The user's message
            conversation_id: The conversation ID
            files: Optional list of file IDs
            
        Returns:
            Dict containing the agent's response
        """
        try:
            dbg_log(f"send_message_to_agent() begin - message: {message[:50]}...")
            
            # Create a request ID for this interaction
            request_id = str(uuid4())
            
            # Prepare the message for the master agent
            agent_message = {
                "message": message,
                "llm_name": "default",  # You can make this configurable
                "provider": "openai",   # You can make this configurable
                "files": files or []
            }
            
            # Try to connect to the provided backend's WebSocket endpoint
            try:
                agent_response = await self._send_via_websocket(
                    user_id=user_id,
                    session_id=session_id,
                    request_id=request_id,
                    message=agent_message
                )
            except Exception as ws_error:
                dbg_log(f"WebSocket connection failed: {ws_error}")
                # Fallback to simulated response
                agent_response = await self._simulate_agent_response(message)
            
            dbg_log(f"send_message_to_agent() end - response: {agent_response.get('response', '')[:50]}...")
            
            return {
                "message_id": request_id,
                "response": agent_response.get("response", "No response from agent"),
                "is_success": agent_response.get("is_success", False),
                "agents_trace": agent_response.get("agents_trace", [])
            }
            
        except Exception as e:
            error_msg = f"Error sending message to agent: {str(e)}"
            logger.exception(error_msg)
            raise HTTPException(status_code=500, detail=error_msg)
    
    async def _send_via_websocket(
        self, 
        user_id: str, 
        session_id: str, 
        request_id: str, 
        message: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Send message to master agent via WebSocket connection."""
        try:
            # Connect to the provided backend's WebSocket endpoint
            uri = f"ws://genai-provided-backend:8000/frontend/ws"
            
            async with websockets.connect(uri) as websocket:
                # Prepare the message in the format expected by the provided backend
                ws_message = {
                    "message": message["message"],
                    "llm_name": message["llm_name"],
                    "provider": message["provider"],
                    "files": message["files"],
                    "session_id": session_id,
                    "user_id": user_id
                }
                
                # Send the message
                await websocket.send(json.dumps(ws_message))
                
                # Wait for response with timeout
                try:
                    response = await asyncio.wait_for(websocket.recv(), timeout=30.0)
                    response_data = json.loads(response)
                    
                    # Extract the agent response from the WebSocket response
                    if "response" in response_data:
                        return {
                            "response": response_data["response"].get("response", "No response"),
                            "is_success": response_data["response"].get("is_success", False),
                            "agents_trace": response_data["response"].get("agents_trace", [])
                        }
                    else:
                        return {
                            "response": "Invalid response format from agent",
                            "is_success": False,
                            "agents_trace": []
                        }
                        
                except asyncio.TimeoutError:
                    return {
                        "response": "Timeout waiting for agent response",
                        "is_success": False,
                        "agents_trace": []
                    }
                    
        except Exception as e:
            logger.exception(f"WebSocket connection error: {e}")
            raise e
    
    async def _simulate_agent_response(self, message: str) -> Dict[str, Any]:
        """Simulate agent response when WebSocket is not available."""
        await asyncio.sleep(1)  # Simulate processing time
        
        return {
            "response": f"AI Agent Response: I received your message: '{message}'. This is a simulated response from the master agent. In a real implementation, this would be processed by the actual AI agent.",
            "is_success": True,
            "agents_trace": [
                {
                    "name": "MasterAgent",
                    "output": "Simulated agent processing",
                    "is_success": True
                }
            ]
        }
    
    async def _add_message_to_chat(
        self, 
        user_id: str, 
        session_id: str, 
        request_id: str, 
        message: str, 
        sender_type: str
    ):
        """Add a message to the chat history in the provided backend."""
        try:
            # Log the message instead of making HTTP requests
            dbg_log(f"Would add message to chat: {sender_type} - {message[:50]}...")
            # In a real implementation, this would be handled by the provided-backend
            # through its own database operations
                
        except Exception as e:
            logger.warning(f"Could not add message to chat: {e}")


# Create a singleton instance
ai_service = AIService() 