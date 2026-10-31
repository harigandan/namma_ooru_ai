from pydantic import BaseModel
from typing import Optional, List

class AIClassifyRequest(BaseModel):
    text: str
    language_hint: Optional[str] = None

class AIClassifyResponse(BaseModel):
    detected_language: str
    predicted_category: str
    category_confidence: float
    predicted_priority: str
    priority_confidence: float
    recommended_department_code: str
    recommended_department_name: str
    summary: str
    summary_ta: Optional[str] = None
    model_version: str

class AIDuplicateItem(BaseModel):
    complaint_id: str
    title: str
    similarity_score: float
    distance_meters: float

class AIDuplicateResponse(BaseModel):
    has_duplicates: bool
    duplicate_candidates: List[AIDuplicateItem] = []
