from fastapi import APIRouter

from src.routes.health.routes import health_router
from src.routes.account.routes import account_router



api_router = APIRouter(prefix="/api")
api_router.include_router(health_router)
api_router.include_router(account_router)