"""Tests for /auth/* — register, login, me, change-password, profile,
forgot/reset-password.
"""
from datetime import datetime, timedelta, timezone

from app.database import SessionLocal
from app.models import PasswordReset, User
from app.security import hash_password

from .helpers import auth_headers, register, register_and_login


class TestRegister:
    def test_register_success(self, client):
        resp = register(client, name="Budi", email="budi@example.com", password="password123")
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["user"]["email"] == "budi@example.com"
        assert body["user"]["name"] == "Budi"
        assert "access_token" in body

    def test_register_duplicate_email_rejected(self, client):
        register(client, email="dupe@example.com")
        resp = register(client, email="dupe@example.com")
        assert resp.status_code == 409

    def test_register_email_is_case_insensitive_for_duplicates(self, client):
        register(client, email="Case@Example.com")
        resp = register(client, email="case@example.com")
        assert resp.status_code == 409

    def test_register_short_password_rejected(self, client):
        resp = register(client, email="short@example.com", password="short")
        assert resp.status_code == 422

    def test_register_invalid_email_rejected(self, client):
        resp = register(client, email="not-an-email")
        assert resp.status_code == 422


class TestLogin:
    def test_login_success(self, client):
        register(client, email="login@example.com", password="password123")
        resp = client.post("/auth/login", json={"email": "login@example.com", "password": "password123"})
        assert resp.status_code == 200
        assert "access_token" in resp.get_json()

    def test_login_wrong_password_rejected(self, client):
        register(client, email="wrongpw@example.com", password="password123")
        resp = client.post("/auth/login", json={"email": "wrongpw@example.com", "password": "nope12345"})
        assert resp.status_code == 401

    def test_login_nonexistent_email_rejected(self, client):
        resp = client.post("/auth/login", json={"email": "ghost@example.com", "password": "password123"})
        assert resp.status_code == 401

    def test_login_error_message_identical_for_missing_user_and_wrong_password(self, client):
        # Guards the "don't leak which one it was" behavior documented
        # in the route itself.
        register(client, email="same-message@example.com", password="password123")
        wrong_password = client.post(
            "/auth/login", json={"email": "same-message@example.com", "password": "nope12345"}
        )
        no_such_user = client.post("/auth/login", json={"email": "nobody@example.com", "password": "nope12345"})
        assert wrong_password.get_json() == no_such_user.get_json()


