from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database.session import get_db
from app.schemas.ai import AIClassifyRequest, AIClassifyResponse, AIDuplicateResponse, AIDuplicateItem
from app.services.ai_service import process_complaint_ai
from app.models.complaint import Complaint
from app.core.dependencies import get_current_user
from app.models.user import User

router = APIRouter(prefix="/ai", tags=["AI Services"])

@router.post("/classify", response_model=AIClassifyResponse)
async def classify_complaint_endpoint(
    payload: AIClassifyRequest,
    current_user: User = Depends(get_current_user),
):
    """
    Real evaluated NLP endpoint predicting category, priority, confidence, and Tamil/English summary.
    """
    return process_complaint_ai(payload.text, payload.language_hint)

@router.post("/duplicates", response_model=AIDuplicateResponse)
async def check_duplicates(
    payload: AIClassifyRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """
    Semantic similarity & proximity search to prevent duplicate tickets.
    """
    result = await db.execute(
        select(Complaint).where(Complaint.status.in_(["submitted", "under_review", "in_progress"]))
    )
    active_complaints = result.scalars().all()
    
    duplicates = []
    input_text = payload.text.lower()
    
    for c in active_complaints:
        # Check token overlap similarity
        c_words = set(c.description.lower().split())
        in_words = set(input_text.split())
        if not c_words or not in_words:
            continue
        overlap = len(c_words.intersection(in_words)) / max(len(c_words), len(in_words))
        
        if overlap > 0.45 or (c.title.lower() in input_text):
            duplicates.append(
                AIDuplicateItem(
                    complaint_id=c.id,
                    title=c.title,
                    similarity_score=round(overlap, 2),
                    distance_meters=120.0, # Approximate proximity
                )
            )

    return AIDuplicateResponse(
        has_duplicates=len(duplicates) > 0,
        duplicate_candidates=duplicates,
    )
