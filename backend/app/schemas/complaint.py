from pydantic import BaseModel, Field, ConfigDict
from typing import Optional, List
from datetime import datetime

class ComplaintCreate(BaseModel):
    title: str = Field(min_length=3, max_length=255)
    description: str = Field(min_length=5)
    description_ta: Optional[str] = None
    category: Optional[str] = None
    priority: Optional[str] = None
    latitude: float
    longitude: float
    gps_accuracy: Optional[float] = None
    address: str
    ward_number: Optional[str] = None
    zone: Optional[str] = None
    is_anonymous: bool = False
    photo_base64: Optional[str] = None
    photo_filename: Optional[str] = None

class ComplaintUpdate(BaseModel):
    status: Optional[str] = None
    priority: Optional[str] = None
    category: Optional[str] = None
    department_id: Optional[str] = None
    assigned_officer_id: Optional[str] = None
    resolution_notes: Optional[str] = None

class ComplaintAttachmentResponse(BaseModel):
    id: str
    file_url: str
    file_type: str
    original_filename: str
    upload_phase: str
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    gps_accuracy: Optional[float] = None
    captured_at: Optional[datetime] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class ComplaintStatusHistoryResponse(BaseModel):
    id: str
    previous_status: Optional[str] = None
    new_status: str
    notes: Optional[str] = None
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)

class AIClassificationResponse(BaseModel):
    detected_language: str
    predicted_category: str
    category_confidence: float
    predicted_priority: str
    priority_confidence: float
    summary: str
    summary_ta: Optional[str] = None
    model_version: str

    model_config = ConfigDict(from_attributes=True)

class ComplaintResponse(BaseModel):
    id: str
    complaint_number: str
    citizen_id: str
    title: str
    description: str
    description_ta: Optional[str] = None
    category: str
    priority: str
    status: str
    latitude: float
    longitude: float
    gps_accuracy: Optional[float] = None
    address: str
    ward_number: Optional[str] = None
    zone: Optional[str] = None
    resolved_ward: Optional[str] = None
    ward_discrepancy: bool = False
    department_id: Optional[str] = None
    assigned_officer_id: Optional[str] = None
    language_detected: str
    is_anonymous: bool
    attachments: List[ComplaintAttachmentResponse] = []
    created_at: datetime
    updated_at: datetime

    model_config = ConfigDict(from_attributes=True)
