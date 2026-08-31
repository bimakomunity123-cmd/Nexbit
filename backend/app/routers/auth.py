from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import Account, User
from ..schemas import LoginRequest, RegisterRequest, TokenResponse, UserOut
from ..security import create_access_token, hash_password, verify_password

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")


@auth_bp.post("/register")
def register():
    body = RegisterRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        existing = db.query(User).filter(User.email == body.email.lower()).first()
        if existing is not None:
            return jsonify({"detail": "Email sudah terdaftar"}), 409

        user = User(name=body.name.strip(), email=body.email.lower(), password_hash=hash_password(body.password))
        db.add(user)
        db.flush()  # assigns user.id before the Account row references it
        # Every new account starts with the same demo balance the old
        # local-only mock used (see futures_page's former _startingBalance).
        db.add(Account(user_id=user.id))
        db.commit()
        db.refresh(user)

        token = create_access_token(subject=user.id)
        return jsonify(TokenResponse(access_token=token, user=UserOut.model_validate(user)).model_dump(mode="json")), 201
    finally:
        db.close()


@auth_bp.post("/login")
def login():
    body = LoginRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == body.email.lower()).first()
        # Same error for "no such user" and "wrong password" — don't leak
        # which one it was.
        if user is None or not verify_password(body.password, user.password_hash):
            return jsonify({"detail": "Email atau password salah"}), 401

        token = create_access_token(subject=user.id)
        return jsonify(TokenResponse(access_token=token, user=UserOut.model_validate(user)).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.get("/me")
def me():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify({"detail": "Missing or invalid bearer token"}), 401
        return jsonify(UserOut.model_validate(user).model_dump(mode="json"))
    finally:
        db.close()
