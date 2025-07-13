# AI Integration Documentation

## Overview

This document explains how the project-backend connects to the master agent to provide AI-powered responses to user messages.

## Architecture

```
User Message → Project Backend → AI Service → Master Agent → Response
```

## Components

### 1. AI Service (`src/services/ai_service.py`)

The AI Service is responsible for:
- Connecting to the master agent via WebSocket
- Sending user messages to the agent
- Receiving and processing AI responses
- Handling fallback responses when the agent is unavailable

### 2. Message Routes (`src/routes/message/routes.py`)

The message routes have been enhanced to:
- Save user messages to the database
- Send messages to the AI service
- Save AI responses to the database
- Return both user message and AI response

### 3. Master Agent Integration

The system connects to the master agent through:
- **WebSocket Connection**: `ws://genai-provided-backend:8000/frontend/ws`
- **Fallback**: Simulated responses when WebSocket is unavailable

## API Endpoints

### POST `/api/message/create`

Creates a new message and gets an AI response.

**Request:**
```json
{
  "message": "Hello, how can you help me?",
  "conversation_id": "uuid"
}
```

**Response:**
```json
{
  "message": "Message created successfully with AI response.",
  "message_id": "uuid",
  "ai_response": {
    "response": "AI Agent Response: I received your message...",
    "is_success": true,
    "agents_trace": [...]
  }
}
```

### POST `/api/message/test-ai`

Test endpoint to verify AI service connection.

**Response:**
```json
{
  "message": "AI service test completed",
  "ai_response": {
    "response": "Test response from AI agent",
    "is_success": true,
    "agents_trace": [...]
  },
  "is_success": true
}
```

## Database Schema

Messages are stored with the following sender types:
- `"User"`: Messages sent by the user
- `"AI"`: Responses from the AI agent

## Configuration

The AI service uses the following configuration:
- **Backend API URL**: `http://genai-provided-backend:8000/api`
- **Master BE API Key**: `7a3fd399-3e48-46a0-ab7c-0eaf38020283::master_server_be`
- **Router WS URL**: `ws://genai-router:8080/ws`
- **Provided Backend WS URL**: `ws://genai-provided-backend:8000/frontend/ws`

## Error Handling

The system includes robust error handling:
1. **WebSocket Connection Failure**: Falls back to simulated responses
2. **Timeout**: Returns timeout error after 30 seconds
3. **Invalid Response Format**: Returns error message
4. **Database Errors**: Continues without AI response if database operations fail

## Testing

To test the AI integration:

1. **Start the Docker services**:
   ```bash
   docker compose up --build
   ```

2. **Test the AI connection**:
   ```bash
   curl -X POST http://localhost:8001/api/message/test-ai \
     -H "Authorization: Bearer YOUR_JWT_TOKEN"
   ```

3. **Send a message**:
   ```bash
   curl -X POST http://localhost:8001/api/message/create \
     -H "Authorization: Bearer YOUR_JWT_TOKEN" \
     -H "Content-Type: application/json" \
     -d '{
       "message": "Hello, AI agent!",
       "conversation_id": "your-conversation-uuid"
     }'
   ```

## Dependencies

The AI integration requires these additional dependencies:
- `httpx>=0.25.0`: HTTP client for API calls
- `websockets>=12.0`: WebSocket client for real-time communication
- `asyncio-mqtt>=0.16.0`: MQTT support (optional)

## Future Enhancements

1. **Real WebSocket Integration**: Connect directly to the master agent
2. **Message History**: Include conversation context in AI requests
3. **File Upload Support**: Handle file attachments in messages
4. **Streaming Responses**: Support for streaming AI responses
5. **Multiple AI Models**: Support for different AI providers and models 