--!strict
-- pcall wrapper that type-checks cleanly even when the callback returns no values.
-- (Luau types `pcall(f)` as returning only the boolean when `f` returns nothing, which
-- breaks `local ok, err = pcall(f)`; returning a value from the inner closure fixes it.)

local protected = {}

function protected.run(fn: () -> ()): (boolean, any)
	return pcall(function(): any
		fn()
		return nil
	end)
end

return protected
