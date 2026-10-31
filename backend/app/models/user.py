from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, ForeignKey, Text, Float
from app.models.base import BaseModel
from typing import Optional, List, TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.complaint import Complaint
    from app.models.ward import Ward

class User(BaseModel):
    __tablename__ = "users"

    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    phone: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    password_hash: Mapped[str] = mapped_column(String(255), nullable=False)
    full_name: Mapped[str] = mapped_column(String(100), nullable=False)
    role: Mapped[str] = mapped_column(String(20), default="citizen", index=True) # citizen, admin, field_officer
    preferred_language: Mapped[str] = mapped_column(String(5), default="en") # en, ta
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)
    is_verified: Mapped[bool] = mapped_column(Boolean, default=False)
    avatar_url: Mapped[Optional[str]] = mapped_column(String(500), nullable=True)

    # Relationships
    citizen_profile: Mapped[Optional["CitizenProfile"]] = relationship(back_populates="user", uselist=False)
    complaints: Mapped[List["Complaint"]] = relationship(back_populates="citizen")

class CitizenProfile(BaseModel):
    __tablename__ = "citizen_profiles"

    user_id: Mapped[str] = mapped_column(String(36), ForeignKey("users.id"), unique=True)
    address: Mapped[Optional[str]] = mapped_column(Text, nullable=True)
    municipality_name: Mapped[Optional[str]] = mapped_column(String(100), default="Greater Chennai Corporation")
    zone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    ward_id: Mapped[Optional[str]] = mapped_column(String(36), ForeignKey("wards.id"), nullable=True)
    ward_number: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    city: Mapped[str] = mapped_column(String(100), default="Chennai")
    pincode: Mapped[Optional[str]] = mapped_column(String(10), nullable=True)
    latitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)
    longitude: Mapped[Optional[float]] = mapped_column(Float, nullable=True)

    user: Mapped["User"] = relationship(back_populates="citizen_profile")
    ward: Mapped[Optional["Ward"]] = relationship(back_populates="citizen_profiles")
