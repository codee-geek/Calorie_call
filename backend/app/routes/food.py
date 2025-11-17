from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from datetime import datetime, date
from app.db.database import get_db
from app.models.food_log_model import FoodLog
from app.models.food_model import FoodItem
from app.services.food_parse_service import food_parse_service
from sqlalchemy import func, and_

router = APIRouter(prefix="/food", tags=["food"])

class FoodParseRequest(BaseModel):
    text: str

class FoodLogCreate(BaseModel):
    user_id: int
    food_id: int
    quantity_grams: float
    calories: float
    source: str = "speech"

class FoodLogResponse(BaseModel):
    id: int
    user_id: int
    food_id: int
    food_name: str
    quantity_grams: float
    calories: float
    timestamp: str
    source: str
    
    class Config:
        from_attributes = True

@router.post("/parse")
def parse_food(request: FoodParseRequest):
    """
    Parse food from text using embeddings
    """
    try:
        result = food_parse_service.parse_food(request.text)
        return result
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error parsing food: {str(e)}")

@router.post("/log", response_model=FoodLogResponse)
def log_food(food_log: FoodLogCreate, db: Session = Depends(get_db)):
    """
    Log a food entry
    """
    try:
        # Get food item name
        food_item = db.query(FoodItem).filter(FoodItem.id == food_log.food_id).first()
        if not food_item:
            raise HTTPException(status_code=404, detail="Food item not found")
        
        # Create food log
        db_log = FoodLog(
            user_id=food_log.user_id,
            food_id=food_log.food_id,
            quantity_grams=food_log.quantity_grams,
            calories=food_log.calories,
            source=food_log.source
        )
        db.add(db_log)
        db.commit()
        db.refresh(db_log)
        
        return FoodLogResponse(
            id=db_log.id,
            user_id=db_log.user_id,
            food_id=db_log.food_id,
            food_name=food_item.name,
            quantity_grams=db_log.quantity_grams,
            calories=db_log.calories,
            timestamp=db_log.timestamp.isoformat(),
            source=db_log.source
        )
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error logging food: {str(e)}")

@router.get("/today")
def get_today_food(user_id: int, db: Session = Depends(get_db)):
    """
    Get today's food logs and total calories
    """
    try:
        today = date.today()
        start_of_day = datetime.combine(today, datetime.min.time())
        end_of_day = datetime.combine(today, datetime.max.time())
        
        # Get today's logs
        logs = db.query(FoodLog).filter(
            and_(
                FoodLog.user_id == user_id,
                FoodLog.timestamp >= start_of_day,
                FoodLog.timestamp <= end_of_day
            )
        ).all()
        
        # Calculate total calories
        total_calories = sum(log.calories for log in logs)
        
        # Format logs
        logs_data = []
        for log in logs:
            food_item = db.query(FoodItem).filter(FoodItem.id == log.food_id).first()
            logs_data.append({
                'id': log.id,
                'user_id': log.user_id,
                'food_id': log.food_id,
                'food_name': food_item.name if food_item else 'Unknown',
                'quantity_grams': log.quantity_grams,
                'calories': log.calories,
                'timestamp': log.timestamp.isoformat(),
                'source': log.source
            })
        
        return {
            'daily_calories': total_calories,
            'logs': logs_data
        }
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error fetching today's food: {str(e)}")

