from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from pydantic import BaseModel
from app.db.database import get_db
from app.models.user_model import User

router = APIRouter(prefix="/user", tags=["user"])

class UserCreate(BaseModel):
    name: str
    phone: str
    pincode: str
    diet_type: str

class UserResponse(BaseModel):
    id: int
    name: str
    phone: str
    pincode: str
    diet_type: str
    created_at: str
    
    class Config:
        from_attributes = True

@router.post("/create", response_model=UserResponse)
def create_user(user: UserCreate, db: Session = Depends(get_db)):
    # Check if user already exists
    existing_user = db.query(User).filter(User.phone == user.phone).first()
    if existing_user:
        return UserResponse(
            id=existing_user.id,
            name=existing_user.name,
            phone=existing_user.phone,
            pincode=existing_user.pincode,
            diet_type=existing_user.diet_type,
            created_at=existing_user.created_at.isoformat()
        )
    
    # Create new user
    db_user = User(
        name=user.name,
        phone=user.phone,
        pincode=user.pincode,
        diet_type=user.diet_type
    )
    db.add(db_user)
    db.commit()
    db.refresh(db_user)
    
    return UserResponse(
        id=db_user.id,
        name=db_user.name,
        phone=db_user.phone,
        pincode=db_user.pincode,
        diet_type=db_user.diet_type,
        created_at=db_user.created_at.isoformat()
    )

