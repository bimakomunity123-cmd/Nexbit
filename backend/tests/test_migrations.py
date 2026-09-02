"""Tests for migrations.py's idempotent column-patching helper — this is
the difference between a routine `git pull` + reload working on the
live PythonAnywhere database and it crashing with "no such column"
once Position gained status/exit_price/realized_pnl/closed_at.
"""
import os
import tempfile

from sqlalchemy import create_engine, inspect, text

from app import migrations

_NEW_COLUMNS = {"status", "exit_price", "realized_pnl", "closed_at"}


def _make_old_schema_db():
    """A standalone sqlite file with `positions` in its pre-Trade-History
    shape — no status/exit_price/realized_pnl/closed_at — plus one row,
    simulating a real user's already-deployed database.
    """
    fd, path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    engine = create_engine(f"sqlite:///{path}")
    with engine.begin() as conn:
        conn.execute(
            text(
                "CREATE TABLE positions ("
                "id VARCHAR PRIMARY KEY, user_id VARCHAR, contract_id VARCHAR, "
                "side VARCHAR, size FLOAT, entry_price FLOAT, leverage INTEGER, "
                "margin_mode VARCHAR, opened_at DATETIME)"
            )
        )
        conn.execute(
            text(
                "INSERT INTO positions "
                "(id, user_id, contract_id, side, size, entry_price, leverage, margin_mode, opened_at) "
                "VALUES ('p1', 'u1', 'BTC', 'long', 0.1, 70000.0, 10, 'isolated', '2024-01-01 00:00:00')"
            )
        )
    return engine, path


def test_run_adds_missing_columns_to_a_pre_existing_table(monkeypatch):
    engine, path = _make_old_schema_db()
    monkeypatch.setattr(migrations, "engine", engine)
    try:
        migrations.run()
        columns = {c["name"] for c in inspect(engine).get_columns("positions")}
        assert _NEW_COLUMNS <= columns

        # A pre-existing row must come out the other side still counting
        # as an open position (the column default, not NULL) — a real
        # user's already-open position can't silently vanish from every
        # "open positions" query just because the schema evolved under it.
        with engine.connect() as conn:
            row = conn.execute(text("SELECT status, exit_price FROM positions WHERE id='p1'")).fetchone()
        assert row[0] == "open"
        assert row[1] is None
    finally:
        engine.dispose()
        os.remove(path)


def test_run_is_idempotent(monkeypatch):
    engine, path = _make_old_schema_db()
    monkeypatch.setattr(migrations, "engine", engine)
    try:
        migrations.run()
        migrations.run()  # must not raise "duplicate column" the second time
        columns = {c["name"] for c in inspect(engine).get_columns("positions")}
        assert _NEW_COLUMNS <= columns
    finally:
        engine.dispose()
        os.remove(path)


def test_run_is_a_noop_on_a_table_that_already_has_every_column():
    # The suite's own database (app.database.engine, via conftest) always
    # has the up-to-date schema straight from create_all — running
    # against it must do nothing and, above all, not error.
    migrations.run()
