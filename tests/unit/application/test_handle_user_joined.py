from __future__ import annotations

import pytest

from retro_blackness.application.roblox.commands.handle_user_joined import (
    HandleUserJoined,
    HandleUserJoinedRequest,
)
from retro_blackness.application.roblox.ports import GameEventNotifierPort
from retro_blackness.domain.roblox.events import UserJoinedGame


class FakeNotifier(GameEventNotifierPort):
    def __init__(self) -> None:
        self.events: list[UserJoinedGame] = []

    async def notify_user_joined(self, event: UserJoinedGame) -> None:
        self.events.append(event)


@pytest.mark.asyncio
async def test_handle_user_joined_notifies_with_domain_event() -> None:
    notifier = FakeNotifier()
    use_case = HandleUserJoined(notifier)

    await use_case.execute(HandleUserJoinedRequest(user_id=1, universe_id=2, place_id=3))

    assert len(notifier.events) == 1
    assert notifier.events[0].user_id.value == 1
    assert notifier.events[0].universe_id.value == 2
    assert notifier.events[0].place_id.value == 3
