import asyncio
import json
import logging
from datetime import datetime
from typing import Optional, Dict, Any
from uuid import uuid4
import httpx

import websockets
from fastapi import HTTPException

from src.logging.log import dbg_log

logger = logging.getLogger(__name__)


class AIService:
    def __init__(self):
        self.provided_backend_ws_url = "ws://genai-provided-backend:8000/frontend/ws"
        self.provided_backend_http_url = "http://genai-provided-backend:8000"
        self.jwt_token = None
        self.llm_name = "default"  # Must match a config in provided-backend
        self.provider = "genai"   # Must match a provider in provided-backend
        
    async def initialize(self):
        """Initialize the AI service by creating a user and getting a JWT token."""
        try:
            await self._ensure_user_and_token()
        except Exception as e:
            logger.warning(f"Failed to initialize AI service: {e}")
            # Continue with simulated responses
            
    async def _ensure_user_and_token(self):
        """Ensure we have a valid user and JWT token in provided-backend."""
        try:
            # Try to register a new user
            username = f"project_backend_user_{uuid4().hex[:8]}"
            password = "ProjectBackend123!"
            
            async with httpx.AsyncClient() as client:
                # Register the user
                register_data = {
                    "username": username,
                    "password": password
                }
                
                register_response = await client.post(
                    f"{self.provided_backend_http_url}/api/register",
                    json=register_data,
                    timeout=10.0
                )
                
                if register_response.status_code == 200:
                    dbg_log(f"Successfully registered user: {username}")
                elif register_response.status_code == 400 and "already exists" in register_response.text:
                    dbg_log(f"User {username} already exists, proceeding to login")
                else:
                    logger.warning(f"User registration failed: {register_response.status_code} - {register_response.text}")
                    return
                
                # Login to get JWT token
                login_data = {
                    "username": username,
                    "password": password
                }
                
                login_response = await client.post(
                    f"{self.provided_backend_http_url}/api/login/access-token",
                    data=login_data,  # Use form data for OAuth2
                    timeout=10.0
                )
                
                if login_response.status_code == 200:
                    token_data = login_response.json()
                    self.jwt_token = token_data.get("access_token")
                    dbg_log(f"Successfully obtained JWT token for user: {username}")
                    
                    # Ensure the user has the required provider and config
                    await self._ensure_provider_and_config(client)
                else:
                    logger.warning(f"Login failed: {login_response.status_code} - {login_response.text}")
                    
        except Exception as e:
            logger.warning(f"Failed to ensure user and token: {e}")
    
    async def _ensure_provider_and_config(self, client):
        """Ensure the user has the genai provider and default config."""
        try:
            headers = {"Authorization": f"Bearer {self.jwt_token}"}
            
            # Check if genai provider exists
            provider_response = await client.get(
                f"{self.provided_backend_http_url}/api/llm/hackathon/genai",
                headers=headers,
                timeout=10.0
            )
            
            if provider_response.status_code == 200:
                dbg_log("GenAI provider already exists")
            else:
                # Create the genai provider with the correct base_url for master-agent
                provider_data = {
                    "name": "genai",
                    "api_key": None,
                    "metadata": {
                        "base_url": "http://genai-master-agent:8000"
                    }
                }
                
                provider_create_response = await client.post(
                    f"{self.provided_backend_http_url}/api/llm/model/provider",
                    headers=headers,
                    json=provider_data,
                    timeout=10.0
                )
                
                if provider_create_response.status_code == 200:
                    dbg_log("Successfully created genai provider")
                else:
                    logger.warning(f"Failed to create genai provider: {provider_create_response.status_code}")
                    return
            
            # Check if default config exists
            configs_response = await client.get(
                f"{self.provided_backend_http_url}/api/llm/model/configs",
                headers=headers,
                timeout=10.0
            )
            
            if configs_response.status_code == 200:
                configs_data = configs_response.json()
                has_default_config = False
                
                for provider in configs_data:
                    if provider.get("provider") == "genai":
                        for config in provider.get("configs", []):
                            if config.get("name") == "default":
                                has_default_config = True
                                break
                        break
                
                if has_default_config:
                    dbg_log("Default config already exists")
                else:
                    # Create the default config
                    config_data = {
                        "name": "default",
                        "model": "gpt-4o",
                        "provider": "genai",
                        "temperature": 0.7,
                        "system_prompt": "You are a helpful AI assistant. Please respond to the user's query to the best of your ability.",
                        "credentials": {}
                    }
                    
                    config_create_response = await client.post(
                        f"{self.provided_backend_http_url}/api/llm/model/config",
                        headers=headers,
                        json=config_data,
                        timeout=10.0
                    )
                    
                    if config_create_response.status_code == 200:
                        dbg_log("Successfully created default config")
                    else:
                        logger.warning(f"Failed to create default config: {config_create_response.status_code}")
            else:
                logger.warning(f"Failed to check configs: {configs_response.status_code}")
                
        except Exception as e:
            logger.warning(f"Failed to ensure provider and config: {e}")
    
    async def send_message_to_agent(
        self, 
        user_id: str, 
        session_id: str, 
        message: str,
        conversation_id: str,
        files: Optional[list] = None
    ) -> Dict[str, Any]:
        """
        Send a message to the master agent via provided-backend's WebSocket.
        
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
            
            # Ensure we have a valid JWT token
            if not self.jwt_token:
                await self._ensure_user_and_token()
            
            # Send message to provided-backend's WebSocket endpoint
            try:
                agent_response = await self._send_via_provided_backend(
                    session_id=session_id,
                    message=message,
                    files=files or []
                )
            except Exception as ws_error:
                dbg_log(f"Provided-backend WebSocket connection failed: {ws_error}")
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
    
    async def _send_via_provided_backend(
        self, 
        session_id: str, 
        message: str,
        files: list
    ) -> Dict[str, Any]:
        """Send message to master agent via provided-backend's WebSocket."""
        if not self.jwt_token:
            raise Exception("No JWT token available")
            
        try:
            # Generate a unique session_id for this websocket connection to avoid conflicts
            unique_session_id = str(uuid4())
            
            # Connect to the provided backend's WebSocket endpoint
            uri = f"{self.provided_backend_ws_url}?token={self.jwt_token}&session_id={unique_session_id}"
            dbg_log(f"Connecting to websocket: {uri}")
            
            async with websockets.connect(uri) as websocket:
                # Prepare the message in the format expected by the provided backend
                ws_message = {
                    "message": message,
                    "llm_name": self.llm_name,
                    "provider": self.provider,
                    "files": files
                }
                
                dbg_log(f"Sending websocket message: {ws_message}")
                
                # Send the message
                await websocket.send(json.dumps(ws_message))
                
                # Wait for response with timeout
                try:
                    # Wait for the actual AI response, not just log messages
                    max_attempts = 10
                    attempt = 0
                    response_data = None
                    
                    while attempt < max_attempts:
                        response = await asyncio.wait_for(websocket.recv(), timeout=10.0)
                        dbg_log(f"Received websocket response (attempt {attempt + 1}): {response[:200]}...")
                        response_data = json.loads(response)
                        
                        # Check if this is the actual AI response
                        if "type" in response_data and response_data["type"] == "agent_response":
                            break
                        elif "type" in response_data and response_data["type"] == "agent_log":
                            # This is a log message, continue waiting for the actual response
                            attempt += 1
                            continue
                        else:
                            # Unknown response type, break and process it
                            break
                    
                    # Parse the provided-backend response format
                    # Expected format: {"type": "agent_response", "response": {...}}
                    if response_data and "type" in response_data and response_data["type"] == "agent_response":
                        if "response" in response_data:
                            agent_response = response_data["response"]
                            # The actual response text is in agent_response["response"]
                            if isinstance(agent_response.get("response"), dict):
                                # If response is a dict, extract the text from it
                                response_text = agent_response["response"].get("response", "No response text")
                            else:
                                # If response is a string, use it directly
                                response_text = agent_response.get("response", "No response")
                            
                            return {
                                "response": response_text,
                                "is_success": True,
                                "agents_trace": agent_response.get("agents_trace", [])
                            }
                        else:
                            return {
                                "response": "Invalid response format: missing 'response' field",
                                "is_success": False,
                                "agents_trace": []
                            }
                    else:
                        # Handle error responses or unexpected formats
                        if response_data and "error" in response_data:
                            return {
                                "response": f"Error from provided-backend: {response_data['error']}",
                                "is_success": False,
                                "agents_trace": []
                            }
                        else:
                            return {
                                "response": f"Unexpected response format: {response_data}",
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
            logger.exception(f"Provided-backend WebSocket connection error: {e}")
            raise e
    
    async def _simulate_agent_response(self, message: str) -> Dict[str, Any]:
        """Simulate agent response when provided-backend is not available."""
        await asyncio.sleep(1)  # Simulate processing time
        
        return {
            "response": f"AI Agent Response: I received your message: '{message}'. This is a simulated response from the master agent. In a real implementation, this would be processed by the actual AI agent through the provided-backend.",
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