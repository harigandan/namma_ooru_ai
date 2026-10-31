from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from app.models.complaint import Complaint, ComplaintStatusHistory
from app.models.ai_classification import AIClassification
from app.models.complaint_assignment import ComplaintAssignment

class ComplaintRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, complaint_id: str) -> Optional[Complaint]:
        result = await self.db.execute(select(Complaint).where(Complaint.id == complaint_id))
        return result.scalar_one_or_none()

    async def get_by_number(self, complaint_number: str) -> Optional[Complaint]:
        result = await self.db.execute(select(Complaint).where(Complaint.complaint_number == complaint_number))
        return result.scalar_one_or_none()

    async def list_complaints(
        self,
        citizen_id: Optional[str] = None,
        department_id: Optional[str] = None,
        assigned_officer_id: Optional[str] = None,
        status: Optional[str] = None,
        category: Optional[str] = None,
        priority: Optional[str] = None,
        skip: int = 0,
        limit: int = 100,
    ) -> List[Complaint]:
        query = select(Complaint)
        if citizen_id:
            query = query.where(Complaint.citizen_id == citizen_id)
        if department_id:
            query = query.where(Complaint.department_id == department_id)
        if assigned_officer_id:
            query = query.where(Complaint.assigned_officer_id == assigned_officer_id)
        if status:
            query = query.where(Complaint.status == status)
        if category:
            query = query.where(Complaint.category == category)
        if priority:
            query = query.where(Complaint.priority == priority)

        query = query.order_by(desc(Complaint.created_at)).offset(skip).limit(limit)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def create(
        self,
        complaint: Complaint,
        classification: Optional[AIClassification] = None,
        initial_history: Optional[ComplaintStatusHistory] = None,
    ) -> Complaint:
        self.db.add(complaint)
        await self.db.flush()

        if classification:
            classification.complaint_id = complaint.id
            self.db.add(classification)

        if initial_history:
            initial_history.complaint_id = complaint.id
            self.db.add(initial_history)

        await self.db.commit()
        await self.db.refresh(complaint)
        return complaint

    async def update(self, complaint: Complaint) -> Complaint:
        await self.db.commit()
        await self.db.refresh(complaint)
        return complaint

    async def add_status_history(self, history: ComplaintStatusHistory) -> ComplaintStatusHistory:
        self.db.add(history)
        await self.db.commit()
        await self.db.refresh(history)
        return history

    async def add_assignment(self, assignment: ComplaintAssignment) -> ComplaintAssignment:
        self.db.add(assignment)
        await self.db.commit()
        await self.db.refresh(assignment)
        return assignment
