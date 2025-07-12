from multiprocessing.managers import public_methods

import psycopg
import os
import uuid

from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from src.routes.account.schema.login_schema import LoginResponse
from src.routes.account.schema.create_schema import CreateRequest, CreateResponse
from src.routes.account.util.hash import hash_string
from src.db.session import get_db_session



account_router = APIRouter(prefix = "/account")



@account_router.post("/create", status_code = status.HTTP_201_CREATED)
async def create(account_info: CreateRequest, db_conn: psycopg.Connection = Depends(get_db_session)):
    db_curr = db_conn.cursor()
    schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
    table = os.environ.get("POSTGRES_ACCOUNT_TABLE")

    uid = str(uuid.uuid4())
    username = account_info.username
    password_hash = hash_string(account_info.password)

    try:
        db_curr.execute(query =  f"insert into {schema}.{table} values (%s, %s, %s)",
                        params = (uid, username, password_hash))
        db_conn.commit()
    except psycopg.errors.UniqueViolation:
        return JSONResponse(status_code = status.HTTP_409_CONFLICT,
                           content = jsonable_encoder(CreateResponse(message = "Username already exists.")))
    except Exception as e:
        return JSONResponse(status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
                            content = jsonable_encoder(CreateResponse(message="Failed to create a new account.")))

    return JSONResponse(status_code = status.HTTP_200_OK,
                        content = jsonable_encoder(CreateResponse(message = "Account created successfully.")))