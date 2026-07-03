--!strict
-- CLI entry (run under Lune) that publishes a built place file to Roblox via Open Cloud.
-- Usage: lune run scripts/publish -- <path-to-rbxlx>
-- Requires env vars: RB_ROBLOX_OPEN_CLOUD_API_KEY, RB_UNIVERSE_ID, RB_PLACE_ID.

local fs = require("@lune/fs")
local process = require("@lune/process")

local publishPlace = require("../src/application/roblox/commands/publish_place")
local placePublisher = require("../src/infrastructure/roblox_api/place_publisher")
local settings = require("../src/infrastructure/config/settings")

local function requireEnvNumber(name: string): number
	local value = tonumber(process.env[name])
	if value == nil then
		error(`{name} environment variable is required`)
	end
	return value
end

local function main()
	local placeFile = process.args[1]
	if placeFile == nil then
		error("usage: lune run scripts/publish -- <path-to-rbxlx>")
	end

	local config = settings.load()
	local universeId = requireEnvNumber("RB_UNIVERSE_ID")
	local placeId = requireEnvNumber("RB_PLACE_ID")
	local content = fs.readFile(placeFile)

	local publisher = placePublisher.new(config.robloxApiBaseUrl, config.robloxOpenCloudApiKey)
	local useCase = publishPlace.new(publisher)
	local result = useCase({ universeId = universeId, placeId = placeId, content = content })

	print(`Published place {placeId} as version {result.versionNumber}`)
end

main()
