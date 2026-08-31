"""Tests for /spot/* — Spot wallet, holdings, and orders."""
from .helpers import auth_headers, register_and_login


def _create_order(client, token, **overrides):
    body = {
        "asset_id": "BTC",
        "side": "buy",
        "order_type": "market",
        "price": 1_000_000_000.0,
        "amount": 0.01,
    }
    body.update(overrides)
    return client.post("/spot/orders", json=body, headers=auth_headers(token))


class TestWallet:
    def test_wallet_auto_created_with_starting_balance(self, client):
        token, _ = register_and_login(client, email="wallet@example.com")
        resp = client.get("/spot/wallet", headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["idr_balance"] == 50_000_000.0

    def test_wallet_without_token_rejected(self, client):
        resp = client.get("/spot/wallet")
        assert resp.status_code == 401


class TestHoldings:
    def test_holdings_empty_for_new_user(self, client):
        token, _ = register_and_login(client, email="noholdings@example.com")
        resp = client.get("/spot/holdings", headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json() == []


class TestMarketOrders:
    def test_market_buy_debits_wallet_and_credits_holding(self, client):
        token, _ = register_and_login(client, email="marketbuy@example.com")
        resp = _create_order(client, token, price=1_000_000_000.0, amount=0.01)
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["order"]["status"] == "filled"
        assert body["wallet"]["idr_balance"] == 50_000_000.0 - 10_000_000.0

        holdings = client.get("/spot/holdings", headers=auth_headers(token)).get_json()
        assert holdings == [{"asset_id": "BTC", "quantity": 0.01}]

    def test_market_buy_beyond_balance_rejected(self, client):
        token, _ = register_and_login(client, email="toomuchbuy@example.com")
        resp = _create_order(client, token, price=1_000_000_000.0, amount=1)  # costs 1B, balance is 50M
        assert resp.status_code == 400

        wallet = client.get("/spot/wallet", headers=auth_headers(token)).get_json()
        assert wallet["idr_balance"] == 50_000_000.0  # untouched

    def test_market_sell_credits_wallet_and_debits_holding(self, client):
        token, _ = register_and_login(client, email="marketsell@example.com")
        _create_order(client, token, side="buy", price=1_000_000_000.0, amount=0.02)

        resp = _create_order(client, token, side="sell", price=1_000_000_000.0, amount=0.01)
        assert resp.status_code == 201
        assert resp.get_json()["wallet"]["idr_balance"] == 50_000_000.0 - 20_000_000.0 + 10_000_000.0

        holdings = client.get("/spot/holdings", headers=auth_headers(token)).get_json()
        assert holdings == [{"asset_id": "BTC", "quantity": 0.01}]

    def test_market_sell_beyond_holding_rejected(self, client):
        token, _ = register_and_login(client, email="oversell@example.com")
        _create_order(client, token, side="buy", price=1_000_000_000.0, amount=0.01)

        resp = _create_order(client, token, side="sell", price=1_000_000_000.0, amount=1)
        assert resp.status_code == 400

    def test_market_sell_with_no_holding_at_all_rejected(self, client):
        token, _ = register_and_login(client, email="neverbought@example.com")
        resp = _create_order(client, token, side="sell", price=1_000_000_000.0, amount=0.01)
        assert resp.status_code == 400


class TestLimitOrders:
    def test_limit_order_stays_open_and_does_not_touch_balance_or_holdings(self, client):
        token, _ = register_and_login(client, email="limitorder@example.com")
        resp = _create_order(client, token, order_type="limit", price=900_000_000.0, amount=0.05)
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["order"]["status"] == "open"
        assert body["wallet"]["idr_balance"] == 50_000_000.0

        holdings = client.get("/spot/holdings", headers=auth_headers(token)).get_json()
        assert holdings == []

    def test_stop_limit_order_also_stays_open(self, client):
        token, _ = register_and_login(client, email="stoplimit@example.com")
        resp = _create_order(client, token, order_type="stop_limit", price=900_000_000.0, amount=0.05)
        assert resp.get_json()["order"]["status"] == "open"


class TestCancelOrder:
    def test_cancel_open_order_succeeds(self, client):
        token, _ = register_and_login(client, email="cancelme@example.com")
        order = _create_order(client, token, order_type="limit").get_json()["order"]

        resp = client.post(f"/spot/orders/{order['id']}/cancel", headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["status"] == "cancelled"

    def test_cancel_already_cancelled_order_rejected(self, client):
        token, _ = register_and_login(client, email="doublecancel@example.com")
        order = _create_order(client, token, order_type="limit").get_json()["order"]
        client.post(f"/spot/orders/{order['id']}/cancel", headers=auth_headers(token))

        resp = client.post(f"/spot/orders/{order['id']}/cancel", headers=auth_headers(token))
        assert resp.status_code == 400

    def test_cannot_cancel_a_filled_order(self, client):
        token, _ = register_and_login(client, email="cancelfilled@example.com")
        order = _create_order(client, token, order_type="market").get_json()["order"]

        resp = client.post(f"/spot/orders/{order['id']}/cancel", headers=auth_headers(token))
        assert resp.status_code == 400

    def test_cancel_nonexistent_order_rejected(self, client):
        token, _ = register_and_login(client, email="cancelghost@example.com")
        resp = client.post("/spot/orders/not-a-real-id/cancel", headers=auth_headers(token))
        assert resp.status_code == 404

    def test_cannot_cancel_another_users_order(self, client):
        token_a, _ = register_and_login(client, email="spota@example.com")
        token_b, _ = register_and_login(client, email="spotb@example.com")
        order = _create_order(client, token_a, order_type="limit").get_json()["order"]

        resp = client.post(f"/spot/orders/{order['id']}/cancel", headers=auth_headers(token_b))
        assert resp.status_code == 404


class TestListOrders:
    def test_orders_listed_newest_first(self, client):
        token, _ = register_and_login(client, email="orderlist@example.com")
        first = _create_order(client, token, asset_id="BTC").get_json()["order"]
        second = _create_order(client, token, asset_id="ETH").get_json()["order"]

        resp = client.get("/spot/orders", headers=auth_headers(token))
        ids_in_order = [o["id"] for o in resp.get_json()]
        assert ids_in_order == [second["id"], first["id"]]

    def test_orders_isolated_per_user(self, client):
        token_a, _ = register_and_login(client, email="ordersa@example.com")
        token_b, _ = register_and_login(client, email="ordersb@example.com")
        _create_order(client, token_a)

        resp_a = client.get("/spot/orders", headers=auth_headers(token_a))
        resp_b = client.get("/spot/orders", headers=auth_headers(token_b))
        assert len(resp_a.get_json()) == 1
        assert len(resp_b.get_json()) == 0


class TestValidation:
    def test_asset_id_with_symbols_rejected(self, client):
        token, _ = register_and_login(client, email="badasset@example.com")
        resp = _create_order(client, token, asset_id="BTC; DROP TABLE")
        assert resp.status_code == 422

    def test_absurdly_large_price_rejected(self, client):
        token, _ = register_and_login(client, email="hugeprice@example.com")
        resp = _create_order(client, token, price=1e20)
        assert resp.status_code == 422

    def test_zero_amount_rejected(self, client):
        token, _ = register_and_login(client, email="zeroamount@example.com")
        resp = _create_order(client, token, amount=0)
        assert resp.status_code == 422

    def test_invalid_side_rejected(self, client):
        token, _ = register_and_login(client, email="badside@example.com")
        resp = _create_order(client, token, side="sideways")
        assert resp.status_code == 422
