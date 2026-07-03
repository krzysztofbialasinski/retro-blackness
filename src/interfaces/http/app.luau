--!strict
-- Builds the net.serve request handler from a route table. Kept separate from the
-- process entry point (main.luau) so it can be exercised in e2e tests without the
-- side effect of binding a fixed port at module load.

local serde = require("@lune/serde")

local httpRouter = require("./router")

local app = {}

local jsonHeaders = { ["content-type"] = "application/json" }

local function respond(status: number, json: any?)
	return {
		status = status,
		headers = jsonHeaders,
		body = if json ~= nil then serde.encode("json", json) else "",
	}
end

function app.handler(routes: { httpRouter.Route }): (request: any) -> any
	return function(request: any)
		local match = httpRouter.match(routes, request.method, request.path)
		if match == nil then
			return respond(404, { detail = "not found" })
		end

		-- Routers translate their own known domain errors into HTTP statuses; this is the
		-- last-resort boundary for anything else, so a single bad request always gets the
		-- same JSON error shape as every other response instead of Lune's plaintext default.
		local ok, result = pcall(match.route.handle, request, match.params)
		if not ok then
			return respond(500, { detail = "internal server error" })
		end

		return respond(result.status, result.json)
	end
end

return app
