from pydantic import BaseModel, ConfigDict
from typing import Optional
from datetime import datetime

class NotificationResponse(BaseModel):
    id: str
    user_id: str
    title: str
    body: str
    notification_type: str
    reference_id: Optional[str] = None
    is_read: bool
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class NotificationCreate(BaseModel):
    user_id: str
    title: str
    body: str
    notification_type: str = "complaint_update"
    reference_id: Optional[str] = None
