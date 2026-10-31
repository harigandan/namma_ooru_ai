import random
import os
import base64
import uuid
import math
from datetime import datetime, timezone
from typing import List, Optional
from fastapi import APIRouter, Depends, HTTPException, status, Query, UploadFile, File, Form
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from sqlalchemy.orm import selectinload
from app.database.session import get_db
from app.models.user import User
from app.models.complaint import Complaint, ComplaintAttachment, ComplaintStatusHistory
from app.models.ai_classification import AIClassification
from app.models.department import Department
from app.models.ward import Ward
from app.schemas.complaint import (
    ComplaintCreate,
    ComplaintUpdate,
    ComplaintResponse,
    ComplaintStatusHistoryResponse,
    ComplaintAttachmentResponse,
)
from app.core.dependencies import get_current_user
from app.services.ai_service import process_complaint_ai
from app.core.config import settings

router = APIRouter(prefix="/complaints", tags=["Complaints"])

def calculate_distance_km(lat1: float, lon1: float, lat2: Optional[float], lon2: Optional[float]) -> float:
    if lat2 is None or lon2 is None:
        return 999999.0
    r = 6371.0
    dlat = math.radians(lat2 - lat1)
    dlon = math.radians(lon2 - lon1)
    a = (math.sin(dlat / 2) ** 2 +
         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) *
         math.sin(dlon / 2) ** 2)
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a))
    return r * c

@router.post("", response_model=ComplaintResponse, status_code=status.HTTP_201_CREATED)
async def create_complaint(
    payload: ComplaintCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    # Process AI categorization & priority
    ai_result = process_complaint_ai(payload.description)
    
    category = payload.category or ai_result.predicted_category
    priority = payload.priority or ai_result.predicted_priority

    # Find matching department
    dept_result = await db.execute(
        select(Department).where(Department.code == ai_result.recommended_department_code)
    )
    department = dept_result.scalar_one_or_none()
    dept_id = department.id if department else None

    # Resolve Ward independently from coordinates
    resolved_ward_str = None
    ward_discrepancy = False
    all_wards_res = await db.execute(select(Ward).where(Ward.is_active == True))
    all_wards = all_wards_res.scalars().all()
    if all_wards:
        best_w = min(
            all_wards,
            key=lambda w: calculate_distance_km(payload.latitude, payload.longitude, w.center_latitude, w.center_longitude)
        )
        resolved_ward_str = best_w.ward_number
        if payload.ward_number and payload.ward_number.strip().lower() != resolved_ward_str.lower():
            ward_discrepancy = True

    # Generate sequential complaint number: NOA-2026-XXXXX
    random_suffix = random.randint(10000, 99999)
    complaint_number = f"NOA-2026-{random_suffix}"

    final_ward = payload.ward_number or resolved_ward_str

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
        gps_accuracy=payload.gps_accuracy,
        address=payload.address,
        ward_number=final_ward,
        zone=payload.zone,
        resolved_ward=resolved_ward_str,
        ward_discrepancy=ward_discrepancy,
        department_id=dept_id,
        language_detected=ai_result.detected_language,
        is_anonymous=payload.is_anonymous,
    )
    db.add(complaint)
    await db.flush()

    # Store AI Classification details
    classification = AIClassification(
        complaint_id=complaint.id,
        detected_language=ai_result.detected_language,
        predicted_category=ai_result.predicted_category,
        category_confidence=ai_result.category_confidence,
        predicted_priority=ai_result.predicted_priority,
        priority_confidence=ai_result.priority_confidence,
        predicted_department_id=dept_id,
        summary=ai_result.summary,
        summary_ta=ai_result.summary_ta,
        model_version=ai_result.model_version,
    )
    db.add(classification)

    # Add initial status history record
    history = ComplaintStatusHistory(
        complaint_id=complaint.id,
        previous_status=None,
        new_status="submitted",
        changed_by=current_user.id,
        notes="Complaint submitted by citizen and classified by Namma Ooru AI.",
    )
    db.add(history)

    # Process embedded photo if attached
    if payload.photo_base64:
        try:
            complaint_upload_dir = os.path.join(settings.UPLOAD_DIR, "complaints")
            os.makedirs(complaint_upload_dir, exist_ok=True)
            
            clean_b64 = payload.photo_base64
            if "," in clean_b64:
                clean_b64 = clean_b64.split(",", 1)[1]
            img_bytes = base64.b64decode(clean_b64)
            
            unique_name = f"{uuid.uuid4().hex[:12]}_{payload.photo_filename or 'gps_camera.jpg'}"
            file_disk_path = os.path.join(complaint_upload_dir, unique_name)
            with open(file_disk_path, "wb") as f:
                f.write(img_bytes)

            attachment = ComplaintAttachment(
                complaint_id=complaint.id,
                file_url=f"/uploads/complaints/{unique_name}",
                file_type="image",
                file_size=len(img_bytes),
                original_filename=payload.photo_filename or "gps_camera.jpg",
                upload_phase="initial",
                uploaded_by=current_user.id,
                latitude=payload.latitude,
                longitude=payload.longitude,
                gps_accuracy=payload.gps_accuracy,
                captured_at=datetime.now(timezone.utc),
            )
            db.add(attachment)
        except Exception as e:
            print(f"Warning: Failed to save base64 attachment: {e}")

    await db.commit()
    
    # Reload with attachments
    res = await db.execute(
        select(Complaint).options(selectinload(Complaint.attachments)).where(Complaint.id == complaint.id)
    )
    return res.scalar_one()

