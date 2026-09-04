"""Tiny in-process schema patcher — this demo has no Alembic (see
main.py's comment above Base.metadata.create_all), and create_all only
creates missing TABLES, it never alters an existing one's columns. So
whenever a new column is added to an existing model (Position.status
and friends, added when closed positions started being kept for the
Trade History tab instead of deleted), anyone with a database from
before that change needs it patched in by hand.

Runs once at startup, right after create_all(). Fully idempotent
(checks what's already there first via SQLAlchemy's dialect-agnostic
inspector) and safe to leave in forever — a no-op once every column
already exists, including on a brand-new database that create_all just
built with every column present from the start.
"""
from sqlalchemy import inspect, text

from .database import engine

# table -> {new column: DDL type/default clause}. Add a new entry here
# whenever a future change adds a column to an existing (not brand-new)
# table — a brand-new table needs no entry, create_all already handles it.
_COLUMN_ADDITIONS = {
    "positions": {
        "status": "VARCHAR DEFAULT 'open'",
        "exit_price": "FLOAT",
        "realized_pnl": "FLOAT",
        "closed_at": "DATETIME",
    },
    "users": {
        "is_active": "BOOLEAN DEFAULT 1",
        "two_factor_enabled": "BOOLEAN DEFAULT 0",
    },
}


def run() -> None:
    inspector = inspect(engine)
    existing_tables = set(inspector.get_table_names())
    with engine.begin() as conn:
        for table, columns in _COLUMN_ADDITIONS.items():
            if table not in existing_tables:
                continue  # fresh DB — create_all already built it with every column
            existing_columns = {c["name"] for c in inspector.get_columns(table)}
            for column, ddl in columns.items():
                if column not in existing_columns:
                    conn.execute(text(f"ALTER TABLE {table} ADD COLUMN {column} {ddl}"))
