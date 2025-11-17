# HealthyFy Me API Reference

Base URL: `http://localhost:8000` (or your deployment URL)

## Endpoints

### Health Check
```
GET /
GET /health
```

### User Endpoints

#### Create User
```
POST /user/create
Content-Type: application/json

Request Body:
{
  "name": "John Doe",
  "phone": "1234567890",
  "pincode": "12345",
  "diet_type": "Vegetarian"
}

Response:
{
  "id": 1,
  "name": "John Doe",
  "phone": "1234567890",
  "pincode": "12345",
  "diet_type": "Vegetarian",
  "created_at": "2024-01-01T12:00:00"
}
```

### Speech Endpoints

#### Upload Audio for Transcription
```
POST /speech/upload
Content-Type: multipart/form-data

Request: FormData with 'file' field (audio file)

Response:
{
  "text": "I ate an apple and a banana",
  "status": "success"
}
```

### Food Endpoints

#### Parse Food from Text
```
POST /food/parse
Content-Type: application/json

Request Body:
{
  "text": "I ate an apple"
}

Response:
{
  "food": {
    "id": 1,
    "name": "Apple",
    "default_quantity_grams": 150.0,
    "calories_per_100g": 52.0
  },
  "quantity_guess": 150.0
}
```

#### Log Food Entry
```
POST /food/log
Content-Type: application/json

Request Body:
{
  "user_id": 1,
  "food_id": 1,
  "quantity_grams": 150.0,
  "calories": 78.0,
  "source": "speech"
}

Response:
{
  "id": 1,
  "user_id": 1,
  "food_id": 1,
  "food_name": "Apple",
  "quantity_grams": 150.0,
  "calories": 78.0,
  "timestamp": "2024-01-01T12:00:00",
  "source": "speech"
}
```

#### Get Today's Food
```
GET /food/today?user_id=1

Response:
{
  "daily_calories": 500.0,
  "logs": [
    {
      "id": 1,
      "user_id": 1,
      "food_id": 1,
      "food_name": "Apple",
      "quantity_grams": 150.0,
      "calories": 78.0,
      "timestamp": "2024-01-01T08:00:00",
      "source": "speech"
    }
  ]
}
```

### Prediction Endpoints

#### Get Next Meal Prediction
```
GET /predict/next?user_id=1

Response:
{
  "food_name": "Apple",
  "confidence": 0.75,
  "reason": "Most frequent in morning meals (last 7 days)"
}
```

## Error Responses

All endpoints may return errors in the following format:

```json
{
  "detail": "Error message description"
}
```

Common HTTP Status Codes:
- `200` - Success
- `400` - Bad Request
- `404` - Not Found
- `500` - Internal Server Error

## Example cURL Commands

### Create User
```bash
curl -X POST http://localhost:8000/user/create \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Test User",
    "phone": "1234567890",
    "pincode": "12345",
    "diet_type": "Vegetarian"
  }'
```

### Parse Food
```bash
curl -X POST http://localhost:8000/food/parse \
  -H "Content-Type: application/json" \
  -d '{"text": "I ate rice and chicken"}'
```

### Get Today's Food
```bash
curl http://localhost:8000/food/today?user_id=1
```

### Upload Audio
```bash
curl -X POST http://localhost:8000/speech/upload \
  -F "file=@audio.wav"
```

## Testing with Postman

1. Import the collection (if available)
2. Set base URL variable
3. Update user_id in requests
4. Test each endpoint

## Rate Limiting

Currently no rate limiting is implemented. For production, consider adding:
- Rate limiting middleware
- Request throttling
- API key authentication

