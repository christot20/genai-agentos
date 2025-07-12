from multiprocessing.managers import public_methods

import psycopg
import os
from typing import AsyncGenerator

from fastapi import APIRouter, status, Depends

from src.routes.account.schema.login_schema import LoginResponse
from src.routes.account.schema.create_schema import CreateResponse
from src.routes.account.util.hash import hash_string
from src.db.session import get_db_session



account_router = APIRouter(prefix = "/account")



@account_router.post("/login", status_code = status.HTTP_200_OK)
async def login(username: str, password: str, db_conn: psycopg.Connection = Depends(get_db_session)) -> LoginResponse:
    db_curr = db_conn.cursor()
    public_schema = os.environ.get("POSTGRES_PUBLIC_SCHEMA")
    account_table = os.environ.get("POSTGRES_ACCOUNT_TABLE")

    #db_curr.execute(f"select * from {public_schema}.{account_table} where ")

    return LoginResponse(
        access_token = "ABC",
        token_type = "Bearer"
    )

@account_router.post("/create", status_code = status.HTTP_201_CREATED)
async def create(username: str, password: str, db_conn: psycopg.Connection = Depends(get_db_session)) -> CreateResponse:
    db_curr = db_conn.cursor()
    public_schema = os.environ.get("POSTGRES_PUBLIC_SCHEMA")
    account_table = os.environ.get("POSTGRES_ACCOUNT_TABLE")

    password_hash = hash_string(password)
    #db_curr.execute(f"")