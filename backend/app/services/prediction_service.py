from sqlalchemy.orm import Session
from sqlalchemy import func, and_
from datetime import datetime, timedelta
from app.models.food_log_model import FoodLog
from app.models.food_model import FoodItem
from collections import Counter

class PredictionService:
    def predict_next_meal(self, db: Session, user_id: int) -> dict:
        """
        Predict next meal based on:
        - Frequency of foods in last 7 days
        - Time-of-day patterns
        """
        # Get current hour
        current_hour = datetime.now().hour
        
        # Get logs from last 7 days
        seven_days_ago = datetime.now() - timedelta(days=7)
        recent_logs = db.query(FoodLog).filter(
            and_(
                FoodLog.user_id == user_id,
                FoodLog.timestamp >= seven_days_ago
            )
        ).all()
        
        if not recent_logs:
            # No history, return default prediction
            return {
                'food_name': 'No prediction available',
                'confidence': 0.0,
                'reason': 'No eating history'
            }
        
        # Time-based filtering
        # Morning: 6-11, Lunch: 12-15, Evening: 16-20, Night: 21-5
        time_category = self._get_time_category(current_hour)
        time_filtered_logs = [
            log for log in recent_logs
            if self._get_time_category(log.timestamp.hour) == time_category
        ]
        
        # Use time-filtered logs if available, otherwise use all logs
        logs_to_analyze = time_filtered_logs if time_filtered_logs else recent_logs
        
        # Count food frequency
        food_counts = Counter()
        for log in logs_to_analyze:
            food_item = db.query(FoodItem).filter(FoodItem.id == log.food_id).first()
            if food_item:
                food_counts[food_item.name] += 1
        
        if not food_counts:
            return {
                'food_name': 'No prediction available',
                'confidence': 0.0,
                'reason': 'No matching time pattern'
            }
        
        # Get most frequent food
        most_common = food_counts.most_common(1)[0]
        food_name = most_common[0]
        frequency = most_common[1]
        
        # Calculate confidence (simple: frequency / total meals in category)
        total_meals = len(logs_to_analyze)
        confidence = min(frequency / total_meals, 1.0) if total_meals > 0 else 0.0
        
        return {
            'food_name': food_name,
            'confidence': round(confidence, 2),
            'reason': f'Most frequent in {time_category} meals (last 7 days)'
        }
    
    def _get_time_category(self, hour: int) -> str:
        """Categorize hour into meal time"""
        if 6 <= hour < 12:
            return 'morning'
        elif 12 <= hour < 16:
            return 'lunch'
        elif 16 <= hour < 21:
            return 'evening'
        else:
            return 'night'

# Global instance
prediction_service = PredictionService()

