--!strict
-- Domain events raised by the Roblox bounded context.

local valueObjects = require("../roblox/value_objects")

local events = {}

export type UserJoinedGame = {
	userId: valueObjects.RobloxUserId,
	universeId: valueObjects.UniverseId,
	placeId: valueObjects.PlaceId,
	occurredAt: number,
}

function events.userJoinedGame(
	userId: valueObjects.RobloxUserId,
	universeId: valueObjects.UniverseId,
	placeId: valueObjects.PlaceId
): UserJoinedGame
	return table.freeze({
		userId = userId,
		universeId = universeId,
		placeId = placeId,
		occurredAt = os.time(),
	})
end

return events
