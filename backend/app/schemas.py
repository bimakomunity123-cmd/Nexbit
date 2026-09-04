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
    is_active: bool
    two_factor_enabled: bool
    created_at: datetime

    class Config:
        from_attributes = True


class TokenResponse(BaseModel):
    access_token: str
    token_type: str = "bearer"
    user: UserOut


class TwoFactorChallengeOut(BaseModel):
    two_factor_required: Literal[True] = True
    challenge_token: str
    # Demo-only shortcut — see TwoFactorChallenge's docstring in
    # models.py. A real product must deliver this over a verified
    # out-of-band channel (SMS/authenticator app), never in the login
    # response itself.
    otp_code: str


class VerifyTwoFactorRequest(BaseModel):
    challenge_token: str
    code: str = Field(pattern=r"^\d{6}$")


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
    status: str
    exit_price: float | None
    realized_pnl: float | None
    opened_at: datetime
    closed_at: datetime | None

    class Config:
        from_attributes = True


class FuturesDepositRequest(BaseModel):
    # A demo "add virtual funds" top-up, not a real payment — see
    # trading.py's deposit() route docstring. Bounded per-request (not
    # a lifetime cap) purely to reject absurd/overflow-shaped numbers.
    amount: float = Field(gt=0, le=1_000_000)


class FuturesWithdrawRequest(BaseModel):
    # The reverse of FuturesDepositRequest — see trading.py's withdraw()
    # route docstring for the balance floor this is checked against.
    amount: float = Field(gt=0, le=1_000_000)


class ExchangeToFuturesRequest(BaseModel):
    # Moves Spot IDR balance into Futures USDT margin — see trading.py's
    # exchange_to_futures() route docstring. `rate` is the client's
    # current IDR-per-USDT quote (LivePriceService's USDT price); same
    # "trust the client's live price" pattern as Spot's order price and
    # Futures' realized PnL. Bounds are generous, just enough to reject
    # absurd/overflow-shaped numbers.
    idr_amount: float = Field(gt=0, le=1_000_000_000)
    rate: float = Field(gt=0, le=100_000)


class ExchangeToSpotRequest(BaseModel):
    # The reverse direction — see ExchangeToFuturesRequest above.
    usdt_amount: float = Field(gt=0, le=1_000_000)
    rate: float = Field(gt=0, le=100_000)


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
    # The mark price at the moment of closing — same client-trusted
    # pattern as realized_pnl above. Stored on the position so the Trade
    # History tab has a real exit price to show.
    exit_price: float = Field(gt=0, le=1_000_000_000)


class FuturesOrderOut(BaseModel):
    id: str
    contract_id: str
    side: str
    order_type: str
    price: float
    size: float
    leverage: int
    margin_mode: str
    status: str
    created_at: datetime

    class Config:
        from_attributes = True


class CreateFuturesOrderRequest(BaseModel):
    contract_id: str = Field(min_length=1, max_length=20, pattern=r"^[A-Za-z0-9]+$")
    side: Literal["long", "short"]
    order_type: Literal["limit", "market", "stop_limit", "stop_market"]
    # Client-supplied — same "trust the client's price" pattern as
    # OpenPositionRequest.entry_price above (this demo has no market-
    # data feed of its own to verify against server-side).
    price: float = Field(gt=0, le=1_000_000_000)
    size: float = Field(gt=0, le=1_000_000)
    leverage: int = Field(ge=1, le=125)
    margin_mode: Literal["cross", "isolated"] = "isolated"


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


class SpotDepositRequest(BaseModel):
    # A demo "add virtual funds" top-up, not a real payment — see
    # spot.py's deposit() route docstring. Bounded per-request (not a
    # lifetime cap) purely to reject absurd/overflow-shaped numbers.
    amount: float = Field(gt=0, le=1_000_000_000)


class SpotWithdrawRequest(BaseModel):
    # The reverse of SpotDepositRequest — see spot.py's withdraw() route
    # docstring.
    amount: float = Field(gt=0, le=1_000_000_000)


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


class KycStatusOut(BaseModel):
    status: Literal["unverified", "pending", "verified"]
    full_name: str | None = None
    id_number: str | None = None
    submitted_at: datetime | None = None


class SubmitKycRequest(BaseModel):
    # Demo-only — never checked against a real identity registry (see
    # KycVerification's docstring in models.py). These are shape checks,
    # not real validation; the Flutter UI tells users not to enter real
    # personal information here.
    full_name: str = Field(min_length=1, max_length=100)
    # 16 digits, loosely matching an Indonesian NIK's shape.
    id_number: str = Field(pattern=r"^\d{16}$")
