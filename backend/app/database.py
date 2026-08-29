"""SQLAlchemy engine/session setup.

Defaults to a local SQLite file (`nexbit.db`, gitignored) so the backend
runs with zero extra setup. Swapping to Postgres later is just changing
DATABASE_URL in .env — nothing else in this app talks to SQLite directly.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import DATABASE_URL

# Some hosts (Render included) hand out the old "postgres://" scheme,
# which SQLAlchemy 1.4+ no longer accepts — normalize it here rather
# than requiring every deploy target to get this exactly right.
_db_url = DATABASE_URL
if _db_url.startswith("postgres://"):
    _db_url = _db_url.replace("postgres://", "postgresql://", 1)

connect_args = {"check_same_thread": False} if _db_url.startswith("sqlite") else {}
engine = create_engine(_db_url, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
