from pydantic import BaseModel, EmailStr, Field, ConfigDict
from typing import Optional
from datetime import datetime

class UserBase(BaseModel):
    email: EmailStr
    phone: str
    full_name: str
    preferred_language: str = "en"

class UserRegister(UserBase):
    password: str = Field(min_length=6)
    city: Optional[str] = "Chennai"
    municipality: Optional[str] = "Greater Chennai Corporation"
    zone: Optional[str] = None
    ward_id: Optional[str] = None
    ward_number: Optional[str] = None
    role: Optional[str] = "citizen"
    authorization_code: Optional[str] = None

class UserLogin(BaseModel):
    email_or_phone: str
    password: str

class TokenResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    role: str
    user_id: str
    full_name: str
    preferred_language: str
    city: Optional[str] = "Chennai"
    municipality: Optional[str] = "Greater Chennai Corporation"
    zone: Optional[str] = None
    ward_id: Optional[str] = None
    ward_number: Optional[str] = None
    ward_name: Optional[str] = None

class RefreshTokenRequest(BaseModel):
    refresh_token: str

class CitizenWardUpdateRequest(BaseModel):
    ward_id: str
    reason: Optional[str] = None

class UserProfileResponse(UserBase):
    id: str
    role: str
    is_active: bool
    is_verified: bool
    created_at: datetime
    city: Optional[str] = "Chennai"
    municipality: Optional[str] = "Greater Chennai Corporation"
    zone: Optional[str] = None
    ward_id: Optional[str] = None
    ward_number: Optional[str] = None
    ward_name: Optional[str] = None

    model_config = ConfigDict(from_attributes=True)
