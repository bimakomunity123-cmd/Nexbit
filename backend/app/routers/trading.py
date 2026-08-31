from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import Account, Position
from ..rate_limit import limiter
from ..schemas import AccountOut, ClosePositionRequest, OpenPositionRequest, PositionOut

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


@trading_bp.get("/positions")
def list_positions():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        positions = db.query(Position).filter(Position.user_id == user.id).all()
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
        if position is None or position.user_id != user.id:
            return jsonify({"detail": "Posisi tidak ditemukan"}), 404

        body = ClosePositionRequest.model_validate(request.get_json(force=True, silent=False) or {})
        account = _get_or_create_account(db, user.id)
        account.realized_pnl += body.realized_pnl
        db.delete(position)
        db.commit()
        db.refresh(account)
        return jsonify(AccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()
