# Deploying to PythonAnywhere (free tier, no card required)

PythonAnywhere's free "Beginner" account doesn't ask for payment info,
which is why this app ended up here instead of Render. Its free web
apps run over WSGI, and the backend is a Flask app (WSGI natively) —
`wsgi_pythonanywhere_template.py` just imports it directly, no adapter
needed. (An earlier version used FastAPI over an ASGI→WSGI adapter,
which hung on every real request under PythonAnywhere's uWSGI setup for
reasons not worth chasing — Flask sidesteps that entirely.) Its
per-user disk is also persistent (unlike most container-based PaaS), so
SQLite is genuinely fine here — no separate database service needed.

## Steps

1. **Sign up** at [pythonanywhere.com](https://www.pythonanywhere.com)
   — free "Beginner" plan, no card.

2. **Open a Bash console** (Dashboard → New console → Bash) and clone
   this repo:
   ```bash
   git clone https://github.com/bimakomunity123-cmd/Nexbit.git
   cd Nexbit/backend
   ```
   (The backend was originally developed on a `backend-deploy` branch
   before it existed on `main` at all — that branch is now stale and
   long behind `main`; always deploy from `main`.)

3. **Create a virtualenv and install dependencies** (still in that
   Bash console):
   ```bash
   mkvirtualenv --python=python3.10 nexbit-venv
   pip install -r requirements.txt
   ```
   (`mkvirtualenv` activates it automatically. If you open a new console
   later, reactivate with `workon nexbit-venv`.)

4. **Generate a real JWT secret** and keep it somewhere safe for the
   next step:
   ```bash
   python3 -c "import secrets; print(secrets.token_hex(32))"
   ```

5. **Create the web app**: Dashboard → **Web** tab → **Add a new web
   app** → pick your domain (`<yourusername>.pythonanywhere.com`) →
   **Manual configuration** → same Python version as step 3.

6. **Set the virtualenv path** on that same Web tab, in the
   "Virtualenv" section: `/home/<yourusername>/.virtualenvs/nexbit-venv`.

7. **Edit the WSGI config file** — the Web tab links to it (something
   like `/var/www/<yourusername>_pythonanywhere_com_wsgi.py`, editable
   right in the browser). Replace its entire contents with
   `wsgi_pythonanywhere_template.py`'s, then fill in:
   - `PROJECT_DIR` → `/home/<yourusername>/Nexbit/backend`
   - `JWT_SECRET` → the value generated in step 4

8. **Reload the web app** (green button, top of the Web tab).

9. **Verify**: open `https://<yourusername>.pythonanywhere.com/health`
   — should show `{"status":"ok"}`.

## Updating after a `git push`

PythonAnywhere doesn't auto-deploy on push. After pushing changes:
```bash
cd ~/Nexbit && git pull
workon nexbit-venv && pip install -r backend/requirements.txt  # only if dependencies changed
```
then reload the web app from the Web tab again.

## Limits worth knowing

Free accounts get limited daily CPU seconds (plenty for a demo, not for
real traffic) and outbound internet access is allowlisted to specific
domains — irrelevant here since this backend doesn't call out to any
third-party API itself.
