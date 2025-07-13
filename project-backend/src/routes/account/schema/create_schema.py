from pydantic import BaseModel



class CreateRequest(BaseModel):
    email: str
    password: str
    firstName: str

class CreateResponse(BaseModel):
    message: str