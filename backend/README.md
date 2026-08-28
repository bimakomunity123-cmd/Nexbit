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

## Deploying (Render)

`render.yaml` at the repo root is a Render Blueprint — it provisions
both the API service and a Postgres database in one go, with
`DATABASE_URL` wired between them automatically and `JWT_SECRET`
auto-generated (nobody needs to invent or store one by hand).

1. Push this repo to GitHub (already done — see the project's git
   history) on whichever branch has this backend.
2. Render dashboard → **New** → **Blueprint** → pick this repo and
   branch. Render reads `render.yaml` and shows what it's about to
   create (a web service + a free Postgres instance) — confirm.
3. Wait for the first deploy to finish, then hit
   `https://<your-service>.onrender.com/health` to confirm it's alive.
4. Update the Flutter app's `kApiBaseUrl`
   (`lib/core/api/api_client.dart`) to that URL (or pass
   `--dart-define=API_BASE_URL=https://<your-service>.onrender.com`
   at build time instead of hardcoding it) before rebuilding/redeploying
   the frontend — otherwise it's still pointed at `localhost:8020`.

Render's free web service tier spins down after inactivity and takes a
few seconds to wake back up on the next request — expect a slow first
login after the app has been idle. Check Render's current pricing page
for up-to-date free-tier limits; they change over time.
