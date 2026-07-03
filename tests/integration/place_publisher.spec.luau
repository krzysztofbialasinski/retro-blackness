--!strict
local net = require("@lune/net")

local expect = require("../support/expect")
local protected = require("../support/protected")
local testing = require("../support/testing")

local placePublisher = require("../../src/infrastructure/roblox_api/place_publisher")
local valueObjects = require("../../src/domain/roblox/value_objects")

testing.describe("infrastructure/roblox_api place publisher")

-- Serves a stub Open Cloud endpoint on `port` for the duration of `run`, then shuts it
-- down. Each test uses a distinct port so a socket lingering in TIME_WAIT after stop()
-- never collides with the next bind.
local function withStub(port: number, run: (baseUrl: string) -> ())
	local handle = net.serve(port, function(request: any)
		if
			request.method == "POST"
			and string.find(request.path, "/universes/v1/10/places/20/versions") ~= nil
		then
			return { status = 200, body = '{"versionNumber":7}' }
		end
		return { status = 500, body = "unexpected request" }
	end)

	local ok, err = protected.run(function()
		run(`http://127.0.0.1:{port}`)
	end)
	handle.stop()
	if not ok then
		error(err)
	end
end

testing.test("publishes content and returns the resulting version number", function()
	withStub(8081, function(baseUrl: string)
		local publisher = placePublisher.new(baseUrl, "secret")
		local result =
			publisher.publish(valueObjects.universeId(10), valueObjects.placeId(20), "rbxlx-bytes")
		expect.that(result.versionNumber).toBe(7)
	end)
end)

testing.test("raises when the publish request fails", function()
	withStub(8082, function(baseUrl: string)
		local publisher = placePublisher.new(baseUrl, "secret")
		local err = expect.throws(function()
			publisher.publish(
				valueObjects.universeId(999),
				valueObjects.placeId(999),
				"rbxlx-bytes"
			)
		end)
		expect.that(string.find(tostring(err), "Roblox place publish failed") ~= nil).toBeTruthy()
	end)
end)

return {}
