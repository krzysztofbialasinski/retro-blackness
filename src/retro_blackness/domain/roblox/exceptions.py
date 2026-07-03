from __future__ import annotations


class RobloxDomainError(Exception):
    """Base class for all Roblox domain errors."""


class RobloxUserNotFound(RobloxDomainError):
    def __init__(self, user_id: int) -> None:
        super().__init__(f"Roblox user {user_id} not found")
        self.user_id = user_id
