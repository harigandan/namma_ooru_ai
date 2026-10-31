from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from sqlalchemy.orm import selectinload
from app.database.session import get_db
from app.models.user import User, CitizenProfile
from app.models.ward import Ward
from app.schemas.auth import (
    UserRegister,
    UserLogin,
    TokenResponse,
    RefreshTokenRequest,
    UserProfileResponse,
    CitizenWardUpdateRequest,
)
from app.core.security import (
    get_password_hash,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
)
from app.core.dependencies import get_current_user

router = APIRouter(prefix="/auth", tags=["Authentication"])

@router.post("/register", response_model=TokenResponse)
async def register_user(payload: UserRegister, db: AsyncSession = Depends(get_db)):
    # Check if user already exists
    result = await db.execute(
        select(User).where(or_(User.email == payload.email, User.phone == payload.phone))
    )
    existing_user = result.scalar_one_or_none()
    if existing_user:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="A user with this email or phone number already exists",
        )

    # Enforce Role Authorization
    target_role = "citizen"
    if payload.role in ["admin", "field_officer"]:
        expected_code = "TN-ADMIN-2026" if payload.role == "admin" else "TN-OFFICER-2026"
        if not payload.authorization_code or payload.authorization_code.strip() != expected_code:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail=f"Registration for privileged role '{payload.role}' requires an authorized government invitation code.",
            )
        target_role = payload.role

    # Validate ward if provided
    selected_ward = None
    if payload.ward_id:
        ward_res = await db.execute(
            select(Ward).options(selectinload(Ward.zone)).where(Ward.id == payload.ward_id, Ward.is_active == True)
        )
        selected_ward = ward_res.scalar_one_or_none()
        if not selected_ward:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="Invalid Ward selection: The chosen ward is invalid or inactive in the municipal database.",
            )

    # Create new User
    user = User(
        email=payload.email,
        phone=payload.phone,
        password_hash=get_password_hash(payload.password),
        full_name=payload.full_name,
        preferred_language=payload.preferred_language,
        role=target_role,
        is_active=True,
        is_verified=True,
    )
    db.add(user)
    await db.flush()

    ward_num = payload.ward_number
    zone_str = payload.zone
    ward_name_str = None
    if selected_ward:
        ward_num = selected_ward.ward_number
        ward_name_str = selected_ward.ward_name
        if selected_ward.zone:
            zone_str = selected_ward.zone.name

    if target_role == "citizen":
        # Create Citizen Profile with validated ward
        profile = CitizenProfile(
            user_id=user.id,
            city=payload.city or "Chennai",
            municipality_name=payload.municipality or "Greater Chennai Corporation",
            zone=zone_str,
            ward_id=selected_ward.id if selected_ward else None,
            ward_number=ward_num,
        )
        db.add(profile)

    await db.commit()
    await db.refresh(user)

    access_token = create_access_token(subject=user.id, role=user.role)
    refresh_token = create_refresh_token(subject=user.id)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        role=user.role,
        user_id=user.id,
        full_name=user.full_name,
        preferred_language=user.preferred_language,
        city=payload.city or "Chennai",
        municipality=payload.municipality or "Greater Chennai Corporation",
        zone=zone_str,
        ward_id=selected_ward.id if selected_ward else None,
        ward_number=ward_num,
        ward_name=ward_name_str,
    )

