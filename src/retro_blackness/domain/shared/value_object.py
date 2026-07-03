from __future__ import annotations

from dataclasses import dataclass


@dataclass(frozen=True, slots=True)
class ValueObject:
    """Marker base for immutable, equality-by-value domain objects."""
