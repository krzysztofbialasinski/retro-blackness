--!strict
-- Tiny assertion helpers used by the specs.

local protected = require("./protected")

local expect = {}

local function repr(value: any): string
	if type(value) == "table" then
		local parts = {}
		for key, item in value do
			table.insert(parts, `{tostring(key)}={tostring(item)}`)
		end
		return "{" .. table.concat(parts, ", ") .. "}"
	end
	return tostring(value)
end

local function deepEqual(a: any, b: any): boolean
	if a == b then
		return true
	end
	if type(a) ~= "table" or type(b) ~= "table" then
		return false
	end
	for key, item in a do
		if not deepEqual(item, b[key]) then
			return false
		end
	end
	for key in b do
		if a[key] == nil then
			return false
		end
	end
	return true
end

export type Expectation = {
	toBe: (expected: any) -> (),
	toEqual: (expected: any) -> (),
	toBeTruthy: () -> (),
	toBeFalsy: () -> (),
}

function expect.that(actual: any): Expectation
	return {
		toBe = function(expected: any)
			if actual ~= expected then
				error(`expected {repr(expected)} but got {repr(actual)}`)
			end
		end,
		toEqual = function(expected: any)
			if not deepEqual(actual, expected) then
				error(`expected {repr(expected)} but got {repr(actual)}`)
			end
		end,
		toBeTruthy = function()
			if not actual then
				error(`expected a truthy value but got {repr(actual)}`)
			end
		end,
		toBeFalsy = function()
			if actual then
				error(`expected a falsy value but got {repr(actual)}`)
			end
		end,
	}
end

-- Runs `fn`, returns the raised error, and fails if `fn` did not raise.
function expect.throws(fn: () -> ()): any
	local ok, err = protected.run(fn)
	if ok then
		error("expected the function to raise an error, but it did not")
	end
	return err
end

return expect
