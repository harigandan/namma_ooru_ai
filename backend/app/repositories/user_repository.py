from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, or_
from app.models.user import User, CitizenProfile
from app.models.refresh_token import RefreshToken

class UserRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, user_id: str) -> Optional[User]:
        result = await self.db.execute(select(User).where(User.id == user_id))
        return result.scalar_one_or_none()

    async def get_by_email(self, email: str) -> Optional[User]:
        result = await self.db.execute(select(User).where(User.email == email))
        return result.scalar_one_or_none()

    async def get_by_phone(self, phone: str) -> Optional[User]:
        result = await self.db.execute(select(User).where(User.phone == phone))
        return result.scalar_one_or_none()

    async def get_by_email_or_phone(self, identifier: str) -> Optional[User]:
        result = await self.db.execute(
            select(User).where(or_(User.email == identifier, User.phone == identifier))
        )
        return result.scalar_one_or_none()

    async def create(self, user: User, profile: Optional[CitizenProfile] = None) -> User:
        self.db.add(user)
        await self.db.flush()
        if profile:
            profile.user_id = user.id
            self.db.add(profile)
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def update(self, user: User) -> User:
        await self.db.commit()
        await self.db.refresh(user)
        return user

    async def list_users(self, role: Optional[str] = None, skip: int = 0, limit: int = 50) -> List[User]:
        query = select(User)
        if role:
            query = query.where(User.role == role)
        query = query.offset(skip).limit(limit)
        result = await self.db.execute(query)
        return list(result.scalars().all())
