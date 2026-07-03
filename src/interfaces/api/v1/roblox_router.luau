--!strict
-- REST route: GET /api/v1/roblox/users/{userId}

local entities = require("../../../domain/roblox/entities")
local exceptions = require("../../../domain/roblox/exceptions")
local getUserProfile = require("../../../application/roblox/queries/get_user_profile")
local httpRouter = require("../../http/router")
local schemas = require("./schemas")

local robloxApiRouter = {}

function robloxApiRouter.new(
	useCase: (request: getUserProfile.Request) -> entities.RobloxUser
): httpRouter.Route
	local function handle(_request: any, params: { string }): httpRouter.RouteResult
		local userId = tonumber(params[1]) or 0
		local ok, result = pcall(useCase, { userId = userId })
		if not ok then
			local err = result :: any
			if exceptions.isRobloxUserNotFound(err) then
				return { status = 404, json = { detail = err.message } }
			end
			error(err)
		end
		return { status = 200, json = schemas.robloxUserResponse(result) }
	end

	return { method = "GET", pattern = "^/api/v1/roblox/users/(%d+)$", handle = handle }
end

return robloxApiRouter
