from __future__ import annotations

from abc import ABC, abstractmethod

from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.events import UserJoinedGame
from retro_blackness.domain.roblox.value_objects import RobloxUserId


class RobloxApiClientPort(ABC):
    """Outbound port for talking to the Roblox Open Cloud API."""

    @abstractmethod
    async def get_user(self, user_id: RobloxUserId) -> RobloxUser: ...


class GameEventNotifierPort(ABC):
    """Outbound port for reacting to events received from a running Roblox game server."""

    @abstractmethod
    async def notify_user_joined(self, event: UserJoinedGame) -> None: ...
