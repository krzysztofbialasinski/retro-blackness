from __future__ import annotations

from fastapi.testclient import TestClient

from retro_blackness.application.roblox.ports import RobloxApiClientPort
from retro_blackness.application.roblox.queries.get_user_profile import GetRobloxUserProfile
from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.value_objects import RobloxUserId
from retro_blackness.interfaces.dependencies import get_roblox_user_profile_use_case
from retro_blackness.main import create_app


class StubRobloxApiClient(RobloxApiClientPort):
    async def get_user(self, user_id: RobloxUserId) -> RobloxUser:
        return RobloxUser(user_id, username="neo", display_name="Neo")


def test_get_user_endpoint_returns_profile() -> None:
    app = create_app()
    stub_use_case = GetRobloxUserProfile(StubRobloxApiClient())
    app.dependency_overrides[get_roblox_user_profile_use_case] = lambda: stub_use_case
    client = TestClient(app)

    response = client.get("/api/v1/roblox/users/1")

    assert response.status_code == 200
    body = response.json()
    assert body == {"user_id": 1, "username": "neo", "display_name": "Neo"}
