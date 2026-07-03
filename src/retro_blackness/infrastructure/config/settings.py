from __future__ import annotations

from functools import lru_cache

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(env_file=".env", env_prefix="RB_", extra="ignore")

    roblox_api_base_url: str = "https://apis.roblox.com"
    roblox_open_cloud_api_key: str = Field(default="")
    roblox_webhook_secret: str = Field(default="")


@lru_cache
def get_settings() -> Settings:
    return Settings()
