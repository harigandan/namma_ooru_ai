from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.core.config import settings
from app.api.v1.router import api_router
from app.database.seed import seed_data

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup: Initialize DB and populate initial seed data
    print("🚀 Initializing Namma Ooru AI Database & Seed Data...")
    await seed_data()
    yield
    print("🛑 Shutting down Namma Ooru AI service...")

app = FastAPI(
    title=settings.PROJECT_NAME,
    description="Intelligent Civic Issue Reporting & Municipal Governance Platform for Tamil Nadu",
    version="1.0.0",
    lifespan=lifespan,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url=f"{settings.API_V1_STR}/docs",
    redoc_url=f"{settings.API_V1_STR}/redoc",
)

# CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.BACKEND_CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Mount API Routers
app.include_router(api_router, prefix=settings.API_V1_STR)

import os
from fastapi.staticfiles import StaticFiles
os.makedirs(settings.UPLOAD_DIR, exist_ok=True)
app.mount("/uploads", StaticFiles(directory=settings.UPLOAD_DIR), name="uploads")

@app.get("/", tags=["Health"])
async def root_health_check():
    return {
        "app": settings.PROJECT_NAME,
        "status": "online",
        "jurisdiction": "Tamil Nadu Municipal Administration",
        "version": "1.0.0",
        "docs": f"{settings.API_V1_STR}/docs",
    }

@app.get("/health", tags=["Health"])
async def health():
    return {"status": "healthy"}
