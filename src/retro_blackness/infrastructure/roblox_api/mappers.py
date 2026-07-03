from __future__ import annotations

from typing import Any

from retro_blackness.domain.roblox.entities import RobloxUser
from retro_blackness.domain.roblox.value_objects import RobloxUserId


def user_from_open_cloud_payload(payload: dict[str, Any]) -> RobloxUser:
    return RobloxUser(
        user_id=RobloxUserId(int(payload["id"])),
        username=payload["name"],
        display_name=payload.get("displayName", payload["name"]),
    )
