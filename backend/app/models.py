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
    """One Futures position, open or closed. Mirrors lib/features/futures/
    domain/models/futures_position.dart's FuturesPosition — contract_id
    refers to that model's static contract lists (FuturesContract isn't
    itself stored here, just its id), and entry_price/leverage/margin_mode
    are exactly what the order form already computed client-side.

    Closing a position used to delete this row outright; it's now kept
    with status='closed' plus exit_price/realized_pnl/closed_at filled
    in, so the Futures page's Trade History tab (previously always
    empty — see FuturesPositionsPanel) has real rows to show. list_
    positions() only returns status='open' rows, so this change is
    invisible to every existing "open positions" consumer.
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
    status: Mapped[str] = mapped_column(String, default="open")  # 'open' | 'closed'
    exit_price: Mapped[float | None] = mapped_column(Float, nullable=True)
    # Same "trust the client's number" caveat as realized_pnl below —
    # this is this position's own PnL at close, distinct from Account.
    # realized_pnl, which keeps a running total across every position.
    realized_pnl: Mapped[float | None] = mapped_column(Float, nullable=True)
    opened_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    closed_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


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


class StakingHolding(Base):
    """One row per (user, asset) — how much of that asset is available
    to stake. Seeded per-asset from a fixed demo default (see
    _DEFAULT_HOLDINGS in routers/staking.py, which must be kept in sync
    with kStakingAssets' availableBalance in
    lib/features/staking/domain/models/staking_asset.dart) the first
    time it's queried for that user. A separate demo "wallet" from
    Spot's IDR balance and Futures' USDT margin account — this app
    doesn't model one unified balance per asset across features, the
    same simplification already made between Spot and Futures.
    """
    __tablename__ = "staking_holdings"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True, nullable=False)
    asset_id: Mapped[str] = mapped_column(String, nullable=False)
    quantity: Mapped[float] = mapped_column(Float, nullable=False, default=0.0)


class StakingAccount(Base):
    """One row per user — accumulates realized_reward every time a
    stake is unstaked, mirroring Futures' Account.realized_pnl above.
    Unlike that field, this one is USD-denominated rather than in any
    particular asset's native unit — a user can stake and unstake
    several different assets (ETH, SOL, ...), and this single number
    has to mean the same thing across all of them, so the Flutter side
    converts each stake's reward to its USD-equivalent (see
    core/market_data/live_pricing.dart's approxUsdPriceFor) before
    sending it here, rather than the raw asset-unit reward amount.
    """
    __tablename__ = "staking_accounts"

    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), primary_key=True)
    realized_reward: Mapped[float] = mapped_column(Float, default=0.0)


class StakingPosition(Base):
    """One stake, active until unstaked. `apy` is locked in at the
    moment of staking (so a later change to a duration tier's rate on
    the Flutter side never retroactively changes an existing stake's
    math) rather than looked up live at read time. Reward accrued so
    far is NOT stored here — like Futures' unrealized PnL, it depends
    on the current time, which only the client needs to compute
    (amount * apy / 100 * elapsed_days / 365); only the reward actually
    realized at the moment of unstaking (client-computed, same "trust
    the client's number" caveat as ClosePositionRequest.realized_pnl
    and Spot's order price — see those for why that's an accepted
    demo-only compromise) gets persisted, into
    StakingAccount.realized_reward.
    """
    __tablename__ = "staking_positions"

    id: Mapped[str] = mapped_column(String, primary_key=True, default=_new_id)
    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), index=True, nullable=False)
    asset_id: Mapped[str] = mapped_column(String, nullable=False)
    amount: Mapped[float] = mapped_column(Float, nullable=False)
    duration_id: Mapped[str] = mapped_column(String, nullable=False)  # 'flexible' | '30d' | '60d' | '90d'
    apy: Mapped[float] = mapped_column(Float, nullable=False)
    status: Mapped[str] = mapped_column(String, default="active")  # 'active' | 'unstaked'
    started_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))
    unstaked_at: Mapped[datetime | None] = mapped_column(DateTime, nullable=True)


class KycVerification(Base):
    """A demo "know your customer" identity check. IMPORTANT: this is
    NOT real identity verification — full_name/id_number are never
    checked against any government registry (Dukcapil or otherwise),
    only validated as plausibly-shaped input (see schemas.py); the
    Flutter UI explicitly tells users not to enter real personal
    information. One submission per user, ever (no resubmit/reject
    flow — kept intentionally minimal).

    Status is derived rather than stored: no row for a user means
    'unverified'; a row younger than routers/kyc.py's _REVIEW_DELAY
    means 'pending'; older means 'verified'. This needs no cron/
    background job — the delay is just computed against submitted_at
    whenever status is read. Replaces what used to be a hardcoded,
    permanently-on "Verified" badge on the Profile page.
    """
    __tablename__ = "kyc_verifications"

    user_id: Mapped[str] = mapped_column(String, ForeignKey("users.id"), primary_key=True)
    full_name: Mapped[str] = mapped_column(String, nullable=False)
    id_number: Mapped[str] = mapped_column(String, nullable=False)
    submitted_at: Mapped[datetime] = mapped_column(DateTime, default=lambda: datetime.now(timezone.utc))


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
