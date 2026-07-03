from __future__ import annotations

import pytest

from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.value_objects import RobloxUserId


def test_rename_display_name_updates_value() -> None:
    user = RobloxUser(RobloxUserId(1), username="neo", display_name="Neo")

    user.rename_display_name("The One")

    assert user.display_name == "The One"


def test_rename_display_name_rejects_blank() -> None:
    user = RobloxUser(RobloxUserId(1), username="neo", display_name="Neo")

    with pytest.raises(ValueError):
        user.rename_display_name("   ")


def test_roblox_user_id_rejects_non_positive() -> None:
    with pytest.raises(ValueError):
        RobloxUserId(0)


def test_entities_are_equal_by_id_not_by_attributes() -> None:
    first = RobloxUser(RobloxUserId(1), username="neo", display_name="Neo")
    second = RobloxUser(RobloxUserId(1), username="different", display_name="Different")

    assert first == second
