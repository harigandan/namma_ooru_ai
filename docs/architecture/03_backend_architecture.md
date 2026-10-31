# Backend Architecture — Namma Ooru AI

> **Version**: 1.0  
> **Last Updated**: 2026-10-31  
> **Stack**: FastAPI · SQLAlchemy 2.0 · PostgreSQL · Python 3.11+

---

## 1. Architecture Overview

The Namma Ooru AI backend is built on **FastAPI** with full async support, following a clean layered architecture that enforces separation of concerns, testability, and maintainability.

### Core Design Principles

| Principle | Implementation |
|---|---|
| **Async-First** | All I/O operations use `async`/`await` — database queries, HTTP calls, file uploads |
| **Layered Architecture** | Routes → Services → Repositories → Database, each layer with a single responsibility |
| **Dependency Injection** | FastAPI's `Depends()` for composable, testable dependency chains |
| **Validation at the Edge** | Pydantic v2 schemas validate all input at the API boundary |
| **Type Safety** | Full type annotations throughout; enforced with `mypy` |
| **Secure by Default** | JWT with refresh token rotation, bcrypt password hashing, role-based access |

### Technology Choices

| Component | Technology | Rationale |
|---|---|---|
| **Framework** | FastAPI 0.100+ | Async, auto-docs, dependency injection, Pydantic integration |
| **ORM** | SQLAlchemy 2.0 (async) | Mature, powerful, native async session support |
| **Migrations** | Alembic | Industry standard for SQLAlchemy migrations |
| **Validation** | Pydantic v2 | 5–50× faster than v1, strict mode, computed fields |
| **Auth** | python-jose (JWT) + passlib (bcrypt) | Battle-tested libraries for token and password handling |
| **Database** | PostgreSQL 15+ with PostGIS | Spatial queries for map features, JSONB for flexible data |
| **Object Storage** | MinIO (dev) / AWS S3 (prod) | S3-compatible API for seamless environment switching |
| **Task Queue** | Celery + Redis (future) | Background AI processing, notifications |

---

## 2. High-Level Architecture

```mermaid
flowchart TD
    Client["Client (Mobile / Web)"]

    subgraph Edge["Edge Layer"]
        CORS["CORS Middleware"]
        RL["Rate Limiter"]
        AuditMW["Audit Middleware"]
        ErrMW["Error Handler"]
    end

    subgraph API["API Layer (FastAPI Routers)"]
        AuthR["auth.py"]
        UsersR["users.py"]
        ComplaintsR["complaints.py"]
        UploadsR["uploads.py"]
        AIR["ai.py"]
        AdminR["admin.py"]
        OfficersR["officers.py"]
        MapsR["maps.py"]
        NotifsR["notifications.py"]
        AnnouncementsR["announcements.py"]
    end

    subgraph Services["Service Layer"]
        AuthS["AuthService"]
        UserS["UserService"]
        ComplaintS["ComplaintService"]
        UploadS["UploadService"]
        AIS["AIService"]
        AdminS["AdminService"]
        OfficerS["OfficerService"]
        MapS["MapService"]
        NotifS["NotificationService"]
        AuditS["AuditService"]
    end

    subgraph Repos["Repository Layer"]
        UserRepo["UserRepository"]
        ComplaintRepo["ComplaintRepository"]
        DeptRepo["DepartmentRepository"]
        OfficerRepo["OfficerRepository"]
        NotifRepo["NotificationRepository"]
        AnnouncementRepo["AnnouncementRepository"]
        AuditRepo["AuditRepository"]
    end

    subgraph Data["Data Layer"]
        SA["SQLAlchemy 2.0 Async"]
        PG["PostgreSQL + PostGIS"]
    end

    subgraph External["External Services"]
        AIPipe["AI Pipeline"]
        ObjStore["Object Storage (MinIO / S3)"]
        NotifExt["Notification Provider (FCM / SMS)"]
    end

    Client --> CORS --> RL --> AuditMW --> ErrMW
    ErrMW --> API

    AuthR --> AuthS
    UsersR --> UserS
    ComplaintsR --> ComplaintS
    UploadsR --> UploadS
    AIR --> AIS
    AdminR --> AdminS
    OfficersR --> OfficerS
    MapsR --> MapS
    NotifsR --> NotifS
    AnnouncementsR --> AdminS

    AuthS --> UserRepo
    UserS --> UserRepo
    ComplaintS --> ComplaintRepo
    ComplaintS --> AIS
    ComplaintS --> NotifS
    OfficerS --> OfficerRepo
    AdminS --> ComplaintRepo
    AdminS --> DeptRepo
    MapS --> ComplaintRepo
    NotifS --> NotifRepo
    AuditS --> AuditRepo
    UploadS --> ObjStore
    AIS --> AIPipe
    NotifS --> NotifExt

    UserRepo --> SA
    ComplaintRepo --> SA
    DeptRepo --> SA
    OfficerRepo --> SA
    NotifRepo --> SA
    AnnouncementRepo --> SA
    AuditRepo --> SA
    SA --> PG
```

---

## 3. Project Structure

