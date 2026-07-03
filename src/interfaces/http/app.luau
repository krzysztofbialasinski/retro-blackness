--!strict
-- Builds the net.serve request handler from a route table. Kept separate from the
-- process entry point (main.luau) so it can be exercised in e2e tests without the
-- side effect of binding a fixed port at module load.

local serde = require("@lune/serde")

local httpRouter = require("./router")

local app = {}

local jsonHeaders = { ["content-type"] = "application/json" }

function app.handler(routes: { httpRouter.Route }): (request: any) -> any
	return function(request: any)
		local match = httpRouter.match(routes, request.method, request.path)
		if match == nil then
			return {
				status = 404,
				headers = jsonHeaders,
				body = serde.encode("json", { detail = "not found" }),
			}
		end

		local result = match.route.handle(request, match.params)
		return {
			status = result.status,
			headers = jsonHeaders,
			body = if result.json ~= nil then serde.encode("json", result.json) else "",
		}
	end
end

return app
