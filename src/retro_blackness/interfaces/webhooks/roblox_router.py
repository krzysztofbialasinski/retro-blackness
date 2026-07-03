from __future__ import annotations

from fastapi import APIRouter, Depends, HTTPException, Request

from retro_blackness.application.roblox.commands.handle_user_joined import (
    HandleUserJoined,
    HandleUserJoinedRequest,
)
from retro_blackness.infrastructure.webhooks.signature_verifier import WebhookSignatureVerifier
from retro_blackness.interfaces.dependencies import (
    get_handle_user_joined_use_case,
    get_webhook_signature_verifier,
)
from retro_blackness.interfaces.webhooks.schemas import UserJoinedWebhookPayload

router = APIRouter(prefix="/webhooks/roblox", tags=["roblox-webhooks"])


@router.post("/user-joined", status_code=202)
async def user_joined(
    request: Request,
    payload: UserJoinedWebhookPayload,
    verifier: WebhookSignatureVerifier = Depends(get_webhook_signature_verifier),
    use_case: HandleUserJoined = Depends(get_handle_user_joined_use_case),
) -> dict[str, str]:
    signature = request.headers.get("x-roblox-signature", "")
    raw_body = await request.body()
    if not verifier.verify(raw_body, signature):
        raise HTTPException(status_code=401, detail="invalid webhook signature")

    await use_case.execute(
        HandleUserJoinedRequest(
            user_id=payload.user_id,
            universe_id=payload.universe_id,
            place_id=payload.place_id,
        )
    )
    return {"status": "accepted"}
