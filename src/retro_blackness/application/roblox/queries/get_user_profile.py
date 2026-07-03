from __future__ import annotations

from dataclasses import dataclass

from retro_blackness.application.roblox.ports import RobloxApiClientPort
from retro_blackness.application.shared.use_case import UseCase
from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.value_objects import RobloxUserId


@dataclass(frozen=True, slots=True)
class GetRobloxUserProfileRequest:
    user_id: int


class GetRobloxUserProfile(UseCase[GetRobloxUserProfileRequest, RobloxUser]):
    def __init__(self, roblox_api: RobloxApiClientPort) -> None:
        self._roblox_api = roblox_api

    async def execute(self, request: GetRobloxUserProfileRequest) -> RobloxUser:
        return await self._roblox_api.get_user(RobloxUserId(request.user_id))
