--!strict
-- Value Objects for the Roblox bounded context: immutable, validated on creation,
-- compared by value. No framework dependencies (pure Luau).

local valueObjects = {}

export type RobloxUserId = { value: number }
export type UniverseId = { value: number }
export type PlaceId = { value: number }

local function assertPositive(kind: string, value: number)
	if value <= 0 or value % 1 ~= 0 then
		error(`{kind} must be a positive integer, got {value}`)
	end
end

function valueObjects.robloxUserId(value: number): RobloxUserId
	assertPositive("RobloxUserId", value)
	return table.freeze({ value = value })
end

function valueObjects.universeId(value: number): UniverseId
	assertPositive("UniverseId", value)
	return table.freeze({ value = value })
end

function valueObjects.placeId(value: number): PlaceId
	assertPositive("PlaceId", value)
	return table.freeze({ value = value })
end

return valueObjects
