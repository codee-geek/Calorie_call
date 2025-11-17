import tempfile
import os
from pathlib import Path

try:
    import whisper
    WHISPER_AVAILABLE = True
except ImportError:
    WHISPER_AVAILABLE = False
    whisper = None

class WhisperService:
    def __init__(self, model_size="small"):
        if not WHISPER_AVAILABLE:
            raise ImportError("openai-whisper is not installed. Please install it with: pip install openai-whisper")
        self.model = whisper.load_model(model_size)
    
    def transcribe_audio(self, audio_file_path: str) -> str:
        """
        Transcribe audio file to text using Whisper
        """
        try:
            result = self.model.transcribe(audio_file_path)
            return result["text"].strip()
        except Exception as e:
            raise Exception(f"Error transcribing audio: {str(e)}")

# Global instance (only created if whisper is available)
whisper_service = None
if WHISPER_AVAILABLE:
    try:
        whisper_service = WhisperService()
    except Exception as e:
        print(f"Warning: Could not initialize Whisper service: {e}")
        whisper_service = None

