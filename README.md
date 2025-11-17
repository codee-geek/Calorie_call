# Calorie Call – Smart Diet Auto-Tracking System

A full-stack application for automatic diet tracking using speech input, calorie counting, and meal prediction.

## Project Structure

```
healthyfy-me/
├── flutter_app/          # Flutter frontend
│   └── lib/
│       ├── screens/      # 5 main screens
│       ├── services/     # API & Speech services
│       ├── models/       # Data models
│       └── main.dart
│
└── backend/              # FastAPI backend
    └── app/
        ├── routes/       # API endpoints
        ├── services/     # Business logic
        ├── models/       # Database models
        └── db/           # Database config
```

## Features

### Frontend (Flutter)
- **Login Screen**: User registration with name, phone, pincode, diet type
- **Home Screen**: Daily calories display and meal list
- **Add Meal Screen**: Voice recording for meal input
- **Confirm Meal Screen**: Review and adjust detected food/quantity
- **Summary Screen**: Daily/weekly stats and top foods

### Backend (FastAPI)
- **Speech-to-Text**: Whisper API integration
- **Food Extraction**: Sentence transformers for food matching
- **Prediction Engine**: Time-based frequency model
- **RESTful API**: All endpoints for frontend integration

## Setup Instructions

### Prerequisites
- Python 3.9+
- Flutter SDK 3.0+
- PostgreSQL database
- Node.js (for Replit deployment)

### Backend Setup

1. **Navigate to backend directory:**
```bash
cd backend
```

2. **Create virtual environment:**
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. **Install dependencies:**
```bash
pip install -r requirements.txt
```

4. **Set up PostgreSQL database:**
```bash
# Create database
createdb healthyfy_db

# Or using psql:
psql -U postgres
CREATE DATABASE healthyfy_db;
```

5. **Configure environment:**
```bash
cp .env.example .env
# Edit .env with your database credentials
```

6. **Run database migrations:**
The tables will be created automatically on first run.

7. **Start the server:**
```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

The API will be available at `http://localhost:8000`

### Frontend Setup

1. **Navigate to Flutter app:**
```bash
cd flutter_app
```

2. **Get dependencies:**
```bash
flutter pub get
```

3. **Update API base URL:**
Edit `lib/main.dart` and update the `baseUrl` in `ApiService`:
```dart
ApiService(baseUrl: 'http://YOUR_BACKEND_URL:8000')
```

4. **Run the app:**
```bash
flutter run
```

## API Endpoints

### User
- `POST /user/create` - Create new user

### Speech
- `POST /speech/upload` - Upload audio file for transcription

### Food
- `POST /food/parse` - Parse food from text
- `POST /food/log` - Log a meal
- `GET /food/today?user_id={id}` - Get today's meals and calories

### Prediction
- `GET /predict/next?user_id={id}` - Predict next meal

## Database Schema

### users
- id (PK)
- name
- phone (unique)
- pincode
- diet_type
- created_at

### food_items
- id (PK)
- name (unique)
- default_quantity_grams
- calories_per_100g

### food_logs
- id (PK)
- user_id (FK)
- food_id (FK)
- quantity_grams
- calories
- timestamp
- source

## Deployment on Replit

### Backend Deployment

1. **Create a new Repl:**
   - Choose Python template
   - Upload backend files

2. **Set environment variables:**
   - Add `DATABASE_URL` in Replit Secrets

3. **Install dependencies:**
   - Replit will auto-install from `requirements.txt`

4. **Run the server:**
   - Add `.replit` file with run command:
   ```
   uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

5. **Update CORS:**
   - In `app/main.py`, update `allow_origins` with your Replit URL

### Frontend Deployment

1. **For Flutter Web:**
   ```bash
   flutter build web
   ```
   - Deploy the `build/web` folder to Replit or any static hosting

2. **Update API URL:**
   - Change base URL to your Replit backend URL

## Development Notes

- **Whisper Model**: Uses `whisper-small` by default (can be changed in `whisper_service.py`)
- **Food Matching**: Uses `sentence-transformers` with `all-MiniLM-L6-v2` model
- **Prediction**: Basic frequency + time-of-day pattern matching
- **Audio Format**: WAV format, 16kHz, mono channel

## Troubleshooting

1. **Whisper not working:**
   - Ensure you have enough disk space (models are ~500MB)
   - Check audio file format (WAV recommended)

2. **Database connection errors:**
   - Verify PostgreSQL is running
   - Check DATABASE_URL in .env file

3. **Flutter build errors:**
   - Run `flutter clean` and `flutter pub get`
   - Check Flutter SDK version compatibility

## License

MIT License

## Author

 calorie call Development Team

# Calorie_call
# Calorie_call
