from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class AnnouncementResponse(BaseModel):
    id: str
    title: str
    title_ta: Optional[str] = None
    content: str
    content_ta: Optional[str] = None
    category: str
    priority: str
    target_zones: Optional[str] = None
    is_active: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class AnnouncementCreate(BaseModel):
    title: str
    title_ta: Optional[str] = None
    content: str
    content_ta: Optional[str] = None
    category: str = "general"
    priority: str = "normal"
    target_zones: Optional[str] = None
