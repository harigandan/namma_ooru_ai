import random
from typing import Optional, List
from datetime import datetime, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from fastapi import HTTPException, status
from app.models.complaint import Complaint, ComplaintStatusHistory
from app.models.ai_classification import AIClassification
from app.models.complaint_assignment import ComplaintAssignment
from app.models.user import User
from app.schemas.complaint import ComplaintCreate, ComplaintUpdate
from app.repositories.complaint_repository import ComplaintRepository
from app.repositories.department_repository import DepartmentRepository
from app.services.ai_service import process_complaint_ai

class ComplaintService:
    def __init__(self, db: AsyncSession):
        self.complaint_repo = ComplaintRepository(db)
        self.dept_repo = DepartmentRepository(db)

    async def create_complaint(self, payload: ComplaintCreate, current_user: User) -> Complaint:
        # Run AI processing
        ai_res = process_complaint_ai(payload.description)
        category = payload.category or ai_res.predicted_category
        priority = payload.priority or ai_res.predicted_priority

        dept = await self.dept_repo.get_by_code(ai_res.recommended_department_code)
        dept_id = dept.id if dept else None

        complaint_number = f"NOA-2026-{random.randint(10000, 99999)}"

        complaint = Complaint(
            complaint_number=complaint_number,
            citizen_id=current_user.id,
            title=payload.title,
            description=payload.description,
            description_ta=payload.description_ta,
            category=category,
            priority=priority,
            status="submitted",
            latitude=payload.latitude,
            longitude=payload.longitude,
            address=payload.address,
            ward_number=payload.ward_number,
            zone=payload.zone,
            department_id=dept_id,
            language_detected=ai_res.detected_language,
            is_anonymous=payload.is_anonymous,
        )

        classification = AIClassification(
            complaint_id="",
            detected_language=ai_res.detected_language,
            predicted_category=ai_res.predicted_category,
            category_confidence=ai_res.category_confidence,
            predicted_priority=ai_res.predicted_priority,
            priority_confidence=ai_res.priority_confidence,
            predicted_department_id=dept_id,
            summary=ai_res.summary,
            summary_ta=ai_res.summary_ta,
            model_version=ai_res.model_version,
        )

        initial_history = ComplaintStatusHistory(
            complaint_id="",
            previous_status=None,
            new_status="submitted",
            changed_by=current_user.id,
            notes="Submitted by citizen and classified by Namma Ooru AI.",
        )

        return await self.complaint_repo.create(complaint, classification, initial_history)

    async def update_status(
        self,
        complaint_id: str,
        payload: ComplaintUpdate,
        current_user: User,
    ) -> Complaint:
        complaint = await self.complaint_repo.get_by_id(complaint_id)
        if not complaint:
            raise HTTPException(status_code=404, detail="Complaint not found")

        old_status = complaint.status
        if payload.status and payload.status != old_status:
            complaint.status = payload.status
            if payload.status == "resolved":
                complaint.resolved_at = datetime.now(timezone.utc)

            history = ComplaintStatusHistory(
                complaint_id=complaint.id,
                previous_status=old_status,
                new_status=payload.status,
                changed_by=current_user.id,
                notes=payload.resolution_notes or f"Status transitioned to {payload.status}",
            )
            await self.complaint_repo.add_status_history(history)

        if payload.priority:
            complaint.priority = payload.priority
        if payload.category:
            complaint.category = payload.category
        if payload.department_id:
            complaint.department_id = payload.department_id
        if payload.assigned_officer_id:
            complaint.assigned_officer_id = payload.assigned_officer_id
        if payload.resolution_notes:
            complaint.resolution_notes = payload.resolution_notes

        return await self.complaint_repo.update(complaint)

    async def assign_complaint(
        self,
        complaint_id: str,
        department_id: str,
        officer_id: Optional[str],
        admin_user: User,
    ) -> Complaint:
        complaint = await self.complaint_repo.get_by_id(complaint_id)
        if not complaint:
            raise HTTPException(status_code=404, detail="Complaint not found")

        complaint.department_id = department_id
        if officer_id:
            complaint.assigned_officer_id = officer_id
        complaint.status = "assigned"

        assignment = ComplaintAssignment(
            complaint_id=complaint.id,
            department_id=department_id,
            officer_id=officer_id,
            assigned_by=admin_user.id,
            is_active=True,
        )
        await self.complaint_repo.add_assignment(assignment)
        return await self.complaint_repo.update(complaint)
