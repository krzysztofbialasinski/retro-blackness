--!strict
local expect = require("../../support/expect")
local testing = require("../../support/testing")

local entities = require("../../../src/domain/roblox/entities")
local getUserProfile = require("../../../src/application/roblox/queries/get_user_profile")
local valueObjects = require("../../../src/domain/roblox/value_objects")

testing.describe("application/roblox get user profile")

testing.test("returns the user resolved by the api port", function()
	local expected = entities.robloxUser(valueObjects.robloxUserId(42), "neo", "Neo")
	local fakeApi = {
		getUser = function(userId: valueObjects.RobloxUserId): entities.RobloxUser
			expect.that(userId.value).toBe(42)
			return expected
		end,
	}

	local useCase = getUserProfile.new(fakeApi)
	local result = useCase({ userId = 42 })

	expect.that(result).toBe(expected)
end)

return {}
