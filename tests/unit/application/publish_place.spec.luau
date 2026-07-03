--!strict
local expect = require("../../support/expect")
local testing = require("../../support/testing")

local publishPlace = require("../../../src/application/roblox/commands/publish_place")
local valueObjects = require("../../../src/domain/roblox/value_objects")

testing.describe("application/roblox publish place")

testing.test("publishes content through the publisher port", function()
	local captured = { universeId = 0, placeId = 0, content = "" }
	local publisher = {
		publish = function(
			universeId: valueObjects.UniverseId,
			placeId: valueObjects.PlaceId,
			content: string
		)
			captured.universeId = universeId.value
			captured.placeId = placeId.value
			captured.content = content
			return { versionNumber = 7 }
		end,
	}

	local useCase = publishPlace.new(publisher)
	local result = useCase({ universeId = 10, placeId = 20, content = "rbxlx-bytes" })

	expect.that(result.versionNumber).toBe(7)
	expect.that(captured.universeId).toBe(10)
	expect.that(captured.placeId).toBe(20)
	expect.that(captured.content).toBe("rbxlx-bytes")
end)

return {}
