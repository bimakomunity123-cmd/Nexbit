"""Pydantic request/response shapes for the auth and trading API."""
from datetime import datetime
from typing import Literal

from pydantic import BaseModel, EmailStr, Field


class RegisterRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)
    email: EmailStr
    password: str = Field(min_length=8, max_length=72)


class LoginRequest(BaseModel):
    email: EmailStr
    password: str


class UserOut(BaseModel):
    id: str
    name: str
    email: EmailStr
    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class AccountOut(BaseModel):
    balance: float
    realized_pnl: float

    class Config:
        from_attributes = True


class PositionOut(BaseModel):
    id: str
    contract_id: str
    side: str
    size: float
    entry_price: float
    leverage: int
    margin_mode: str
    opened_at: datetime

    class Config:
        from_attributes = True


class OpenPositionRequest(BaseModel):
    contract_id: str = Field(min_length=1, max_length=20)
    side: Literal["long", "short"]
    size: float = Field(gt=0)
    entry_price: float = Field(gt=0)
    leverage: int = Field(ge=1, le=125)
    margin_mode: Literal["cross", "isolated"] = "isolated"


class ClosePositionRequest(BaseModel):
    # Client-computed — the backend has no live market-data feed of its
    # own to verify this against (see Account's docstring in models.py).
    # Fine for this demo's mock trading; a real ledger would never trust
    # a client-supplied PnL figure.
    realized_pnl: float


class ChangePasswordRequest(BaseModel):
    old_password: str
    new_password: str = Field(min_length=8, max_length=72)


class UpdateProfileRequest(BaseModel):
    name: str = Field(min_length=1, max_length=100)


class ForgotPasswordRequest(BaseModel):
    email: EmailStr


class ResetPasswordRequest(BaseModel):
    token: str
    new_password: str = Field(min_length=8, max_length=72)
