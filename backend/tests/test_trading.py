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


class TestDeposit:
    def test_deposit_credits_balance(self, client):
        token, _ = register_and_login(client, email="deposit@example.com")
        resp = client.post("/trading/deposit", json={"amount": 500}, headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["balance"] == 1750.0

    def test_deposit_accumulates_across_multiple_calls(self, client):
        token, _ = register_and_login(client, email="depositmulti@example.com")
        client.post("/trading/deposit", json={"amount": 100}, headers=auth_headers(token))
        resp = client.post("/trading/deposit", json={"amount": 250}, headers=auth_headers(token))
        assert resp.get_json()["balance"] == 1600.0

    def test_deposit_zero_or_negative_rejected(self, client):
        token, _ = register_and_login(client, email="depositzero@example.com")
        resp = client.post("/trading/deposit", json={"amount": 0}, headers=auth_headers(token))
        assert resp.status_code == 422
        resp = client.post("/trading/deposit", json={"amount": -5}, headers=auth_headers(token))
        assert resp.status_code == 422

    def test_deposit_absurdly_large_amount_rejected(self, client):
        token, _ = register_and_login(client, email="deposithuge@example.com")
        resp = client.post("/trading/deposit", json={"amount": 1e10}, headers=auth_headers(token))
        assert resp.status_code == 422

    def test_deposit_without_token_rejected(self, client):
        resp = client.post("/trading/deposit", json={"amount": 100})
        assert resp.status_code == 401


class TestExchange:
    def test_exchange_to_futures_moves_balance_both_ways(self, client):
        token, _ = register_and_login(client, email="exchangein@example.com")
        # Spot starts at 50,000,000 IDR, Futures at 1250.0 USDT.
        resp = client.post(
            "/trading/exchange/to-futures",
            json={"idr_amount": 15_000_000, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200
        body = resp.get_json()
        assert body["spot_wallet"]["idr_balance"] == 35_000_000
        assert body["futures_account"]["balance"] == 2250.0

    def test_exchange_to_spot_moves_balance_both_ways(self, client):
        token, _ = register_and_login(client, email="exchangeout@example.com")
        resp = client.post(
            "/trading/exchange/to-spot",
            json={"usdt_amount": 250, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200
        body = resp.get_json()
        assert body["futures_account"]["balance"] == 1000.0
        assert body["spot_wallet"]["idr_balance"] == 53_750_000

    def test_exchange_to_futures_insufficient_spot_balance_rejected(self, client):
        token, _ = register_and_login(client, email="exchangeinshort@example.com")
        resp = client.post(
            "/trading/exchange/to-futures",
            json={"idr_amount": 999_999_999, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 400

    def test_exchange_to_spot_insufficient_futures_balance_rejected(self, client):
        token, _ = register_and_login(client, email="exchangeoutshort@example.com")
        resp = client.post(
            "/trading/exchange/to-spot",
            json={"usdt_amount": 999_999, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 400

    def test_exchange_to_spot_floored_by_used_margin(self, client):
        token, _ = register_and_login(client, email="exchangemargin@example.com")
        # Opens a position that locks up 700 USDT of margin (7000 notional
        # / 10x leverage), leaving only 550 of the 1250 starting balance
        # actually available to move out.
        _open_position(client, token, size=0.1, entry_price=70_000.0, leverage=10)
        resp = client.post(
            "/trading/exchange/to-spot",
            json={"usdt_amount": 600, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 400

        resp = client.post(
            "/trading/exchange/to-spot",
            json={"usdt_amount": 500, "rate": 15_000},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200

    def test_exchange_zero_or_negative_amount_rejected(self, client):
        token, _ = register_and_login(client, email="exchangezero@example.com")
        resp = client.post(
            "/trading/exchange/to-futures", json={"idr_amount": 0, "rate": 15_000}, headers=auth_headers(token)
        )
        assert resp.status_code == 422
        resp = client.post(
            "/trading/exchange/to-spot", json={"usdt_amount": -5, "rate": 15_000}, headers=auth_headers(token)
        )
        assert resp.status_code == 422

    def test_exchange_invalid_rate_rejected(self, client):
        token, _ = register_and_login(client, email="exchangerate@example.com")
        resp = client.post(
            "/trading/exchange/to-futures", json={"idr_amount": 100_000, "rate": 0}, headers=auth_headers(token)
        )
        assert resp.status_code == 422

    def test_exchange_without_token_rejected(self, client):
        resp = client.post("/trading/exchange/to-futures", json={"idr_amount": 100_000, "rate": 15_000})
        assert resp.status_code == 401
        resp = client.post("/trading/exchange/to-spot", json={"usdt_amount": 100, "rate": 15_000})
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