```
backend/
├── app/
│   ├── __init__.py
│   ├── main.py                        # FastAPI app factory, lifespan events
│   │
│   ├── core/
│   │   ├── __init__.py
│   │   ├── config.py                  # Pydantic Settings from environment
│   │   ├── security.py                # JWT creation, verification, password hashing
│   │   ├── dependencies.py            # Common deps: get_db, get_current_user
│   │   ├── exceptions.py              # Custom HTTP exception classes
│   │   └── rate_limiter.py            # Token-bucket rate limiting
│   │
│   ├── api/
│   │   ├── __init__.py
│   │   └── v1/
│   │       ├── __init__.py
│   │       ├── router.py              # Aggregates all v1 routes
│   │       ├── auth.py                # POST /login, /register, /refresh, /logout
│   │       ├── users.py               # GET/PATCH /users/me, GET /users/{id}
│   │       ├── complaints.py          # Full CRUD + filtering + status transitions
│   │       ├── uploads.py             # POST /upload, GET /files/{id}
│   │       ├── ai.py                  # POST /classify, GET /duplicates
│   │       ├── admin.py               # Dashboard stats, user mgmt, dept mgmt
│   │       ├── officers.py            # Assignment, workload, field operations
│   │       ├── maps.py                # GeoJSON endpoints, heatmap data
│   │       ├── notifications.py       # GET /notifications, PATCH /read
│   │       └── announcements.py       # CRUD for public announcements
│   │
│   ├── models/
│   │   ├── __init__.py
│   │   ├── base.py                    # DeclarativeBase, UUID pk, timestamps mixin
│   │   ├── user.py                    # User, CitizenProfile
│   │   ├── department.py              # Department
│   │   ├── field_officer.py           # FieldOfficer
│   │   ├── complaint.py               # Complaint, Attachment, StatusHistory
│   │   ├── ai_classification.py       # AIClassification
│   │   ├── notification.py            # Notification
│   │   ├── announcement.py            # Announcement
│   │   ├── feedback.py                # ResolutionFeedback
│   │   ├── audit_log.py               # AuditLog
│   │   ├── refresh_token.py           # RefreshToken
│   │   └── geographic_cluster.py      # GeographicIssueCluster
│   │
│   ├── schemas/
│   │   ├── __init__.py
│   │   ├── auth.py                    # LoginRequest, RegisterRequest, TokenResponse
│   │   ├── user.py                    # UserRead, UserUpdate, UserList
│   │   ├── complaint.py               # ComplaintCreate, ComplaintRead, ComplaintFilter
│   │   ├── ai.py                      # ClassificationRequest, ClassificationResponse
│   │   ├── admin.py                   # DashboardStats, AnalyticsResponse
│   │   ├── officer.py                 # AssignmentCreate, WorkloadResponse
│   │   ├── map.py                     # GeoJSONFeature, HeatmapData
│   │   ├── notification.py            # NotificationRead, NotificationList
│   │   ├── announcement.py            # AnnouncementCreate, AnnouncementRead
│   │   └── common.py                  # PaginatedResponse, ErrorResponse, HealthCheck
│   │
│   ├── services/
│   │   ├── __init__.py
│   │   ├── auth_service.py            # Register, login, token refresh, logout
│   │   ├── user_service.py            # Profile management, role queries
│   │   ├── complaint_service.py       # Create, update, transition, search
│   │   ├── ai_service.py              # Orchestrates AI pipeline components
│   │   ├── upload_service.py          # Validate, store, generate presigned URLs
│   │   ├── notification_service.py    # Push (FCM), email, SMS dispatch
│   │   ├── admin_service.py           # Dashboard aggregation, analytics
│   │   ├── officer_service.py         # Assignment algo, workload balancing
│   │   ├── map_service.py             # Spatial queries, cluster generation
│   │   └── audit_service.py           # Write audit log entries
│   │
│   ├── repositories/
│   │   ├── __init__.py
│   │   ├── user_repository.py         # User CRUD, profile queries
│   │   ├── complaint_repository.py    # Complaint CRUD, filters, spatial queries
│   │   ├── department_repository.py   # Department lookup, stats
│   │   ├── officer_repository.py      # Officer CRUD, workload queries
│   │   ├── notification_repository.py # Notification CRUD, batch mark-read
│   │   ├── announcement_repository.py # Announcement CRUD, active listing
│   │   └── audit_repository.py        # Append-only audit log writes
│   │
│   ├── ai/
│   │   ├── __init__.py
│   │   ├── pipeline.py                # Main orchestrator — chains all AI steps
│   │   ├── language_detector.py       # Tamil / English / mixed detection
│   │   ├── text_preprocessor.py       # Normalization, tokenization, stopwords
│   │   ├── classifier.py             # TF-IDF + SVM category classification
│   │   ├── priority_detector.py       # Heuristic urgency scoring
│   │   ├── department_recommender.py  # Category → department mapping
│   │   ├── summarizer.py             # Extractive TextRank summarization
│   │   ├── duplicate_detector.py      # Sentence-BERT + cosine similarity
│   │   ├── hotspot_analyzer.py        # DBSCAN geographic clustering
│   │   └── models/
│   │       └── README.md              # Instructions for trained model files
│   │
│   ├── middleware/
│   │   ├── __init__.py
│   │   ├── cors.py                    # CORS origin whitelist configuration
│   │   ├── rate_limit.py              # Sliding-window rate limit middleware
│   │   ├── audit.py                   # Request/response audit logging
│   │   └── error_handler.py           # Global exception → JSON response handler
│   │
│   ├── database/
│   │   ├── __init__.py
│   │   ├── session.py                 # AsyncSessionLocal factory, engine setup
│   │   ├── init_db.py                 # Create tables, verify connectivity
│   │   └── seed.py                    # Seed departments, admin user, test data
│   │
│   └── tests/
│       ├── __init__.py
│       ├── conftest.py                # Fixtures: test DB, client, auth headers
│       ├── test_auth.py               # Registration, login, refresh, logout
│       ├── test_complaints.py         # CRUD, filtering, status transitions
│       ├── test_admin.py              # Dashboard, user management
│       ├── test_ai.py                 # Classification, duplicate detection
│       ├── test_officer.py            # Assignment, workload
│       ├── test_maps.py              # GeoJSON, heatmap
│       └── test_uploads.py            # File validation, upload, retrieval
│
├── alembic/
│   ├── env.py                         # Async Alembic environment config
│   └── versions/
│       └── 001_initial_schema.py      # Initial migration with all tables
│
├── alembic.ini                        # Alembic configuration
├── requirements.txt                   # Production dependencies
├── requirements-dev.txt               # Dev/test dependencies
├── Dockerfile                         # Multi-stage production build
└── .env.example                       # Environment variable template
```

### Layer Responsibilities

| Layer | Responsibility | Rules |
|---|---|---|
| **Routes** (`api/`) | Parse HTTP requests, call services, return responses | No business logic. Only validation + delegation |
| **Services** (`services/`) | Business logic, orchestration, authorization checks | No direct SQL. Call repositories for data access |
| **Repositories** (`repositories/`) | Data access, query construction, ORM operations | No business logic. Pure data in/out |
| **Models** (`models/`) | SQLAlchemy ORM table definitions | No methods beyond simple properties |
| **Schemas** (`schemas/`) | Pydantic v2 request/response validation | Decoupled from ORM models |

---

## 4. Dependency Injection Pattern

FastAPI's `Depends()` system enables composable, testable dependency chains. Each dependency in the chain is automatically resolved and injected.

