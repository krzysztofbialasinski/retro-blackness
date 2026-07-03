from __future__ import annotations

from dataclasses import dataclass

from retro_blackness.domain.shared.value_object import ValueObject


@dataclass(frozen=True, slots=True)
class RobloxUserId(ValueObject):
    value: int

    def __post_init__(self) -> None:
        if self.value <= 0:
            raise ValueError("RobloxUserId must be a positive integer")


@dataclass(frozen=True, slots=True)
class UniverseId(ValueObject):
    value: int

    def __post_init__(self) -> None:
        if self.value <= 0:
            raise ValueError("UniverseId must be a positive integer")


@dataclass(frozen=True, slots=True)
class PlaceId(ValueObject):
    value: int

    def __post_init__(self) -> None:
        if self.value <= 0:
            raise ValueError("PlaceId must be a positive integer")
