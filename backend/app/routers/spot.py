from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import SpotHolding, SpotOrder, SpotWallet
from ..schemas import CreateSpotOrderRequest, SpotHoldingOut, SpotOrderOut, SpotWalletOut

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
