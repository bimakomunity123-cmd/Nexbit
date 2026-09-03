"""KYC-lite — see KycVerification's docstring in models.py for the "this
is NOT real identity verification" disclosure. Status is derived rather
than stored: no row for a user means 'unverified'; a row younger than
_REVIEW_DELAY means 'pending'; older means 'verified'. No cron/
background job needed — the delay is just computed against
submitted_at whenever status is read.
"""
from datetime import datetime, timedelta, timezone

from flask import Blueprint, jsonify, request

from ..auth_helpers import current_user
from ..database import SessionLocal
from ..models import KycVerification
from ..rate_limit import limiter
from ..schemas import KycStatusOut, SubmitKycRequest

kyc_bp = Blueprint("kyc", __name__, url_prefix="/kyc")

_UNAUTHORIZED = ({"detail": "Missing or invalid bearer token"}, 401)

# Short enough to demo a real "pending -> verified" transition without
# an actual wait; long enough that checking status right after
# submitting still shows 'pending' rather than resolving instantly.
_REVIEW_DELAY = timedelta(seconds=15)


def _status_dict(record: KycVerification | None) -> dict:
    if record is None:
        return {"status": "unverified", "full_name": None, "id_number": None, "submitted_at": None}
    submitted_at = record.submitted_at.replace(tzinfo=timezone.utc)
    status = "pending" if datetime.now(timezone.utc) - submitted_at < _REVIEW_DELAY else "verified"
    return {
        "status": status,
        "full_name": record.full_name,
        "id_number": record.id_number,
        "submitted_at": record.submitted_at,
    }


@kyc_bp.get("/status")
def get_status():
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]
        record = db.get(KycVerification, user.id)
        return jsonify(KycStatusOut.model_validate(_status_dict(record)).model_dump(mode="json"))
    finally:
        db.close()


@kyc_bp.post("/submit")
@limiter.limit("5 per hour")
def submit():
    """One submission per user, ever — there's no reject/resubmit flow
    in this lite version. Once a row exists the user is already
    'pending' or 'verified' (see _status_dict), so a second POST is
    always rejected outright rather than needing its own status check.
    """
    db = SessionLocal()
    try:
        user = current_user(db)
        if user is None:
            return jsonify(_UNAUTHORIZED[0]), _UNAUTHORIZED[1]

        if db.get(KycVerification, user.id) is not None:
            return jsonify({"detail": "Verifikasi sudah pernah diajukan"}), 400

        body = SubmitKycRequest.model_validate(request.get_json(force=True, silent=False) or {})
        record = KycVerification(user_id=user.id, full_name=body.full_name, id_number=body.id_number)
        db.add(record)
        db.commit()
        db.refresh(record)
        return jsonify(KycStatusOut.model_validate(_status_dict(record)).model_dump(mode="json")), 201
    finally:
        db.close()
