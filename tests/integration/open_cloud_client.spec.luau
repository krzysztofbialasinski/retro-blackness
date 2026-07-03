--!strict
local net = require("@lune/net")

local expect = require("../support/expect")
local protected = require("../support/protected")
local testing = require("../support/testing")

local exceptions = require("../../src/domain/roblox/exceptions")
local openCloudClient = require("../../src/infrastructure/roblox_api/open_cloud_client")
local valueObjects = require("../../src/domain/roblox/value_objects")

testing.describe("infrastructure/roblox_api open cloud client")

-- Serves a stub Open Cloud endpoint on `port` for the duration of `run`, then shuts it
-- down. Each test uses a distinct port so a socket lingering in TIME_WAIT after stop()
-- never collides with the next bind.
local function withStub(port: number, run: (baseUrl: string) -> ())
	local handle = net.serve(port, function(request: any)
		if string.find(request.path, "/users/1") ~= nil then
			return { status = 200, body = '{"id":1,"name":"neo","displayName":"Neo"}' }
		end
		return { status = 404, body = "not found" }
	end)

	local ok, err = protected.run(function()
		run(`http://127.0.0.1:{port}`)
	end)
	handle.stop()
	if not ok then
		error(err)
	end
end

testing.test("maps the open cloud payload to a domain user", function()
	withStub(8071, function(baseUrl: string)
		local client = openCloudClient.new(baseUrl, "secret")
		local user = client.getUser(valueObjects.robloxUserId(1))
		expect.that(user.username).toBe("neo")
		expect.that(user.displayName).toBe("Neo")
	end)
end)

testing.test("raises RobloxUserNotFound on a 404 response", function()
	withStub(8073, function(baseUrl: string)
		local client = openCloudClient.new(baseUrl, "secret")
		local err = expect.throws(function()
			client.getUser(valueObjects.robloxUserId(2))
		end)
		expect.that(exceptions.isRobloxUserNotFound(err)).toBeTruthy()
	end)
end)

return {}
