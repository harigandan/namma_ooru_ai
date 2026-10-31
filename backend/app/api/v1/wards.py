from fastapi import APIRouter, Depends, HTTPException, Query, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.database.session import get_db
from app.models.ward import Municipality, Zone, Ward
from pydantic import BaseModel, ConfigDict
from typing import List, Optional
import math

router = APIRouter(prefix="/wards", tags=["Wards & Geography"])

class MunicipalityResponse(BaseModel):
    id: str
    name: str
    name_ta: str
    code: str
    district: str
    model_config = ConfigDict(from_attributes=True)

class ZoneResponse(BaseModel):
    id: str
    municipality_id: str
    name: str
    name_ta: str
    zone_number: int
    code: str
    model_config = ConfigDict(from_attributes=True)

class WardResponse(BaseModel):
    id: str
    zone_id: str
    ward_number: str
    ward_name: str
    ward_name_ta: str
    center_latitude: Optional[float] = None
    center_longitude: Optional[float] = None
    model_config = ConfigDict(from_attributes=True)

class WardResolveResponse(BaseModel):
    ward_id: str
    ward_number: str
    ward_name: str
    ward_name_ta: str
    zone_name: str
    distance_km: float

@router.get("/municipalities", response_model=List[MunicipalityResponse])
async def list_municipalities(db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Municipality).where(Municipality.is_active == True).order_by(Municipality.name))
    return result.scalars().all()

@router.get("/zones", response_model=List[ZoneResponse])
async def list_zones(
    municipality_id: Optional[str] = Query(None),
    db: AsyncSession = Depends(get_db)
):
    query = select(Zone).where(Zone.is_active == True)
    if municipality_id:
        query = query.where(Zone.municipality_id == municipality_id)
    result = await db.execute(query.order_by(Zone.zone_number))
    return result.scalars().all()

@router.get("", response_model=List[WardResponse])
async def list_wards(
    zone_id: Optional[str] = Query(None),
    query_str: Optional[str] = Query(None, alias="q"),
    db: AsyncSession = Depends(get_db)
):
    query = select(Ward).where(Ward.is_active == True)
    if zone_id:
        query = query.where(Ward.zone_id == zone_id)
    if query_str:
        pattern = f"%{query_str}%"
        query = query.where(Ward.ward_number.ilike(pattern) | Ward.ward_name.ilike(pattern) | Ward.ward_name_ta.ilike(pattern))
    result = await db.execute(query.order_by(Ward.ward_number))
    return result.scalars().all()

@router.get("/resolve", response_model=WardResolveResponse)
async def resolve_ward_by_coordinates(
    latitude: float = Query(...),
    longitude: float = Query(...),
    db: AsyncSession = Depends(get_db)
):
    """Finds the nearest ward based on haversine distance to ward center point."""
    result = await db.execute(
        select(Ward).options(selectinload(Ward.zone)).where(Ward.is_active == True)
    )
    wards = result.scalars().all()
    if not wards:
        raise HTTPException(status_code=404, detail="No wards configured in database")

    def haversine(lat1, lon1, lat2, lon2):
        if lat2 is None or lon2 is None:
            return 999999.0
        r = 6371.0 # Earth radius in km
        dlat = math.radians(lat2 - lat1)
        dlon = math.radians(lon2 - lon1)
        a = (math.sin(dlat / 2) ** 2 +
             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
             math.sin(dlon / 2) ** 2)
        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
        return r * c

    best_ward = None
    min_dist = float("inf")
    for w in wards:
        d = haversine(latitude, longitude, w.center_latitude, w.center_longitude)
        if d < min_dist:
            min_dist = d
            best_ward = w

    if not best_ward:
        raise HTTPException(status_code=404, detail="Could not resolve ward")

    return WardResolveResponse(
        ward_id=best_ward.id,
        ward_number=best_ward.ward_number,
        ward_name=best_ward.ward_name,
        ward_name_ta=best_ward.ward_name_ta,
        zone_name=best_ward.zone.name if best_ward.zone else "Chennai Zone",
        distance_km=round(min_dist, 2),
    )

@router.get("/{ward_id}", response_model=WardResponse)
async def get_ward(ward_id: str, db: AsyncSession = Depends(get_db)):
    result = await db.execute(select(Ward).where(Ward.id == ward_id))
    ward = result.scalar_one_or_none()
    if not ward:
        raise HTTPException(status_code=404, detail="Ward not found")
    return ward
