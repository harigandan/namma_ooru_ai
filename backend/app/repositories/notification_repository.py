from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from app.models.notification import Notification, Announcement

class NotificationRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def list_for_user(self, user_id: str, unread_only: bool = False) -> List[Notification]:
        query = select(Notification).where(Notification.user_id == user_id)
        if unread_only:
            query = query.where(Notification.is_read == False)
        query = query.order_by(desc(Notification.created_at))
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def create(self, notif: Notification) -> Notification:
        self.db.add(notif)
        await self.db.commit()
        await self.db.refresh(notif)
        return notif

    async def mark_as_read(self, notif_id: str) -> Optional[Notification]:
        result = await self.db.execute(select(Notification).where(Notification.id == notif_id))
        notif = result.scalar_one_or_none()
        if notif:
            notif.is_read = True
            await self.db.commit()
            await self.db.refresh(notif)
        return notif

    async def list_announcements(self, active_only: bool = True) -> List[Announcement]:
        query = select(Announcement)
        if active_only:
            query = query.where(Announcement.is_active == True)
        query = query.order_by(desc(Announcement.created_at))
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def create_announcement(self, ann: Announcement) -> Announcement:
        self.db.add(ann)
        await self.db.commit()
        await self.db.refresh(ann)
        return ann