```mermaid
flowchart LR
    Request["HTTP Request"]
    GetDB["get_db()"]
    GetUser["get_current_user(db)"]
    RequireRole["require_role('admin')"]
    Handler["Route Handler"]
    Service["Service(db)"]
    Repo["Repository(db)"]
    DB["Database"]

    Request --> GetDB
    GetDB -->|"AsyncSession"| GetUser
    GetUser -->|"User model"| RequireRole
    RequireRole -->|"User model (verified)"| Handler
    Handler --> Service
    Service --> Repo
    Repo --> DB
```

### Dependency Implementations

**`get_db()` — Database Session Provider**

```python
from sqlalchemy.ext.asyncio import AsyncSession
from app.database.session import AsyncSessionLocal

async def get_db() -> AsyncGenerator[AsyncSession, None]:
    async with AsyncSessionLocal() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
```

**`get_current_user()` — JWT Authentication**

```python
from fastapi import Depends, HTTPException, status
from fastapi.security import OAuth2PasswordBearer

oauth2_scheme = OAuth2PasswordBearer(tokenUrl="/api/v1/auth/login")

async def get_current_user(
    token: str = Depends(oauth2_scheme),
    db: AsyncSession = Depends(get_db),
) -> User:
    payload = verify_access_token(token)
    if payload is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token",
        )
    user = await UserRepository(db).get_by_id(payload["sub"])
    if user is None or not user.is_active:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED)
    return user
```

**`require_role()` — Role-Based Access Control**

```python
def require_role(*roles: str):
    async def role_checker(
        current_user: User = Depends(get_current_user),
    ) -> User:
        if current_user.role not in roles:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Insufficient permissions",
            )
        return current_user
    return role_checker
```

**Usage in a Route**

```python
@router.get("/admin/dashboard")
async def get_dashboard(
    admin: User = Depends(require_role("admin", "super_admin")),
    db: AsyncSession = Depends(get_db),
):
    service = AdminService(db)
    return await service.get_dashboard_stats()
```

### Dependency Chain Visualization

```mermaid
flowchart TD
    subgraph Public["Public Endpoints"]
        Login["POST /auth/login"]
        Register["POST /auth/register"]
        Health["GET /health"]
    end

    subgraph Authenticated["Authenticated Endpoints"]
        GetMe["GET /users/me"]
        CreateComplaint["POST /complaints"]
        GetNotifs["GET /notifications"]
    end

    subgraph RoleProtected["Role-Protected Endpoints"]
        AdminDash["GET /admin/dashboard"]
        AssignOfficer["POST /officers/assign"]
        ManageDepts["PUT /admin/departments"]
    end

    GetDB["get_db()"] --> GetMe
    GetDB --> CreateComplaint
    GetDB --> GetNotifs

    GetDB --> AdminDash
    GetDB --> AssignOfficer
    GetDB --> ManageDepts

    GetCU["get_current_user()"] --> GetMe
    GetCU --> CreateComplaint
    GetCU --> GetNotifs

    GetCU --> RRAdmin["require_role('admin')"]
    GetCU --> RROfficer["require_role('admin', 'officer')"]

    RRAdmin --> AdminDash
    RRAdmin --> ManageDepts
    RROfficer --> AssignOfficer
```

---

## 5. Authentication Flow

### 5.1 Registration

```mermaid
sequenceDiagram
    actor User
    participant API as "FastAPI Router"
    participant AuthS as "AuthService"
    participant UserR as "UserRepository"
    participant DB as "PostgreSQL"

    User->>API: POST /api/v1/auth/register<br/>{"phone", "password", "name", "ward_number"}
    API->>API: Validate with RegisterRequest schema
    API->>AuthS: register(register_data)
    AuthS->>UserR: get_by_phone(phone)
    UserR->>DB: SELECT * FROM users WHERE phone = ?
    DB-->>UserR: null (no existing user)
    UserR-->>AuthS: None

    AuthS->>AuthS: hash_password(password)
    AuthS->>UserR: create(user_data)
    UserR->>DB: INSERT INTO users (...)
    DB-->>UserR: User record
    UserR-->>AuthS: User

    AuthS->>AuthS: create_access_token(user.id)
    AuthS->>AuthS: create_refresh_token(user.id)
    AuthS->>UserR: store_refresh_token(token_hash, user.id)
    UserR->>DB: INSERT INTO refresh_tokens (...)
    DB-->>UserR: OK

    AuthS-->>API: TokenResponse
    API-->>User: 201 {"access_token", "refresh_token", "token_type", "expires_in"}
```

### 5.2 Login

```mermaid
sequenceDiagram
    actor User
    participant API as "FastAPI Router"
    participant AuthS as "AuthService"
    participant UserR as "UserRepository"
    participant DB as "PostgreSQL"

    User->>API: POST /api/v1/auth/login<br/>{"phone", "password"}
    API->>API: Validate with LoginRequest schema
    API->>AuthS: login(credentials)

    AuthS->>UserR: get_by_phone(phone)
    UserR->>DB: SELECT * FROM users WHERE phone = ?
    DB-->>UserR: User record
    UserR-->>AuthS: User

    AuthS->>AuthS: verify_password(password, user.hashed_password)

    alt Password Invalid
        AuthS-->>API: raise InvalidCredentials
        API-->>User: 401 {"detail": "Invalid phone or password"}
    else Password Valid
        AuthS->>AuthS: create_access_token(user.id, role)
        AuthS->>AuthS: create_refresh_token(user.id)
        AuthS->>DB: INSERT INTO refresh_tokens (token_hash, user_id, expires_at)
        AuthS-->>API: TokenResponse
        API-->>User: 200 {"access_token", "refresh_token", "token_type", "expires_in"}
    end
```

### 5.3 Token Refresh with Rotation

> [!IMPORTANT]
> Refresh token rotation ensures that each refresh token can only be used **once**. When a refresh token is used, it is immediately revoked and a new pair (access + refresh) is issued. If a revoked token is reused, **all tokens for that user are invalidated** — this detects token theft.

