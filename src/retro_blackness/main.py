from __future__ import annotations

from fastapi import FastAPI

from retro_blackness.interfaces.api.v1.roblox_router import router as roblox_api_router
from retro_blackness.interfaces.webhooks.roblox_router import router as roblox_webhook_router


def create_app() -> FastAPI:
    app = FastAPI(title="retro-blackness", description="Roblox integration service")
    app.include_router(roblox_api_router)
    app.include_router(roblox_webhook_router)
    return app


app = create_app()
