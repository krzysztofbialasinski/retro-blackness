--!strict
local net = require("@lune/net")
local serde = require("@lune/serde")

local expect = require("../support/expect")
local protected = require("../support/protected")
local testing = require("../support/testing")

local app = require("../../src/interfaces/http/app")
local entities = require("../../src/domain/roblox/entities")
local getUserProfile = require("../../src/application/roblox/queries/get_user_profile")
local robloxApiRouter = require("../../src/interfaces/api/v1/roblox_router")
local valueObjects = require("../../src/domain/roblox/value_objects")

testing.describe("interfaces/api e2e roblox router")

local PORT = 8072

testing.test("GET /api/v1/roblox/users/{id} returns the profile as JSON", function()
	local stubUseCase = function(request: getUserProfile.Request): entities.RobloxUser
		return entities.robloxUser(valueObjects.robloxUserId(request.userId), "neo", "Neo")
	end
	local routes = { robloxApiRouter.new(stubUseCase) }

	local handle = net.serve(PORT, app.handler(routes))
	local ok, err = protected.run(function()
		local response = net.request({
			url = `http://127.0.0.1:{PORT}/api/v1/roblox/users/1`,
		})
		expect.that(response.statusCode).toBe(200)

		local body = serde.decode("json", response.body)
		expect.that(body.user_id).toBe(1)
		expect.that(body.username).toBe("neo")
		expect.that(body.display_name).toBe("Neo")
	end)
	handle.stop()
	if not ok then
		error(err)
	end
end)

return {}
