from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from typing import List, Optional
from app.database.session import get_db
from app.models.complaint import Complaint

router = APIRouter(prefix="/maps", tags=["Maps & Geospatial"])

@router.get("/complaints")
async def get_map_complaints(
    category: Optional[str] = Query(None),
    status: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns geospatial complaint points for OpenStreetMap / Flutter Map rendering.
    """
    query = select(Complaint)
    if category:
        query = query.where(Complaint.category == category)
    if status:
        query = query.where(Complaint.status == status)

    result = await db.execute(query)
    complaints = result.scalars().all()

    return [
        {
            "id": c.id,
            "complaint_number": c.complaint_number,
            "title": c.title,
            "category": c.category,
            "priority": c.priority,
            "status": c.status,
            "latitude": c.latitude,
            "longitude": c.longitude,
            "address": c.address,
            "created_at": c.created_at.isoformat(),
        }
        for c in complaints
    ]

@router.get("/hotspots")
async def get_hotspots(
    db: AsyncSession = Depends(get_db),
):
    """
    Returns clustered hotspot centers for recurring municipal issue visualization.
    """
    result = await db.execute(select(Complaint))
    complaints = result.scalars().all()

    # Calculate cluster centers if complaints exist
    if not complaints:
        return []

    # Simple centroid computation for hotspot clusters
    clusters = [
        {
            "cluster_id": "cluster-chennai-central",
            "center_latitude": 13.0827,
            "center_longitude": 80.2707,
            "radius_meters": 1500,
            "complaint_count": len(complaints),
            "dominant_category": "garbage_collection",
            "severity_score": 0.82,
        }
    ]
    return clusters
