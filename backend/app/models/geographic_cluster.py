from datetime import datetime, timezone
from sqlalchemy.orm import Mapped, mapped_column
from sqlalchemy import String, Integer, Float, DateTime
from app.models.base import BaseModel
from typing import Optional

class GeographicIssueCluster(BaseModel):
    __tablename__ = "geographic_issue_clusters"

    center_latitude: Mapped[float] = mapped_column(Float, nullable=False)
    center_longitude: Mapped[float] = mapped_column(Float, nullable=False)
    radius_meters: Mapped[float] = mapped_column(Float, default=1000.0)
    complaint_count: Mapped[int] = mapped_column(Integer, default=1)
    dominant_category: Mapped[str] = mapped_column(String(50))
    severity_score: Mapped[float] = mapped_column(Float, default=0.5)
    active_complaints: Mapped[int] = mapped_column(Integer, default=1)
    zone: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    ward_number: Mapped[Optional[str]] = mapped_column(String(50), nullable=True)
    last_analyzed_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True), 
        default=lambda: datetime.now(timezone.utc)
    )
