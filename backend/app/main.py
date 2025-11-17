from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.routes import user, speech, food, prediction
from app.db.database import engine, Base
import logging

logger = logging.getLogger(__name__)

# Create tables (with error handling)
try:
    Base.metadata.create_all(bind=engine)
    logger.info("Database tables created successfully")
except Exception as e:
    logger.warning(f"Could not create database tables: {e}. Make sure PostgreSQL is running and configured.")

app = FastAPI(
    title="HealthyFy Me API",
    description="Smart Diet Auto-Tracking System Backend",
    version="1.0.0"
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify exact origins
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(user.router)
app.include_router(speech.router)
app.include_router(food.router)
app.include_router(prediction.router)

@app.get("/")
def root():
    return {
        "message": "HealthyFy Me API",
        "version": "1.0.0",
        "status": "running"
    }

@app.get("/health")
def health_check():
    return {"status": "healthy"}

