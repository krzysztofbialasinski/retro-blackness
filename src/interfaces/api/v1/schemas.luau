--!strict
-- Response shapes for the v1 REST API.

local entities = require("../../../domain/roblox/entities")

local schemas = {}

export type RobloxUserResponse = {
	user_id: number,
	username: string,
	display_name: string,
}

function schemas.robloxUserResponse(user: entities.RobloxUser): RobloxUserResponse
	return {
		user_id = user.userId.value,
		username = user.username,
		display_name = user.displayName,
	}
end

return schemas
