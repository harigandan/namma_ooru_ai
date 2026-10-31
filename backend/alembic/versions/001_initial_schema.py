"""001_initial_schema

Revision ID: 001_initial_schema
Revises: 
Create Date: 2026-10-31

"""
from typing import Sequence, Union
from alembic import op
import sqlalchemy as sa

revision: str = '001_initial_schema'
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None

def upgrade() -> None:
    # 1. users
    op.create_table(
        'users',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('email', sa.String(length=255), unique=True, nullable=False, index=True),
        sa.Column('phone', sa.String(length=20), unique=True, nullable=False, index=True),
        sa.Column('password_hash', sa.String(length=255), nullable=False),
        sa.Column('full_name', sa.String(length=100), nullable=False),
        sa.Column('role', sa.String(length=20), default='citizen', index=True),
        sa.Column('preferred_language', sa.String(length=5), default='en'),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('is_verified', sa.Boolean(), default=False),
        sa.Column('avatar_url', sa.String(length=500), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 2. citizen_profiles
    op.create_table(
        'citizen_profiles',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id'), unique=True, nullable=False),
        sa.Column('address', sa.Text(), nullable=True),
        sa.Column('ward_number', sa.String(length=50), nullable=True),
        sa.Column('zone', sa.String(length=50), nullable=True),
        sa.Column('city', sa.String(length=100), default='Chennai'),
        sa.Column('pincode', sa.String(length=10), nullable=True),
        sa.Column('latitude', sa.Float(), nullable=True),
        sa.Column('longitude', sa.Float(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 3. departments
    op.create_table(
        'departments',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('name', sa.String(length=100), unique=True, nullable=False, index=True),
        sa.Column('name_ta', sa.String(length=100), nullable=False),
        sa.Column('code', sa.String(length=20), unique=True, nullable=False, index=True),
        sa.Column('description', sa.Text(), nullable=True),
        sa.Column('head_name', sa.String(length=100), nullable=True),
        sa.Column('contact_email', sa.String(length=255), nullable=True),
        sa.Column('contact_phone', sa.String(length=20), nullable=True),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 4. field_officers
    op.create_table(
        'field_officers',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id'), unique=True, nullable=False),
        sa.Column('department_id', sa.String(length=36), sa.ForeignKey('departments.id'), nullable=False),
        sa.Column('employee_id', sa.String(length=50), unique=True, nullable=False, index=True),
        sa.Column('designation', sa.String(length=100), nullable=False),
        sa.Column('assigned_zone', sa.String(length=50), nullable=True),
        sa.Column('is_available', sa.Boolean(), default=True),
        sa.Column('current_latitude', sa.Float(), nullable=True),
        sa.Column('current_longitude', sa.Float(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 5. complaints
    op.create_table(
        'complaints',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_number', sa.String(length=50), unique=True, nullable=False, index=True),
        sa.Column('citizen_id', sa.String(length=36), sa.ForeignKey('users.id'), index=True, nullable=False),
        sa.Column('title', sa.String(length=255), nullable=False),
        sa.Column('description', sa.Text(), nullable=False),
        sa.Column('description_ta', sa.Text(), nullable=True),
        sa.Column('category', sa.String(length=50), index=True, nullable=False),
        sa.Column('priority', sa.String(length=20), index=True, nullable=False),
        sa.Column('status', sa.String(length=30), index=True, nullable=False),
        sa.Column('latitude', sa.Float(), nullable=False),
        sa.Column('longitude', sa.Float(), nullable=False),
        sa.Column('address', sa.Text(), nullable=False),
        sa.Column('ward_number', sa.String(length=50), nullable=True),
        sa.Column('zone', sa.String(length=50), nullable=True),
        sa.Column('department_id', sa.String(length=36), sa.ForeignKey('departments.id'), nullable=True),
        sa.Column('assigned_officer_id', sa.String(length=36), sa.ForeignKey('field_officers.id'), nullable=True),
        sa.Column('language_detected', sa.String(length=10), default='en'),
        sa.Column('is_anonymous', sa.Boolean(), default=False),
        sa.Column('sla_deadline', sa.DateTime(timezone=True), nullable=True),
        sa.Column('resolved_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('resolution_notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 6. complaint_attachments
    op.create_table(
        'complaint_attachments',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_id', sa.String(length=36), sa.ForeignKey('complaints.id'), index=True, nullable=False),
        sa.Column('file_url', sa.String(length=500), nullable=False),
        sa.Column('file_type', sa.String(length=20), default='image'),
        sa.Column('file_size', sa.Integer(), default=0),
        sa.Column('original_filename', sa.String(length=255)),
        sa.Column('upload_phase', sa.String(length=20), default='initial'),
        sa.Column('uploaded_by', sa.String(length=36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 7. complaint_status_history
    op.create_table(
        'complaint_status_history',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_id', sa.String(length=36), sa.ForeignKey('complaints.id'), index=True, nullable=False),
        sa.Column('previous_status', sa.String(length=30), nullable=True),
        sa.Column('new_status', sa.String(length=30), nullable=False),
        sa.Column('changed_by', sa.String(length=36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('notes', sa.Text(), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 8. complaint_assignments
    op.create_table(
        'complaint_assignments',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_id', sa.String(length=36), sa.ForeignKey('complaints.id'), index=True, nullable=False),
        sa.Column('department_id', sa.String(length=36), sa.ForeignKey('departments.id'), index=True, nullable=False),
        sa.Column('officer_id', sa.String(length=36), sa.ForeignKey('field_officers.id'), nullable=True),
        sa.Column('assigned_by', sa.String(length=36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('assigned_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('unassigned_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 9. ai_classifications
    op.create_table(
        'ai_classifications',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_id', sa.String(length=36), sa.ForeignKey('complaints.id'), unique=True, nullable=False),
        sa.Column('detected_language', sa.String(length=10), default='en'),
        sa.Column('predicted_category', sa.String(length=50), nullable=False),
        sa.Column('category_confidence', sa.Float(), default=0.0),
        sa.Column('predicted_priority', sa.String(length=20), nullable=False),
        sa.Column('priority_confidence', sa.Float(), default=0.0),
        sa.Column('predicted_department_id', sa.String(length=36), sa.ForeignKey('departments.id'), nullable=True),
        sa.Column('department_confidence', sa.Float(), default=0.0),
        sa.Column('summary', sa.Text(), nullable=False),
        sa.Column('summary_ta', sa.Text(), nullable=True),
        sa.Column('model_version', sa.String(length=50), default='v1.0.0-rules-nlp'),
        sa.Column('processing_time_ms', sa.Integer(), default=0),
        sa.Column('is_override', sa.Boolean(), default=False),
        sa.Column('overridden_by', sa.String(length=36), sa.ForeignKey('users.id'), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 10. notifications
    op.create_table(
        'notifications',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id'), index=True, nullable=False),
        sa.Column('title', sa.String(length=200), nullable=False),
        sa.Column('body', sa.Text(), nullable=False),
        sa.Column('notification_type', sa.String(length=50), default='complaint_update'),
        sa.Column('reference_id', sa.String(length=36), nullable=True),
        sa.Column('is_read', sa.Boolean(), default=False, index=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 11. announcements
    op.create_table(
        'announcements',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('title', sa.String(length=200), nullable=False),
        sa.Column('title_ta', sa.String(length=200), nullable=True),
        sa.Column('content', sa.Text(), nullable=False),
        sa.Column('content_ta', sa.Text(), nullable=True),
        sa.Column('category', sa.String(length=50), default='general'),
        sa.Column('priority', sa.String(length=20), default='normal'),
        sa.Column('target_zones', sa.String(length=255), nullable=True),
        sa.Column('published_by', sa.String(length=36), sa.ForeignKey('users.id'), nullable=False),
        sa.Column('is_active', sa.Boolean(), default=True),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 12. resolution_feedback
    op.create_table(
        'resolution_feedback',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('complaint_id', sa.String(length=36), sa.ForeignKey('complaints.id'), unique=True, index=True, nullable=False),
        sa.Column('citizen_id', sa.String(length=36), sa.ForeignKey('users.id'), index=True, nullable=False),
        sa.Column('rating', sa.Integer(), nullable=False),
        sa.Column('feedback_text', sa.Text(), nullable=True),
        sa.Column('is_satisfied', sa.Boolean(), default=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 13. audit_logs
    op.create_table(
        'audit_logs',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id'), nullable=True, index=True),
        sa.Column('action', sa.String(length=100), nullable=False),
        sa.Column('resource_type', sa.String(length=100), nullable=False),
        sa.Column('resource_id', sa.String(length=36), nullable=True),
        sa.Column('details', sa.Text(), nullable=True),
        sa.Column('ip_address', sa.String(length=50), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 14. refresh_tokens
    op.create_table(
        'refresh_tokens',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('user_id', sa.String(length=36), sa.ForeignKey('users.id'), index=True, nullable=False),
        sa.Column('token_hash', sa.String(length=255), unique=True, index=True, nullable=False),
        sa.Column('expires_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('is_revoked', sa.Boolean(), default=False),
        sa.Column('revoked_at', sa.DateTime(timezone=True), nullable=True),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

    # 15. geographic_issue_clusters
    op.create_table(
        'geographic_issue_clusters',
        sa.Column('id', sa.String(length=36), primary_key=True),
        sa.Column('center_latitude', sa.Float(), nullable=False),
        sa.Column('center_longitude', sa.Float(), nullable=False),
        sa.Column('radius_meters', sa.Float(), default=1000.0),
        sa.Column('complaint_count', sa.Integer(), default=1),
        sa.Column('dominant_category', sa.String(length=50), nullable=False),
        sa.Column('severity_score', sa.Float(), default=0.5),
        sa.Column('active_complaints', sa.Integer(), default=1),
        sa.Column('zone', sa.String(length=50), nullable=True),
        sa.Column('ward_number', sa.String(length=50), nullable=True),
        sa.Column('last_analyzed_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('created_at', sa.DateTime(timezone=True), nullable=False),
        sa.Column('updated_at', sa.DateTime(timezone=True), nullable=False),
    )

def downgrade() -> None:
    tables = [
        'geographic_issue_clusters',
        'refresh_tokens',
        'audit_logs',
        'resolution_feedback',
        'announcements',
        'notifications',
        'ai_classifications',
        'complaint_assignments',
        'complaint_status_history',
        'complaint_attachments',
        'complaints',
        'field_officers',
        'departments',
        'citizen_profiles',
        'users',
    ]
    for table in tables:
        op.drop_table(table)
