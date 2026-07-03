--!strict
-- Adapter for the Roblox Open Cloud API (https://apis.roblox.com). Implements
-- RobloxApiClientPort using Lune's HTTP client.

local net = require("@lune/net")
local serde = require("@lune/serde")

local entities = require("../../domain/roblox/entities")
local exceptions = require("../../domain/roblox/exceptions")
local ports = require("../../application/roblox/ports")
local valueObjects = require("../../domain/roblox/value_objects")
local mappers = require("./mappers")

local openCloudClient = {}

function openCloudClient.new(baseUrl: string, apiKey: string): ports.RobloxApiClientPort
	local trimmedBase = (baseUrl:gsub("/+$", ""))

	local headers: net.HttpHeaderMap = { ["x-api-key"] = apiKey }

	local function getUser(userId: valueObjects.RobloxUserId): entities.RobloxUser
		local requestParams: net.FetchParams = {
			url = `{trimmedBase}/users/v1/users/{userId.value}`,
			method = "GET",
			headers = headers,
		}
		local response = net.request(requestParams)
		if response.statusCode == 404 then
			error(exceptions.robloxUserNotFound(userId.value))
		end
		if not response.ok then
			error(`Roblox API error {response.statusCode}: {response.statusMessage}`)
		end
		return mappers.userFromOpenCloudPayload(serde.decode("json", response.body))
	end

	return { getUser = getUser }
end

return openCloudClient
