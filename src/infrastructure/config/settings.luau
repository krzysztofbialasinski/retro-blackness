--!strict
-- Application settings, loaded from environment variables (prefix RB_).

local process = require("@lune/process")

local settings = {}

export type Settings = {
	robloxApiBaseUrl: string,
	robloxOpenCloudApiKey: string,
	robloxWebhookSecret: string,
	port: number,
}

function settings.load(): Settings
	return {
		robloxApiBaseUrl = process.env.RB_ROBLOX_API_BASE_URL or "https://apis.roblox.com",
		robloxOpenCloudApiKey = process.env.RB_ROBLOX_OPEN_CLOUD_API_KEY or "",
		robloxWebhookSecret = process.env.RB_ROBLOX_WEBHOOK_SECRET or "",
		port = tonumber(process.env.RB_PORT) or 8080,
	}
end

return settings
