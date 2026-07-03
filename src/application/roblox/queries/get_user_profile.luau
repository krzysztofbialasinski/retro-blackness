--!strict
-- Query use case: fetch a Roblox user's profile through the API client port.

local entities = require("../../../domain/roblox/entities")
local valueObjects = require("../../../domain/roblox/value_objects")
local ports = require("../ports")

local getUserProfile = {}

export type Request = { userId: number }

function getUserProfile.new(
	api: ports.RobloxApiClientPort
): (request: Request) -> entities.RobloxUser
	return function(request: Request): entities.RobloxUser
		return api.getUser(valueObjects.robloxUserId(request.userId))
	end
end

return getUserProfile
