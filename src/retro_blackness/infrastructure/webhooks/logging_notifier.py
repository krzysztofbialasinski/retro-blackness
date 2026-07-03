from __future__ import annotations

import logging

from retro_blackness.application.roblox.ports import GameEventNotifierPort
from retro_blackness.domain.roblox.events import UserJoinedGame

logger = logging.getLogger(__name__)


class LoggingGameEventNotifier(GameEventNotifierPort):
    """Default adapter: records game events to the application log.

    Replace with a real adapter (message queue, analytics sink, ...) as needs grow.
    """

    async def notify_user_joined(self, event: UserJoinedGame) -> None:
        logger.info(
            "user_joined_game user_id=%s universe_id=%s place_id=%s",
            event.user_id.value,
            event.universe_id.value,
            event.place_id.value,
        )
