--!strict
-- Command use case: publish a built place file to a Roblox experience via the publisher port.

local valueObjects = require("../../../domain/roblox/value_objects")
local ports = require("../ports")

local publishPlace = {}

export type Request = { universeId: number, placeId: number, content: string }

function publishPlace.new(
	publisher: ports.PlacePublisherPort
): (request: Request) -> ports.PublishPlaceResult
	return function(request: Request): ports.PublishPlaceResult
		return publisher.publish(
			valueObjects.universeId(request.universeId),
			valueObjects.placeId(request.placeId),
			request.content
		)
	end
end

return publishPlace
