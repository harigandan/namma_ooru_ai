from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, Text, ForeignKey, Float
from app.models.base import BaseModel
from typing import Optional, List

class Department(BaseModel):
    __tablename__ = "departments"

    name: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    name_ta: Mapped[str] = mapped_column(String(100), nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    description: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    head_name: Mapped[Optional[str]] = mapped_column(String(100), nullable=True)
    contact_email: Mapped[Optional[str]] = mapped_column(String(255), nullable=True)
    contact_phone: Mapped[Optional[str]] = mapped_column(String(20), nullable=True)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationships
    field_officers: Mapped[List["FieldOfficer"]] = relationship(back_populates="department")
    complaints: Mapped[List["Complaint"]] = relationship(back_populates="department")

class FieldOfficer(BaseModel):
    __tablename__ = "field_officers"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), unique=True)
    department_id: Mapped[str] = mapped_column(String(36), ForeignKey("departments.id"))
    employee_id: Mapped[str] = mapped_column(String(50), unique=True, index=True)
    designation: Mapped[str] = mapped_column(String(100))
    assigned_zone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    is_available: Mapped[bool] = mapped_column(Boolean, default=True)
    current_latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    current_longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    # Relationships
    department: Mapped["Department"] = relationship(back_populates="field_officers")
    user: Mapped["User"] = relationship()
