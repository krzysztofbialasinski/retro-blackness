--!strict
local net = require("@lune/net")
local serde = require("@lune/serde")

local expect = require("../support/expect")
local protected = require("../support/protected")
local testing = require("../support/testing")

local app = require("../../src/interfaces/http/app")
local handleUserJoined = require("../../src/application/roblox/commands/handle_user_joined")
local ports = require("../../src/application/roblox/ports")
local robloxWebhookRouter = require("../../src/interfaces/webhooks/roblox_router")

testing.describe("interfaces/webhooks e2e roblox router")

local function fakeVerifier(shouldAccept: boolean): ports.SignatureVerifierPort
	return {
		verify = function(_body: string, _signature: string): boolean
			return shouldAccept
		end,
	}
end

testing.test("POST /webhooks/roblox/user-joined accepts a validly signed payload", function()
	local captured: { handleUserJoined.Request } = {}
	local stubUseCase = function(request: handleUserJoined.Request)
		table.insert(captured, request)
	end
	local routes = { robloxWebhookRouter.new(fakeVerifier(true), stubUseCase) }
	local port = 8074

	local handle = net.serve(port, app.handler(routes))
	local ok, err = protected.run(function()
		local headers: net.HttpHeaderMap =
			{ ["x-roblox-signature"] = "accepted-by-the-fake-verifier" }
		local requestParams: net.FetchParams = {
			url = `http://127.0.0.1:{port}/webhooks/roblox/user-joined`,
			method = "POST",
			headers = headers,
			body = serde.encode("json", { user_id = 1, universe_id = 2, place_id = 3 }),
		}
		local response = net.request(requestParams)
		expect.that(response.statusCode).toBe(202)
		expect.that(#captured).toBe(1)
		expect.that(captured[1].userId).toBe(1)
		expect.that(captured[1].universeId).toBe(2)
		expect.that(captured[1].placeId).toBe(3)
	end)
	handle.stop()
	if not ok then
		error(err)
	end
end)

testing.test("POST /webhooks/roblox/user-joined rejects an invalid signature", function()
	local stubUseCase = function(_request: handleUserJoined.Request) end
	local routes = { robloxWebhookRouter.new(fakeVerifier(false), stubUseCase) }
	local port = 8075

	local handle = net.serve(port, app.handler(routes))
	local ok, err = protected.run(function()
		local headers: net.HttpHeaderMap = { ["x-roblox-signature"] = "wrong" }
		local requestParams: net.FetchParams = {
			url = `http://127.0.0.1:{port}/webhooks/roblox/user-joined`,
			method = "POST",
			headers = headers,
			body = serde.encode("json", { user_id = 1, universe_id = 2, place_id = 3 }),
		}
		local response = net.request(requestParams)
		expect.that(response.statusCode).toBe(401)
	end)
	handle.stop()
	if not ok then
		error(err)
	end
end)

return {}
