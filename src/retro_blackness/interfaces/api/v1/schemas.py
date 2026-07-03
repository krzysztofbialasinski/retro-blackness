from __future__ import annotations

from pydantic import BaseModel


class RobloxUserResponse(BaseModel):
    user_id: int
    username: str
    display_name: str
