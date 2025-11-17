from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from app.db.database import get_db
from app.services.prediction_service import prediction_service

router = APIRouter(prefix="/predict", tags=["prediction"])

@router.get("/next")
def get_next_prediction(user_id: int, db: Session = Depends(get_db)):
    """
    Predict next meal based on user history
    """
    try:
        prediction = prediction_service.predict_next_meal(db, user_id)
        return prediction
    except Exception as e:
        return {
            'food_name': 'Error',
            'confidence': 0.0,
            'reason': str(e)
        }

