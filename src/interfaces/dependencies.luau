--!strict
-- Composition root: wires adapters into use cases and builds the route table.

local getUserProfile = require("../application/roblox/queries/get_user_profile")
local handleUserJoined = require("../application/roblox/commands/handle_user_joined")
local settings = require("../infrastructure/config/settings")
local openCloudClient = require("../infrastructure/roblox_api/open_cloud_client")
local loggingNotifier = require("../infrastructure/webhooks/logging_notifier")
local signatureVerifier = require("../infrastructure/webhooks/signature_verifier")
local httpRouter = require("./http/router")
local robloxApiRouter = require("./api/v1/roblox_router")
local robloxWebhookRouter = require("./webhooks/roblox_router")

local dependencies = {}

function dependencies.buildRoutes(config: settings.Settings?): { httpRouter.Route }
	local resolved = config or settings.load()

	local apiClient = openCloudClient.new(resolved.robloxApiBaseUrl, resolved.robloxOpenCloudApiKey)
	local verifier = signatureVerifier.new(resolved.robloxWebhookSecret)
	local notifier = loggingNotifier.new()

	local getUserProfileUseCase = getUserProfile.new(apiClient)
	local handleUserJoinedUseCase = handleUserJoined.new(notifier)

	return {
		robloxApiRouter.new(getUserProfileUseCase),
		robloxWebhookRouter.new(verifier, handleUserJoinedUseCase),
	}
end

return dependencies
