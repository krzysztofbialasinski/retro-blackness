--!strict
local expect = require("../../support/expect")
local testing = require("../../support/testing")

local entities = require("../../../src/domain/roblox/entities")
local valueObjects = require("../../../src/domain/roblox/value_objects")

testing.describe("domain/roblox entities")

testing.test("renameDisplayName updates the display name", function()
	local user = entities.robloxUser(valueObjects.robloxUserId(1), "neo", "Neo")
	entities.renameDisplayName(user, "The One")
	expect.that(user.displayName).toBe("The One")
end)

testing.test("renameDisplayName rejects a blank name", function()
	local user = entities.robloxUser(valueObjects.robloxUserId(1), "neo", "Neo")
	expect.throws(function()
		entities.renameDisplayName(user, "   ")
	end)
end)

testing.test("robloxUserId rejects a non-positive value", function()
	expect.throws(function()
		valueObjects.robloxUserId(0)
	end)
end)

testing.test("entities are equal by id, not by attributes", function()
	local first = entities.robloxUser(valueObjects.robloxUserId(1), "neo", "Neo")
	local second = entities.robloxUser(valueObjects.robloxUserId(1), "different", "Different")
	expect.that(entities.sameIdentity(first, second)).toBeTruthy()
end)

return {}
