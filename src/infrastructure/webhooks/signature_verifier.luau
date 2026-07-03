--!strict
-- Verifies HMAC-SHA256 signatures on inbound webhook payloads from a Roblox game server.
--
-- NOTE: this uses Lune's `serde.hmac` (base64 digest) over the raw body. When wiring a real
-- Roblox webhook source, confirm the exact signature scheme in Roblox's docs (encoding and
-- whether a timestamp is prepended) and adjust this adapter to match.

local serde = require("@lune/serde")

local ports = require("../../application/roblox/ports")

local signatureVerifier = {}

local function constantTimeEquals(a: string, b: string): boolean
	if #a ~= #b then
		return false
	end
	local diff = 0
	for index = 1, #a do
		diff = bit32.bor(diff, bit32.bxor(string.byte(a, index), string.byte(b, index)))
	end
	return diff == 0
end

function signatureVerifier.new(secret: string): ports.SignatureVerifierPort
	local function verify(body: string, signature: string): boolean
		if signature == "" then
			return false
		end
		local expected = serde.hmac("sha256", body, secret)
		return constantTimeEquals(expected, signature)
	end

	return { verify = verify }
end

return signatureVerifier
