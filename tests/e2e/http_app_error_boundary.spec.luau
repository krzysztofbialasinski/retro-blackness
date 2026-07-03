--!strict
local net = require("@lune/net")
local serde = require("@lune/serde")

local expect = require("../support/expect")
local protected = require("../support/protected")
local testing = require("../support/testing")

local app = require("../../src/interfaces/http/app")
local httpRouter = require("../../src/interfaces/http/router")

testing.describe("interfaces/http e2e app error boundary")

testing.test(
	"returns the same JSON error shape as other errors instead of a plaintext body",
	function()
		local explodingRoute: httpRouter.Route = {
			method = "GET",
			pattern = "^/boom$",
			handle = function(_request: any, _params: { string }): httpRouter.RouteResult
				error("kaboom")
			end,
		}
		local routes = { explodingRoute }
		local port = 8083

		local handle = net.serve(port, app.handler(routes))
		local ok, err = protected.run(function()
			local response = net.request({ url = `http://127.0.0.1:{port}/boom` })
			expect.that(response.statusCode).toBe(500)
			expect.that(response.headers["content-type"]).toBe("application/json")

			local body = serde.decode("json", response.body)
			expect.that(body.detail).toBe("internal server error")
		end)
		handle.stop()
		if not ok then
			error(err)
		end
	end
)

return {}
