from fastapi import APIRouter, Depends
from pydantic import BaseModel
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from app.database.session import get_db
from app.models.user import User, CitizenProfile
from app.models.ward import Ward
from app.schemas.auth import UserProfileResponse
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])

class UserUpdate(BaseModel):
    full_name: Optional[str] = None
    preferred_language: Optional[str] = None

@router.get("/me", response_model=UserProfileResponse)
async def get_current_user_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User)
        .options(
            selectinload(User.citizen_profile).selectinload(CitizenProfile.ward)
        )
        .where(User.id == current_user.id)
    )
    user = result.scalar_one_or_none() or current_user
    profile = user.citizen_profile

    ward_num = None
    ward_nm = None
    if profile:
        if profile.ward:
            ward_num = profile.ward.ward_number
            ward_nm = profile.ward.ward_name
        elif profile.ward_number:
            ward_num = profile.ward_number

    return UserProfileResponse(
        id=user.id,
        email=user.email,
        phone=user.phone,
        full_name=user.full_name,
        role=user.role,
        preferred_language=user.preferred_language,
        is_active=user.is_active,
        is_verified=user.is_verified,
        created_at=user.created_at,
        city=profile.city if profile else "Chennai",
        municipality=profile.municipality_name if profile else "Greater Chennai Corporation",
        zone=profile.zone if profile else None,
        ward_id=profile.ward_id if profile else None,
        ward_number=ward_num,
        ward_name=ward_nm,
    )

@router.patch("/me", response_model=UserProfileResponse)
async def update_current_user_profile(
    payload: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if payload.full_name is not None:
        current_user.full_name = payload.full_name
    if payload.preferred_language is not None:
        current_user.preferred_language = payload.preferred_language

    await db.commit()
    await db.refresh(current_user)
    return current_user
