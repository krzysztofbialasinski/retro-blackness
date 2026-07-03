from __future__ import annotations

from dataclasses import dataclass, field
from datetime import UTC, datetime


@dataclass(frozen=True, slots=True)
class DomainEvent:
    """Marker base for events raised by the domain. Subclasses add payload fields."""

    occurred_at: datetime = field(default_factory=lambda: datetime.now(UTC), kw_only=True)
