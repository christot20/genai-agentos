import psycopg
import os
import uuid
from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from src.routes.conversation.schema.conversation_schema import CreateResponse, ListResponse, Conversation
from src.routes.account.util.token import validate_jwt, get_uuid_from_jwt
from src.logging.log import dbg_log
from src.db.session import get_db_session



conversation_router = APIRouter(prefix = "/conversation")
security = HTTPBearer()



@conversation_router.post("/create")
async def create(token: HTTPAuthorizationCredentials = Depends(security), db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"create() begin")
        dbg_log(f"scheme = {token.scheme} | credentials = {token.credentials}")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_CONVERSATION_TABLE")

        if not validate_jwt(token, db_curr):
            return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                content = jsonable_encoder(CreateResponse(message = "Unauthorized")))

        conversation_id = uuid.uuid4()
        creator_id = get_uuid_from_jwt(token, db_curr)
        db_curr.execute(query = f"insert into {schema}.{table} (conversation_id, creator_id) values (%s, %s)",
                        params = (conversation_id, creator_id))
        db_conn.commit()

        return JSONResponse(status_code = status.HTTP_201_CREATED,
                            content = jsonable_encoder(CreateResponse(message = "Conversation created successfully.",
                                                                      conversation_id = conversation_id)))
    finally:
        dbg_log(f"create() end")

@conversation_router.get("/list")
async def list(token: HTTPAuthorizationCredentials = Depends(security), db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"list() begin")
        dbg_log(f"scheme = {token.scheme} | credentials = {token.credentials}")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_CONVERSATION_TABLE")

        if not validate_jwt(token, db_curr):
            return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                content = jsonable_encoder(CreateResponse(message = "Unauthorized")))

        creator_id = get_uuid_from_jwt(token, db_curr)
        dbg_log(f"creator_id = {creator_id}")
        db_curr.execute(query = f"select * from {schema}.{table} where creator_id = %s",
                        params = (creator_id,))
        query_response = db_curr.fetchall()
        dbg_log(f"query_response = {query_response}")

        convos = []
        for row in query_response:
            convos.append(Conversation(conversation_id = row[0],
                                              creator_id = row[1],
                                              title = row[2],
                                              creation_date = row[3],
                                              updated_date = row[4]))
        dbg_log(f"conversations = {convos}")

        return JSONResponse(status_code = status.HTTP_201_CREATED,
                            content = jsonable_encoder(ListResponse(message = "Success",
                                                                    conversations = convos)))
    finally:
        dbg_log(f"list() end")