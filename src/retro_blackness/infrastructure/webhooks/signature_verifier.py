from __future__ import annotations

import hashlib
import hmac


class WebhookSignatureVerifier:
    """Verifies HMAC-SHA256 signatures on inbound webhook payloads from a Roblox game server."""

    def __init__(self, secret: str) -> None:
        self._secret = secret.encode("utf-8")

    def verify(self, raw_body: bytes, signature: str) -> bool:
        if not signature:
            return False
        expected = hmac.new(self._secret, raw_body, hashlib.sha256).hexdigest()
        return hmac.compare_digest(expected, signature)
