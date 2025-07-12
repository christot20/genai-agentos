from multiprocessing.managers import public_methods

import psycopg
import os
import uuid

from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder

from src.routes.account.schema.login_schema import LoginRequest, LoginResponse
from src.routes.account.schema.create_schema import CreateRequest, CreateResponse
from src.routes.account.util.hash import hash_string
from src.routes.account.util.token import create_jwt
from src.db.session import get_db_session
from src.logging.log import dbg_log



account_router = APIRouter(prefix = "/account")



@account_router.post("/create")
async def create(account_info: CreateRequest, db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"create() begin")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_ACCOUNT_TABLE")

        uid = str(uuid.uuid4())
        username = account_info.username
        salt, password_hash = hash_string(m = account_info.password)

        try:
            db_curr.execute(query =  f"insert into {schema}.{table} (uuid, username, salt, password) values (%s, %s, %s, %s)",
                            params = (uid, username, salt, password_hash))
            db_conn.commit()
        except psycopg.errors.UniqueViolation:
            return JSONResponse(status_code = status.HTTP_409_CONFLICT,
                               content = jsonable_encoder(CreateResponse(message = "Username already exists.")))
        except Exception:
            return JSONResponse(status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
                                content = jsonable_encoder(CreateResponse(message="Unknown error occurred when creating an account.")))

        return JSONResponse(status_code = status.HTTP_200_OK,
                            content = jsonable_encoder(CreateResponse(message = "Account created successfully.")))
    finally:
        dbg_log(f"create() end")


@account_router.post("/login")
async def login(account_info: LoginRequest, db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"login() begin")

        db_curr = db_conn.cursor()
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_ACCOUNT_TABLE")

        try:
            username = account_info.username
            db_curr.execute(query = f"select * from {schema}.{table} where username = %s",
                             params = (username,))
            query_response = db_curr.fetchone()
            if query_response is None:
                return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                    content = jsonable_encoder(CreateResponse(message = "Username or password is incorrect..")))

            salt = query_response[2]
            password_hash = query_response[3]
            _, request_hash = hash_string(m = account_info.password, salt = salt)
            if request_hash != password_hash:
                return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                    content = jsonable_encoder(CreateResponse(message = "Username or password is incorrect..")))

            uuid = query_response[0]
            username = query_response[1]
            creation_date = query_response[4]
            jwt = create_jwt(uuid = uuid,
                             username = username,
                             creation_date = creation_date)
        except Exception as e:
            print(e)
            return JSONResponse(status_code = status.HTTP_500_INTERNAL_SERVER_ERROR,
                                content = jsonable_encoder(LoginResponse(message = "Unknown error occurred when logging in.")))

        return JSONResponse(status_code = status.HTTP_202_ACCEPTED,
                            content = jsonable_encoder(LoginResponse(message = "Logged in successfully.",
                                                                     token_type = "Bearer",
                                                                     access_token = jwt)))
    finally:
        dbg_log(f"login() end")