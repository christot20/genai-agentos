from src.routes.health.schema.health_schema import HealthResponse

from fastapi import APIRouter, status
from fastapi.responses import JSONResponse
from fastapi.encoders import jsonable_encoder



health_router = APIRouter()



@health_router.get("/health")
async def health():
    return JSONResponse(status_code = status.HTTP_200_OK,
                        content = jsonable_encoder(HealthResponse(status = "Up")))