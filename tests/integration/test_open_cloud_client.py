from __future__ import annotations

import httpx
import pytest
import respx

from retro_blackness.domain.roblox.exceptions import RobloxUserNotFound
from retro_blackness.domain.roblox.value_objects import RobloxUserId
from retro_blackness.infrastructure.roblox_api.open_cloud_client import RobloxOpenCloudClient


@pytest.mark.asyncio
@respx.mock
async def test_get_user_maps_open_cloud_payload() -> None:
    respx.get("https://apis.roblox.com/users/v1/users/1").mock(
        return_value=httpx.Response(200, json={"id": 1, "name": "neo", "displayName": "Neo"})
    )
    client = RobloxOpenCloudClient(base_url="https://apis.roblox.com", api_key="secret")

    user = await client.get_user(RobloxUserId(1))

    assert user.username == "neo"
    assert user.display_name == "Neo"

    await client.aclose()


@pytest.mark.asyncio
@respx.mock
async def test_get_user_raises_not_found_on_404() -> None:
    respx.get("https://apis.roblox.com/users/v1/users/1").mock(return_value=httpx.Response(404))
    client = RobloxOpenCloudClient(base_url="https://apis.roblox.com", api_key="secret")

    with pytest.raises(RobloxUserNotFound):
        await client.get_user(RobloxUserId(1))

    await client.aclose()
