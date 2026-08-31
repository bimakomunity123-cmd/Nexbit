"""Shared Flask-Limiter instance, applied to the auth/spot/trading
endpoints most worth protecting from brute-force or spam (login,
register, password reset, order creation).

Uses the default in-memory storage — fine for this demo's single-
process deployment (PythonAnywhere's free tier runs one worker, and
local dev is a single process too), but each worker would keep its own
counters if this ever ran with multiple processes, and every counter
resets on restart/reload. A real production deployment needs a shared
backend instead (Redis, via Limiter's `storage_uri`) so limits actually
hold across workers and survive a restart.
"""
from flask_limiter import Limiter
from flask_limiter.util import get_remote_address

limiter = Limiter(
    key_func=get_remote_address,
    # A generous fallback for every route that isn't given its own
    # tighter limit below — not meant to be the real defense, just a
    # backstop against something hammering the API entirely.
    default_limits=["200 per hour"],
)
