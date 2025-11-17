"""
Script to initialize database with food items from CSV
"""
import pandas as pd
from sqlalchemy.orm import Session
from app.db.database import SessionLocal, engine, Base
from app.models.food_model import FoodItem
from pathlib import Path

def init_food_items():
    """Load food items from CSV into database"""
    Base.metadata.create_all(bind=engine)
    db: Session = SessionLocal()
    
    try:
        # Check if food items already exist
        existing_count = db.query(FoodItem).count()
        if existing_count > 0:
            print(f"Food items already exist ({existing_count} items)")
            return
        
        # Load CSV
        csv_path = Path(__file__).parent / "food_db.csv"
        if not csv_path.exists():
            print(f"CSV file not found at {csv_path}")
            return
        
        df = pd.read_csv(csv_path)
        
        # Insert food items
        for _, row in df.iterrows():
            food_item = FoodItem(
                id=int(row['id']),
                name=row['name'],
                default_quantity_grams=float(row['default_quantity_grams']),
                calories_per_100g=float(row['calories_per_100g'])
            )
            db.add(food_item)
        
        db.commit()
        print(f"Successfully loaded {len(df)} food items into database")
    
    except Exception as e:
        db.rollback()
        print(f"Error initializing food items: {e}")
    finally:
        db.close()

if __name__ == "__main__":
    init_food_items()

