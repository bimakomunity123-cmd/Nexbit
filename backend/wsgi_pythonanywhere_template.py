"""Template for PythonAnywhere's WSGI config file.

The backend is a Flask app, which speaks WSGI natively — no adapter
needed (an earlier version of this file used a2wsgi to bridge a FastAPI/
ASGI app, which turned out to hang under PythonAnywhere's uWSGI setup
for reasons not worth chasing further; Flask sidesteps the whole
problem).

This file is a TEMPLATE, not something PythonAnywhere reads directly.
On the "Web" tab of your PythonAnywhere dashboard, open the actual WSGI
config file it links to (something like
/var/www/<yourusername>_pythonanywhere_com_wsgi.py) and replace its
contents with this, filling in the two <...> placeholders first. See
DEPLOY_PYTHONANYWHERE.md for the full walkthrough.
"""
import os
import sys

# 1) Path to this backend/ folder inside your PythonAnywhere home dir —
#    e.g. '/home/yourusername/Nexbit/backend'.
PROJECT_DIR = "/home/<yourusername>/Nexbit/backend"
if PROJECT_DIR not in sys.path:
    sys.path.insert(0, PROJECT_DIR)

# 2) Config — PythonAnywhere's free tier has no dashboard env-var panel,
#    so these are set directly here instead of via .env.
#    Generate a real secret with:
#      python3 -c "import secrets; print(secrets.token_hex(32))"
os.environ.setdefault("JWT_SECRET", "<paste a real generated secret here>")
os.environ.setdefault("JWT_EXPIRES_MINUTES", "60")
os.environ.setdefault("DATABASE_URL", f"sqlite:///{PROJECT_DIR}/nexbit.db")
os.environ.setdefault("CORS_ORIGINS", "https://bimakomunity123-cmd.github.io")
os.environ.setdefault("CORS_ORIGIN_REGEX", r"http://(localhost|127\.0\.0\.1)(:\d+)?")

from app.main import app as application  # noqa: E402