```mermaid
sequenceDiagram
    actor User
    participant API as "FastAPI Router"
    participant AuthS as "AuthService"
    participant DB as "PostgreSQL"

    User->>API: POST /api/v1/auth/refresh<br/>{"refresh_token": "old_token"}
    API->>AuthS: refresh(old_token)

    AuthS->>DB: SELECT * FROM refresh_tokens<br/>WHERE token_hash = hash(old_token)
    DB-->>AuthS: RefreshToken record

    alt Token Not Found or Expired
        AuthS-->>API: raise InvalidToken
        API-->>User: 401 {"detail": "Invalid or expired refresh token"}
    else Token Already Revoked (reuse detected)
        AuthS->>DB: UPDATE refresh_tokens<br/>SET revoked = true<br/>WHERE user_id = ? AND revoked = false
        Note over AuthS,DB: Revoke ALL tokens for this user (theft detected)
        AuthS-->>API: raise TokenTheftDetected
        API-->>User: 401 {"detail": "Security alert — all sessions revoked"}
    else Token Valid
        AuthS->>DB: UPDATE refresh_tokens<br/>SET revoked = true WHERE id = ?
        Note over AuthS,DB: Revoke the old refresh token

        AuthS->>AuthS: create_access_token(user.id, role)
        AuthS->>AuthS: create_refresh_token(user.id)
        AuthS->>DB: INSERT INTO refresh_tokens<br/>(token_hash, user_id, parent_token_id, expires_at)

        AuthS-->>API: TokenResponse
        API-->>User: 200 {"access_token", "refresh_token (new)", "expires_in"}
    end
```

### 5.4 Logout (Token Revocation)

```mermaid
sequenceDiagram
    actor User
    participant API as "FastAPI Router"
    participant AuthS as "AuthService"
    participant DB as "PostgreSQL"

    User->>API: POST /api/v1/auth/logout<br/>Authorization: Bearer {access_token}<br/>{"refresh_token": "current_token"}
    API->>API: Verify access_token via get_current_user
    API->>AuthS: logout(user_id, refresh_token)

    AuthS->>DB: UPDATE refresh_tokens<br/>SET revoked = true<br/>WHERE token_hash = hash(refresh_token)<br/>AND user_id = ?
    DB-->>AuthS: OK

    AuthS-->>API: Success
    API-->>User: 200 {"message": "Logged out successfully"}
```

### Token Configuration

| Parameter | Value | Notes |
|---|---|---|
| Access Token Lifetime | 15 minutes | Short-lived for security |
| Refresh Token Lifetime | 7 days | Longer-lived, stored hashed in DB |
| Algorithm | HS256 | HMAC-SHA256, symmetric |
| Token Storage (Client) | Secure HTTP-only cookie (web) / Encrypted storage (mobile) | Never in localStorage |
| Password Hashing | bcrypt (12 rounds) | Via passlib |

---

## 6. Request Processing Pipeline

Every HTTP request passes through a well-defined middleware chain before reaching the route handler. Each middleware performs a specific responsibility and either passes the request forward or short-circuits with an error response.

```mermaid
flowchart LR
    subgraph Incoming["Incoming Request"]
        Req["HTTP Request"]
    end

    subgraph MW["Middleware Stack (order matters)"]
        direction LR
        EH["Error Handler"]
        CORS["CORS"]
        Audit["Audit Logger"]
        RL["Rate Limiter"]
    end

    subgraph App["Application"]
        Auth["Auth Dependency"]
        Route["Route Handler"]
        Svc["Service Layer"]
    end

    subgraph Outgoing["Outgoing Response"]
        Res["HTTP Response"]
    end

    Req --> EH
    EH --> CORS
    CORS --> Audit
    Audit --> RL
    RL --> Auth
    Auth --> Route
    Route --> Svc
    Svc --> Route
    Route --> Res

    EH -.->|"Catches unhandled exceptions"| Res
    RL -.->|"429 if rate exceeded"| Res
    CORS -.->|"Adds CORS headers"| Res
```

### Middleware Details

| Middleware | Purpose | Behavior on Failure |
|---|---|---|
| **Error Handler** | Wraps entire pipeline; catches unhandled exceptions | Returns structured JSON error |
| **CORS** | Validates `Origin` header against whitelist | Blocks cross-origin requests |
| **Audit Logger** | Logs request method, path, user, IP, timestamp, duration | Never blocks; logs asynchronously |
| **Rate Limiter** | Token-bucket algorithm per IP / per user | Returns `429 Too Many Requests` |
| **Auth Dependency** | JWT verification (per-route, not middleware) | Returns `401 Unauthorized` |

### Rate Limiting Rules

| Endpoint Pattern | Window | Max Requests | Scope |
|---|---|---|---|
| `POST /auth/login` | 15 min | 5 | Per IP |
| `POST /auth/register` | 1 hour | 3 | Per IP |
| `POST /complaints` | 1 hour | 10 | Per User |
| `POST /upload` | 1 hour | 20 | Per User |
| `GET /*` (general reads) | 1 min | 60 | Per User |
| `POST /auth/refresh` | 15 min | 10 | Per IP |

---

## 7. AI Pipeline Architecture

The AI pipeline processes complaint text (Tamil or English) through a sequence of specialized components. Each component is independently testable and replaceable.

> [!NOTE]
> This pipeline uses **traditional ML and NLP** — not large language models. This is intentional for predictability, cost efficiency, offline capability, and deterministic behavior in a civic governance context.

### 7.1 Pipeline Flow

```mermaid
flowchart TD
    Input["Complaint Input<br/>(text + optional image + location)"]
    LD["Language Detector"]
    PP["Text Preprocessor"]
    CC["Category Classifier"]
    PD["Priority Detector"]
    DR["Department Recommender"]
    DD["Duplicate Detector"]
    SUM["Summarizer"]
    HA["Hotspot Analyzer"]
    Result["Classification Result"]

    Input --> LD
    LD -->|"lang: ta / en / mixed"| PP
    PP -->|"cleaned tokens"| CC
    CC -->|"category + confidence"| PD
    PD -->|"priority: low / medium / high / critical"| DR
    DR -->|"department_id + confidence"| DD
    DD -->|"duplicate_ids[] + similarity scores"| SUM
    SUM -->|"summary text"| Result
    
    Input -->|"coordinates"| HA
    HA -->|"cluster_id (if applicable)"| Result

    style Input fill:#e1f5fe
    style Result fill:#e8f5e9
```

### 7.2 Pipeline Orchestrator

