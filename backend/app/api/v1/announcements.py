from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List
from app.database.session import get_db
from app.models.user import User
from app.models.notification import Announcement
from app.schemas.announcement import AnnouncementResponse, AnnouncementCreate
from app.repositories.notification_repository import NotificationRepository
from app.core.dependencies import require_role

router = APIRouter(prefix="/announcements", tags=["Announcements"])

@router.get("", response_model=List[AnnouncementResponse])
async def list_public_announcements(
    db: AsyncSession = Depends(get_db),
):
    repo = NotificationRepository(db)
    return await repo.list_announcements(active_only=True)

@router.post("", response_model=AnnouncementResponse, status_code=status.HTTP_201_CREATED)
async def create_announcement(
    payload: AnnouncementCreate,
    admin_user: User = Depends(require_role(["admin"])),
    db: AsyncSession = Depends(get_db),
):
    repo = NotificationRepository(db)
    ann = Announcement(
        title=payload.title,
        title_ta=payload.title_ta,
        content=payload.content,
        content_ta=payload.content_ta,
        category=payload.category,
        priority=payload.priority,
        target_zones=payload.target_zones,
        published_by=admin_user.id,
        is_active=True,
    )
    return await repo.create_announcement(ann)
