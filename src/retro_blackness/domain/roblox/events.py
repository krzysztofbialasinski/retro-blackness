from __future__ import annotations

from dataclasses import dataclass

from retro_blackness.domain.roblox.value_objects import PlaceId, RobloxUserId, UniverseId
from retro_blackness.domain.shared.domain_event import DomainEvent


@dataclass(frozen=True, slots=True)
class UserJoinedGame(DomainEvent):
    """Raised when a Roblox player joins a game server (from an inbound webhook)."""

    user_id: RobloxUserId
    universe_id: UniverseId
    place_id: PlaceId