```python
# app/ai/pipeline.py
@dataclass
class ClassificationResult:
    language: str                           # "ta", "en", "mixed"
    category: str                           # e.g., "road_damage"
    category_confidence: float              # 0.0 – 1.0
    priority: str                           # "low", "medium", "high", "critical"
    priority_reasoning: str                 # Human-readable explanation
    department_id: UUID                     # Recommended department
    department_confidence: float
    summary: str                            # Extractive summary
    potential_duplicates: list[DuplicateMatch]  # Similar existing complaints
    cluster_id: UUID | None                 # Geographic cluster, if any

class AIPipeline:
    def __init__(self):
        self.language_detector = LanguageDetector()
        self.preprocessor = TextPreprocessor()
        self.classifier = CategoryClassifier()
        self.priority_detector = PriorityDetector()
        self.department_recommender = DepartmentRecommender()
        self.duplicate_detector = DuplicateDetector()
        self.summarizer = Summarizer()
        self.hotspot_analyzer = HotspotAnalyzer()

    async def classify(
        self, text: str, lat: float | None, lng: float | None
    ) -> ClassificationResult:
        lang = self.language_detector.detect(text)
        cleaned = self.preprocessor.process(text, lang)
        category, cat_conf = self.classifier.classify(cleaned, lang)
        priority, reasoning = self.priority_detector.assess(cleaned, category, lang)
        dept_id, dept_conf = await self.department_recommender.recommend(category)
        duplicates = await self.duplicate_detector.find(cleaned, lat, lng)
        summary = self.summarizer.summarize(text, lang)
        cluster_id = await self.hotspot_analyzer.assign_cluster(lat, lng, category)

        return ClassificationResult(
            language=lang,
            category=category,
            category_confidence=cat_conf,
            priority=priority,
            priority_reasoning=reasoning,
            department_id=dept_id,
            department_confidence=dept_conf,
            summary=summary,
            potential_duplicates=duplicates,
            cluster_id=cluster_id,
        )
```

### 7.3 Component Details

#### Language Detector

| Aspect | Detail |
|---|---|
| **Approach** | `langdetect` library + custom Tamil Unicode range check (U+0B80–U+0BFF) |
| **Outputs** | `"ta"` (Tamil), `"en"` (English), `"mixed"` (both scripts detected) |
| **Fallback** | Defaults to `"en"` if detection confidence < 0.5 |
| **Mixed Handling** | Tanglish (Tamil written in Latin script) detected via keyword dictionary |

```python
class LanguageDetector:
    TAMIL_RANGE = range(0x0B80, 0x0C00)

    def detect(self, text: str) -> str:
        tamil_chars = sum(1 for c in text if ord(c) in self.TAMIL_RANGE)
        total_alpha = sum(1 for c in text if c.isalpha())

        if total_alpha == 0:
            return "en"

        tamil_ratio = tamil_chars / total_alpha
        if tamil_ratio > 0.5:
            return "ta"
        elif tamil_ratio > 0.1:
            return "mixed"
        return "en"
```

#### Text Preprocessor

| Aspect | Detail |
|---|---|
| **English** | Lowercase → remove URLs/emails → remove punctuation → tokenize → stopword removal (NLTK) → lemmatize (WordNet) |
| **Tamil** | Unicode normalization (NFC) → remove punctuation (preserving Tamil chars) → tokenize on whitespace → Tamil stopword removal (custom list) |
| **Mixed** | Split into script-specific segments → process each → recombine |

#### Category Classifier

| Aspect | Detail |
|---|---|
| **Algorithm** | TF-IDF vectorizer + Linear SVM (sklearn) |
| **Training Data** | Curated civic complaint corpus (~5,000+ labeled examples) |
| **Categories** | `road_damage`, `water_supply`, `sewage`, `garbage`, `streetlight`, `encroachment`, `noise`, `drainage`, `public_safety`, `other` |
| **Tamil Support** | Option A: Translate-then-classify (Google Translate API). Option B: Multilingual TF-IDF with mixed corpus |
| **Confidence** | SVM's `decision_function` normalized to 0–1 via Platt scaling |
| **Retraining** | Periodic batch retraining with newly labeled data; model versioning |

> [!TIP]
> The classifier starts with a modest labeled dataset and improves over time as admin-corrected classifications feed back into training data. Track accuracy per category in the admin dashboard.

#### Priority Detector

| Aspect | Detail |
|---|---|
| **Approach** | **Rule-based heuristics** enhanced with keyword severity scoring |
| **Not ML** | Explicitly heuristic — no trained model. Deterministic and auditable |
| **Keyword Banks** | Critical: `"collapse"`, `"flood"`, `"fire"`, `"sewage overflow"`, `"accident"` |
| | High: `"broken pipe"`, `"no water"`, `"road cave-in"`, `"dangerous"` |
| | Medium: `"pothole"`, `"garbage dump"`, `"dim streetlight"` |
| | Low: `"suggestion"`, `"improvement"`, `"request"`, `"paint"` |
| **Modifiers** | Category-inherent risk (sewage > streetlight), keyword match count, location proximity to schools/hospitals |
| **Output** | Priority level + human-readable reasoning string |

```python
class PriorityDetector:
    def assess(self, text: str, category: str, lang: str) -> tuple[str, str]:
        score = 0.0
        reasons = []

        # Category-inherent risk
        category_weights = {
            "sewage": 0.4, "water_supply": 0.3, "public_safety": 0.5,
            "road_damage": 0.3, "drainage": 0.3, "garbage": 0.2,
            "streetlight": 0.2, "noise": 0.1, "encroachment": 0.15,
        }
        score += category_weights.get(category, 0.1)

        # Keyword severity scan
        for keyword, weight in self.critical_keywords:
            if keyword in text.lower():
                score += weight
                reasons.append(f"Critical keyword detected: '{keyword}'")

        # Map score to priority
        if score >= 0.8:
            return "critical", "; ".join(reasons) or "High-severity category with critical indicators"
        elif score >= 0.5:
            return "high", "; ".join(reasons) or "Elevated severity indicators"
        elif score >= 0.3:
            return "medium", "; ".join(reasons) or "Standard priority"
        return "low", "No elevated severity indicators detected"
```

#### Department Recommender

| Aspect | Detail |
|---|---|
| **Primary** | Static category → department mapping table |
| **Refinement** | Historical assignment corrections create weighted overrides |
| **Ambiguity** | When category confidence < 0.6, returns top-2 recommendations for admin review |
| **Data Source** | `departments` table seeded with Tamil Nadu civic department structure |

#### Duplicate Detector

| Aspect | Detail |
|---|---|
| **Embeddings** | Sentence-BERT (`all-MiniLM-L6-v2` — 80MB, fast) |
| **Similarity** | Cosine similarity threshold ≥ 0.80 |
| **Spatial Filter** | Only compare within 500m radius (PostGIS `ST_DWithin`) |
| **Time Window** | Only compare complaints from last 30 days |
| **Output** | List of `{complaint_id, similarity_score, distance_m}` |
| **Performance** | Pre-computed embeddings stored in DB; index with pgvector extension |

