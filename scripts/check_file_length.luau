--!strict
-- Quality gate: fail if any .luau file exceeds the project's max line count.

local fs = require("@lune/fs")
local process = require("@lune/process")

local MAX_LINES = 500
local DIRS = { "src", "tests", "scripts", "game" }

local violations: { string } = {}

local function countLines(content: string): number
	return select(2, string.gsub(content, "\n", "\n")) + 1
end

local function walk(dir: string)
	if not fs.isDir(dir) then
		return
	end
	for _, name in fs.readDir(dir) do
		local path = `{dir}/{name}`
		if fs.isDir(path) then
			walk(path)
		elseif string.match(path, "%.luau$") ~= nil then
			local lines = countLines(fs.readFile(path))
			if lines > MAX_LINES then
				table.insert(violations, `  {path}: {lines} lines`)
			end
		end
	end
end

local function main()
	for _, dir in DIRS do
		walk(dir)
	end

	if #violations > 0 then
		print(`Files exceeding the {MAX_LINES}-line limit:`)
		for _, entry in violations do
			print(entry)
		end
		process.exit(1)
	end

	print(`OK: all .luau files are within {MAX_LINES} lines.`)
end

main()
