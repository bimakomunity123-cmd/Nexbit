"""Tests for /kyc/* — the demo identity-verification-lite flow."""
from datetime import timedelta

from app.routers import kyc

from .helpers import auth_headers, register_and_login

_VALID_BODY = {"full_name": "Budi Santoso", "id_number": "1234567890123456"}


class TestStatus:
    def test_defaults_to_unverified(self, client):
        token, _ = register_and_login(client, email="kycstatus@example.com")
        resp = client.get("/kyc/status", headers=auth_headers(token))
        assert resp.status_code == 200
        body = resp.get_json()
        assert body["status"] == "unverified"
        assert body["full_name"] is None

    def test_without_token_rejected(self, client):
        resp = client.get("/kyc/status")
        assert resp.status_code == 401

    def test_isolated_per_user(self, client):
        token_a, _ = register_and_login(client, email="kyca@example.com")
        token_b, _ = register_and_login(client, email="kycb@example.com")
        client.post("/kyc/submit", json=_VALID_BODY, headers=auth_headers(token_a))

        resp_a = client.get("/kyc/status", headers=auth_headers(token_a))
        resp_b = client.get("/kyc/status", headers=auth_headers(token_b))
        assert resp_a.get_json()["status"] == "pending"
        assert resp_b.get_json()["status"] == "unverified"


class TestSubmit:
    def test_submit_creates_pending_status(self, client):
        token, _ = register_and_login(client, email="kycsubmit@example.com")
        resp = client.post("/kyc/submit", json=_VALID_BODY, headers=auth_headers(token))
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["status"] == "pending"
        assert body["full_name"] == "Budi Santoso"
        assert body["id_number"] == "1234567890123456"
        assert body["submitted_at"] is not None

    def test_status_transitions_to_verified_after_review_delay(self, client, monkeypatch):
        # No real clock-waiting: shrink the review window to nothing so
        # any already-submitted record instantly counts as reviewed.
        monkeypatch.setattr(kyc, "_REVIEW_DELAY", timedelta(seconds=0))
        token, _ = register_and_login(client, email="kycverified@example.com")
        client.post("/kyc/submit", json=_VALID_BODY, headers=auth_headers(token))

        resp = client.get("/kyc/status", headers=auth_headers(token))
        assert resp.get_json()["status"] == "verified"

    def test_cannot_submit_twice(self, client):
        token, _ = register_and_login(client, email="kyctwice@example.com")
        client.post("/kyc/submit", json=_VALID_BODY, headers=auth_headers(token))
        resp = client.post("/kyc/submit", json=_VALID_BODY, headers=auth_headers(token))
        assert resp.status_code == 400

    def test_submit_empty_name_rejected(self, client):
        token, _ = register_and_login(client, email="kycnoname@example.com")
        resp = client.post(
            "/kyc/submit", json={"full_name": "", "id_number": "1234567890123456"}, headers=auth_headers(token)
        )
        assert resp.status_code == 422

    def test_submit_invalid_id_number_rejected(self, client):
        token, _ = register_and_login(client, email="kycbadid@example.com")
        resp = client.post(
            "/kyc/submit", json={"full_name": "Budi Santoso", "id_number": "123"}, headers=auth_headers(token)
        )
        assert resp.status_code == 422

        resp = client.post(
            "/kyc/submit",
            json={"full_name": "Budi Santoso", "id_number": "12345678901234ab"},
            headers=auth_headers(token),
        )
        assert resp.status_code == 422

    def test_submit_without_token_rejected(self, client):
        resp = client.post("/kyc/submit", json=_VALID_BODY)
        assert resp.status_code == 401
