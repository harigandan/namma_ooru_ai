from typing import Optional, Dict, Any
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status
from app.models.user import User, CitizenProfile
from app.schemas.auth import UserRegister, UserLogin, TokenResponse
from app.repositories.user_repository import UserRepository
from app.core.security import get_password_hash, verify_password, create_access_token, create_refresh_token, decode_token

class AuthService:
    def __init__(self, db: AsyncSession):
        self.user_repo = UserRepository(db)

    async def register(self, payload: UserRegister) -> TokenResponse:
        existing = await self.user_repo.get_by_email_or_phone(payload.email)
        if existing:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this email already exists"
            )
        existing_phone = await self.user_repo.get_by_phone(payload.phone)
        if existing_phone:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="User with this phone number already exists"
            )

        user = User(
            email=payload.email,
            phone=payload.phone,
            password_hash=get_password_hash(payload.password),
            full_name=payload.full_name,
            preferred_language=payload.preferred_language,
            role="citizen",
            is_active=True,
            is_verified=True,
        )
        profile = CitizenProfile(
            city=payload.city or "Chennai",
        )
        created_user = await self.user_repo.create(user, profile)

        access_token = create_access_token(subject=created_user.id, role=created_user.role)
        refresh_token = create_refresh_token(subject=created_user.id)

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            role=created_user.role,
            user_id=created_user.id,
            full_name=created_user.full_name,
            preferred_language=created_user.preferred_language,
        )

    async def login(self, payload: UserLogin) -> TokenResponse:
        user = await self.user_repo.get_by_email_or_phone(payload.email_or_phone)
        if not user or not verify_password(payload.password, user.password_hash):
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Incorrect email/phone or password"
            )
        if not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Inactive account"
            )

        access_token = create_access_token(subject=user.id, role=user.role)
        refresh_token = create_refresh_token(subject=user.id)

        return TokenResponse(
            access_token=access_token,
            refresh_token=refresh_token,
            role=user.role,
            user_id=user.id,
            full_name=user.full_name,
            preferred_language=user.preferred_language,
        )

    async def refresh(self, refresh_token: str) -> Dict[str, str]:
        payload = decode_token(refresh_token)
        if not payload or payload.get("type") != "refresh":
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid or expired refresh token"
            )
        user_id = payload.get("sub")
        user = await self.user_repo.get_by_id(user_id)
        if not user or not user.is_active:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="User not found or inactive"
            )

        new_access = create_access_token(subject=user.id, role=user.role)
        new_refresh = create_refresh_token(subject=user.id)
        return {
            "access_token": new_access,
            "refresh_token": new_refresh,
            "token_type": "bearer",
        }
