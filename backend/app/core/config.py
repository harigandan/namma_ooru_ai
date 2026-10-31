import os
from typing import List
from pydantic_settings import BaseSettings

class Settings(BaseSettings):
    PROJECT_NAME: str = "Namma Ooru AI"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "namma-ooru-super-secret-production-key-change-in-prod-2026")
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 60 * 24 # 24 hours
    REFRESH_TOKEN_EXPIRE_DAYS: int = 7

    # Database
    DATABASE_URL: str = os.getenv(
        "DATABASE_URL", 
        "sqlite+aiosqlite:///./namma_ooru.db"
    )

    # CORS
    BACKEND_CORS_ORIGINS: List[str] = ["*"]

    # Storage
    UPLOAD_DIR: str = "./uploads"

    model_config = {"case_sensitive": True}

settings = Settings()
