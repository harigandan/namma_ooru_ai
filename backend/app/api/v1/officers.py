from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from typing import List, Optional
from app.database.session import get_db
from app.models.user import User
from app.models.complaint import Complaint
from app.schemas.complaint import ComplaintResponse
from app.schemas.officer import OfficerWorkUpdate
from app.core.dependencies import get_current_user, require_role
from app.services.complaint_service import ComplaintService

router = APIRouter(prefix="/officer", tags=["Field Officers"])

@router.get("/assignments", response_model=List[ComplaintResponse])
async def get_officer_assignments(
    officer: User = Depends(require_role(["field_officer", "admin"])),
    db: AsyncSession = Depends(get_db),
):
    """
    Returns complaints assigned to the logged-in field officer.
    """
    complaint_service = ComplaintService(db)
    complaints = await complaint_service.complaint_repo.list_complaints()
    return complaints

@router.post("/assignments/{complaint_id}/updates")
async def update_assignment_progress(
    complaint_id: str,
    payload: OfficerWorkUpdate,
    officer: User = Depends(require_role(["field_officer", "admin"])),
    db: AsyncSession = Depends(get_db),
):
    complaint_service = ComplaintService(db)
    from app.schemas.complaint import ComplaintUpdate
    updated = await complaint_service.update_status(
        complaint_id=complaint_id,
        payload=ComplaintUpdate(
            status=payload.status,
            resolution_notes=payload.resolution_notes,
        ),
        current_user=officer,
    )
    return {"message": "Status updated successfully", "status": updated.status}

@router.post("/assignments/{complaint_id}/complete")
async def complete_assignment(
    complaint_id: str,
    payload: OfficerWorkUpdate,
    officer: User = Depends(require_role(["field_officer", "admin"])),
    db: AsyncSession = Depends(get_db),
):
    complaint_service = ComplaintService(db)
    from app.schemas.complaint import ComplaintUpdate
    updated = await complaint_service.update_status(
        complaint_id=complaint_id,
        payload=ComplaintUpdate(
            status="resolved",
            resolution_notes=payload.resolution_notes or "Field maintenance resolved.",
        ),
        current_user=officer,
    )
    return {"message": "Assignment marked as resolved", "status": updated.status}
