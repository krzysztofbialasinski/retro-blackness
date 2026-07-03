--!strict
-- Outbound ports for the Roblox context. Infrastructure adapters implement these;
-- the application layer depends only on the interfaces, never on concrete adapters.

local entities = require("../../domain/roblox/entities")
local events = require("../../domain/roblox/events")
local valueObjects = require("../../domain/roblox/value_objects")

local ports = {}

export type RobloxApiClientPort = {
	getUser: (userId: valueObjects.RobloxUserId) -> entities.RobloxUser,
}

export type GameEventNotifierPort = {
	notifyUserJoined: (event: events.UserJoinedGame) -> (),
}

export type PublishPlaceResult = { versionNumber: number }

export type PlacePublisherPort = {
	publish: (
		universeId: valueObjects.UniverseId,
		placeId: valueObjects.PlaceId,
		content: string
	) -> PublishPlaceResult,
}

return ports
