"""Shared "resolve the Bearer token to a User" helper — used by every
router that needs to know who's asking (auth.py's /me, trading.py's
account/positions endpoints).
"""
from flask import request

from .models import User
from .security import decode_access_token


def current_user(db) -> User | None:
    """Reads the Bearer token from the request and resolves it to a User,
    or None if missing/invalid/expired — callers turn that into a 401."""
    auth_header = request.headers.get("Authorization", "")
    if not auth_header.startswith("Bearer "):
        return None
    user_id = decode_access_token(auth_header.removeprefix("Bearer ").strip())
    if user_id is None:
        return None
    return db.get(User, user_id)
