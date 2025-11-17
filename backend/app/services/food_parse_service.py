import pandas as pd
from sentence_transformers import SentenceTransformer
import numpy as np
from pathlib import Path
import os

class FoodParseService:
    def __init__(self):
        # Load food database
        db_path = Path(__file__).parent.parent.parent / "food_db.csv"
        if db_path.exists():
            self.food_df = pd.read_csv(db_path)
        else:
            # Create dummy data if file doesn't exist
            self.food_df = pd.DataFrame({
                'id': range(1, 21),
                'name': [
                    'Apple', 'Banana', 'Rice', 'Chicken Breast', 'Salmon',
                    'Broccoli', 'Egg', 'Bread', 'Milk', 'Yogurt',
                    'Orange', 'Pasta', 'Beef', 'Potato', 'Carrot',
                    'Spinach', 'Cheese', 'Butter', 'Avocado', 'Tomato'
                ],
                'default_quantity_grams': [150, 120, 200, 100, 150, 100, 50, 30, 250, 200, 180, 200, 100, 150, 100, 100, 30, 15, 200, 150],
                'calories_per_100g': [52, 89, 130, 165, 208, 34, 155, 265, 42, 59, 47, 131, 250, 77, 41, 23, 402, 717, 160, 18]
            })
        
        # Load sentence transformer model
        try:
            self.model = SentenceTransformer('all-MiniLM-L6-v2')
        except:
            # Fallback if model can't be loaded
            self.model = None
        
        # Pre-compute embeddings for food items
        if self.model:
            self.food_embeddings = self.model.encode(
                self.food_df['name'].tolist(),
                show_progress_bar=False
            )
        else:
            self.food_embeddings = None
    
    def parse_food(self, text: str) -> dict:
        """
        Parse food from text using embeddings similarity
        """
        if self.model is None or self.food_embeddings is None:
            # Fallback: simple keyword matching
            text_lower = text.lower()
            for idx, row in self.food_df.iterrows():
                if row['name'].lower() in text_lower:
                    return {
                        'food': {
                            'id': int(row['id']),
                            'name': row['name'],
                            'default_quantity_grams': float(row['default_quantity_grams']),
                            'calories_per_100g': float(row['calories_per_100g'])
                        },
                        'quantity_guess': float(row['default_quantity_grams'])
                    }
            # Default fallback
            default_food = self.food_df.iloc[0]
            return {
                'food': {
                    'id': int(default_food['id']),
                    'name': default_food['name'],
                    'default_quantity_grams': float(default_food['default_quantity_grams']),
                    'calories_per_100g': float(default_food['calories_per_100g'])
                },
                'quantity_guess': float(default_food['default_quantity_grams'])
            }
        
        # Use embeddings for similarity search
        text_embedding = self.model.encode([text], show_progress_bar=False)[0]
        
        # Calculate cosine similarity
        similarities = np.dot(self.food_embeddings, text_embedding) / (
            np.linalg.norm(self.food_embeddings, axis=1) * np.linalg.norm(text_embedding)
        )
        
        # Get best match
        best_idx = np.argmax(similarities)
        best_match = self.food_df.iloc[best_idx]
        
        # Extract quantity from text (simple heuristic)
        quantity_guess = self._extract_quantity(text, best_match['default_quantity_grams'])
        
        return {
            'food': {
                'id': int(best_match['id']),
                'name': best_match['name'],
                'default_quantity_grams': float(best_match['default_quantity_grams']),
                'calories_per_100g': float(best_match['calories_per_100g'])
            },
            'quantity_guess': quantity_guess
        }
    
    def _extract_quantity(self, text: str, default_quantity: float) -> float:
        """
        Simple quantity extraction from text
        """
        import re
        # Look for numbers followed by g, grams, kg, etc.
        patterns = [
            r'(\d+)\s*g(?:rams?)?',
            r'(\d+)\s*kg',
            r'(\d+)\s*oz',
        ]
        
        for pattern in patterns:
            match = re.search(pattern, text.lower())
            if match:
                value = float(match.group(1))
                if 'kg' in pattern:
                    value *= 1000
                elif 'oz' in pattern:
                    value *= 28.35
                return value
        
        return default_quantity

# Global instance
food_parse_service = FoodParseService()

