import uuid
from pydantic import BaseModel
from datetime import datetime



class CreateResponse(BaseModel):
    message: str
    conversation_id: uuid.UUID | None = None

class Conversation(BaseModel):
    conversation_id: uuid.UUID
    creator_id: uuid.UUID
    title: str | None
    creation_date: datetime
    updated_date: datetime

class ListResponse(BaseModel):
    message: str
    conversations: list[Conversation]