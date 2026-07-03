from __future__ import annotations

from dataclasses import dataclass

from retro_blackness.application.roblox.ports import GameEventNotifierPort
from retro_blackness.application.shared.use_case import UseCase
from retro_blackness.domain.roblox.events import UserJoinedGame
from retro_blackness.domain.roblox.value_objects import PlaceId, RobloxUserId, UniverseId


@dataclass(frozen=True, slots=True)
class HandleUserJoinedRequest:
    user_id: int
    universe_id: int
    place_id: int


class HandleUserJoined(UseCase[HandleUserJoinedRequest, None]):
    def __init__(self, notifier: GameEventNotifierPort) -> None:
        self._notifier = notifier

    async def execute(self, request: HandleUserJoinedRequest) -> None:
        event = UserJoinedGame(
            user_id=RobloxUserId(request.user_id),
            universe_id=UniverseId(request.universe_id),
            place_id=PlaceId(request.place_id),
        )
        await self._notifier.notify_user_joined(event)