#### Summarizer

| Aspect | Detail |
|---|---|
| **Algorithm** | Extractive summarization using TextRank (graph-based sentence ranking) |
| **Not Generative** | No LLM — extracts the most representative sentences from the complaint text |
| **Max Length** | 2 sentences or 100 words, whichever is shorter |
| **Tamil** | Sentence segmentation on `।` and `.` characters; TextRank on sentence graph |

#### Hotspot Analyzer

| Aspect | Detail |
|---|---|
| **Algorithm** | DBSCAN (Density-Based Spatial Clustering of Applications with Noise) |
| **Parameters** | `eps` = 200m, `min_samples` = 5 complaints |
| **Weighting** | Recent complaints weighted higher; critical/high priority weighted 2× |
| **Update Frequency** | Re-clustered every 6 hours via background job |
| **Output** | Cluster ID, centroid coordinates, complaint count, dominant category |
| **Storage** | `geographic_issue_clusters` table with PostGIS geometry columns |

---

## 8. Error Handling Strategy

### 8.1 Custom Exception Hierarchy

```mermaid
classDiagram
    class AppException {
        +int status_code
        +str error_code
        +str message
        +dict details
    }

    class AuthenticationError {
        +status_code = 401
        +error_code = "AUTHENTICATION_ERROR"
    }

    class AuthorizationError {
        +status_code = 403
        +error_code = "AUTHORIZATION_ERROR"
    }

    class NotFoundError {
        +status_code = 404
        +error_code = "NOT_FOUND"
    }

    class ValidationError {
        +status_code = 422
        +error_code = "VALIDATION_ERROR"
        +list field_errors
    }

    class ConflictError {
        +status_code = 409
        +error_code = "CONFLICT"
    }

    class RateLimitError {
        +status_code = 429
        +error_code = "RATE_LIMIT_EXCEEDED"
        +int retry_after
    }

    class ExternalServiceError {
        +status_code = 502
        +error_code = "EXTERNAL_SERVICE_ERROR"
    }

    AppException <|-- AuthenticationError
    AppException <|-- AuthorizationError
    AppException <|-- NotFoundError
    AppException <|-- ValidationError
    AppException <|-- ConflictError
    AppException <|-- RateLimitError
    AppException <|-- ExternalServiceError
```

### 8.2 Consistent Error Response Format

Every error response follows this structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Request validation failed",
    "details": {
      "fields": [
        {
          "field": "phone",
          "message": "Phone number must be 10 digits",
          "value": "12345"
        },
        {
          "field": "ward_number",
          "message": "Ward number must be between 1 and 100",
          "value": 0
        }
      ]
    }
  },
  "request_id": "req_a1b2c3d4"
}
```

### 8.3 Global Exception Handler

```python
# app/middleware/error_handler.py
from fastapi import Request
from fastapi.responses import JSONResponse
from app.core.exceptions import AppException

async def global_exception_handler(request: Request, call_next):
    try:
        response = await call_next(request)
        return response
    except AppException as e:
        return JSONResponse(
            status_code=e.status_code,
            content={
                "error": {
                    "code": e.error_code,
                    "message": e.message,
                    "details": e.details,
                },
                "request_id": request.state.request_id,
            },
        )
    except Exception as e:
        logger.exception("Unhandled exception", request_id=request.state.request_id)
        return JSONResponse(
            status_code=500,
            content={
                "error": {
                    "code": "INTERNAL_ERROR",
                    "message": "An unexpected error occurred",
                    "details": {},
                },
                "request_id": request.state.request_id,
            },
        )
```

### 8.4 HTTP Status Code Usage

| Status | Meaning | When Used |
|---|---|---|
| `200` | OK | Successful GET, PUT, PATCH |
| `201` | Created | Successful POST creating a resource |
| `204` | No Content | Successful DELETE |
| `400` | Bad Request | Malformed request body |
| `401` | Unauthorized | Missing or invalid JWT |
| `403` | Forbidden | Valid JWT but insufficient role |
| `404` | Not Found | Resource does not exist |
| `409` | Conflict | Duplicate resource (e.g., phone already registered) |
| `422` | Unprocessable Entity | Pydantic validation failure |
| `429` | Too Many Requests | Rate limit exceeded |
| `500` | Internal Server Error | Unhandled exception (never leak details) |
| `502` | Bad Gateway | External service (S3, FCM) failure |

---

## 9. Testing Strategy

### 9.1 Testing Pyramid

```mermaid
flowchart TD
    subgraph E2E["E2E Tests (few)"]
        E1["Full API flow: register → login → create complaint → verify"]
    end
    subgraph Integration["Integration Tests (moderate)"]
        I1["API route → service → repository → test DB"]
        I2["AI pipeline with sample data"]
    end
    subgraph Unit["Unit Tests (many)"]
        U1["Service logic with mocked repos"]
        U2["Schema validation edge cases"]
        U3["AI components individually"]
        U4["Utility functions"]
    end

    E2E ~~~ Integration
    Integration ~~~ Unit

    style E2E fill:#ffcdd2
    style Integration fill:#fff9c4
    style Unit fill:#c8e6c9
```

### 9.2 Test Infrastructure

| Component | Tool | Purpose |
|---|---|---|
| **Runner** | `pytest` + `pytest-asyncio` | Async test execution |
| **HTTP Client** | `httpx.AsyncClient` | Async API call testing |
| **Fixtures** | `conftest.py` with `pytest` fixtures | Shared test setup |
| **Factories** | `factory_boy` + `faker` | Realistic test data generation |
| **Database** | Separate PostgreSQL (CI) / SQLite async (local unit) | Isolated test data |
| **Coverage** | `pytest-cov` | Minimum 80% line coverage |
| **Mocking** | `unittest.mock` / `pytest-mock` | External service isolation |

### 9.3 Key Test Fixtures

```python
# app/tests/conftest.py
import pytest
from httpx import AsyncClient, ASGITransport
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession

@pytest.fixture
async def test_db():
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)
    async with AsyncSession(engine) as session:
        yield session
    await engine.dispose()

@pytest.fixture
async def client(test_db):
    app.dependency_overrides[get_db] = lambda: test_db
    async with AsyncClient(
        transport=ASGITransport(app=app),
        base_url="http://test"
    ) as ac:
        yield ac
    app.dependency_overrides.clear()

