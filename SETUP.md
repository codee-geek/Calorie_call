# Quick Setup Guide for HealthyFy Me

## Prerequisites Checklist

- [ ] Python 3.9+ installed
- [ ] Flutter SDK 3.0+ installed
- [ ] PostgreSQL installed and running
- [ ] Git (optional, for version control)

## Step-by-Step Setup

### 1. Backend Setup (FastAPI)

```bash
# Navigate to backend
cd backend

# Create virtual environment
python3 -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# Install dependencies
pip install -r requirements.txt

# Set up database
# Option 1: Using psql
psql -U postgres
CREATE DATABASE healthyfy_db;
\q

# Option 2: Using createdb command
createdb healthyfy_db

# Create .env file
cp .env.example .env
# Edit .env and add your database URL:
# DATABASE_URL=postgresql://username:password@localhost:5432/healthyfy_db

# Initialize food database
python init_db.py

# Run the server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

**Backend should now be running at:** `http://localhost:8000`

**Test the API:**
```bash
curl http://localhost:8000/health
```

### 2. Frontend Setup (Flutter)

```bash
# Navigate to Flutter app
cd flutter_app

# Get dependencies
flutter pub get

# Update API URL (if needed)
# Edit lib/main.dart and change the baseUrl in ApiService
# For local development: 'http://localhost:8000'
# For Replit: 'https://your-repl-url.repl.co'

# Run on connected device/emulator
flutter run

# Or build for specific platform
flutter build apk        # Android
flutter build ios        # iOS
flutter build web        # Web
```

### 3. First Run

1. **Start Backend:**
   - Make sure PostgreSQL is running
   - Start the FastAPI server (see Backend Setup)

2. **Start Frontend:**
   - Run `flutter run` in the `flutter_app` directory
   - App will open on your device/emulator

3. **Test the Flow:**
   - Register a new user on Login Screen
   - Navigate to Home Screen
   - Tap "Add Meal" button
   - Record audio describing your meal
   - Confirm the detected food
   - View your daily calories

## Common Issues & Solutions

### Issue: Whisper model download fails
**Solution:** The first run will download the Whisper model (~500MB). Ensure stable internet connection.

### Issue: Database connection error
**Solution:** 
- Verify PostgreSQL is running: `pg_isready`
- Check DATABASE_URL in `.env` file
- Ensure database exists: `psql -l | grep healthyfy_db`

### Issue: Flutter build errors
**Solution:**
```bash
flutter clean
flutter pub get
flutter run
```

### Issue: CORS errors in browser
**Solution:** Update `allow_origins` in `backend/app/main.py` to include your frontend URL.

### Issue: Audio recording not working
**Solution:**
- Check microphone permissions on device
- For iOS: Add microphone permission in `Info.plist`
- For Android: Add microphone permission in `AndroidManifest.xml`

## Replit Deployment

### Backend on Replit

1. Create new Python Repl
2. Upload all backend files
3. Set environment variable `DATABASE_URL` in Replit Secrets
4. Replit will auto-install dependencies from `requirements.txt`
5. The `.replit` file will auto-run the server

### Frontend on Replit

1. Build Flutter web: `flutter build web`
2. Upload `build/web` folder to Replit
3. Update API URL in Flutter code to your Replit backend URL
4. Serve static files using a simple HTTP server

## Testing Endpoints

Use these curl commands to test the API:

```bash
# Health check
curl http://localhost:8000/health

# Create user
curl -X POST http://localhost:8000/user/create \
  -H "Content-Type: application/json" \
  -d '{"name":"Test User","phone":"1234567890","pincode":"12345","diet_type":"Vegetarian"}'

# Parse food
curl -X POST http://localhost:8000/food/parse \
  -H "Content-Type: application/json" \
  -d '{"text":"I ate an apple"}'
```

## Next Steps

- [ ] Set up production database
- [ ] Configure CORS properly for production
- [ ] Add authentication/authorization
- [ ] Deploy to production servers
- [ ] Set up CI/CD pipeline

## Support

For issues or questions, check the main README.md file or create an issue in the repository.

