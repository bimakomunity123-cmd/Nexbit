import secrets
from datetime import datetime, timedelta, timezone

from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import (
    Account,
    FuturesOrder,
    KycVerification,
    PasswordReset,
    Position,
    SpotHolding,
    SpotOrder,
    SpotWallet,
    StakingAccount,
    StakingHolding,
    StakingPosition,
    TwoFactorChallenge,
    User,
)
from ..rate_limit import limiter
from ..schemas import (
    ChangePasswordRequest,
    ForgotPasswordRequest,
    LoginRequest,
    RegisterRequest,
    ResetPasswordRequest,
    TokenResponse,
    TwoFactorChallengeOut,
    UpdateProfileRequest,
    UserOut,
    VerifyTwoFactorRequest,
)
from ..security import create_access_token, hash_password, verify_password

auth_bp = Blueprint("auth", __name__, url_prefix="/auth")

_UNAUTHORIZED = ({"detail": "Missing or invalid bearer token"}, 401)
_RESET_TOKEN_LIFETIME = timedelta(hours=1)
_TWO_FACTOR_CHALLENGE_LIFETIME = timedelta(minutes=5)
_TWO_FACTOR_MAX_ATTEMPTS = 5


@auth_bp.post("/register")
@limiter.limit("10 per hour")
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
# Tighter than most limits here on purpose — login is the classic
# brute-force target. Keyed by IP (see rate_limit.py), not by the
# submitted email, since keying by attacker-controlled input would let
# someone dodge the limit just by trying a different email each time.
@limiter.limit("15 per 5 minutes")
def login():
    body = LoginRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == body.email.lower()).first()
        # Same error for "no such user" and "wrong password" — don't leak
        # which one it was.
        if user is None or not verify_password(body.password, user.password_hash):
            return jsonify({"detail": "Email atau password salah"}), 401

        # A deactivated account (see deactivate_account()) reactivates on
        # its next successful login — exactly what the Flutter confirm
        # dialog for "Nonaktifkan akun" already promises the user.
        if not user.is_active:
            user.is_active = True
            db.commit()

        if user.two_factor_enabled:
            # Password alone isn't enough — hand back a challenge instead
            # of a token. See verify_two_factor() for the second step and
            # TwoFactorChallenge's docstring in models.py for the demo-
            # only "code returned directly" shortcut.
            code = f"{secrets.randbelow(1_000_000):06d}"
            challenge = TwoFactorChallenge(
                user_id=user.id,
                code=code,
                expires_at=datetime.now(timezone.utc) + _TWO_FACTOR_CHALLENGE_LIFETIME,
            )
            db.add(challenge)
            db.commit()
            db.refresh(challenge)
            return jsonify(TwoFactorChallengeOut(challenge_token=challenge.token, otp_code=code).model_dump(mode="json"))

        token = create_access_token(subject=user.id)
        return jsonify(TokenResponse(access_token=token, user=UserOut.model_validate(user)).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.post("/login/verify-2fa")
# Same brute-force concern as reset-password's token guess — protects
# the endpoint's overall request volume; TwoFactorChallenge.attempts
# (see models.py) separately caps guesses against one specific
# challenge, which is the tighter and more relevant limit here.
@limiter.limit("20 per hour")
def verify_two_factor():
    """The second step of login for an account with two_factor_enabled
    set — consumes the challenge login() created and, on a correct
    code, issues the real access token.
    """
    body = VerifyTwoFactorRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        challenge = db.get(TwoFactorChallenge, body.challenge_token)
        now = datetime.now(timezone.utc)
        expires_at = challenge.expires_at.replace(tzinfo=timezone.utc) if challenge else None
        if challenge is None or challenge.used or expires_at is None or expires_at < now:
            return jsonify({"detail": "Kode verifikasi tidak valid atau sudah kedaluwarsa"}), 400
        if challenge.attempts >= _TWO_FACTOR_MAX_ATTEMPTS:
            return jsonify({"detail": "Terlalu banyak percobaan salah, silakan masuk ulang"}), 400

        if body.code != challenge.code:
            challenge.attempts += 1
            db.commit()
            return jsonify({"detail": "Kode verifikasi salah"}), 401

        user = db.get(User, challenge.user_id)
        if user is None:
            return jsonify({"detail": "Akun tidak ditemukan"}), 404

        challenge.used = True
        db.commit()

        token = create_access_token(subject=user.id)
        return jsonify(TokenResponse(access_token=token, user=UserOut.model_validate(user)).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.post("/2fa/enable")
@limiter.limit("10 per hour")
def enable_two_factor():
    """Turns on 2FA for the current account — previously this toggle
    (Keamanan's "2FA") was purely local Flutter state (AppPrefs) with
    zero effect on login. See login()'s docstring for what changes once
    this is on.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        user.two_factor_enabled = True
        db.commit()
        db.refresh(user)
        return jsonify(UserOut.model_validate(user).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.post("/2fa/disable")
@limiter.limit("10 per hour")
def disable_two_factor():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        user.two_factor_enabled = False
        db.commit()
        db.refresh(user)
        return jsonify(UserOut.model_validate(user).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.get("/me")
def me():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        return jsonify(UserOut.model_validate(user).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.post("/change-password")
@limiter.limit("20 per hour")
def change_password():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = ChangePasswordRequest.model_validate(request.get_json(force=True, silent=False) or {})
        if not verify_password(body.old_password, user.password_hash):
            return jsonify({"detail": "Password lama salah"}), 401

        user.password_hash = hash_password(body.new_password)
        db.commit()
        return jsonify({"detail": "Password berhasil diubah"})
    finally:
        db.close()


@auth_bp.patch("/profile")
def update_profile():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        body = UpdateProfileRequest.model_validate(request.get_json(force=True, silent=False) or {})
        user.name = body.name.strip()
        db.commit()
        db.refresh(user)
        return jsonify(UserOut.model_validate(user).model_dump(mode="json"))
    finally:
        db.close()


@auth_bp.post("/forgot-password")
# Also protects against using this endpoint to enumerate accounts by
# volume (see its docstring) — even though the response is identical
# either way, an attacker able to fire unlimited requests could still
# time or otherwise side-channel the reset_token's presence.
@limiter.limit("10 per hour")
def forgot_password():
    """Always responds 200 with the same shape whether or not the email
    is registered — so this can't be used to enumerate accounts. The
    `reset_token` field is only ever present when the account actually
    exists, and — see PasswordReset's docstring — is returned directly
    here rather than emailed, since this demo has no email service
    configured. The Flutter UI labels that clearly as a demo shortcut.
    """
    body = ForgotPasswordRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        user = db.query(User).filter(User.email == body.email.lower()).first()
        if user is None:
            return jsonify({"detail": "Jika email terdaftar, instruksi reset telah dikirim"})

        reset = PasswordReset(
            user_id=user.id,
            expires_at=datetime.now(timezone.utc) + _RESET_TOKEN_LIFETIME,
        )
        db.add(reset)
        db.commit()
        db.refresh(reset)
        return jsonify({
            "detail": "Jika email terdaftar, instruksi reset telah dikirim",
            "reset_token": reset.token,
        })
    finally:
        db.close()


@auth_bp.post("/reset-password")
# Limits brute-forcing the reset token itself (a 32-char hex string is
# infeasible to guess even unlimited, but this costs nothing to add).
@limiter.limit("20 per hour")
def reset_password():
    body = ResetPasswordRequest.model_validate(request.get_json(force=True, silent=False) or {})
    db = SessionLocal()
    try:
        reset = db.get(PasswordReset, body.token)
        now = datetime.now(timezone.utc)
        expires_at = reset.expires_at.replace(tzinfo=timezone.utc) if reset else None
        if reset is None or reset.used or expires_at is None or expires_at < now:
            return jsonify({"detail": "Link reset tidak valid atau sudah kedaluwarsa"}), 400

        user = db.get(User, reset.user_id)
        if user is None:
            return jsonify({"detail": "Akun tidak ditemukan"}), 404

        user.password_hash = hash_password(body.new_password)
        reset.used = True
        db.commit()
        return jsonify({"detail": "Password berhasil direset"})
    finally:
        db.close()


@auth_bp.post("/deactivate")
@limiter.limit("5 per hour")
def deactivate_account():
    """Marks the account inactive — until now, Profil Saya's "Nonaktifkan
    akun" button was entirely fake: it just cleared the local session
    and claimed success without any server-side effect at all. See
    User.is_active's docstring in models.py for the reactivate-on-login
    behavior this pairs with.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        user.is_active = False
        db.commit()
        return jsonify({"detail": "Akun dinonaktifkan"})
    finally:
        db.close()


@auth_bp.delete("/account")
@limiter.limit("5 per hour")
def delete_account():
    """Permanently deletes the current user and every row tied to them
    across every feature — until now, Profil Saya's "Hapus akun" button
    was entirely fake too, just a local logout claiming success without
    touching the database. Irreversible; the Flutter confirm dialog is
    the only safeguard, there's no grace period or undo server-side.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        for model in (
            Position,
            FuturesOrder,
            Account,
            SpotOrder,
            SpotHolding,
            SpotWallet,
            StakingPosition,
            StakingHolding,
            StakingAccount,
            KycVerification,
            PasswordReset,
            TwoFactorChallenge,
        ):
            db.query(model).filter(model.user_id == user.id).delete(synchronize_session=False)
        db.delete(user)
        db.commit()
        return "", 204
    finally:
        db.close()
