--!strict
local expect = require("../../support/expect")
local testing = require("../../support/testing")

local events = require("../../../src/domain/roblox/events")
local handleUserJoined = require("../../../src/application/roblox/commands/handle_user_joined")

testing.describe("application/roblox handle user joined")

testing.test("notifies with a domain event built from the request", function()
	local captured: { events.UserJoinedGame } = {}
	local notifier = {
		notifyUserJoined = function(event: events.UserJoinedGame)
			table.insert(captured, event)
		end,
	}

	local useCase = handleUserJoined.new(notifier)
	useCase({ userId = 1, universeId = 2, placeId = 3 })

	expect.that(#captured).toBe(1)
	expect.that(captured[1].userId.value).toBe(1)
	expect.that(captured[1].universeId.value).toBe(2)
	expect.that(captured[1].placeId.value).toBe(3)
end)

return {}
