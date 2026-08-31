"""Tests for /trading/* — Futures account balance and positions."""
from .helpers import auth_headers, register_and_login


def _open_position(client, token, **overrides):
    body = {
        "contract_id": "BTC",
        "side": "long",
        "size": 0.1,
        "entry_price": 70000.0,
        "leverage": 10,
        "margin_mode": "isolated",
    }
    body.update(overrides)
    return client.post("/trading/positions", json=body, headers=auth_headers(token))


class TestAccount:
    def test_account_auto_created_with_starting_balance(self, client):
        token, _ = register_and_login(client, email="account@example.com")
        resp = client.get("/trading/account", headers=auth_headers(token))
        assert resp.status_code == 200
        body = resp.get_json()
        assert body["balance"] == 1250.0
        assert body["realized_pnl"] == 0.0

    def test_account_without_token_rejected(self, client):
        resp = client.get("/trading/account")
        assert resp.status_code == 401


class TestOpenPosition:
    def test_open_position_success(self, client):
        token, _ = register_and_login(client, email="openpos@example.com")
        resp = _open_position(client, token)
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["contract_id"] == "BTC"
        assert body["side"] == "long"
        assert body["leverage"] == 10
        assert "id" in body

    def test_open_position_appears_in_list(self, client):
        token, _ = register_and_login(client, email="listpos@example.com")
        _open_position(client, token)
        resp = client.get("/trading/positions", headers=auth_headers(token))
        assert resp.status_code == 200
        assert len(resp.get_json()) == 1

    def test_open_position_invalid_side_rejected(self, client):
        token, _ = register_and_login(client, email="badside@example.com")
        resp = _open_position(client, token, side="sideways")
        assert resp.status_code == 422

    def test_open_position_leverage_out_of_range_rejected(self, client):
        token, _ = register_and_login(client, email="badlev@example.com")
        resp = _open_position(client, token, leverage=500)
        assert resp.status_code == 422

    def test_open_position_negative_size_rejected(self, client):
        token, _ = register_and_login(client, email="badsize@example.com")
        resp = _open_position(client, token, size=-1)
        assert resp.status_code == 422

    def test_open_position_without_token_rejected(self, client):
        resp = client.post("/trading/positions", json={
            "contract_id": "BTC", "side": "long", "size": 0.1,
            "entry_price": 70000.0, "leverage": 10, "margin_mode": "isolated",
        })
        assert resp.status_code == 401

    def test_positions_are_isolated_per_user(self, client):
        token_a, _ = register_and_login(client, email="usera@example.com")
        token_b, _ = register_and_login(client, email="userb@example.com")
        _open_position(client, token_a)

        resp_a = client.get("/trading/positions", headers=auth_headers(token_a))
        resp_b = client.get("/trading/positions", headers=auth_headers(token_b))
        assert len(resp_a.get_json()) == 1
        assert len(resp_b.get_json()) == 0


class TestClosePosition:
    def test_close_position_updates_realized_pnl_and_removes_position(self, client):
        token, _ = register_and_login(client, email="closepos@example.com")
        opened = _open_position(client, token).get_json()

        resp = client.post(
            f"/trading/positions/{opened['id']}/close",
            json={"realized_pnl": 42.5},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200
        assert resp.get_json()["realized_pnl"] == 42.5

        positions = client.get("/trading/positions", headers=auth_headers(token))
        assert positions.get_json() == []

    def test_close_position_accumulates_across_multiple_closes(self, client):
        token, _ = register_and_login(client, email="accumulate@example.com")
        first = _open_position(client, token).get_json()
        second = _open_position(client, token).get_json()

        client.post(f"/trading/positions/{first['id']}/close", json={"realized_pnl": 10}, headers=auth_headers(token))
        resp = client.post(
            f"/trading/positions/{second['id']}/close", json={"realized_pnl": -3}, headers=auth_headers(token)
        )
        assert resp.get_json()["realized_pnl"] == 7

    def test_close_nonexistent_position_rejected(self, client):
        token, _ = register_and_login(client, email="noexist@example.com")
        resp = client.post(
            "/trading/positions/not-a-real-id/close", json={"realized_pnl": 0}, headers=auth_headers(token)
        )
        assert resp.status_code == 404

    def test_cannot_close_another_users_position(self, client):
        token_a, _ = register_and_login(client, email="ownera@example.com")
        token_b, _ = register_and_login(client, email="ownerb@example.com")
        opened = _open_position(client, token_a).get_json()

        resp = client.post(
            f"/trading/positions/{opened['id']}/close", json={"realized_pnl": 0}, headers=auth_headers(token_b)
        )
        assert resp.status_code == 404

    def test_close_position_pnl_out_of_bounds_rejected(self, client):
        token, _ = register_and_login(client, email="hugepnl@example.com")
        opened = _open_position(client, token).get_json()
        resp = client.post(
            f"/trading/positions/{opened['id']}/close",
            json={"realized_pnl": 1e15},
            headers=auth_headers(token),
        )
        assert resp.status_code == 422
