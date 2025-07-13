import uuid
from pydantic import BaseModel
from datetime import datetime
from typing import Optional, Dict, Any



class CreateRequest(BaseModel):
    message: str
    conversation_id: uuid.UUID

class CreateResponse(BaseModel):
    message: str
    message_id: uuid.UUID | None = None
    ai_response: Optional[Dict[str, Any]] = None

class ListRequest(BaseModel):
    conversation_id: uuid.UUID

class Message(BaseModel):
    message_id: uuid.UUID
    sender_type: str
    creation_date: datetime
    message: str

class ListResponse(BaseModel):
    message: str
    messages: list[Message]