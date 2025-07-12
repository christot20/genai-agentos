from src.routes.health.schema.health_schema import health_response

from fastapi import APIRouter, status



health_router = APIRouter()



@health_router.get("/health", status_code = status.HTTP_200_OK)
async def health() -> health_response:
    return health_response(
        status = "Up"
    )