@router.post("/login", response_model=TokenResponse)
async def login_user(payload: UserLogin, db: AsyncSession = Depends(get_db)):
    result = await db.execute(
        select(User).options(
            selectinload(User.citizen_profile).selectinload(CitizenProfile.ward)
        ).where(
            or_(User.email == payload.email_or_phone, User.phone == payload.email_or_phone)
        )
    )
    user = result.scalar_one_or_none()
    if not user or not verify_password(payload.password, user.password_hash):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Incorrect email/phone or password",
        )

    if not user.is_active:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Inactive user account")

    access_token = create_access_token(subject=user.id, role=user.role)
    refresh_token = create_refresh_token(subject=user.id)

    city_val = "Chennai"
    municipality_val = "Greater Chennai Corporation"
    zone_val = None
    ward_id_val = None
    ward_num_val = None
    ward_name_val = None

    if user.citizen_profile:
        city_val = user.citizen_profile.city or city_val
        municipality_val = user.citizen_profile.municipality_name or municipality_val
        zone_val = user.citizen_profile.zone
        ward_id_val = user.citizen_profile.ward_id
        ward_num_val = user.citizen_profile.ward_number
        if user.citizen_profile.ward:
            ward_name_val = user.citizen_profile.ward.ward_name
            ward_num_val = user.citizen_profile.ward.ward_number

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        role=user.role,
        user_id=user.id,
        full_name=user.full_name,
        preferred_language=user.preferred_language,
        city=city_val,
        municipality=municipality_val,
        zone=zone_val,
        ward_id=ward_id_val,
        ward_number=ward_num_val,
        ward_name=ward_name_val,
    )

@router.post("/refresh")
async def refresh_token(payload: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    decoded = decode_token(payload.refresh_token)
    if not decoded or decoded.get("type") != "refresh":
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid refresh token")
    
    user_id = decoded.get("sub")
    result = await db.execute(select(User).where(User.id == user_id))
    user = result.scalar_one_or_none()
    if not user or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="User not found or inactive")

    new_access_token = create_access_token(subject=user.id, role=user.role)
    new_refresh_token = create_refresh_token(subject=user.id)

    return {
        "access_token": new_access_token,
        "refresh_token": new_refresh_token,
        "token_type": "bearer",
    }

@router.get("/me", response_model=UserProfileResponse)
async def get_my_profile(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(User).options(
            selectinload(User.citizen_profile).selectinload(CitizenProfile.ward)
        ).where(User.id == current_user.id)
    )
    user = result.scalar_one()

    city_val = "Chennai"
    municipality_val = "Greater Chennai Corporation"
    zone_val = None
    ward_id_val = None
    ward_num_val = None
    ward_name_val = None

    if user.citizen_profile:
        city_val = user.citizen_profile.city or city_val
        municipality_val = user.citizen_profile.municipality_name or municipality_val
        zone_val = user.citizen_profile.zone
        ward_id_val = user.citizen_profile.ward_id
        ward_num_val = user.citizen_profile.ward_number
        if user.citizen_profile.ward:
            ward_name_val = user.citizen_profile.ward.ward_name
            ward_num_val = user.citizen_profile.ward.ward_number

    return UserProfileResponse(
        id=user.id,
        email=user.email,
        phone=user.phone,
        full_name=user.full_name,
        preferred_language=user.preferred_language,
        role=user.role,
        is_active=user.is_active,
        is_verified=user.is_verified,
        created_at=user.created_at,
        city=city_val,
        municipality=municipality_val,
        zone=zone_val,
        ward_id=ward_id_val,
        ward_number=ward_num_val,
        ward_name=ward_name_val,
    )

@router.patch("/ward", response_model=UserProfileResponse)
async def update_citizen_ward(
    payload: CitizenWardUpdateRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Allows a citizen to request an official ward correction, validated against the database."""
    ward_res = await db.execute(
        select(Ward).options(selectinload(Ward.zone)).where(Ward.id == payload.ward_id, Ward.is_active == True)
    )
    ward = ward_res.scalar_one_or_none()
    if not ward:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Invalid ward_id: Selected ward is not found or is currently inactive.",
        )

    # Fetch citizen profile
    prof_res = await db.execute(
        select(CitizenProfile).where(CitizenProfile.user_id == current_user.id)
    )
    profile = prof_res.scalar_one_or_none()
    if not profile:
        profile = CitizenProfile(user_id=current_user.id)
        db.add(profile)

    profile.ward_id = ward.id
    profile.ward_number = ward.ward_number
    if ward.zone:
        profile.zone = ward.zone.name

    await db.commit()

    return await get_my_profile(current_user=current_user, db=db)
