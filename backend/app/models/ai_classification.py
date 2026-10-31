from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, Text, ForeignKey, Float, Integer
from app.models.base import BaseModel
from typing import Optional

class AIClassification(BaseModel):
    __tablename__ = "ai_classifications"

    complaint_id: Mapped[str] = mapped_column(String(36), ForeignKey("complaints.id"), unique=True)
    detected_language: Mapped[str] = mapped_column(String(10), default="en")
    
    predicted_category: Mapped[str] = mapped_column(String(50))
    category_confidence: Mapped[float] = mapped_column(Float, default=0.0)
    
    predicted_priority: Mapped[str] = mapped_column(String(20))
    priority_confidence: Mapped[float] = mapped_column(Float, default=0.0)
    
    predicted_department_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("departments.id"), nullable=True)
    department_confidence: Mapped[float] = mapped_column(Float, default=0.0)
    
    summary: Mapped[str] = mapped_column(Text)
    summary_ta: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    model_version: Mapped[str] = mapped_column(String(50), default="v1.0.0-rules-nlp")
    processing_time_ms: Mapped[int] = mapped_column(Integer, default=0)
    
    is_override: Mapped[bool] = mapped_column(Boolean, default=False)
    overridden_by: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("users.id"), nullable=True)

    complaint: Mapped["Complaint"] = relationship(back_populates="ai_classification")
