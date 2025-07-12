import jwt
import uuid
import os
import psycopg
from datetime import datetime
from fastapi.security import HTTPAuthorizationCredentials

from src.logging.log import dbg_log



def create_jwt(uuid: uuid, username: str, creation_date: datetime):
    try:
        dbg_log(f"create_jwt() begin")

        payload = {
            "uuid": str(uuid),
            "username": username,
            "creation_date": str(creation_date)
        }
        key = os.environ.get("JWT_SECRET_KEY")
        algorithm = os.environ.get("JWT_ALGORITHM")

        token = jwt.encode(payload = payload,
                           key = key,
                           algorithm = algorithm)
        return token
    finally:
        dbg_log(f"create_jwt() end")

def validate_jwt(jwt_credentials: HTTPAuthorizationCredentials, db_curr: psycopg.Cursor):
    try:
        dbg_log(f"validate_jwt() begin")

        key = os.environ.get("JWT_SECRET_KEY")
        algorithm = os.environ.get("JWT_ALGORITHM")
        schema = os.environ.get("POSTGRES_NAVICARE_SCHEMA")
        table = os.environ.get("POSTGRES_ACCOUNT_TABLE")


        try:
            if jwt_credentials.scheme != "Bearer":
                return False

            decoded_jwt = jwt.decode(jwt=jwt_credentials.credentials,
                                     key=key,
                                     algorithms=[algorithm])

            uuid = decoded_jwt["uuid"]
            username = decoded_jwt["username"]
            creation_date = decoded_jwt["creation_date"]

            db_curr.execute(query = f"select * from {schema}.{table} where uuid = %s and username = %s and creation_date = %s",
                            params = (uuid, username, creation_date))
            if db_curr.fetchone() is None:
                return False
        except KeyError:
            return False
        except jwt.exceptions.InvalidSignatureError:
            return False

        return True
    finally:
        dbg_log(f"validate_jwt() end")