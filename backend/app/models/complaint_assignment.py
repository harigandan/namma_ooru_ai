from datetime import datetime, timezone
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, ForeignKey, DateTime
from app.models.base import BaseModel
from typing import Optional

class ComplaintAssignment(BaseModel):
    __tablename__ = "complaint_assignments"

    complaint_id: Mapped[str] = mapped_column(String(36), ForeignKey("complaints.id"), index=True)
    department_id: Mapped[str] = mapped_column(String(36), ForeignKey("departments.id"), index=True)
    officer_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("field_officers.id"), nullable=True)
    assigned_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    assigned_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc)
    )
    unassigned_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    complaint: Mapped["Complaint"] = relationship()
    department: Mapped["Department"] = relationship()
    officer: Mapped[Optional["FieldOfficer"]] = relationship()
