"""App configuration, loaded from environment variables (.env in dev).

JWT_SECRET has a dev-only fallback so `uvicorn app.main:app` works out of
the box with zero setup, but that fallback is intentionally obvious and
MUST be overridden (via a real .env, not committed) before this is ever
exposed to the internet — anyone who reads this file could forge tokens
otherwise.
"""
import os

from dotenv import load_dotenv

load_dotenv()

JWT_SECRET = os.getenv("JWT_SECRET", "dev-only-insecure-secret-change-me")
JWT_ALGORITHM = "HS256"
JWT_EXPIRES_MINUTES = int(os.getenv("JWT_EXPIRES_MINUTES", "60"))

DATABASE_URL = os.getenv("DATABASE_URL", "sqlite:///./nexbit.db")

# Origins allowed to call this API. The deployed demo's exact origin,
# plus a regex for local dev — `flutter run -d chrome` picks a random
# port every time, so an exact-match list can't cover it.
CORS_ORIGINS = os.getenv(
    "CORS_ORIGINS",
    "https://bimakomunity123-cmd.github.io",
).split(",")
CORS_ORIGIN_REGEX = os.getenv("CORS_ORIGIN_REGEX", r"http://(localhost|127\.0\.0\.1)(:\d+)?")
