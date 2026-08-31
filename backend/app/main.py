import re

from flask import Flask, jsonify, request
from flask_cors import CORS
from flask_limiter.errors import RateLimitExceeded
from pydantic import ValidationError
from werkzeug.exceptions import HTTPException

from .config import CORS_ORIGIN_REGEX, CORS_ORIGINS
from .database import Base, engine
from .rate_limit import limiter
from .routers.auth import auth_bp
from .routers.spot import spot_bp
from .routers.trading import trading_bp

# Dev-friendly: create tables on startup instead of requiring a separate
# migration step. Fine for SQLite + this early stage; swap for real
# migrations (Alembic) once the schema needs to evolve without wiping data.
# All router imports above must come first so Account/Position/SpotWallet/
# SpotHolding/SpotOrder (used only by trading.py/spot.py) are registered
# on Base.metadata before this runs — otherwise those tables would
# silently never get created.
Base.metadata.create_all(bind=engine)

app = Flask(__name__)
CORS(app, origins=[*CORS_ORIGINS, re.compile(CORS_ORIGIN_REGEX)], supports_credentials=True)
limiter.init_app(app)
app.register_blueprint(auth_bp)
app.register_blueprint(trading_bp)
app.register_blueprint(spot_bp)


@app.errorhandler(ValidationError)
def handle_validation_error(err: ValidationError):
    # Mirrors FastAPI's {"detail": ...} error shape so api_client.dart's
    # error handling doesn't need to know which backend framework is
    # behind it.
    return jsonify({"detail": err.errors()}), 422


@app.errorhandler(RateLimitExceeded)
def handle_rate_limit_exceeded(err: RateLimitExceeded):
    # Registered ahead of the generic HTTPException handler below (Flask
    # dispatches to the most specific matching handler) so this gets a
    # readable Indonesian message instead of Flask-Limiter's default
    # "4 per 1 minute" description.
    return jsonify({"detail": "Terlalu banyak percobaan. Coba lagi beberapa saat lagi."}), 429


@app.errorhandler(HTTPException)
def handle_http_exception(err: HTTPException):
    # Flask/Werkzeug's default error pages are HTML — normalize to the
    # same {"detail": ...} JSON shape as everything else (covers e.g. a
    # malformed/missing JSON body, 404, 405).
    return jsonify({"detail": err.description or err.name}), err.code or 500


@app.get("/health")
def health():
    return jsonify({"status": "ok"})


if __name__ == "__main__":
    # Local dev only — `python -m app.main` from backend/. Production
    # (Render, PythonAnywhere) serves `app` via gunicorn/WSGI instead.
    app.run(host="0.0.0.0", port=8020, debug=True)
