from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse
from fastapi import Request

from src.routes.api import api_router
from src.services.ai_service import ai_service

app = FastAPI(title="Project Backend")
app.include_router(api_router)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.on_event("startup")
async def startup_event():
    """Initialize services on startup."""
    await ai_service.initialize()


@app.route("/")
async def redirect_to_docs(request: Request):
    """Redirect to docs on the root url of the app"""
    return RedirectResponse("/docs")