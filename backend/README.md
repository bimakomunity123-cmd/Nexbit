# Nexbit backend

Real auth API (register/login/JWT) replacing the "any credentials
accepted" behavior in the Flutter app. This is Phase 1 of the
launch-readiness roadmap — the part that's realistic to build directly;
see the project's launch-readiness assessment for what's still missing
(real market data, custody, compliance, etc).

FastAPI + SQLAlchemy + SQLite (swap to Postgres later by changing
`DATABASE_URL` — nothing else needs to change). Password hashing uses
`bcrypt` directly, not `passlib` — passlib's bcrypt backend is broken
against `bcrypt>=4.1` (raises `AttributeError: module 'bcrypt' has no
attribute '__about__'`), a known upstream incompatibility.

## Run it

```bash
cd backend
python3 -m venv .venv
./.venv/Scripts/pip.exe install -r requirements.txt   # Windows
# .venv/bin/pip install -r requirements.txt            # macOS/Linux

cp .env.example .env   # then edit JWT_SECRET at minimum

./.venv/Scripts/python.exe -m uvicorn app.main:app --reload --port 8020
```

Interactive API docs at `http://localhost:8020/docs` once it's running.

## Endpoints

| Method | Path            | Auth      | Notes                              |
|--------|-----------------|-----------|-------------------------------------|
| POST   | `/auth/register`| —         | `{name, email, password}` → token + user |
| POST   | `/auth/login`   | —         | `{email, password}` → token + user  |
| GET    | `/auth/me`      | Bearer JWT| Current user from the token         |
| GET    | `/health`       | —         | Liveness check                      |

## What's NOT here yet

Just auth. Balances, orders, positions, and real market data are still
mock state on the Flutter side — wiring those to this backend (or a
real market-data provider) is the next slice of Phase 1, not done here.

## Deploying

Not deployed anywhere yet — the live GitHub Pages demo currently has no
backend to call. Render, Railway, or Fly.io all have a free tier that
fits this app; whichever you pick, set `CORS_ORIGINS` to the deployed
API's actual allowed frontend origin(s) and `DATABASE_URL` to a real
Postgres instance instead of SQLite (SQLite's file-based storage doesn't
survive most hosts' ephemeral filesystems, and won't safely support
concurrent connections in production anyway).