@router.post("/{complaint_id}/attachments", response_model=ComplaintAttachmentResponse)
async def upload_complaint_attachment(
    complaint_id: str,
    file: UploadFile = File(...),
    latitude: Optional[float] = Form(None),
    longitude: Optional[float] = Form(None),
    gps_accuracy: Optional[float] = Form(None),
    upload_phase: str = Form("initial"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Uploads a photo attachment with verified GPS coordinates and accuracy."""
    comp_res = await db.execute(select(Complaint).where(Complaint.id == complaint_id))
    complaint = comp_res.scalar_one_or_none()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")

    complaint_upload_dir = os.path.join(settings.UPLOAD_DIR, "complaints")
    os.makedirs(complaint_upload_dir, exist_ok=True)

    unique_name = f"{uuid.uuid4().hex[:12]}_{file.filename}"
    file_disk_path = os.path.join(complaint_upload_dir, unique_name)
    
    contents = await file.read()
    with open(file_disk_path, "wb") as f:
        f.write(contents)

    attachment = ComplaintAttachment(
        complaint_id=complaint.id,
        file_url=f"/uploads/complaints/{unique_name}",
        file_type="image",
        file_size=len(contents),
        original_filename=file.filename or "gps_camera.jpg",
        upload_phase=upload_phase,
        uploaded_by=current_user.id,
        latitude=latitude,
        longitude=longitude,
        gps_accuracy=gps_accuracy,
        captured_at=datetime.now(timezone.utc),
    )
    db.add(attachment)
    await db.commit()
    await db.refresh(attachment)
    return attachment

@router.get("", response_model=List[ComplaintResponse])
async def list_complaints(
    status_filter: Optional[str] = Query(None, alias="status"),
    category_filter: Optional[str] = Query(None, alias="category"),
    ward_filter: Optional[str] = Query(None, alias="ward"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    query = select(Complaint).options(selectinload(Complaint.attachments))
    
    # If citizen, only view own complaints (unless admin)
    if current_user.role == "citizen":
        query = query.where(Complaint.citizen_id == current_user.id)
    
    if status_filter and status_filter != "all":
        query = query.where(Complaint.status == status_filter)
    if category_filter and category_filter != "all":
        query = query.where(Complaint.category == category_filter)
    if ward_filter and ward_filter != "all":
        query = query.where(Complaint.ward_number == ward_filter)
        
    query = query.order_by(desc(Complaint.created_at))
    result = await db.execute(query)
    complaints = result.scalars().all()
    return complaints

@router.get("/{complaint_id}", response_model=ComplaintResponse)
async def get_complaint(
    complaint_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Complaint).options(selectinload(Complaint.attachments)).where(Complaint.id == complaint_id)
    )
    complaint = result.scalar_one_or_none()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
        
    if current_user.role == "citizen" and complaint.citizen_id != current_user.id:
        raise HTTPException(status_code=403, detail="Forbidden: You can only view your own complaints")
        
    return complaint

@router.patch("/{complaint_id}", response_model=ComplaintResponse)
async def update_complaint(
    complaint_id: str,
    payload: ComplaintUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(Complaint).options(selectinload(Complaint.attachments)).where(Complaint.id == complaint_id)
    )
    complaint = result.scalar_one_or_none()
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
        db.add(history)

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

    await db.commit()
    await db.refresh(complaint)
    return complaint

@router.get("/{complaint_id}/history", response_model=List[ComplaintStatusHistoryResponse])
async def get_complaint_history(
    complaint_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(
        select(ComplaintStatusHistory)
        .where(ComplaintStatusHistory.complaint_id == complaint_id)
        .order_by(desc(ComplaintStatusHistory.created_at))
    )
    history = result.scalars().all()
    return history

@router.post("/{complaint_id}/feedback")
async def submit_complaint_feedback(
    complaint_id: str,
    rating: int = Query(..., ge=1, le=5),
    feedback_text: Optional[str] = None,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    result = await db.execute(select(Complaint).where(Complaint.id == complaint_id))
    complaint = result.scalar_one_or_none()
    if not complaint:
        raise HTTPException(status_code=404, detail="Complaint not found")
        
    return {
        "message": "Feedback submitted successfully",
        "complaint_id": complaint_id,
        "rating": rating,
        "feedback_text": feedback_text,
    }
