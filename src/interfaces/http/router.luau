--!strict
-- Minimal HTTP route matcher for net.serve. A route matches when its method equals the
-- request method and its Luau string pattern matches the request path; pattern captures
-- become the route's path parameters.

local httpRouter = {}

export type RouteResult = { status: number, json: any? }

export type Route = {
	method: string,
	pattern: string,
	handle: (request: any, params: { string }) -> RouteResult,
}

export type Match = { route: Route, params: { string } }

function httpRouter.match(routes: { Route }, method: string, path: string): Match?
	for _, route in routes do
		if route.method == method then
			local captures = { string.match(path, route.pattern) }
			if captures[1] ~= nil then
				return { route = route, params = captures :: { string } }
			end
		end
	end
	return nil
end

return httpRouter
