--!strict
-- Quality gate: fail if any function's cyclomatic complexity exceeds the limit.
--
-- This is a documented best-effort HEURISTIC (the Luau ecosystem has no mccabe-equivalent
-- linter): line comments are stripped, then complexity is estimated as 1 + the number of
-- decision keywords (if / elseif / for / while / repeat / and / or) counted per function,
-- where functions are delimited by the `function` keyword. Good enough to catch runaway
-- branching in small, single-responsibility modules; not a full control-flow analysis.

local fs = require("@lune/fs")
local process = require("@lune/process")

local MAX_COMPLEXITY = 10
local DIRS = { "src", "scripts", "tests" }
local DECISION_KEYWORDS = {
	["if"] = true,
	["elseif"] = true,
	["for"] = true,
	["while"] = true,
	["repeat"] = true,
	["and"] = true,
	["or"] = true,
}

local violations: { string } = {}

local function analyze(path: string, content: string)
	local stripped = string.gsub(content, "%-%-[^\n]*", "")
	local maxForFile = 0
	local complexity = 1
	local seenFunction = false

	for word in string.gmatch(stripped, "[%a_]+") do
		if word == "function" then
			if complexity > maxForFile then
				maxForFile = complexity
			end
			seenFunction = true
			complexity = 1
		elseif seenFunction and DECISION_KEYWORDS[word] then
			complexity += 1
		end
	end
	if complexity > maxForFile then
		maxForFile = complexity
	end

	if maxForFile > MAX_COMPLEXITY then
		table.insert(
			violations,
			`  {path}: a function has estimated complexity {maxForFile} (> {MAX_COMPLEXITY})`
		)
	end
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
			analyze(path, fs.readFile(path))
		end
	end
end

local function main()
	for _, dir in DIRS do
		walk(dir)
	end

	if #violations > 0 then
		print(`Functions exceeding cyclomatic complexity {MAX_COMPLEXITY}:`)
		for _, entry in violations do
			print(entry)
		end
		process.exit(1)
	end

	print(`OK: no function exceeds estimated complexity {MAX_COMPLEXITY}.`)
end

main()
