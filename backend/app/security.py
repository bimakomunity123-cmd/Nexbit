"""Password hashing (bcrypt directly — passlib's bcrypt backend is broken
against bcrypt>=4.1, see backend/README.md) and JWT issuing/verification.
"""
from datetime import datetime, timedelta, timezone

import bcrypt
import jwt

from .config import JWT_ALGORITHM, JWT_EXPIRES_MINUTES, JWT_SECRET

# bcrypt has a hard 72-byte input limit — reject longer passwords up front
# (schemas.py already caps at 72 chars) rather than silently truncating.
_MAX_PASSWORD_BYTES = 72


def hash_password(password: str) -> str:
    return bcrypt.hashpw(password.encode("utf-8")[:_MAX_PASSWORD_BYTES], bcrypt.gensalt()).decode("utf-8")


def verify_password(password: str, password_hash: str) -> bool:
    return bcrypt.checkpw(password.encode("utf-8")[:_MAX_PASSWORD_BYTES], password_hash.encode("utf-8"))


def create_access_token(subject: str) -> str:
    now = datetime.now(timezone.utc)
    payload = {
        "sub": subject,
        "iat": now,
        "exp": now + timedelta(minutes=JWT_EXPIRES_MINUTES),
    }
    return jwt.encode(payload, JWT_SECRET, algorithm=JWT_ALGORITHM)


def decode_access_token(token: str) -> str | None:
    """Returns the user id (`sub`) if the token is valid, else None."""
    try:
        payload = jwt.decode(token, JWT_SECRET, algorithms=[JWT_ALGORITHM])
        return payload.get("sub")
    except jwt.PyJWTError:
        return None
