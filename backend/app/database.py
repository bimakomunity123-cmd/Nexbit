"""SQLAlchemy engine/session setup.

Defaults to a local SQLite file (`nexbit.db`, gitignored) so the backend
runs with zero extra setup. Swapping to Postgres later is just changing
DATABASE_URL in .env — nothing else in this app talks to SQLite directly.
"""
from sqlalchemy import create_engine
from sqlalchemy.orm import DeclarativeBase, sessionmaker

from .config import DATABASE_URL

connect_args = {"check_same_thread": False} if DATABASE_URL.startswith("sqlite") else {}
engine = create_engine(DATABASE_URL, connect_args=connect_args)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
