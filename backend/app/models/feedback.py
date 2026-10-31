from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, ForeignKey, Integer, Text
from app.models.base import BaseModel
from typing import Optional

class ResolutionFeedback(BaseModel):
    __tablename__ = "resolution_feedback"

    complaint_id: Mapped[str] = mapped_column(String(36), ForeignKey("complaints.id"), unique=True, index=True)
    citizen_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True)
    rating: Mapped[int] = mapped_column(Integer, nullable=False) # 1 to 5
    feedback_text: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    is_satisfied: Mapped[bool] = mapped_column(Boolean, default=True)

    complaint: Mapped["Complaint"] = relationship()
    citizen: Mapped["User"] = relationship()
