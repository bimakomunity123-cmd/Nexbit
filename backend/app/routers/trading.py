from datetime import datetime, timezone

from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import Account, Position
from ..rate_limit import limiter
from ..schemas import (
    AccountOut,
    ClosePositionRequest,
    ExchangeToFuturesRequest,
    ExchangeToSpotRequest,
    FuturesDepositRequest,
    FuturesWithdrawRequest,
    OpenPositionRequest,
    PositionOut,
    SpotWalletOut,
)
from .spot import _get_or_create_wallet

trading_bp = Blueprint("trading", __name__, url_prefix="/trading")

_UNAUTHORIZED = ({"detail": "Missing or invalid bearer token"}, 401)


def _get_or_create_account(db, user_id: str) -> Account:
    account = db.get(Account, user_id)
    if account is None:
        account = Account(user_id=user_id)
        db.add(account)
        db.commit()
        db.refresh(account)
    return account


def _used_margin(db, user_id: str) -> float:
    """Sum of every open position's margin (entry_price * size / leverage
    — same formula as FuturesPosition.margin on the Flutter side), used
    to floor how much of the Futures balance exchange_to_spot() and
    withdraw() let a user move out. Computed from stored, already-trusted
    position fields (not live prices), unlike the account-card's own
    margin-ratio display.
    """
    positions = db.query(Position).filter(Position.user_id == user_id, Position.status == "open").all()
    return sum((p.entry_price * p.size) / p.leverage for p in positions)


