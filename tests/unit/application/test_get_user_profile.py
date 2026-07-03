from __future__ import annotations

import pytest

from retro_blackness.application.roblox.ports import RobloxApiClientPort
from retro_blackness.application.roblox.queries.get_user_profile import (
    GetRobloxUserProfile,
    GetRobloxUserProfileRequest,
)
from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.value_objects import RobloxUserId


class FakeRobloxApiClient(RobloxApiClientPort):
    def __init__(self, user: RobloxUser) -> None:
        self._user = user

    async def get_user(self, user_id: RobloxUserId) -> RobloxUser:
        assert user_id == self._user.user_id
        return self._user


@pytest.mark.asyncio
async def test_get_user_profile_returns_user_from_port() -> None:
    user = RobloxUser(RobloxUserId(42), username="neo", display_name="Neo")
    use_case = GetRobloxUserProfile(FakeRobloxApiClient(user))

    result = await use_case.execute(GetRobloxUserProfileRequest(user_id=42))

    assert result is user
