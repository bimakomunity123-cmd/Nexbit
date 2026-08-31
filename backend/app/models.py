"""Database models — auth (User), plus Account/Position now that Futures
balances/positions live here instead of in-memory Flutter state.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import Boolean, DateTime, Float, ForeignKey, Integer, String
from sqlalchemy.orm import Mapped, mapped_column

from .database import Base


def _new_id() -> str:
    return uuid.uuid4().hex


class User(Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    name: Mapped[str] = mapped_column(String, nullable=False)
    email: Mapped[str] = mapped_column(String, nullable=False, unique=True, index=True)
    password_hash: Mapped[str] = mapped_column(String, nullable=False)
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))


class Account(Base):
    """One row per user — the demo trading balance. `balance` is the
    starting/deposited amount (every new user gets the same 1250.0 the
    old local-only mock used); `realized_pnl` accumulates every closed
    position's profit/loss. Unrealized PnL and available balance are NOT
    stored here — they depend on live mark prices, which only the
    frontend has (see LivePriceService), so the client computes those
    the same way it always did, just sourcing balance/realized_pnl from
    here instead of a local constant.
    """
    __tablename__ = "accounts"

    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), primary_key=True)
    balance: Mapped[float] = mapped_column(Float, default=1250.0)
    realized_pnl: Mapped[float] = mapped_column(Float, default=0.0)


class Position(Base):
    """One open Futures position. Mirrors lib/features/futures/domain/
    models/futures_position.dart's FuturesPosition — contract_id refers
    to that model's static contract lists (FuturesContract isn't itself
    stored here, just its id), and entry_price/leverage/margin_mode are
    exactly what the order form already computed client-side.
    """
    __tablename__ = "positions"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True, nullable=False)
    contract_id: Mapped[str] = mapped_column(String, nullable=False)  # 'BTC', 'ETH', ...
    side: Mapped[str] = mapped_column(String, nullable=False)  # 'long' | 'short'
    size: Mapped[float] = mapped_column(Float, nullable=False)
    entry_price: Mapped[float] = mapped_column(Float, nullable=False)
    leverage: Mapped[int] = mapped_column(Integer, nullable=False)
    margin_mode: Mapped[str] = mapped_column(String, default="isolated")
    opened_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))


class SpotWallet(Base):
    """One row per user — the demo Spot wallet balance, denominated in
    IDR to match kTradingPairs' quote currency for crypto (see that
    file's comment on IDR-quoted spot vs USDT-quoted futures). For
    simplicity, non-IDR pairs (forex majors, gold) are bought/sold
    against this same balance at their displayed price at face value —
    a real multi-currency exchange would need a separate book per quote
    currency; this single-book demo doesn't.
    """
    __tablename__ = "spot_wallets"

    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), primary_key=True)
    idr_balance: Mapped[float] = mapped_column(Float, default=50_000_000.0)


class SpotHolding(Base):
    """One row per (user, asset) the user currently holds a nonzero
    quantity of — e.g. 0.05 BTC. Left at 0 rather than deleted once
    fully sold, which is harmless (list_holdings filters quantity > 0)
    and avoids a delete-then-recreate dance if the same asset is bought
    again later.
    """
    __tablename__ = "spot_holdings"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True, nullable=False)
    asset_id: Mapped[str] = mapped_column(String, nullable=False)  # 'BTC', 'ETH', 'EUR', ...
    quantity: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)


class SpotOrder(Base):
    """A spot buy/sell order. Market orders fill immediately against the
    client-supplied price — same "trust the client's price" caveat as
    Futures' ClosePositionRequest.realized_pnl (see Account's docstring
    above), acceptable only because this demo has no real market-data
    feed of its own to verify against. Limit/stop-limit orders are just
    recorded as 'open' and never auto-fill — there's no real order book/
    matching engine behind this demo, so cancelling is the only thing
    that ever changes their status (matching what the old UI-only mock
    already did before this model existed).
    """
    __tablename__ = "spot_orders"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True, nullable=False)
    asset_id: Mapped[str] = mapped_column(String, nullable=False)
    side: Mapped[str] = mapped_column(String, nullable=False)  # 'buy' | 'sell'
    order_type: Mapped[str] = mapped_column(String, nullable=False)  # 'limit' | 'market' | 'stop_limit'
    price: Mapped[float] = mapped_column(Float, nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String, default="open")  # 'open' | 'filled' | 'cancelled'
    created_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))


class PasswordReset(Base):
    """A one-time password-reset token. IMPORTANT demo compromise: this
    app has no outbound email service configured (PythonAnywhere's free
    tier restricts most outbound SMTP anyway), so /auth/forgot-password
    returns this token directly in its JSON response instead of emailing
    it — clearly labeled as a demo limitation in the Flutter UI. A real
    implementation must NEVER do this: the token must only ever reach the
    user through a verified out-of-band channel (email), and the forgot-
    password endpoint must respond identically whether or not the email
    exists, so it can't be used to enumerate registered accounts.
    """
    __tablename__ = "password_resets"

    token: Mapped[str] = mapped_column(String, primary_key=True, default=lambda: uuid.uuid4().hex)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime, nullable=False)
    used: Mapped[bool] = mapped_column(Boolean, default=False)