@trading_bp.get("/account")
def get_account():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        account = _get_or_create_account(db, user.id)
        return jsonify(AccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()


@trading_bp.post("/deposit")
@limiter.limit("10 per hour")
def deposit():
    """Adds virtual funds to the demo Futures margin balance — a "top
    up" button, not a real payment: there's no card/bank flow behind
    it, just crediting Account.balance directly. A real product would
    never let a client-facing endpoint mint balance like this; this
    exists only because there's no other way to get funds into the
    demo account at all otherwise (new users start at a fixed 1250.0 —
    see Account's docstring in models.py).
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = FuturesDepositRequest.model_validate(request.get_json(force=True, silent=False) or {})
        account = _get_or_create_account(db, user.id)
        account.balance += body.amount
        db.commit()
        db.refresh(account)
        return jsonify(AccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()


@trading_bp.post("/withdraw")
@limiter.limit("10 per hour")
def withdraw():
    """The reverse of deposit() — removes virtual funds from the demo
    Futures margin balance. Just like deposit() isn't a real payment,
    this isn't a real payout: there's nowhere for the money to actually
    go, it's simply debited from Account.balance. Floored by balance +
    realized_pnl - used_margin, the same demo-acceptable approximation
    (ignoring unrealized PnL, which only the client has live prices for)
    as exchange_to_spot()'s identical check.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = FuturesWithdrawRequest.model_validate(request.get_json(force=True, silent=False) or {})
        account = _get_or_create_account(db, user.id)
        available = account.balance + account.realized_pnl - _used_margin(db, user.id)
        if body.amount > available:
            return jsonify({"detail": "Saldo tidak cukup untuk ditarik"}), 400

        account.balance -= body.amount
        db.commit()
        db.refresh(account)
        return jsonify(AccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()


def _exchange_response(wallet, account):
    return {
        "spot_wallet": SpotWalletOut.model_validate(wallet).model_dump(mode="json"),
        "futures_account": AccountOut.model_validate(account).model_dump(mode="json"),
    }


@trading_bp.post("/exchange/to-futures")
@limiter.limit("60 per minute")
def exchange_to_futures():
    """The Exchange button's Spot→Futures direction: moves IDR out of the
    demo Spot wallet and credits the equivalent USDT to the Futures
    margin balance. `rate` is the client's current IDR-per-USDT quote
    (LivePriceService's USDT price) — trusted the same way Spot's order
    price and Futures' realized PnL already are, since this demo has no
    market-data feed of its own server-side. Unlike deposit(), this
    doesn't mint money — it just moves it between the two demo ledgers,
    both updated in the same commit so a failure can't credit one side
    without debiting the other.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = ExchangeToFuturesRequest.model_validate(request.get_json(force=True, silent=False) or {})
        wallet = _get_or_create_wallet(db, user.id)
        if body.idr_amount > wallet.idr_balance:
            return jsonify({"detail": "Saldo Spot tidak cukup"}), 400

        account = _get_or_create_account(db, user.id)
        wallet.idr_balance -= body.idr_amount
        account.balance += body.idr_amount / body.rate
        db.commit()
        db.refresh(wallet)
        db.refresh(account)
        return jsonify(_exchange_response(wallet, account))
    finally:
        db.close()


@trading_bp.post("/exchange/to-spot")
@limiter.limit("60 per minute")
def exchange_to_spot():
    """The reverse direction — Futures USDT margin into Spot IDR balance.
    Floored by balance + realized_pnl - used_margin, deliberately
    ignoring unrealized PnL (which depends on live mark prices only the
    client has — same caveat FuturesAccountInfoCard's own available-
    balance figure carries). A demo-acceptable approximation, not the
    precise margin check a real exchange would enforce.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = ExchangeToSpotRequest.model_validate(request.get_json(force=True, silent=False) or {})
        account = _get_or_create_account(db, user.id)
        available = account.balance + account.realized_pnl - _used_margin(db, user.id)
        if body.usdt_amount > available:
            return jsonify({"detail": "Saldo Futures tidak cukup"}), 400

        wallet = _get_or_create_wallet(db, user.id)
        account.balance -= body.usdt_amount
        wallet.idr_balance += body.usdt_amount * body.rate
        db.commit()
        db.refresh(wallet)
        db.refresh(account)
        return jsonify(_exchange_response(wallet, account))
    finally:
        db.close()


@trading_bp.get("/positions")
def list_positions():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        positions = (
            db.query(Position).filter(Position.user_id == user.id, Position.status == "open").all()
        )
        return jsonify([PositionOut.model_validate(p).model_dump(mode="json") for p in positions])
    finally:
        db.close()


@trading_bp.get("/positions/history")
def list_position_history():
    """Closed positions — backs the Futures page's Trade History tab
    (previously always empty; see Position's docstring in models.py for
    why closing no longer deletes the row). Newest first, capped at 200
    so a very active demo account never returns an unbounded list.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        positions = (
            db.query(Position)
            .filter(Position.user_id == user.id, Position.status == "closed")
            .order_by(Position.closed_at.desc())
            .limit(200)
            .all()
        )
        return jsonify([PositionOut.model_validate(p).model_dump(mode="json") for p in positions])
    finally:
        db.close()


@trading_bp.post("/positions")
@limiter.limit("60 per minute")
def open_position():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = OpenPositionRequest.model_validate(request.get_json(force=True, silent=False) or {})
        position = Position(
            user_id=user.id,
            contract_id=body.contract_id,
            side=body.side,
            size=body.size,
            entry_price=body.entry_price,
            leverage=body.leverage,
            margin_mode=body.margin_mode,
        )
        db.add(position)
        db.commit()
        db.refresh(position)
        return jsonify(PositionOut.model_validate(position).model_dump(mode="json")), 201
    finally:
        db.close()


@trading_bp.post("/positions/<position_id>/close")
@limiter.limit("60 per minute")
def close_position(position_id: str):
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        position = db.get(Position, position_id)
        if position is None or position.user_id != user.id or position.status != "open":
            return jsonify({"detail": "Posisi tidak ditemukan"}), 404

        body = ClosePositionRequest.model_validate(request.get_json(force=True, silent=False) or {})
        account = _get_or_create_account(db, user.id)
        account.realized_pnl += body.realized_pnl
        position.status = "closed"
        position.exit_price = body.exit_price
        position.realized_pnl = body.realized_pnl
        position.closed_at = datetime.now(timezone.utc)
        db.commit()
        db.refresh(account)
        return jsonify(AccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()
