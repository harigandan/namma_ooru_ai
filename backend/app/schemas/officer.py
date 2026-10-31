from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class FieldOfficerResponse(BaseModel):
    id: str
    user_id: str
    department_id: str
    employee_id: str
    designation: str
    assigned_zone: Optional[str] = None
    is_available: bool

    model_config = ConfigDict(from_attributes=True)

class OfficerWorkUpdate(BaseModel):
    status: str # in_progress, resolved
    resolution_notes: Optional[str] = None
    photo_urls: Optional[list[str]] = None
