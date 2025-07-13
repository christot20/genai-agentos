from pydantic import BaseModel



class LoginRequest(BaseModel):
    email: str
    password: str

class LoginResponse(BaseModel):
    message: str
    token_type: str | None = None
    access_token: str | None = None