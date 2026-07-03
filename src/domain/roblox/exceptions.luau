--!strict
-- Structured domain errors. Luau has no exception classes, so errors are tagged
-- tables raised with `error(...)` and identified by their `kind`.

local exceptions = {}

export type RobloxUserNotFound = {
	kind: "RobloxUserNotFound",
	userId: number,
	message: string,
}

function exceptions.robloxUserNotFound(userId: number): RobloxUserNotFound
	local notFound: RobloxUserNotFound = {
		kind = "RobloxUserNotFound",
		userId = userId,
		message = `Roblox user {userId} not found`,
	}
	return table.freeze(notFound)
end

function exceptions.isRobloxUserNotFound(err: any): boolean
	return type(err) == "table" and err.kind == "RobloxUserNotFound"
end

return exceptions
