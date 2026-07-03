from __future__ import annotations

from functools import lru_cache

from retro_blackness.application.roblox.commands.handle_user_joined import HandleUserJoined
from retro_blackness.application.roblox.queries.get_user_profile import GetRobloxUserProfile
from retro_blackness.infrastructure.config.settings import get_settings
from retro_blackness.infrastructure.roblox_api.open_cloud_client import RobloxOpenCloudClient
from retro_blackness.infrastructure.webhooks.logging_notifier import LoggingGameEventNotifier
from retro_blackness.infrastructure.webhooks.signature_verifier import WebhookSignatureVerifier


@lru_cache
def get_roblox_api_client() -> RobloxOpenCloudClient:
    settings = get_settings()
    return RobloxOpenCloudClient(
        base_url=settings.roblox_api_base_url,
        api_key=settings.roblox_open_cloud_api_key,
    )


def get_roblox_user_profile_use_case() -> GetRobloxUserProfile:
    return GetRobloxUserProfile(get_roblox_api_client())


def get_handle_user_joined_use_case() -> HandleUserJoined:
    return HandleUserJoined(LoggingGameEventNotifier())


def get_webhook_signature_verifier() -> WebhookSignatureVerifier:
    return WebhookSignatureVerifier(get_settings().roblox_webhook_secret)
