from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from .config import CORS_ORIGIN_REGEX, CORS_ORIGINS
from .database import Base, engine
from .routers import auth

# Dev-friendly: create tables on startup instead of requiring a separate
# migration step. Fine for SQLite + this early stage; swap for real
# migrations (Alembic) once the schema needs to evolve without wiping data.
Base.metadata.create_all(bind=engine)

app = FastAPI(title="Nexbit API", version="0.1.0")

app.add_middleware(
    CORSMiddleware,
    allow_origins=CORS_ORIGINS,
    allow_origin_regex=CORS_ORIGIN_REGEX,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(auth.router)


@app.get("/health")
def health():
    return {"status": "ok"}
