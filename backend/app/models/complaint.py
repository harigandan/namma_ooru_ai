from datetime import datetime, timezone
from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, Text, ForeignKey, Float, Integer, DateTime
from app.models.base import BaseModel
from typing import Optional, List

class Complaint(BaseModel):
    __tablename__ = "complaints"

    complaint_number: Mapped[str] = mapped_column(String(50), unique=True, index=True, nullable=False)
    citizen_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), index=True)
    title: Mapped[str] = mapped_column(String(255), nullable=False)
    description: Mapped[str] = mapped_column(Text, nullable=False)
    description_ta: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    
    category: Mapped[str] = mapped_column(String(50), index=True, default="other")
    priority: Mapped[str] = mapped_column(String(20), index=True, default="medium") # low, medium, high, critical
    status: Mapped[str] = mapped_column(String(30), index=True, default="submitted") # submitted, under_review, assigned, in_progress, resolved, closed, reopened
    
    latitude: Mapped[float] = mapped_column(Float, nullable=False)
    longitude: Mapped[float] = mapped_column(Float, nullable=False)
    gps_accuracy: Mapped[Optional[float]] = mapped_column(Float, nullable=True) # in meters
    address: Mapped[str] = mapped_column(Text, nullable=False)
    ward_number: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    zone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    resolved_ward: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    ward_discrepancy: Mapped[bool] = mapped_column(Boolean, default=False)
    
    department_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("departments.id"), nullable=True)
    assigned_officer_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("field_officers.id"), nullable=True)
    
    language_detected: Mapped[str] = mapped_column(String(10), default="en")
    is_anonymous: Mapped[bool] = mapped_column(Boolean, default=False)
    sla_deadline: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    resolved_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)
    resolution_notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    # Relationships
    citizen: Mapped["User"] = relationship(back_populates="complaints")
    department: Mapped[Optional["Department"]] = relationship(back_populates="complaints")
    assigned_officer: Mapped[Optional["FieldOfficer"]] = relationship()
    attachments: Mapped[List["ComplaintAttachment"]] = relationship(back_populates="complaint", cascade="all, delete-orphan")
    status_history: Mapped[List["ComplaintStatusHistory"]] = relationship(back_populates="complaint", cascade="all, delete-orphan")
    ai_classification: Mapped[Optional["AIClassification"]] = relationship(back_populates="complaint", uselist=False, cascade="all, delete-orphan")

class ComplaintAttachment(BaseModel):
    __tablename__ = "complaint_attachments"

    complaint_id: Mapped[str] = mapped_column(String(36), ForeignKey("complaints.id"), index=True)
    file_url: Mapped[str] = mapped_column(String(500), nullable=False)
    file_type: Mapped[str] = mapped_column(String(20), default="image") # image, audio, document
    file_size: Mapped[int] = mapped_column(Integer, default=0)
    original_filename: Mapped[str] = mapped_column(String(255))
    upload_phase: Mapped[str] = mapped_column(String(20), default="initial") # initial, progress, resolution
    uploaded_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    gps_accuracy: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    captured_at: Mapped[Optional[datetime]] = mapped_column(DateTime(timezone=True), nullable=True)

    complaint: Mapped["Complaint"] = relationship(back_populates="attachments")

class ComplaintStatusHistory(BaseModel):
    __tablename__ = "complaint_status_history"

    complaint_id: Mapped[str] = mapped_column(String(36), ForeignKey("complaints.id"), index=True)
    previous_status: Mapped[Optional[str]] = mapped_column(String(30), nullable=True)
    new_status: Mapped[str] = mapped_column(String(30), nullable=False)
    changed_by: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"))
    notes: Mapped[Optional[str]] = mapped_column(Text, nullable=True)

    complaint: Mapped["Complaint"] = relationship(back_populates="status_history")
