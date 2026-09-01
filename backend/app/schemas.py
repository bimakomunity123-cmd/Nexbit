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
    # Letters/digits only — not because contract ids need to be validated
    # against the real list (this demo doesn't maintain one server-side),
    # but so obviously-garbage input can't reach the database at all.
    contract_id: str = Field(min_length=1, max_length=20, pattern=r"^[A-Za-z0-9]+$")
    side: Literal["long", "short"]
    # Upper bounds are generous (way past any realistic order) — just
    # enough to reject absurd/overflow-shaped numbers, not to model a
    # real exchange's actual size limits.
    size: float = Field(gt=0, le=1_000_000)
    entry_price: float = Field(gt=0, le=1_000_000_000)
    leverage: int = Field(ge=1, le=125)
    margin_mode: Literal["cross", "isolated"] = "isolated"


class ClosePositionRequest(BaseModel):
    # Client-computed — the backend has no live market-data feed of its
    # own to verify this against (see Account's docstring in models.py).
    # Fine for this demo's mock trading; a real ledger would never trust
    # a client-supplied PnL figure. Bounded to a generous-but-finite
    # range for the same reason as OpenPositionRequest's fields above.
    realized_pnl: float = Field(ge=-1_000_000_000, le=1_000_000_000)


class SpotWalletOut(BaseModel):
    idr_balance: float

    class Config:
        from_attributes = True


class SpotHoldingOut(BaseModel):
    asset_id: str
    quantity: float

    class Config:
        from_attributes = True


class SpotOrderOut(BaseModel):
    id: str
    asset_id: str
    side: str
    order_type: str
    price: float
    amount: float
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class CreateSpotOrderRequest(BaseModel):
    asset_id: str = Field(min_length=1, max_length=10, pattern=r"^[A-Za-z0-9]+$")
    side: Literal["buy", "sell"]
    order_type: Literal["limit", "market", "stop_limit"]
    # Client-supplied — see SpotOrder's docstring in models.py for why
    # that's an accepted demo-only limitation. Bounds are generous (IDR
    # prices run into the billions for BTC) — just enough to reject
    # absurd/overflow-shaped numbers, not to model real price limits.
    price: float = Field(gt=0, le=100_000_000_000)
    amount: float = Field(gt=0, le=1_000_000)


class StakingHoldingOut(BaseModel):
    asset_id: str
    quantity: float

    class Config:
        from_attributes = True


class StakingAccountOut(BaseModel):
    realized_reward: float

    class Config:
        from_attributes = True


class StakingPositionOut(BaseModel):
    id: str
    asset_id: str
    amount: float
    duration_id: str
    apy: float
    status: str
    started_at: datetime
    unstaked_at: datetime | None

    class Config:
        from_attributes = True


class CreateStakingPositionRequest(BaseModel):
    asset_id: str = Field(min_length=1, max_length=10, pattern=r"^[A-Za-z0-9]+$")
    amount: float = Field(gt=0, le=1_000_000)
    duration_id: str = Field(min_length=1, max_length=20, pattern=r"^[A-Za-z0-9]+$")
    apy: float = Field(gt=0, le=100)


class UnstakePositionRequest(BaseModel):
    # Client-computed accrued reward — see StakingPosition's docstring
    # in models.py for why that's an accepted demo-only limitation.
    reward: float = Field(ge=0, le=1_000_000)


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