@pytest.fixture
async def auth_headers(client):
    """Register + login, return auth headers."""
    await client.post("/api/v1/auth/register", json={
        "phone": "9876543210", "password": "Test@1234",
        "full_name": "Test User", "ward_number": 1,
    })
    response = await client.post("/api/v1/auth/login", json={
        "phone": "9876543210", "password": "Test@1234",
    })
    token = response.json()["access_token"]
    return {"Authorization": f"Bearer {token}"}
```

### 9.4 Test Example

```python
# app/tests/test_complaints.py
@pytest.mark.asyncio
async def test_create_complaint(client, auth_headers):
    response = await client.post(
        "/api/v1/complaints",
        headers=auth_headers,
        json={
            "title": "Broken streetlight on Anna Nagar 3rd street",
            "description": "The streetlight near house #42 has been broken for a week.",
            "category": "streetlight",
            "latitude": 13.0827,
            "longitude": 80.2707,
            "ward_number": 15,
        },
    )
    assert response.status_code == 201
    data = response.json()
    assert data["status"] == "submitted"
    assert data["tracking_id"] is not None
    assert "id" in data
```

---

## 10. Configuration Management

### 10.1 Pydantic Settings

```python
# app/core/config.py
from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
    )

    # Application
    APP_NAME: str = "Namma Ooru AI"
    APP_VERSION: str = "1.0.0"
    DEBUG: bool = False
    ENVIRONMENT: str = "production"  # development | testing | production

    # Server
    HOST: str = "0.0.0.0"
    PORT: int = 8000
    WORKERS: int = 4

    # Database
    DATABASE_URL: str
    DB_POOL_SIZE: int = 20
    DB_MAX_OVERFLOW: int = 10
    DB_POOL_TIMEOUT: int = 30

    # JWT
    JWT_SECRET_KEY: str
    JWT_ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 15
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Object Storage
    S3_ENDPOINT_URL: str = "http://localhost:9000"
    S3_ACCESS_KEY: str
    S3_SECRET_KEY: str
    S3_BUCKET_NAME: str = "namma-ooru-uploads"
    S3_REGION: str = "ap-south-1"
    PRESIGNED_URL_EXPIRY: int = 3600  # seconds

    # Rate Limiting
    RATE_LIMIT_ENABLED: bool = True
    RATE_LIMIT_DEFAULT_RPM: int = 60

    # CORS
    CORS_ORIGINS: list[str] = ["http://localhost:3000"]

    # Notifications (FCM)
    FCM_SERVICE_ACCOUNT_PATH: str = ""

    # AI Pipeline
    AI_MODEL_DIR: str = "./app/ai/models"
    DUPLICATE_SIMILARITY_THRESHOLD: float = 0.80
    DUPLICATE_RADIUS_METERS: int = 500
    HOTSPOT_CLUSTER_EPS_METERS: int = 200
    HOTSPOT_MIN_SAMPLES: int = 5

settings = Settings()
```

### 10.2 Environment-Specific Configuration

| Setting | Development | Testing | Production |
|---|---|---|---|
| `DEBUG` | `true` | `true` | `false` |
| `DATABASE_URL` | `postgresql+asyncpg://dev:dev@localhost/namma_dev` | `sqlite+aiosqlite:///:memory:` | `postgresql+asyncpg://...@rds/namma_prod` |
| `S3_ENDPOINT_URL` | `http://localhost:9000` (MinIO) | `http://localhost:9000` (MinIO) | `https://s3.ap-south-1.amazonaws.com` |
| `CORS_ORIGINS` | `["http://localhost:3000"]` | `["http://test"]` | `["https://nammaooru.ai"]` |
| `RATE_LIMIT_ENABLED` | `false` | `false` | `true` |
| `WORKERS` | `1` | `1` | `4` |
| `LOG_LEVEL` | `DEBUG` | `WARNING` | `INFO` |

### 10.3 `.env.example`

```env
# Application
APP_NAME="Namma Ooru AI"
ENVIRONMENT=development
DEBUG=true

# Database
DATABASE_URL=postgresql+asyncpg://namma:secret@localhost:5432/namma_ooru_dev

# JWT (generate with: openssl rand -hex 32)
JWT_SECRET_KEY=change-me-to-a-random-64-char-hex-string
JWT_ALGORITHM=HS256
ACCESS_TOKEN_EXPIRE_MINUTES=15
REFRESH_TOKEN_EXPIRE_DAYS=7

# Object Storage (MinIO for development)
S3_ENDPOINT_URL=http://localhost:9000
S3_ACCESS_KEY=minioadmin
S3_SECRET_KEY=minioadmin
S3_BUCKET_NAME=namma-ooru-uploads

# CORS
CORS_ORIGINS=["http://localhost:3000","http://localhost:5173"]

# Notifications
FCM_SERVICE_ACCOUNT_PATH=./firebase-service-account.json

# Rate Limiting
RATE_LIMIT_ENABLED=false
```

> [!CAUTION]
> **Never commit `.env` files to version control.** The `.env.example` file serves as a template. All secrets — `JWT_SECRET_KEY`, `S3_SECRET_KEY`, database passwords — must be injected via environment variables in CI/CD and production.

---

## 11. Object Storage

### 11.1 Architecture

```mermaid
flowchart LR
    Client["Client App"]
    API["FastAPI Upload Endpoint"]
    VS["Validation Service"]
    US["Upload Service"]
    Store["Object Storage<br/>(MinIO / S3)"]
    DB["PostgreSQL<br/>(Attachment metadata)"]

    Client -->|"multipart/form-data"| API
    API --> VS
    VS -->|"validate type + size"| US
    US -->|"PUT object"| Store
    US -->|"INSERT attachment record"| DB

    Client2["Client App"] -->|"GET /files/{id}"| API2["FastAPI File Endpoint"]
    API2 -->|"query"| DB
    DB -->|"object key"| API2
    API2 -->|"generate presigned URL"| Store
    Store -->|"presigned URL"| API2
    API2 -->|"302 redirect or JSON"| Client2
```

### 11.2 File Validation Rules

| Rule | Value | Rationale |
|---|---|---|
| **Allowed Types** | `image/jpeg`, `image/png`, `image/webp`, `video/mp4`, `application/pdf` | Only complaint-relevant file types |
| **Max File Size** | Images: 10 MB, Videos: 50 MB, PDFs: 5 MB | Prevent storage abuse |
| **Max Files per Complaint** | 5 | Reasonable evidence limit |
| **Filename Sanitization** | UUID-based keys; original name stored in metadata | Prevent path traversal attacks |
| **Content Verification** | Magic byte check (not just MIME from header) | Prevent disguised executables |

