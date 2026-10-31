from fastapi import APIRouter
from app.api.v1.auth import router as auth_router
from app.api.v1.users import router as users_router
from app.api.v1.complaints import router as complaints_router
from app.api.v1.ai import router as ai_router
from app.api.v1.admin import router as admin_router
from app.api.v1.officers import router as officers_router
from app.api.v1.maps import router as maps_router
from app.api.v1.notifications import router as notifications_router
from app.api.v1.announcements import router as announcements_router
from app.api.v1.wards import router as wards_router

api_router = APIRouter()
api_router.include_router(auth_router)
api_router.include_router(users_router)
api_router.include_router(complaints_router)
api_router.include_router(ai_router)
api_router.include_router(admin_router)
api_router.include_router(officers_router)
api_router.include_router(maps_router)
api_router.include_router(notifications_router)
api_router.include_router(announcements_router)
api_router.include_router(wards_router)
