from __future__ import annotations

from pydantic import BaseModel


class UserJoinedWebhookPayload(BaseModel):
    user_id: int
    universe_id: int
    place_id: int
