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

        message_id = uuid.uuid4()
        conversation_id = message_info.conversation_id
        message = message_info.message
        db_curr.execute(query = f"insert into {schema}.{table} (message_id, conversation_id, sender_type, message) values (%s, %s, %s, %s)",
                        params = (message_id, conversation_id, "User", message))
        db_conn.commit()

        return JSONResponse(status_code = status.HTTP_201_CREATED,
                            content = jsonable_encoder(CreateResponse(message = "Message create successfully.",
                                                                      message_id = message_id)))
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