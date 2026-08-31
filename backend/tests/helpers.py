"""Small request-building helpers shared across test modules — nothing
here is a fixture, just plain functions test files call directly.
"""


def register(client, name="Test User", email="test@example.com", password="password123"):
    return client.post("/auth/register", json={"name": name, "email": email, "password": password})


def register_and_login(client, email="test@example.com", password="password123", name="Test User"):
    """Registers a fresh user and returns (token, user_dict) — the
    common starting point for any test that needs an authenticated
    client."""
    resp = register(client, name=name, email=email, password=password)
    assert resp.status_code == 201, resp.get_json()
    body = resp.get_json()
    return body["access_token"], body["user"]


def auth_headers(token):
    return {"Authorization": f"Bearer {token}"}