class TestMe:
    def test_me_with_valid_token(self, client):
        token, user = register_and_login(client, email="me@example.com")
        resp = client.get("/auth/me", headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["email"] == user["email"]

    def test_me_without_token_rejected(self, client):
        resp = client.get("/auth/me")
        assert resp.status_code == 401

    def test_me_with_garbage_token_rejected(self, client):
        resp = client.get("/auth/me", headers=auth_headers("not-a-real-token"))
        assert resp.status_code == 401


class TestChangePassword:
    def test_change_password_success_then_can_login_with_new_password(self, client):
        token, _ = register_and_login(client, email="changepw@example.com", password="password123")
        resp = client.post(
            "/auth/change-password",
            json={"old_password": "password123", "new_password": "newpassword456"},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200

        old_login = client.post("/auth/login", json={"email": "changepw@example.com", "password": "password123"})
        assert old_login.status_code == 401

        new_login = client.post("/auth/login", json={"email": "changepw@example.com", "password": "newpassword456"})
        assert new_login.status_code == 200

    def test_change_password_wrong_old_password_rejected(self, client):
        token, _ = register_and_login(client, email="wrongold@example.com", password="password123")
        resp = client.post(
            "/auth/change-password",
            json={"old_password": "totallywrong", "new_password": "newpassword456"},
            headers=auth_headers(token),
        )
        assert resp.status_code == 401

    def test_change_password_without_token_rejected(self, client):
        resp = client.post(
            "/auth/change-password", json={"old_password": "x", "new_password": "newpassword456"}
        )
        assert resp.status_code == 401


class TestUpdateProfile:
    def test_update_profile_name(self, client):
        token, _ = register_and_login(client, email="profile@example.com", name="Old Name")
        resp = client.patch("/auth/profile", json={"name": "New Name"}, headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["name"] == "New Name"

        me = client.get("/auth/me", headers=auth_headers(token))
        assert me.get_json()["name"] == "New Name"

    def test_update_profile_without_token_rejected(self, client):
        resp = client.patch("/auth/profile", json={"name": "New Name"})
        assert resp.status_code == 401


class TestForgotAndResetPassword:
    def test_forgot_password_existing_email_returns_token(self, client):
        register(client, email="forgot@example.com")
        resp = client.post("/auth/forgot-password", json={"email": "forgot@example.com"})
        assert resp.status_code == 200
        assert "reset_token" in resp.get_json()

    def test_forgot_password_nonexistent_email_same_shape_no_token(self, client):
        existing_resp = None
        register(client, email="exists@example.com")
        existing_resp = client.post("/auth/forgot-password", json={"email": "exists@example.com"})
        ghost_resp = client.post("/auth/forgot-password", json={"email": "ghost@example.com"})

        # Same response text either way (can't be used to enumerate
        # accounts) — only reset_token's presence differs.
        assert existing_resp.get_json()["detail"] == ghost_resp.get_json()["detail"]
        assert "reset_token" in existing_resp.get_json()
        assert "reset_token" not in ghost_resp.get_json()

    def test_reset_password_with_valid_token_then_can_login(self, client):
        register(client, email="reset@example.com", password="password123")
        forgot = client.post("/auth/forgot-password", json={"email": "reset@example.com"})
        token = forgot.get_json()["reset_token"]

        resp = client.post("/auth/reset-password", json={"token": token, "new_password": "brandnew789"})
        assert resp.status_code == 200

        login = client.post("/auth/login", json={"email": "reset@example.com", "password": "brandnew789"})
        assert login.status_code == 200

    def test_reset_password_token_cannot_be_reused(self, client):
        register(client, email="reuse@example.com")
        forgot = client.post("/auth/forgot-password", json={"email": "reuse@example.com"})
        token = forgot.get_json()["reset_token"]

        first = client.post("/auth/reset-password", json={"token": token, "new_password": "firstnew123"})
        assert first.status_code == 200

        second = client.post("/auth/reset-password", json={"token": token, "new_password": "secondnew123"})
        assert second.status_code == 400

    def test_reset_password_invalid_token_rejected(self, client):
        resp = client.post("/auth/reset-password", json={"token": "not-a-real-token", "new_password": "whatever123"})
        assert resp.status_code == 400

    def test_reset_password_expired_token_rejected(self, client):
        _, user = register_and_login(client, email="expired@example.com")
        db = SessionLocal()
        try:
            expired = PasswordReset(
                user_id=user["id"],
                expires_at=datetime.now(timezone.utc) - timedelta(hours=1),
            )
            db.add(expired)
            db.commit()
            db.refresh(expired)
            expired_token = expired.token
        finally:
            db.close()

        resp = client.post(
            "/auth/reset-password", json={"token": expired_token, "new_password": "whatever123"}
        )
        assert resp.status_code == 400


class TestPasswordHashing:
    def test_stored_password_is_not_plaintext(self, client):
        register(client, email="hashcheck@example.com", password="password123")
        db = SessionLocal()
        try:
            user = db.query(User).filter(User.email == "hashcheck@example.com").first()
            assert user is not None
            assert user.password_hash != "password123"
            assert user.password_hash.startswith("$2b$")  # bcrypt hash prefix
        finally:
            db.close()
        # hash_password/verify_password imported here just to keep the
        # import used and make the bcrypt dependency this test relies
        # on explicit.
        assert hash_password("x") != "x"
