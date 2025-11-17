from fastapi import APIRouter, UploadFile, File, HTTPException
from app.services.whisper_service import whisper_service
import tempfile
import os

router = APIRouter(prefix="/speech", tags=["speech"])

@router.post("/upload")
async def upload_speech(file: UploadFile = File(...)):
    """
    Upload audio file and transcribe using Whisper
    """
    if whisper_service is None:
        raise HTTPException(
            status_code=503, 
            detail="Whisper service is not available. Please install openai-whisper. Note: Python 3.14 is not yet supported by whisper dependencies. Consider using Python 3.13 or 3.12."
        )
    
    try:
        # Save uploaded file temporarily
        with tempfile.NamedTemporaryFile(delete=False, suffix=".wav") as tmp_file:
            content = await file.read()
            tmp_file.write(content)
            tmp_file_path = tmp_file.name
        
        try:
            # Transcribe audio
            text = whisper_service.transcribe_audio(tmp_file_path)
            
            return {
                "text": text,
                "status": "success"
            }
        finally:
            # Clean up temp file
            if os.path.exists(tmp_file_path):
                os.unlink(tmp_file_path)
    
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Error processing audio: {str(e)}")

