from fastapi import FastAPI

from src.routes.api import api_router



app = FastAPI(title="Project Backend")
app.include_router(api_router)