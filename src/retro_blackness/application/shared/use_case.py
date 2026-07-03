from __future__ import annotations

from abc import ABC, abstractmethod


class UseCase[TRequest, TResponse](ABC):
    """A single application-level operation, orchestrating domain objects via ports."""

    @abstractmethod
    async def execute(self, request: TRequest) -> TResponse: ...
