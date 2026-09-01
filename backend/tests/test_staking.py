"""Tests for /staking/* — Staking holdings, account, and positions."""
from .helpers import auth_headers, register_and_login


def _create_position(client, token, **overrides):
    body = {"asset_id": "ETH", "amount": 0.5, "duration_id": "flexible", "apy": 2.0}
    body.update(overrides)
    return client.post("/staking/positions", json=body, headers=auth_headers(token))


class TestHoldings:
    def test_holdings_seeded_with_all_known_assets(self, client):
        token, _ = register_and_login(client, email="stakeholdings@example.com")
        resp = client.get("/staking/holdings", headers=auth_headers(token))
        assert resp.status_code == 200
        by_asset = {h["asset_id"]: h["quantity"] for h in resp.get_json()}
        assert by_asset == {
            "ETH": 1.8548,
            "SOL": 42.3,
            "USDT": 2450.0,
            "ADA": 5200.0,
            "BNB": 3.2,
            "DOT": 150.0,
        }

    def test_holdings_without_token_rejected(self, client):
        resp = client.get("/staking/holdings")
        assert resp.status_code == 401


class TestAccount:
    def test_account_auto_created_at_zero(self, client):
        token, _ = register_and_login(client, email="stakeaccount@example.com")
        resp = client.get("/staking/account", headers=auth_headers(token))
        assert resp.status_code == 200
        assert resp.get_json()["realized_reward"] == 0.0

    def test_account_without_token_rejected(self, client):
        resp = client.get("/staking/account")
        assert resp.status_code == 401


class TestCreatePosition:
    def test_stake_success_debits_holding(self, client):
        token, _ = register_and_login(client, email="stakecreate@example.com")
        resp = _create_position(client, token, asset_id="ETH", amount=0.5)
        assert resp.status_code == 201
        body = resp.get_json()
        assert body["position"]["status"] == "active"
        assert body["position"]["asset_id"] == "ETH"
        assert body["holding"]["quantity"] == 1.8548 - 0.5

    def test_stake_beyond_holding_rejected(self, client):
        token, _ = register_and_login(client, email="staketoomuch@example.com")
        resp = _create_position(client, token, asset_id="ETH", amount=100)
        assert resp.status_code == 400

        holding = client.get("/staking/holdings", headers=auth_headers(token)).get_json()
        eth = next(h for h in holding if h["asset_id"] == "ETH")
        assert eth["quantity"] == 1.8548  # untouched

    def test_stake_appears_in_positions_list(self, client):
        token, _ = register_and_login(client, email="stakelist@example.com")
        _create_position(client, token)
        resp = client.get("/staking/positions", headers=auth_headers(token))
        assert resp.status_code == 200
        assert len(resp.get_json()) == 1

    def test_stake_locks_in_apy_at_creation(self, client):
        token, _ = register_and_login(client, email="stakeapy@example.com")
        resp = _create_position(client, token, apy=12.34)
        assert resp.get_json()["position"]["apy"] == 12.34

    def test_stake_invalid_asset_id_rejected(self, client):
        token, _ = register_and_login(client, email="stakebadasset@example.com")
        resp = _create_position(client, token, asset_id="ETH; DROP TABLE")
        assert resp.status_code == 422

    def test_stake_zero_amount_rejected(self, client):
        token, _ = register_and_login(client, email="stakezero@example.com")
        resp = _create_position(client, token, amount=0)
        assert resp.status_code == 422

    def test_stake_apy_out_of_range_rejected(self, client):
        token, _ = register_and_login(client, email="stakebadapy@example.com")
        resp = _create_position(client, token, apy=500)
        assert resp.status_code == 422

    def test_stake_without_token_rejected(self, client):
        resp = client.post(
            "/staking/positions",
            json={"asset_id": "ETH", "amount": 0.1, "duration_id": "flexible", "apy": 2.0},
        )
        assert resp.status_code == 401

    def test_stakes_isolated_per_user(self, client):
        token_a, _ = register_and_login(client, email="stakeusera@example.com")
        token_b, _ = register_and_login(client, email="stakeuserb@example.com")
        _create_position(client, token_a)

        resp_a = client.get("/staking/positions", headers=auth_headers(token_a))
        resp_b = client.get("/staking/positions", headers=auth_headers(token_b))
        assert len(resp_a.get_json()) == 1
        assert len(resp_b.get_json()) == 0


class TestUnstake:
    def test_unstake_returns_principal_and_credits_reward(self, client):
        token, _ = register_and_login(client, email="stakeunstake@example.com")
        position = _create_position(client, token, asset_id="SOL", amount=5).get_json()["position"]

        resp = client.post(
            f"/staking/positions/{position['id']}/unstake",
            json={"reward": 0.12},
            headers=auth_headers(token),
        )
        assert resp.status_code == 200
        body = resp.get_json()
        assert body["position"]["status"] == "unstaked"
        assert body["position"]["unstaked_at"] is not None
        assert body["holding"]["quantity"] == 42.3  # principal returned in full
        assert body["account"]["realized_reward"] == 0.12

    def test_unstake_accumulates_across_multiple_stakes(self, client):
        token, _ = register_and_login(client, email="stakeaccumulate@example.com")
        first = _create_position(client, token, asset_id="ETH", amount=0.1).get_json()["position"]
        second = _create_position(client, token, asset_id="ETH", amount=0.1).get_json()["position"]

        client.post(f"/staking/positions/{first['id']}/unstake", json={"reward": 0.01}, headers=auth_headers(token))
        resp = client.post(
            f"/staking/positions/{second['id']}/unstake", json={"reward": 0.02}, headers=auth_headers(token)
        )
        assert resp.get_json()["account"]["realized_reward"] == 0.03

    def test_cannot_unstake_already_unstaked_position(self, client):
        token, _ = register_and_login(client, email="stakedouble@example.com")
        position = _create_position(client, token).get_json()["position"]
        client.post(f"/staking/positions/{position['id']}/unstake", json={"reward": 0}, headers=auth_headers(token))

        resp = client.post(
            f"/staking/positions/{position['id']}/unstake", json={"reward": 0}, headers=auth_headers(token)
        )
        assert resp.status_code == 400

    def test_unstake_nonexistent_position_rejected(self, client):
        token, _ = register_and_login(client, email="stakeghost@example.com")
        resp = client.post(
            "/staking/positions/not-a-real-id/unstake", json={"reward": 0}, headers=auth_headers(token)
        )
        assert resp.status_code == 404

    def test_cannot_unstake_another_users_position(self, client):
        token_a, _ = register_and_login(client, email="stakeownera@example.com")
        token_b, _ = register_and_login(client, email="stakeownerb@example.com")
        position = _create_position(client, token_a).get_json()["position"]

        resp = client.post(
            f"/staking/positions/{position['id']}/unstake", json={"reward": 0}, headers=auth_headers(token_b)
        )
        assert resp.status_code == 404

    def test_unstake_negative_reward_rejected(self, client):
        token, _ = register_and_login(client, email="stakenegreward@example.com")
        position = _create_position(client, token).get_json()["position"]
        resp = client.post(
            f"/staking/positions/{position['id']}/unstake", json={"reward": -1}, headers=auth_headers(token)
        )
        assert resp.status_code == 422
