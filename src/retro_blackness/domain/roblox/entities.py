from __future__ import annotations

from retro_blackness.domain.roblox.value_objects import RobloxUserId
from retro_blackness.domain.shared.entity import Entity


class RobloxUser(Entity[RobloxUserId]):
    """A Roblox account, as known to this service."""

    def __init__(self, user_id: RobloxUserId, username: str, display_name: str) -> None:
        super().__init__(user_id)
        self._username = username
        self._display_name = display_name

    @property
    def user_id(self) -> RobloxUserId:
        return self._id

    @property
    def username(self) -> str:
        return self._username

    @property
    def display_name(self) -> str:
        return self._display_name

    def rename_display_name(self, new_display_name: str) -> None:
        if not new_display_name.strip():
            raise ValueError("display_name cannot be blank")
        self._display_name = new_display_name
