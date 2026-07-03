--!strict
-- Default GameEventNotifierPort adapter: records game events to stdout.
-- Replace with a real adapter (message queue, analytics sink, ...) as needs grow.

local events = require("../../domain/roblox/events")
local ports = require("../../application/roblox/ports")

local loggingNotifier = {}

function loggingNotifier.new(): ports.GameEventNotifierPort
	local function notifyUserJoined(event: events.UserJoinedGame)
		print(
			`user_joined_game user_id={event.userId.value} `
				.. `universe_id={event.universeId.value} place_id={event.placeId.value}`
		)
	end

	return { notifyUserJoined = notifyUserJoined }
end

return loggingNotifier
