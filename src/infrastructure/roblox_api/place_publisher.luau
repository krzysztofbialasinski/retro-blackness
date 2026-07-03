--!strict
-- Adapter that publishes a place version through the Roblox Open Cloud API.
--
-- NOTE: confirm the exact endpoint and payload against current Roblox Open Cloud docs before
-- relying on this in production; the versioned place-publish path has changed over time.

local net = require("@lune/net")
local serde = require("@lune/serde")

local ports = require("../../application/roblox/ports")
local valueObjects = require("../../domain/roblox/value_objects")

local placePublisher = {}

function placePublisher.new(baseUrl: string, apiKey: string): ports.PlacePublisherPort
	local trimmedBase = (baseUrl:gsub("/+$", ""))
	local headers: net.HttpHeaderMap = {
		["x-api-key"] = apiKey,
		["content-type"] = "application/octet-stream",
	}

	local function publish(
		universeId: valueObjects.UniverseId,
		placeId: valueObjects.PlaceId,
		content: string
	): ports.PublishPlaceResult
		local path = `/universes/v1/{universeId.value}/places/{placeId.value}/versions`
		local requestParams: net.FetchParams = {
			url = `{trimmedBase}{path}?versionType=Published`,
			method = "POST",
			headers = headers,
			body = content,
		}
		local response = net.request(requestParams)
		if not response.ok then
			error(`Roblox place publish failed {response.statusCode}: {response.statusMessage}`)
		end
		local decoded = serde.decode("json", response.body)
		return { versionNumber = decoded.versionNumber }
	end

	return { publish = publish }
end

return placePublisher
