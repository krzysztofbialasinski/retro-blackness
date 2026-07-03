from __future__ import annotations

import httpx

from retro_blackness.application.roblox.ports import RobloxApiClientPort
from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.exceptions import RobloxUserNotFound
from retro_blackness.domain.roblox.value_objects import RobloxUserId
from retro_blackness.infrastructure.roblox_api.mappers import user_from_open_cloud_payload


class RobloxOpenCloudClient(RobloxApiClientPort):
    """Adapter for the Roblox Open Cloud API (https://apis.roblox.com)."""

    def __init__(
        self,
        base_url: str,
        api_key: str,
        http_client: httpx.AsyncClient | None = None,
    ) -> None:
        self._base_url = base_url.rstrip("/")
        self._api_key = api_key
        self._http = http_client or httpx.AsyncClient()

    async def get_user(self, user_id: RobloxUserId) -> RobloxUser:
        response = await self._http.get(
            f"{self._base_url}/users/v1/users/{user_id.value}",
            headers={"x-api-key": self._api_key},
        )
        if response.status_code == 404:
            raise RobloxUserNotFound(user_id.value)
        response.raise_for_status()
        return user_from_open_cloud_payload(response.json())

    async def aclose(self) -> None:
        await self._http.aclose()
