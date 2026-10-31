from sqlalchemy.orm import Mapped, mapped_column, relationship
from sqlalchemy import String, Boolean, ForeignKey, Integer
from app.models.base import BaseModel
from typing import Optional, List, TYPE_CHECKING

if TYPE_CHECKING:
    from app.models.user import CitizenProfile

class Municipality(BaseModel):
    __tablename__ = "municipalities"

    name: Mapped[str] = mapped_column(String(100), unique=True, index=True, nullable=False)
    name_ta: Mapped[str] = mapped_column(String(200), nullable=False)
    code: Mapped[str] = mapped_column(String(20), unique=True, index=True, nullable=False)
    district: Mapped[str] = mapped_column(String(100), default="Chennai")
    state: Mapped[str] = mapped_column(String(50), default="Tamil Nadu")
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationships
    zones: Mapped[List["Zone"]] = relationship(back_populates="municipality", cascade="all, delete-orphan")

class Zone(BaseModel):
    __tablename__ = "zones"

    municipality_id: Mapped[str] = mapped_column(String(36), ForeignKey("municipalities.id"), index=True, nullable=False)
    name: Mapped[str] = mapped_column(String(100), nullable=False)
    name_ta: Mapped[str] = mapped_column(String(200), nullable=False)
    zone_number: Mapped[int] = mapped_column(Integer, nullable=False)
    code: Mapped[str] = mapped_column(String(20), nullable=False)
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Relationships
    municipality: Mapped["Municipality"] = relationship(back_populates="zones")
    wards: Mapped[List["Ward"]] = relationship(back_populates="zone", cascade="all, delete-orphan")

class Ward(BaseModel):
    __tablename__ = "wards"

    zone_id: Mapped[str] = mapped_column(String(36), ForeignKey("zones.id"), index=True, nullable=False)
    ward_number: Mapped[str] = mapped_column(String(20), index=True, nullable=False) # e.g. "Ward 102"
    ward_name: Mapped[str] = mapped_column(String(100), nullable=False) # e.g. "Anna Nagar West"
    ward_name_ta: Mapped[str] = mapped_column(String(200), nullable=False) # e.g. "அண்ணா நகர் மேற்கு"
    is_active: Mapped[bool] = mapped_column(Boolean, default=True)

    # Geographic boundary center point
    center_latitude: Mapped[Optional[float]] = mapped_column(nullable=True)
    center_longitude: Mapped[Optional[float]] = mapped_column(nullable=True)

    # Relationships
    zone: Mapped["Zone"] = relationship(back_populates="wards")
    citizen_profiles: Mapped[List["CitizenProfile"]] = relationship(back_populates="ward")
