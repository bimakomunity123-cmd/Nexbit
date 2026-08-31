"""Database models — auth (User), plus Account/Position now that Futures
balances/positions live here instead of in-memory Flutter state.
"""
import uuid
from datetime import datetime, timezone

from sqlalchemy import DateTime, Float, ForeignKey, Integer, String
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
