from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import SpotHolding, SpotOrder, SpotWallet
from ..rate_limit import limiter
from ..schemas import (
    CreateSpotOrderRequest,
    SpotDepositRequest,
    SpotHoldingOut,
    SpotOrderOut,
    SpotWalletOut,
    SpotWithdrawRequest,
)

spot_bp = Blueprint("spot", __name__, url_prefix="/spot")

_UNAUTHORIZED = ({"detail": "Missing or invalid bearer token"}, 401)


def _get_or_create_wallet(db, user_id: str) -> SpotWallet:
    wallet = db.get(SpotWallet, user_id)
    if wallet is None:
        wallet = SpotWallet(user_id=user_id)
        db.add(wallet)
        db.commit()
        db.refresh(wallet)
    return wallet


def _get_or_create_holding(db, user_id: str, asset_id: str) -> SpotHolding:
    holding = (
        db.query(SpotHolding)
        .filter(SpotHolding.user_id == user_id, SpotHolding.asset_id == asset_id)
        .first()
    )
    if holding is None:
        holding = SpotHolding(user_id=user_id, asset_id=asset_id, quantity=0.0)
        db.add(holding)
        db.flush()  # assigns holding.id and makes it visible within this session
    return holding


@spot_bp.get("/wallet")
def get_wallet():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        wallet = _get_or_create_wallet(db, user.id)
        return jsonify(SpotWalletOut.model_validate(wallet).model_dump(mode="json"))
    finally:
        db.close()


@spot_bp.post("/deposit")
@limiter.limit("10 per hour")
def deposit():
    """Adds virtual funds to the demo Spot IDR wallet — a "top up"
    button, not a real payment: there's no bank/e-wallet flow behind
    it, just crediting SpotWallet.idr_balance directly. A real product
    would never let a client-facing endpoint mint balance like this;
    this exists only because there's no other way to get funds into
    the demo wallet at all otherwise (new users start at a fixed
    50,000,000 — see StakingHolding's docstring-adjacent SpotWallet
    default in models.py).
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = SpotDepositRequest.model_validate(request.get_json(force=True, silent=False) or {})
        wallet = _get_or_create_wallet(db, user.id)
        wallet.idr_balance += body.amount
        db.commit()
        db.refresh(wallet)
        return jsonify(SpotWalletOut.model_validate(wallet).model_dump(mode="json"))
    finally:
        db.close()


@spot_bp.post("/withdraw")
@limiter.limit("10 per hour")
def withdraw():
    """The reverse of deposit() — removes virtual funds from the demo
    Spot IDR wallet. Just like deposit() isn't a real payment, this
    isn't a real payout: there's nowhere for the money to actually go,
    it's simply debited from SpotWallet.idr_balance. Capped at the
    current balance — holdings (BTC, ETH, ...) aren't liquidated to
    cover a shortfall, same as create_order()'s own balance check.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = SpotWithdrawRequest.model_validate(request.get_json(force=True, silent=False) or {})
        wallet = _get_or_create_wallet(db, user.id)
        if body.amount > wallet.idr_balance:
            return jsonify({"detail": "Saldo tidak cukup untuk ditarik"}), 400

        wallet.idr_balance -= body.amount
        db.commit()
        db.refresh(wallet)
        return jsonify(SpotWalletOut.model_validate(wallet).model_dump(mode="json"))
    finally:
        db.close()


@spot_bp.get("/holdings")
def list_holdings():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        holdings = (
            db.query(SpotHolding)
            .filter(SpotHolding.user_id == user.id, SpotHolding.quantity > 0)
            .all()
        )
        return jsonify([SpotHoldingOut.model_validate(h).model_dump(mode="json") for h in holdings])
    finally:
        db.close()


@spot_bp.get("/orders")
def list_orders():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        orders = (
            db.query(SpotOrder)
            .filter(SpotOrder.user_id == user.id)
            .order_by(SpotOrder.created_at.desc())
            .all()
        )
        return jsonify([SpotOrderOut.model_validate(o).model_dump(mode="json") for o in orders])
    finally:
        db.close()


@spot_bp.post("/orders")
# Guards against a runaway client (or a script) hammering order
# creation — generous enough not to bother a real user clicking Beli/
# Jual repeatedly, tight enough to blunt spam.
@limiter.limit("60 per minute")
def create_order():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = CreateSpotOrderRequest.model_validate(request.get_json(force=True, silent=False) or {})
        wallet = _get_or_create_wallet(db, user.id)
        holding = _get_or_create_holding(db, user.id, body.asset_id)
        cost = body.price * body.amount
        status = "open"

        # Market orders fill immediately; limit/stop-limit just get
        # recorded (see SpotOrder's docstring) — no balance/holding
        # changes until a real matching engine (which this demo doesn't
        # have) would fill them.
        if body.order_type == "market":
            if body.side == "buy":
                if wallet.idr_balance < cost:
                    return jsonify({"detail": "Saldo tidak cukup"}), 400
                wallet.idr_balance -= cost
                holding.quantity += body.amount
            else:
                if holding.quantity < body.amount:
                    return jsonify({"detail": "Jumlah aset tidak cukup"}), 400
                holding.quantity -= body.amount
                wallet.idr_balance += cost
            status = "filled"

        order = SpotOrder(
            user_id=user.id,
            asset_id=body.asset_id,
            side=body.side,
            order_type=body.order_type,
            price=body.price,
            amount=body.amount,
            status=status,
        )
        db.add(order)
        db.commit()
        db.refresh(order)
        db.refresh(wallet)
        return jsonify({
            "order": SpotOrderOut.model_validate(order).model_dump(mode="json"),
            "wallet": SpotWalletOut.model_validate(wallet).model_dump(mode="json"),
        }), 201
    finally:
        db.close()


@spot_bp.post("/orders/<order_id>/cancel")
@limiter.limit("60 per minute")
def cancel_order(order_id: str):
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        order = db.get(SpotOrder, order_id)
        if order is None or order.user_id != user.id:
            return jsonify({"detail": "Order tidak ditemukan"}), 404
        if order.status != "open":
            return jsonify({"detail": "Order tidak bisa dibatalkan"}), 400

        order.status = "cancelled"
        db.commit()
        return jsonify(SpotOrderOut.model_validate(order).model_dump(mode="json"))
    finally:
        db.close()
