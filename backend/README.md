# Nexbit backend

Real API behind the Flutter app's auth, Futures balance/positions, and
Spot wallet/orders — replacing what used to be entirely mock/in-memory
Flutter state. Live at `https://morphy.pythonanywhere.com`. See the
root README's [Yang perlu diketahui sebelum dianggap "siap pakai"](../README.md#yang-perlu-diketahui-sebelum-dianggap-siap-pakai)
section for what's still missing before this could handle real money
(real market-data verification, a production database, KYC/compliance,
etc).

Flask + SQLAlchemy + SQLite (swap to Postgres later by changing
`DATABASE_URL` — nothing else needs to change). Password hashing uses
`bcrypt` directly, not `passlib` — passlib's bcrypt backend is broken
against `bcrypt>=4.1` (raises `AttributeError: module 'bcrypt' has no
attribute '__about__'`), a known upstream incompatibility.

Originally built with FastAPI, rewritten to Flask after FastAPI (served
via an ASGI→WSGI adapter, `a2wsgi`) hung on every real HTTP request once
deployed under PythonAnywhere's uWSGI — worked fine called directly in a
Python console, timed out (504) over actual HTTP, and wasn't worth
chasing further. Flask speaks WSGI natively, which every one of these
hosts (PythonAnywhere, Render via gunicorn) supports without an adapter
in the loop.

## Run it

```bash
cd backend
python3 -m venv .venv
./.venv/Scripts/pip.exe install -r requirements.txt   # Windows
# .venv/bin/pip install -r requirements.txt            # macOS/Linux

cp .env.example .env   # then edit JWT_SECRET at minimum

./.venv/Scripts/python.exe -m app.main
```

Runs on `http://localhost:8020` with the debug reloader on. Point the
Flutter app at it with
`flutter run -d chrome --dart-define=API_BASE_URL=http://localhost:8020`.

## Endpoints

All error responses share one shape: `{"detail": "..."}`  (or, for a
Pydantic validation failure, `{"detail": [...]}` with per-field errors).
Every rate limit below returns 429 with `{"detail": "Terlalu banyak
percobaan. Coba lagi beberapa saat lagi."}` once exceeded.

### Auth (`/auth`)

| Method | Path                    | Auth      | Rate limit    | Notes |
|--------|-------------------------|-----------|----------------|-------|
| POST   | `/auth/register`        | —         | 10/hour        | `{name, email, password}` → token + user |
| POST   | `/auth/login`           | —         | 15/5 min       | `{email, password}` → token + user |
| GET    | `/auth/me`              | Bearer JWT| —              | Current user from the token |
| POST   | `/auth/change-password` | Bearer JWT| 20/hour        | `{old_password, new_password}` |
| PATCH  | `/auth/profile`         | Bearer JWT| —              | `{name}` → updated user |
| POST   | `/auth/forgot-password` | —         | 10/hour        | `{email}` → same response whether or not the email exists; `reset_token` present only if it does (see below) |
| POST   | `/auth/reset-password`  | —         | 20/hour        | `{token, new_password}` |

**Demo-only compromise, not something a real product should do:**
`/auth/forgot-password` returns the reset token directly in its JSON
response instead of emailing it, since this app has no email/SMTP
service configured. It's clearly labeled "Mode Demo" in the Flutter UI.
The endpoint still can't be used to enumerate accounts — the response
text is identical either way, only `reset_token`'s presence differs.

### Futures trading (`/trading`)

| Method | Path                              | Auth      | Rate limit | Notes |
|--------|-----------------------------------|-----------|-------------|-------|
| GET    | `/trading/account`                | Bearer JWT| —           | `{balance, realized_pnl}` — created on first access |
| GET    | `/trading/positions`              | Bearer JWT| —           | List of open positions |
| POST   | `/trading/positions`               | Bearer JWT| 60/min      | `{contract_id, side, size, entry_price, leverage, margin_mode}` |
| POST   | `/trading/positions/<id>/close`   | Bearer JWT| 60/min      | `{realized_pnl}` — client-computed, see note below |

### Spot trading (`/spot`)

| Method | Path                        | Auth      | Rate limit | Notes |
|--------|-----------------------------|-----------|-------------|-------|
| GET    | `/spot/wallet`              | Bearer JWT| —           | `{idr_balance}` — starts at 50,000,000, created on first access |
| GET    | `/spot/holdings`            | Bearer JWT| —           | Per-asset quantities currently held (> 0 only) |
| GET    | `/spot/orders`              | Bearer JWT| —           | All orders, newest first |
| POST   | `/spot/orders`              | Bearer JWT| 60/min      | `{asset_id, side, order_type, price, amount}` — Market fills immediately (balance/holding updated, 400 if insufficient); Limit/Stop-Limit just get recorded as open |
| POST   | `/spot/orders/<id>/cancel`  | Bearer JWT| 60/min      | Only works on an order still `open` |

**Demo-only compromise, not something a real product should do:**
`price`/`entry_price`/`realized_pnl` above are client-supplied and
trusted as-is — this backend has no live market-data feed of its own to
verify them against. Fine for this demo's mock trading; a real ledger
would never trust a client-computed price or PnL figure. Also: neither
Futures nor Spot has a real matching engine — Limit/Stop-Limit orders
never auto-fill regardless of price, only Market/Instant orders execute
immediately.

### Misc

| Method | Path      | Auth | Notes           |
|--------|-----------|------|------------------|
| GET    | `/health` | —    | Liveness check  |

## Deploying

**Live today: PythonAnywhere** (free tier, no card required) — see
[DEPLOY_PYTHONANYWHERE.md](DEPLOY_PYTHONANYWHERE.md) for the full
walkthrough and how to push updates to it.

`render.yaml` at the repo root is an alternative Render Blueprint
(web service + Postgres) that was tried first and abandoned — Render's
free tier requires a payment card even for the Blueprint flow, which is
why this ended up on PythonAnywhere instead. It's kept in the repo as a
documented alternative in case that trade-off is ever preferable (e.g.
Postgres instead of SQLite, no PythonAnywhere CPU-second limits).
Whichever host is used, update the Flutter app's `kApiBaseUrl`
(`lib/core/api/api_client.dart`, or `--dart-define=API_BASE_URL=...`
at build time) to match before rebuilding the frontend.
