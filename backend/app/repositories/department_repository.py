from typing import Optional, List
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.models.department import Department, FieldOfficer

class DepartmentRepository:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def get_by_id(self, dept_id: str) -> Optional[Department]:
        result = await self.db.execute(select(Department).where(Department.id == dept_id))
        return result.scalar_one_or_none()

    async def get_by_code(self, code: str) -> Optional[Department]:
        result = await self.db.execute(select(Department).where(Department.code == code))
        return result.scalar_one_or_none()

    async def list_departments(self, only_active: bool = True) -> List[Department]:
        query = select(Department)
        if only_active:
            query = query.where(Department.is_active == True)
        result = await self.db.execute(query)
        return list(result.scalars().all())

    async def create(self, dept: Department) -> Department:
        self.db.add(dept)
        await self.db.commit()
        await self.db.refresh(dept)
        return dept

    async def list_officers(self, department_id: Optional[str] = None) -> List[FieldOfficer]:
        query = select(FieldOfficer)
        if department_id:
            query = query.where(FieldOfficer.department_id == department_id)
        result = await self.db.execute(query)
        return list(result.scalars().all())
