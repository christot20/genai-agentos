import psycopg
import os
import uuid
from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from src.routes.message.schema.message_schema import CreateRequest, CreateResponse, Message, ListRequest, ListResponse
from src.routes.account.util.token import validate_jwt, get_uuid_from_jwt
from src.logging.log import dbg_log
from src.db.session import get_db_session
from src.services.ai_service import ai_service



message_router = APIRouter(prefix = "/message")
security = HTTPBearer()



@message_router.post("/create")
async def create(message_info: CreateRequest, token: HTTPAuthorizationCredentials = Depends(security), db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"create() begin")
        dbg_log(f"scheme = {token.scheme} | credentials = {token.credentials}")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_MESSAGE_TABLE")

        if not validate_jwt(token, db_curr):
            return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                content = jsonable_encoder(CreateResponse(message = "Unauthorized")))

        # Get user ID from token
        user_id = get_uuid_from_jwt(token, db_curr)
        
        # Create message ID for user message
        user_message_id = uuid.uuid4()
        conversation_id = message_info.conversation_id
        message = message_info.message
        
        # Save user message to database
        db_curr.execute(query = f"insert into {schema}.{table} (message_id, conversation_id, sender_type, message) values (%s, %s, %s, %s)",
                        params = (user_message_id, conversation_id, "User", message))
        db_conn.commit()

        # Send message to AI agent and get response
        try:
            # Use conversation_id as session_id for the AI service
            session_id = str(conversation_id)
            
            ai_response = await ai_service.send_message_to_agent(
                user_id=str(user_id),
                session_id=session_id,
                message=message,
                conversation_id=str(conversation_id)
            )
            
            # Save AI response to database
            ai_message_id = uuid.uuid4()
            ai_response_text = ai_response.get("response", "No response from AI agent")
            
            db_curr.execute(query = f"insert into {schema}.{table} (message_id, conversation_id, sender_type, message) values (%s, %s, %s, %s)",
                            params = (ai_message_id, conversation_id, "AI", ai_response_text))
            db_conn.commit()
            
            dbg_log(f"AI response saved: {ai_response_text[:50]}...")
            
        except Exception as ai_error:
            dbg_log(f"Error getting AI response: {ai_error}")
            # Continue without AI response - user message was still saved
            ai_response = {"response": "Sorry, I couldn't process your message at this time.", "is_success": False}

        return JSONResponse(status_code = status.HTTP_201_CREATED,
                            content = jsonable_encoder(CreateResponse(
                                message = "Message created successfully with AI response.",
                                message_id = user_message_id,
                                ai_response = ai_response
                            )))
                            
    except psycopg.errors.ForeignKeyViolation as _:
        return JSONResponse(status_code = status.HTTP_400_BAD_REQUEST,
                            content = jsonable_encoder(CreateResponse(message = "Invalid conversation_id supplied.")))
    finally:
        dbg_log(f"create() end")

@message_router.get("/list")
async def list(message_info: ListRequest, token: HTTPAuthorizationCredentials = Depends(security), db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"list() begin")
        dbg_log(f"scheme = {token.scheme} | credentials = {token.credentials}")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        message_table = os.environ.get("POSTGRES_MESSAGE_TABLE")
        conversation_table = os.environ.get("POSTGRES_CONVERSATION_TABLE")

        if not validate_jwt(token, db_curr):
            return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                content = jsonable_encoder(CreateResponse(message = "Unauthorized")))

        creator_id = get_uuid_from_jwt(token, db_curr)

        db_curr.execute(query = f"select m.message_id, m.sender_type, m.creation_date, m.message from {schema}.{message_table} m inner join {schema}.{conversation_table} c on m.conversation_id = c.conversation_id where c.creator_id = %s",
                        params = (creator_id,))
        query_response = db_curr.fetchall()
        dbg_log(f"query_response = {query_response}")

        messages = []
        for row in query_response:
            messages.append(Message(message_id = row[0],
                                    sender_type = row[1],
                                    creation_date = row[2],
                                    message = row[3]))
        dbg_log(f"conversations = {messages}")

        return JSONResponse(status_code = status.HTTP_201_CREATED,
                            content = jsonable_encoder(ListResponse(message = "Success",
                                                                    messages = messages)))
    finally:
        dbg_log(f"list() end")

@message_router.post("/test-ai")
async def test_ai_connection(token: HTTPAuthorizationCredentials = Depends(security)):
    """Test endpoint to verify AI service connection."""
    try:
        dbg_log(f"test_ai_connection() begin")
        
        # Get user ID from token
        user_id = get_uuid_from_jwt(token, None)  # We don't need db cursor for this
        
        # Test the AI service with a simple message
        test_response = await ai_service.send_message_to_agent(
            user_id=str(user_id),
            session_id="test-session",
            message="Hello, this is a test message to verify AI service connection.",
            conversation_id="test-conversation"
        )
        
        return JSONResponse(
            status_code=status.HTTP_200_OK,
            content={
                "message": "AI service test completed",
                "ai_response": test_response,
                "is_success": test_response.get("is_success", False)
            }
        )
        
    except Exception as e:
        dbg_log(f"test_ai_connection() error: {e}")
        return JSONResponse(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            content={
                "message": f"AI service test failed: {str(e)}",
                "is_success": False
            }
        )
    finally:
        dbg_log(f"test_ai_connection() end")