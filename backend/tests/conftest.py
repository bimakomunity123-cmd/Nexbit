"""Shared pytest fixtures for the whole backend test suite.

Everything here revolves around one thing: get a real Flask app talking
to a throwaway SQLite database, isolated from both the real nexbit.db
and from every other test, and with a clean rate-limit slate — so tests
can freely register/login/hammer endpoints without leaking state into
each other or touching anything a developer actually cares about.
"""
import os
import tempfile

import pytest

# Must happen before `app.*` is imported anywhere — app/config.py reads
# these once, at import time, and every other module imports from it.
_TEST_DB_FD, _TEST_DB_PATH = tempfile.mkstemp(suffix=".db")
os.close(_TEST_DB_FD)
os.environ["DATABASE_URL"] = f"sqlite:///{_TEST_DB_PATH}"
os.environ["JWT_SECRET"] = "test-secret-not-for-production-32bytes-min"

from app.database import Base, engine  # noqa: E402
from app.main import app as flask_app  # noqa: E402
from app.rate_limit import limiter  # noqa: E402


@pytest.fixture(scope="session", autouse=True)
def _cleanup_db_file():
    yield
    engine.dispose()
    try:
        os.remove(_TEST_DB_PATH)
    except OSError:
        pass  # already gone, or still locked — not worth failing the run over


@pytest.fixture(autouse=True)
def _fresh_database():
    """Wipes and recreates every table before each test, so no test
    ever sees another's leftover users/positions/orders."""
    Base.metadata.drop_all(bind=engine)
    Base.metadata.create_all(bind=engine)
    yield


@pytest.fixture(autouse=True)
def _fresh_rate_limits():
    """Flask-Limiter's in-memory storage lives for the whole process,
    not per-test — reset it before each test so one test's requests
    never count toward another's limit (test_rate_limiting.py included,
    which deliberately wants to start from zero)."""
    limiter.reset()
    yield


@pytest.fixture
def client():
    flask_app.config.update(TESTING=True)
    with flask_app.test_client() as c:
        yield c
