"""Tests for the Flask-Limiter setup in app/rate_limit.py — that the
tight limits on brute-force-able endpoints actually trigger, and that
the 429 response has this app's own {"detail": ...} shape rather than
Flask-Limiter's default plain-text description.
"""
from .helpers import register


class TestLoginRateLimit:
    def test_login_blocked_after_15_attempts_in_5_minutes(self, client):
        register(client, email="ratelimited@example.com", password="password123")

        for _ in range(15):
            resp = client.post(
                "/auth/login", json={"email": "ratelimited@example.com", "password": "wrongpassword"}
            )
            assert resp.status_code == 401

        blocked = client.post(
            "/auth/login", json={"email": "ratelimited@example.com", "password": "wrongpassword"}
        )
        assert blocked.status_code == 429
        assert blocked.get_json() == {"detail": "Terlalu banyak percobaan. Coba lagi beberapa saat lagi."}

    def test_login_rate_limit_is_shared_across_different_emails(self, client):
        # Keyed by IP (see rate_limit.py), not by the submitted email —
        # otherwise an attacker could dodge the limit just by trying a
        # different email on every request.
        for i in range(15):
            client.post("/auth/login", json={"email": f"attempt{i}@example.com", "password": "x"})

        blocked = client.post("/auth/login", json={"email": "yet-another@example.com", "password": "x"})
        assert blocked.status_code == 429


class TestRegisterRateLimit:
    def test_register_blocked_after_10_attempts_in_an_hour(self, client):
        for i in range(10):
            resp = register(client, email=f"regspam{i}@example.com")
            assert resp.status_code == 201

        blocked = register(client, email="regspam-overflow@example.com")
        assert blocked.status_code == 429


class TestForgotPasswordRateLimit:
    def test_forgot_password_blocked_after_10_attempts_in_an_hour(self, client):
        register(client, email="forgotspam@example.com")
        for _ in range(10):
            resp = client.post("/auth/forgot-password", json={"email": "forgotspam@example.com"})
            assert resp.status_code == 200

        blocked = client.post("/auth/forgot-password", json={"email": "forgotspam@example.com"})
        assert blocked.status_code == 429
