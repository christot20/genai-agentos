import psycopg
from fastapi import APIRouter, status, Depends
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials

from src.routes.health.schema.health_schema import HealthResponse
from src.routes.account.util.token import validate_jwt
from src.db.session import get_db_session
from src.logging.log import dbg_log


health_router = APIRouter()
security = HTTPBearer()



@health_router.get("/health")
async def health():
    try:
        dbg_log("health() begin")
        return JSONResponse(status_code = status.HTTP_200_OK,
                            content = jsonable_encoder(HealthResponse(status = "Up")))
    finally:
        dbg_log("health() end")

@health_router.get("/healthSecure")
async def health_secure(token: HTTPAuthorizationCredentials = Depends(security), db_conn: psycopg.Connection = Depends(get_db_session)):
    try:
        dbg_log(f"health_secure() begin")
        dbg_log(f"scheme = {token.scheme} | credentials = {token.credentials}")

        if not validate_jwt(token, db_conn.cursor()):
            return JSONResponse(status_code = status.HTTP_401_UNAUTHORIZED,
                                content = jsonable_encoder(HealthResponse(status = "Unauthorized")))

        return JSONResponse(status_code = status.HTTP_200_OK,
                            content = jsonable_encoder(HealthResponse(status = "Up")))
    finally:
        dbg_log(f"health_secure() end")