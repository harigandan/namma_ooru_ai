from pydantic import BaseModel
from typing import List, Dict

class DepartmentStat(BaseModel):
    department_id: str
    department_name: str
    total_complaints: int
    resolved_complaints: int
    avg_resolution_hours: float

class CategoryStat(BaseModel):
    category: str
    count: int

class AdminDashboardMetrics(BaseModel):
    total_complaints: int
    pending_complaints: int
    in_progress_complaints: int
    resolved_complaints: int
    high_priority_complaints: int
    average_resolution_hours: float
    categories_breakdown: List[CategoryStat]
    department_stats: List[DepartmentStat]
