--!strict
-- Translates Roblox Open Cloud JSON payloads into domain entities.

local entities = require("../../domain/roblox/entities")
local valueObjects = require("../../domain/roblox/value_objects")

local mappers = {}

export type OpenCloudUserPayload = {
	id: string,
	name: string,
	displayName: string?,
}

function mappers.userFromOpenCloudPayload(payload: OpenCloudUserPayload): entities.RobloxUser
	return entities.robloxUser(
		valueObjects.robloxUserId(tonumber(payload.id) :: number),
		payload.name,
		payload.displayName or payload.name
	)
end

return mappers
