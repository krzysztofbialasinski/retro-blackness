--!strict
-- Inbound webhook route: POST /webhooks/roblox/user-joined

local serde = require("@lune/serde")

local handleUserJoined = require("../../application/roblox/commands/handle_user_joined")
local httpRouter = require("../http/router")
local signatureVerifier = require("../../infrastructure/webhooks/signature_verifier")

local robloxWebhookRouter = {}

function robloxWebhookRouter.new(
	verifier: signatureVerifier.SignatureVerifier,
	useCase: (request: handleUserJoined.Request) -> ()
): httpRouter.Route
	local function handle(request: any, _params: { string }): httpRouter.RouteResult
		local signature = request.headers["x-roblox-signature"] or ""
		if not verifier.verify(request.body, signature) then
			return { status = 401, json = { detail = "invalid webhook signature" } }
		end

		local payload = serde.decode("json", request.body)
		useCase({
			userId = payload.user_id,
			universeId = payload.universe_id,
			placeId = payload.place_id,
		})
		return { status = 202, json = { status = "accepted" } }
	end

	return { method = "POST", pattern = "^/webhooks/roblox/user%-joined$", handle = handle }
end

return robloxWebhookRouter
