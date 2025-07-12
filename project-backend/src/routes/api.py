from fastapi import APIRouter

from src.routes.health.routes import health_router



api_router = APIRouter(prefix="/api")
api_router.include_router(health_router)