--!strict
-- RobloxUser entity: defined by identity (userId), not by attribute values.

local valueObjects = require("../roblox/value_objects")

local entities = {}

export type RobloxUser = {
	userId: valueObjects.RobloxUserId,
	username: string,
	displayName: string,
}

function entities.robloxUser(
	userId: valueObjects.RobloxUserId,
	username: string,
	displayName: string
): RobloxUser
	return {
		userId = userId,
		username = username,
		displayName = displayName,
	}
end

function entities.renameDisplayName(user: RobloxUser, newDisplayName: string)
	if newDisplayName:match("%S") == nil then
		error("displayName cannot be blank")
	end
	user.displayName = newDisplayName
end

-- Entity equality is by identity: two RobloxUsers are the same iff their ids match.
function entities.sameIdentity(a: RobloxUser, b: RobloxUser): boolean
	return a.userId.value == b.userId.value
end

return entities
