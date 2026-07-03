from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException

from retro_blackness.application.roblox.queries.get_user_profile import (
    GetRobloxUserProfile,
    GetRobloxUserProfileRequest,
)
from retro_blackness.domain.roblox.exceptions import RobloxUserNotFound
from retro_blackness.interfaces.api.v1.schemas import RobloxUserResponse
from retro_blackness.interfaces.dependencies import get_roblox_user_profile_use_case

router = APIRouter(prefix="/api/v1/roblox", tags=["roblox"])


@router.get("/users/{user_id}", response_model=RobloxUserResponse)
async def get_user(
    user_id: int,
    use_case: GetRobloxUserProfile = Depends(get_roblox_user_profile_use_case),
) -> RobloxUserResponse:
    try:
        user = await use_case.execute(GetRobloxUserProfileRequest(user_id=user_id))
    except RobloxUserNotFound as exc:
        raise HTTPException(status_code=404, detail=str(exc)) from exc

    return RobloxUserResponse(
        user_id=user.user_id.value,
        username=user.username,
        display_name=user.display_name,
    )
