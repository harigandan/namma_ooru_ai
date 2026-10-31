# System Architecture — Namma Ooru AI

> **Version:** 1.0
> **Last Updated:** 2026-10-31
> **Status:** Living Document

---

## Table of Contents

1. [System Overview](#1-system-overview)
2. [High-Level Architecture](#2-high-level-architecture)
3. [Technology Stack](#3-technology-stack)
4. [Deployment Architecture](#4-deployment-architecture)
5. [Security Architecture](#5-security-architecture)
6. [Data Flow Diagrams](#6-data-flow-diagrams)
7. [Scalability Considerations](#7-scalability-considerations)
8. [Integration Points](#8-integration-points)
9. [Development vs Production Environments](#9-development-vs-production-environments)

---

## 1. System Overview

**Namma Ooru AI** (_"Our City AI"_ in Tamil) is an AI-powered smart civic governance platform purpose-built for municipalities across Tamil Nadu. It bridges the gap between citizens and local government by providing an intelligent, transparent, and multilingual system for civic complaint management, infrastructure tracking, and municipal service delivery.

### 1.1 Mission

Empower every citizen — regardless of language, literacy level, or technical ability — to participate in local governance, while giving municipal administrators the data-driven tools they need to respond efficiently and allocate resources wisely.

### 1.2 Target Users

| Persona | Description | Primary Interface |
|---|---|---|
| **Citizens** | Residents of Tamil Nadu municipalities who report civic issues (potholes, garbage, water supply, streetlights, etc.) and track resolution progress. | Mobile App (Android / iOS) |
| **Municipal Administrators** | Ward-level and city-level officials who triage, assign, and oversee complaint resolution. Access dashboards, analytics, and AI-generated insights. | Web App + Mobile App |
| **Field Officers** | On-the-ground maintenance crews and inspectors who receive assignments, update work status, and upload evidence of resolution. | Mobile App |
| **Department Heads** | Senior officials who monitor aggregate performance, review hotspot analyses, and make policy decisions. | Web App |

### 1.3 Key Capabilities

- **Multilingual Complaint Submission** — Text (Tamil & English), voice (Speech-to-Text), and photo-based reporting.
- **AI-Powered Categorization** — Automatic classification of complaints into departments and priority levels using NLP.
- **Duplicate & Similarity Detection** — Semantic similarity analysis to cluster related complaints and avoid redundant work.
- **Geospatial Hotspot Analysis** — DBSCAN clustering on PostGIS data to surface problem areas on the map.
- **Real-Time Tracking** — Citizens see live status updates; administrators see SLA compliance dashboards.
- **Push Notifications** — Firebase Cloud Messaging keeps all stakeholders informed at every status transition.
- **Role-Based Access Control** — Fine-grained permissions ensure data visibility is appropriate to each user's role.
- **Offline-First Mobile** — Core flows work without connectivity; syncs automatically when back online.

---

## 2. High-Level Architecture

The platform follows a **layered client-server architecture** with a clear separation between presentation, API, processing, and data layers.

```mermaid
flowchart TD
    subgraph Clients["Client Layer"]
        MobileApp["📱 Flutter Mobile App\n(Android / iOS)"]
        WebApp["🖥️ Flutter Web App\n(Admin Dashboard)"]
    end

    subgraph Gateway["API & Edge Layer"]
        Nginx["Nginx Reverse Proxy\n(SSL Termination, Rate Limiting)"]
        API["FastAPI Backend\n(REST API, WebSocket)"]
    end

    subgraph Processing["AI / ML Processing Layer"]
        NLP["Tamil NLP Pipeline\n(spaCy, langdetect)"]
        Classifier["Complaint Classifier\n(scikit-learn)"]
        Similarity["Semantic Similarity\n(Sentence Transformers)"]
        Hotspot["Hotspot Analyzer\n(DBSCAN + PostGIS)"]
    end

    subgraph DataLayer["Data & Storage Layer"]
        PG["PostgreSQL 16\n+ PostGIS 3.4"]
        Redis["Redis\n(Cache, Rate Limiting)"]
        MinIO["MinIO / S3\n(Object Storage)"]
    end

    subgraph External["External Services"]
        FCM["Firebase Cloud Messaging\n(Push Notifications)"]
        STT["Speech-to-Text\n(Google / Azure)"]
        SMS["SMS Gateway\n(Configurable Provider)"]
        Email["Email Service\n(SMTP)"]
        OSM["OpenStreetMap\n(Tile Server / Geocoding)"]
    end

    MobileApp -->|"HTTPS / REST"| Nginx
    WebApp -->|"HTTPS / REST"| Nginx
    Nginx -->|"Proxy Pass"| API

    API --> NLP
    API --> Classifier
    API --> Similarity
    API --> Hotspot

    API -->|"SQLAlchemy"| PG
    API -->|"Cache / Sessions"| Redis
    API -->|"File Upload / Download"| MinIO

    API -->|"Push"| FCM
    API -->|"Transcription"| STT
    API -->|"Alerts"| SMS
    API -->|"Notifications"| Email

    MobileApp -->|"Map Tiles"| OSM
    WebApp -->|"Map Tiles"| OSM
```

### 2.1 Layer Responsibilities

| Layer | Responsibility |
|---|---|
| **Client** | UI rendering, local state, offline queue, map display, camera/mic access |
| **API & Edge** | Authentication, authorization, request validation, routing, SSL termination |
| **AI / ML Processing** | Language detection, complaint classification, duplicate detection, spatial clustering |
| **Data & Storage** | Persistent relational data, geospatial queries, binary object storage, ephemeral cache |
| **External Services** | Push delivery, voice transcription, SMS/email dispatch, map tile serving |

---

## 3. Technology Stack

### 3.1 Frontend

| Component | Technology | Purpose |
|---|---|---|
| Framework | **Flutter 3.x** (Dart 3.x) | Cross-platform mobile + web from a single codebase |
| Design System | **Material 3** | Consistent, accessible UI with dynamic theming |
| State Management | **Riverpod 2.x** | Compile-safe, testable reactive state |
| Navigation | **GoRouter** | Declarative, deep-link-aware routing |
| HTTP Client | **Dio** | Interceptors for auth tokens, retry logic, logging |
| Data Models | **Freezed + json_serializable** | Immutable models with union types and JSON codegen |
| Secure Storage | **flutter_secure_storage** | Encrypted storage for JWT tokens and sensitive config |
| Maps | **flutter_map** | OpenStreetMap-based mapping with custom tile layers |
| Localization | **flutter_localizations + ARB** | Tamil / English i18n |
| Image Handling | **image_picker, image_cropper** | Camera capture and photo preprocessing |
| Audio | **record, just_audio** | Voice complaint recording and playback |

### 3.2 Backend

| Component | Technology | Purpose |
|---|---|---|
| Language | **Python 3.15** | Modern Python with latest typing and performance features |
| Framework | **FastAPI 0.115+** | Async REST API with automatic OpenAPI docs |
| ORM | **SQLAlchemy 2.x** | Async ORM with 2.0-style query API |
| Validation | **Pydantic v2** | Request/response validation with high performance |
| Migrations | **Alembic** | Version-controlled database schema migrations |
| Authentication | **python-jose (JWT)** | Access token (15 min) + refresh token (7 day) flow |
| Password Hashing | **passlib[bcrypt]** | Industry-standard bcrypt hashing |
| ASGI Server | **Uvicorn** | High-performance async server with `--workers` support |
| Task Processing | **In-process async** (v1); **Celery** (future) | Background AI/ML processing |
| File Handling | **python-multipart, Pillow** | Multipart uploads, image validation and thumbnailing |
| Testing | **pytest, pytest-asyncio, httpx** | Async-aware test suite with ASGI transport |

### 3.3 Database

| Component | Technology | Purpose |
|---|---|---|
| RDBMS | **PostgreSQL 16** | Primary relational data store |
| Geospatial | **PostGIS 3.4** | Spatial indexing, distance queries, geometry operations |
| Primary Keys | **UUID v4** | Non-sequential, globally unique identifiers |
| Schema Design | **Fully normalized (3NF+)** | Referential integrity with foreign keys and constraints |
| Indexing | **B-tree, GiST, GIN** | Optimized for text search, spatial queries, and lookups |
| Connection Pooling | **SQLAlchemy async pool / PgBouncer** | Efficient connection reuse |

### 3.4 AI / ML

| Component | Technology | Purpose |
|---|---|---|
| Classification | **scikit-learn** | Complaint category and priority prediction (SVM/Random Forest) |
| NLP | **spaCy** | Tokenization, NER, and text preprocessing |
| Language Detection | **langdetect** | Identify Tamil vs English vs mixed-code input |
| Semantic Similarity | **Sentence Transformers** | Embed complaints for duplicate/cluster detection |
| Spatial Clustering | **DBSCAN (scikit-learn) + PostGIS** | Identify geographic complaint hotspots |
| Tamil NLP | **Custom Pipeline** | Tamil-specific tokenizer, stopword removal, transliteration normalization |

### 3.5 Infrastructure

| Component | Technology | Purpose |
|---|---|---|
| Containerization | **Docker & Docker Compose** | Reproducible, isolated service deployment |
| Reverse Proxy | **Nginx** | SSL termination, static file serving, load balancing |
| Object Storage | **MinIO** (dev/small) / **S3** (prod) | Photos, audio files, attachments |
| Caching | **Redis 7** | Response caching, rate-limit counters, session store |
| Monitoring | **Prometheus + Grafana** (future) | Metrics collection and visualization |
| Logging | **Structured JSON logs → stdout** | Container-native log aggregation |

---

## 4. Deployment Architecture

The production deployment uses Docker Compose orchestration behind an Nginx edge proxy.

```mermaid
flowchart LR
    Internet["🌐 Internet"] -->|"HTTPS :443"| LB["Load Balancer\n(Cloud / HAProxy)"]

    LB --> Nginx["Nginx\n(SSL Termination\nStatic Assets\nRate Limiting)"]

    Nginx -->|":8000"| API1["FastAPI Worker 1"]
    Nginx -->|":8001"| API2["FastAPI Worker 2"]
    Nginx -->|":8002"| API3["FastAPI Worker N"]

    API1 --> PG["PostgreSQL 16\n+ PostGIS 3.4"]
    API2 --> PG
    API3 --> PG

    API1 --> Redis["Redis 7\n(Cache / Rate Limit)"]
    API2 --> Redis
    API3 --> Redis

    API1 --> MinIO["MinIO\n(Object Storage)"]
    API2 --> MinIO
    API3 --> MinIO

    API1 -->|"HTTPS"| FCM["Firebase Cloud\nMessaging"]
    API2 -->|"HTTPS"| FCM
    API3 -->|"HTTPS"| FCM

    PG --> PGBackup["Automated\nBackups"]
    MinIO --> ObjBackup["Object\nBackups"]
```

### 4.1 Container Topology

| Container | Image | Ports | Replicas |
|---|---|---|---|
| `nginx` | `nginx:1.27-alpine` | 80, 443 (host) | 1 |
| `api` | Custom (Python 3.15 + FastAPI) | 8000 (internal) | 1–N (configurable) |
| `postgres` | `postgis/postgis:16-3.4` | 5432 (internal) | 1 |
| `redis` | `redis:7-alpine` | 6379 (internal) | 1 |
| `minio` | `minio/minio:latest` | 9000, 9001 (internal) | 1 |

### 4.2 Volume Mounts

| Volume | Mount Path | Purpose |
|---|---|---|
| `pg_data` | `/var/lib/postgresql/data` | Database persistence |
| `minio_data` | `/data` | Object storage persistence |
| `redis_data` | `/data` | Cache persistence (optional) |
| `nginx_certs` | `/etc/nginx/certs` | SSL/TLS certificates |
| `app_logs` | `/var/log/app` | Application log persistence |

---

## 5. Security Architecture

> [!IMPORTANT]
> Security is enforced at **every layer** — client, network, API, and database. No single point of failure protects the system.

### 5.1 Authentication

```
┌──────────────────────────────────────────────────────────────┐
│                    Token Lifecycle                            │
│                                                              │
│  Login ──► Access Token (JWT, 15 min)                        │
│            + Refresh Token (opaque, 7 days, DB-stored)       │
│                                                              │
│  On Expiry ──► Refresh endpoint ──► New Access Token         │
│                                     + Rotated Refresh Token  │
│                                     + Old Refresh Revoked    │
│                                                              │
│  Logout ──► Revoke all refresh tokens for session            │
└──────────────────────────────────────────────────────────────┘
```

| Mechanism | Detail |
|---|---|
| **Access Token** | JWT (HS256), 15-minute TTL, contains `user_id`, `role`, `iat`, `exp` |
| **Refresh Token** | Cryptographically random opaque string, 7-day TTL, stored in DB |
| **Refresh Rotation** | Every refresh issues a new pair; old refresh is immediately revoked |
| **Revocation** | Refresh tokens tracked in `refresh_tokens` table; revocation is instant |
| **Password Storage** | bcrypt with cost factor 12; never stored or logged in plaintext |

### 5.2 Authorization — Role-Based Access Control (RBAC)

| Role | Permissions |
|---|---|
| `citizen` | Create complaints, view own complaints, update own profile |
| `field_officer` | View assigned complaints, update status, upload resolution evidence |
| `admin` | View all complaints, assign/reassign, manage users, access analytics |
| `super_admin` | Full system access, manage roles, system configuration |

RBAC is enforced at the **API layer** via FastAPI dependency injection:

```python
# Pseudocode — role enforcement
@router.get("/admin/dashboard")
async def dashboard(current_user: User = Depends(require_role("admin"))):
    ...
```

### 5.3 Network & Transport Security

| Control | Implementation |
|---|---|
| **HTTPS Enforcement** | Nginx redirects all HTTP → HTTPS; HSTS header enabled |
| **CORS** | Allowlist of known origins; credentials mode restricted |
| **Rate Limiting** | Redis-backed sliding window; 100 req/min per IP (configurable) |
| **Request Size Limits** | Nginx `client_max_body_size` set to 10 MB |

### 5.4 Input Validation & Data Protection

| Control | Implementation |
|---|---|
| **Schema Validation** | Pydantic v2 models on every request body and query parameter |
| **File Upload Validation** | MIME type verification + magic-byte check; max size 5 MB per file |
| **SQL Injection Prevention** | Parameterized queries via SQLAlchemy ORM exclusively |
| **XSS Prevention** | No server-side HTML rendering; API returns JSON only |
| **Audit Logging** | All write operations logged with `user_id`, `timestamp`, `action`, `resource` |
| **Sensitive Data** | Passwords, tokens, and PII never appear in logs or error responses |

---

## 6. Data Flow Diagrams

### 6.1 Complaint Submission Flow

This is the primary user journey — a citizen submitting a civic complaint through the mobile app.

```mermaid
sequenceDiagram
    actor Citizen
    participant App as Flutter Mobile App
    participant API as FastAPI Backend
    participant STT as Speech-to-Text Service
    participant AI as AI/ML Pipeline
    participant DB as PostgreSQL + PostGIS
    participant Storage as MinIO / S3
    participant FCM as Firebase Cloud Messaging
    participant Admin as Admin Dashboard

    Citizen->>App: Open "New Complaint"
    Citizen->>App: Enter description (text or voice)
    Citizen->>App: Attach photo + GPS location

    alt Voice Input
        App->>API: Upload audio file
        API->>STT: Transcribe audio
        STT-->>API: Transcribed text (Tamil/English)
        API-->>App: Return transcription for review
        Citizen->>App: Confirm or edit transcription
    end

    App->>API: POST /complaints (text, photo, location)
    API->>API: Validate input (Pydantic)
    API->>Storage: Upload photo → get object URL
    Storage-->>API: Object URL

    API->>AI: Process complaint text
    AI->>AI: Detect language (langdetect)
    AI->>AI: Classify category & priority (scikit-learn)
    AI->>AI: Check duplicates (Sentence Transformers)
    AI-->>API: Category, Priority, Duplicate candidates

    alt Duplicate Found
        API-->>App: Suggest linking to existing complaint
        Citizen->>App: Confirm or override
    end

    API->>DB: INSERT complaint record
    DB-->>API: Complaint ID (UUID)

    API->>FCM: Notify ward admin (new complaint)
    FCM-->>Admin: Push notification

    API-->>App: 201 Created (complaint details)
    App-->>Citizen: "Complaint #ID submitted successfully"
```

### 6.2 Authentication Flow

Covers login, token refresh, and logout — the three core auth operations.

```mermaid
sequenceDiagram
    actor User
    participant App as Flutter App
    participant API as FastAPI Backend
    participant DB as PostgreSQL
    participant Redis as Redis Cache

    Note over User, Redis: === LOGIN FLOW ===

    User->>App: Enter phone/email + password
    App->>API: POST /auth/login {credentials}
    API->>DB: Lookup user by identifier
    DB-->>API: User record (hashed password)
    API->>API: Verify bcrypt hash

    alt Invalid Credentials
        API-->>App: 401 Unauthorized
        App-->>User: "Invalid credentials"
    end

    API->>DB: INSERT refresh_token record
    API-->>App: 200 OK {access_token, refresh_token}
    App->>App: Store tokens in Secure Storage

    Note over User, Redis: === TOKEN REFRESH FLOW ===

    App->>App: Access token expired (15 min)
    App->>API: POST /auth/refresh {refresh_token}
    API->>DB: Lookup refresh_token
    DB-->>API: Token record (valid, not revoked)

    alt Token Revoked or Expired
        API-->>App: 401 Unauthorized
        App-->>User: Redirect to login
    end

    API->>DB: Revoke old refresh_token
    API->>DB: INSERT new refresh_token
    API-->>App: 200 OK {new_access_token, new_refresh_token}
    App->>App: Replace tokens in Secure Storage

    Note over User, Redis: === LOGOUT FLOW ===

    User->>App: Tap "Logout"
    App->>API: POST /auth/logout {refresh_token}
    API->>DB: Revoke all refresh_tokens for session
    API->>Redis: Add access_token JTI to blacklist (TTL = remaining exp)
    API-->>App: 200 OK
    App->>App: Clear Secure Storage
    App-->>User: Redirect to login screen
```

### 6.3 Complaint Lifecycle State Machine

```mermaid
stateDiagram-v2
    [*] --> Submitted: Citizen submits
    Submitted --> UnderReview: Admin reviews
    UnderReview --> Assigned: Admin assigns to field officer
    UnderReview --> Rejected: Invalid/duplicate
    Assigned --> InProgress: Field officer starts work
    InProgress --> Resolved: Field officer marks complete
    Resolved --> Closed: Admin verifies resolution
    Resolved --> Reopened: Citizen disputes
    Reopened --> Assigned: Re-assigned
    Rejected --> [*]
    Closed --> [*]
```

---

## 7. Scalability Considerations

### 7.1 Current Architecture (v1)

| Dimension | Strategy |
|---|---|
| **Horizontal API Scaling** | Multiple Uvicorn workers behind Nginx; stateless API design allows adding containers freely |
| **Database Connection Pooling** | SQLAlchemy async pool (`pool_size=20`, `max_overflow=10`) prevents connection exhaustion |
| **Redis Caching** | Frequently-read data (ward lists, category trees, user profiles) cached with TTL to reduce DB load |
| **Object Storage** | MinIO/S3 handles binary assets outside the DB; CDN-ready presigned URLs |
| **Async I/O** | FastAPI's async endpoints ensure high concurrency on I/O-bound workloads (DB, HTTP, file) |

### 7.2 Future Scaling Path

| Milestone | Enhancement |
|---|---|
| **10K+ daily users** | Introduce **Celery + Redis** task queue for AI/ML processing to decouple from request cycle |
| **50K+ daily users** | Add **PostgreSQL read replicas** for analytics queries and dashboard reads |
| **100K+ daily users** | Deploy behind a **CDN** (CloudFront / Cloudflare) for static assets and map tile caching |
| **Multi-city rollout** | Evaluate **Kubernetes** orchestration for multi-node, auto-scaling deployments |
| **Real-time features** | Adopt **WebSocket** channels (FastAPI + Redis pub/sub) for live complaint tracking |

> [!TIP]
> The stateless API design and externalized session/cache (Redis) mean that horizontal scaling requires **zero code changes** — only infrastructure configuration.

---

## 8. Integration Points

### 8.1 Integration Map

| Service | Protocol | Direction | Auth | Purpose |
|---|---|---|---|---|
| **OpenStreetMap** | HTTPS (tile URL) | Outbound | None (public) | Map tile rendering in Flutter apps; Nominatim for reverse geocoding |
| **Firebase Cloud Messaging** | HTTPS (FCM v1 API) | Outbound | Service Account JSON | Push notifications to Android/iOS/Web clients |
| **Speech-to-Text** | HTTPS (REST / gRPC) | Outbound | API Key / OAuth2 | Transcribe Tamil/English voice complaints (Google Cloud STT or Azure) |
| **SMS Gateway** | HTTPS (REST) | Outbound | API Key | OTP delivery and status update SMS to citizens |
| **Email Service** | SMTP / HTTPS API | Outbound | SMTP credentials / API key | Account verification, password reset, admin reports |
| **MinIO / S3** | HTTPS (S3-compatible) | Bidirectional | Access Key + Secret | Upload complaint photos/audio; serve via presigned URLs |

### 8.2 Integration Design Principles

1. **Provider Abstraction** — Each external service is accessed through an **interface/adapter layer**. Swapping providers (e.g., Google STT → Azure STT) requires only a new adapter implementation, no business logic changes.
2. **Configuration-Driven** — Provider selection and credentials are managed via environment variables, not hardcoded.
3. **Graceful Degradation** — If a non-critical service (e.g., SMS) is unavailable, the core flow completes and the notification is queued for retry.
4. **Retry & Circuit Breaker** — External HTTP calls use exponential backoff retries with a circuit breaker pattern to avoid cascading failures.

---

## 9. Development vs Production Environments

### 9.1 Environment Matrix

| Aspect | Development | Production |
|---|---|---|
| **Database** | SQLite (in-memory or file) for rapid iteration; optional local PostgreSQL via Docker | PostgreSQL 16 + PostGIS 3.4 (managed or containerized) |
| **Object Storage** | Local MinIO container (`localhost:9000`) | AWS S3 or self-hosted MinIO cluster with replication |
| **Push Notifications** | Mock FCM adapter (logs to console) | Real Firebase Cloud Messaging with service account |
| **SMS Gateway** | Console logger (no real SMS sent) | Production SMS provider (MSG91, Twilio, etc.) |
| **Email** | MailHog / console backend | Production SMTP relay (SES, SendGrid, etc.) |
| **Speech-to-Text** | Pre-recorded fixture responses or local Whisper model | Google Cloud STT or Azure Cognitive Services |
| **Redis** | Optional; in-memory fallback or local container | Dedicated Redis 7 instance with persistence |
| **SSL/TLS** | Self-signed or HTTP-only (localhost) | Valid certificate via Let's Encrypt or CA |
| **Debug Mode** | FastAPI `--reload` enabled; verbose logging (DEBUG level) | Multi-worker Uvicorn; structured JSON logging (INFO level) |
| **CORS** | Permissive (`*`) for local development | Strict allowlist of production domains |
| **Rate Limiting** | Disabled or very high limits | Enforced (100 req/min per IP, configurable) |
| **AI/ML Models** | Smaller/faster models; optional model mocking | Full-size production-trained models |

### 9.2 Environment Configuration

All environment-specific values are managed through a single `.env` file (never committed to version control) and loaded via Pydantic `BaseSettings`:

```
# .env (example)
ENVIRONMENT=development|production
DATABASE_URL=postgresql+asyncpg://user:pass@host:5432/namma_ooru
REDIS_URL=redis://localhost:6379/0
MINIO_ENDPOINT=localhost:9000
MINIO_ACCESS_KEY=minioadmin
MINIO_SECRET_KEY=minioadmin
FCM_SERVICE_ACCOUNT_PATH=/secrets/firebase.json
JWT_SECRET_KEY=<random-256-bit-key>
CORS_ORIGINS=["http://localhost:3000"]
```

> [!CAUTION]
> The `.env` file contains secrets and **must** be listed in `.gitignore`. Production secrets should be injected via a secrets manager (Vault, AWS Secrets Manager) or container orchestration secrets, never baked into images.

### 9.3 Local Development Quick Start

```bash
# 1. Clone the repository
git clone https://github.com/org/namma-ooru-ai.git
cd namma-ooru-ai

# 2. Copy example environment config
cp .env.example .env

# 3. Start infrastructure services
docker compose -f docker-compose.dev.yml up -d postgres redis minio

# 4. Run database migrations
alembic upgrade head

# 5. Start the API server (hot reload)
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 6. Start Flutter app
cd frontend && flutter run
```

---

## Appendix A — Key Design Decisions

| Decision | Rationale |
|---|---|
| **Flutter for both mobile and web** | Single codebase reduces maintenance burden; Dart's strong typing catches errors at compile time |
| **FastAPI over Django** | Async-native, automatic OpenAPI docs, Pydantic-first validation, better performance for I/O-bound workloads |
| **PostgreSQL + PostGIS** | Industry-standard RDBMS with best-in-class geospatial support; critical for location-based civic data |
| **UUID primary keys** | Prevents enumeration attacks; safe for client-side generation; no sequential exposure |
| **Redis for rate limiting** | In-memory speed for sliding-window counters; atomic operations prevent race conditions |
| **MinIO (S3-compatible)** | Self-hostable in dev/staging; seamless migration to AWS S3 in production with zero code changes |
| **Sentence Transformers for dedup** | Semantic similarity outperforms keyword matching for multilingual, colloquial civic complaints |
| **Custom Tamil NLP** | Off-the-shelf NLP models underperform on Tamil text; a custom pipeline addresses script-specific tokenization and code-mixing |

---

*This document is maintained alongside the codebase and updated as architectural decisions evolve.*
