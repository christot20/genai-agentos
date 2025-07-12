from src.routes.health.schema.health_schema import HealthResponse

from fastapi import APIRouter, status



health_router = APIRouter()



@health_router.get("/health", status_code = status.HTTP_200_OK)
async def health() -> HealthResponse:
    return HealthResponse(
        status = "Up"
    )