### 11.3 Upload Service Implementation

```python
# app/services/upload_service.py
class UploadService:
    ALLOWED_TYPES = {
        "image/jpeg": ".jpg", "image/png": ".png", "image/webp": ".webp",
        "video/mp4": ".mp4", "application/pdf": ".pdf",
    }
    MAX_SIZES = {
        "image": 10 * 1024 * 1024,   # 10 MB
        "video": 50 * 1024 * 1024,   # 50 MB
        "application": 5 * 1024 * 1024,  # 5 MB
    }

    async def upload(
        self, file: UploadFile, complaint_id: UUID, user_id: UUID
    ) -> Attachment:
        # 1. Validate content type
        if file.content_type not in self.ALLOWED_TYPES:
            raise ValidationError(f"File type '{file.content_type}' not allowed")

        # 2. Validate file size
        content = await file.read()
        media_type = file.content_type.split("/")[0]
        if len(content) > self.MAX_SIZES.get(media_type, 5 * 1024 * 1024):
            raise ValidationError("File exceeds maximum allowed size")

        # 3. Verify magic bytes
        if not self._verify_magic_bytes(content, file.content_type):
            raise ValidationError("File content does not match declared type")

        # 4. Generate storage key
        ext = self.ALLOWED_TYPES[file.content_type]
        object_key = f"complaints/{complaint_id}/{uuid4()}{ext}"

        # 5. Upload to S3/MinIO
        await self.s3_client.put_object(
            Bucket=settings.S3_BUCKET_NAME,
            Key=object_key,
            Body=content,
            ContentType=file.content_type,
        )

        # 6. Store metadata in DB
        attachment = Attachment(
            complaint_id=complaint_id,
            uploaded_by=user_id,
            original_filename=file.filename,
            object_key=object_key,
            content_type=file.content_type,
            size_bytes=len(content),
        )
        return await self.repo.create(attachment)

    async def get_presigned_url(self, object_key: str) -> str:
        return await self.s3_client.generate_presigned_url(
            "get_object",
            Params={"Bucket": settings.S3_BUCKET_NAME, "Key": object_key},
            ExpiresIn=settings.PRESIGNED_URL_EXPIRY,
        )
```

### 11.4 Storage Organization

```
namma-ooru-uploads/                   (S3 bucket)
├── complaints/
│   ├── {complaint_uuid}/
│   │   ├── {file_uuid}.jpg           (complaint photos)
│   │   ├── {file_uuid}.mp4           (complaint videos)
│   │   └── {file_uuid}.pdf           (supporting documents)
│   └── ...
├── profiles/
│   ├── {user_uuid}/
│   │   └── avatar.jpg                (profile pictures)
│   └── ...
└── announcements/
    ├── {announcement_uuid}/
    │   └── {file_uuid}.jpg           (announcement images)
    └── ...
```

### 11.5 Environment Parity

| Feature | Development (MinIO) | Production (AWS S3) |
|---|---|---|
| **API** | S3-compatible | Native S3 |
| **Endpoint** | `http://localhost:9000` | `https://s3.ap-south-1.amazonaws.com` |
| **Auth** | Access key + secret | IAM role (EC2/ECS) or access key |
| **Encryption** | Optional | SSE-S3 (AES-256) enabled |
| **Lifecycle** | Manual | Auto-delete after 1 year for resolved complaints |
| **CDN** | None | CloudFront (optional, for public announcements) |

---

## 12. API Versioning Strategy

All routes are prefixed with `/api/v1/`. This allows future breaking changes to be introduced under `/api/v2/` while maintaining backward compatibility.

```python
# app/main.py
from app.api.v1.router import v1_router

app = FastAPI(title="Namma Ooru AI", version="1.0.0")
app.include_router(v1_router, prefix="/api/v1")
```

```python
# app/api/v1/router.py
from fastapi import APIRouter
from app.api.v1 import auth, users, complaints, uploads, ai, admin, officers, maps, notifications, announcements

v1_router = APIRouter()
v1_router.include_router(auth.router, prefix="/auth", tags=["Authentication"])
v1_router.include_router(users.router, prefix="/users", tags=["Users"])
v1_router.include_router(complaints.router, prefix="/complaints", tags=["Complaints"])
v1_router.include_router(uploads.router, prefix="/uploads", tags=["Uploads"])
v1_router.include_router(ai.router, prefix="/ai", tags=["AI Classification"])
v1_router.include_router(admin.router, prefix="/admin", tags=["Admin"])
v1_router.include_router(officers.router, prefix="/officers", tags=["Field Officers"])
v1_router.include_router(maps.router, prefix="/maps", tags=["Maps"])
v1_router.include_router(notifications.router, prefix="/notifications", tags=["Notifications"])
v1_router.include_router(announcements.router, prefix="/announcements", tags=["Announcements"])
```

---

## 13. Database Session Management

```python
# app/database/session.py
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker,
)
from app.core.config import settings

engine = create_async_engine(
    settings.DATABASE_URL,
    pool_size=settings.DB_POOL_SIZE,
    max_overflow=settings.DB_MAX_OVERFLOW,
    pool_timeout=settings.DB_POOL_TIMEOUT,
    pool_pre_ping=True,           # Verify connections before use
    echo=settings.DEBUG,          # SQL logging in debug mode
)

AsyncSessionLocal = async_sessionmaker(
    bind=engine,
    class_=AsyncSession,
    expire_on_commit=False,       # Avoid lazy-load issues in async
)
```

### Application Lifespan

```python
# app/main.py
from contextlib import asynccontextmanager

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    logger.info("Initializing database connection pool...")
    await init_db(engine)
    logger.info("Loading AI models...")
    ai_pipeline = AIPipeline()
    await ai_pipeline.load_models()
    app.state.ai_pipeline = ai_pipeline
    yield
    # Shutdown
    logger.info("Disposing database engine...")
    await engine.dispose()

app = FastAPI(title="Namma Ooru AI", lifespan=lifespan)
```

> [!WARNING]
> Always use `expire_on_commit=False` with async sessions. Without this, accessing model attributes after commit triggers implicit lazy loads, which are not supported in async SQLAlchemy and will raise `MissingGreenlet` errors.
