from datetime import datetime, timezone

from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import StakingAccount, StakingHolding, StakingPosition
from ..rate_limit import limiter
from ..schemas import (
    CreateStakingPositionRequest,
    StakingAccountOut,
    StakingHoldingOut,
    StakingPositionOut,
    UnstakePositionRequest,
)

staking_bp = Blueprint("staking", __name__, url_prefix="/staking")

_UNAUTHORIZED = ({"detail": "Missing or invalid bearer token"}, 401)

# Demo seed balances per asset — must stay in sync with kStakingAssets'
# availableBalance in
# lib/features/staking/domain/models/staking_asset.dart. An asset not
# listed here seeds at 0 (so staking it is immediately rejected as
# insufficient balance instead of crashing).
_DEFAULT_HOLDINGS = {
    "ETH": 1.8548,
    "SOL": 42.3,
    "USDT": 2450.0,
    "ADA": 5200.0,
    "BNB": 3.2,
    "DOT": 150.0,
}


def _get_or_create_account(db, user_id: str) -> StakingAccount:
    account = db.get(StakingAccount, user_id)
    if account is None:
        account = StakingAccount(user_id=user_id)
        db.add(account)
        db.commit()
        db.refresh(account)
    return account


def _get_or_create_holding(db, user_id: str, asset_id: str) -> StakingHolding:
    holding = (
        db.query(StakingHolding)
        .filter(StakingHolding.user_id == user_id, StakingHolding.asset_id == asset_id)
        .first()
    )
    if holding is None:
        holding = StakingHolding(user_id=user_id, asset_id=asset_id, quantity=_DEFAULT_HOLDINGS.get(asset_id, 0.0))
        db.add(holding)
        db.flush()  # assigns holding.id and makes it visible within this session
    return holding


@staking_bp.get("/holdings")
def list_holdings():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        # Seed every known asset up front (unlike Spot, where a holding
        # only ever exists once something's actually been bought) so
        # the Marketplace/Detail pages can show a real "available
        # balance" for every asset on a user's very first visit, not
        # just ones they've already staked before.
        for asset_id in _DEFAULT_HOLDINGS:
            _get_or_create_holding(db, user.id, asset_id)
        db.commit()
        holdings = db.query(StakingHolding).filter(StakingHolding.user_id == user.id).all()
        return jsonify([StakingHoldingOut.model_validate(h).model_dump(mode="json") for h in holdings])
    finally:
        db.close()


@staking_bp.get("/account")
def get_account():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        account = _get_or_create_account(db, user.id)
        return jsonify(StakingAccountOut.model_validate(account).model_dump(mode="json"))
    finally:
        db.close()


@staking_bp.get("/positions")
def list_positions():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        positions = (
            db.query(StakingPosition)
            .filter(StakingPosition.user_id == user.id)
            .order_by(StakingPosition.started_at.desc())
            .all()
        )
        return jsonify([StakingPositionOut.model_validate(p).model_dump(mode="json") for p in positions])
    finally:
        db.close()


@staking_bp.post("/positions")
@limiter.limit("60 per minute")
def create_position():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = CreateStakingPositionRequest.model_validate(request.get_json(force=True, silent=False) or {})
        holding = _get_or_create_holding(db, user.id, body.asset_id)
        if holding.quantity < body.amount:
            return jsonify({"detail": "Saldo aset tidak cukup untuk staking"}), 400

        holding.quantity -= body.amount
        position = StakingPosition(
            user_id=user.id,
            asset_id=body.asset_id,
            amount=body.amount,
            duration_id=body.duration_id,
            apy=body.apy,
        )
        db.add(position)
        db.commit()
        db.refresh(position)
        db.refresh(holding)
        return jsonify({
            "position": StakingPositionOut.model_validate(position).model_dump(mode="json"),
            "holding": StakingHoldingOut.model_validate(holding).model_dump(mode="json"),
        }), 201
    finally:
        db.close()


@staking_bp.post("/positions/<position_id>/unstake")
@limiter.limit("60 per minute")
def unstake_position(position_id: str):
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        position = db.get(StakingPosition, position_id)
        if position is None or position.user_id != user.id:
            return jsonify({"detail": "Stake tidak ditemukan"}), 404
        if position.status != "active":
            return jsonify({"detail": "Stake sudah tidak aktif"}), 400

        body = UnstakePositionRequest.model_validate(request.get_json(force=True, silent=False) or {})
        holding = _get_or_create_holding(db, user.id, position.asset_id)
        account = _get_or_create_account(db, user.id)

        holding.quantity += position.amount
        account.realized_reward += body.reward
        position.status = "unstaked"
        position.unstaked_at = datetime.now(timezone.utc)

        db.commit()
        db.refresh(position)
        db.refresh(holding)
        db.refresh(account)
        return jsonify({
            "position": StakingPositionOut.model_validate(position).model_dump(mode="json"),
            "holding": StakingHoldingOut.model_validate(holding).model_dump(mode="json"),
            "account": StakingAccountOut.model_validate(account).model_dump(mode="json"),
        })
    finally:
        db.close()
