--!strict
-- Command use case: react to a "user joined game" event from an inbound webhook by
-- building the domain event and dispatching it through the notifier port.

local events = require("../../../domain/roblox/events")
local valueObjects = require("../../../domain/roblox/value_objects")
local ports = require("../ports")

local handleUserJoined = {}

export type Request = { userId: number, universeId: number, placeId: number }

function handleUserJoined.new(notifier: ports.GameEventNotifierPort): (request: Request) -> ()
	return function(request: Request)
		local event = events.userJoinedGame(
			valueObjects.robloxUserId(request.userId),
			valueObjects.universeId(request.universeId),
			valueObjects.placeId(request.placeId)
		)
		notifier.notifyUserJoined(event)
	end
end

return handleUserJoined
