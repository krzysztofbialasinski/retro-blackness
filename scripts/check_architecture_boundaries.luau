--!strict
-- Quality gate: enforce the inward-only dependency rule (CLAUDE.md, Hard rules #3).
--
-- domain/ must never require application/, infrastructure/, or interfaces/, and application/
-- must never require infrastructure/ or interfaces/ (application/ -> domain/ is allowed). Both
-- layers must also stay free of @lune/* requires, which is what lets the coverage gate run
-- under the bare `luau` VM. This is a static, path-based check: it resolves each require(...)
-- argument against the requiring file's own directory and does not load or execute any code.

local fs = require("@lune/fs")
local process = require("@lune/process")

local PURE_DIRS = { "src/domain", "src/application" }
local FORBIDDEN_PREFIXES_BY_DIR: { [string]: { string } } = {
	["src/domain"] = { "src/application/", "src/infrastructure/", "src/interfaces/" },
	["src/application"] = { "src/infrastructure/", "src/interfaces/" },
}

local violations: { string } = {}

local function dirOf(path: string): string
	return string.match(path, "^(.*)/[^/]+$") or "."
end

-- Resolves a require(...) argument (e.g. "../../domain/roblox/entities") against the
-- directory of the file that contains it, producing a repo-root-relative path.
local function resolveRequirePath(fromDir: string, requirePath: string): string
	local segments: { string } = {}
	for segment in string.gmatch(fromDir, "[^/]+") do
		table.insert(segments, segment)
	end
	for segment in string.gmatch(requirePath, "[^/]+") do
		if segment == ".." then
			segments[#segments] = nil
		elseif segment ~= "." then
			table.insert(segments, segment)
		end
	end
	return table.concat(segments, "/")
end

local function startsWithAny(value: string, prefixes: { string }): boolean
	for _, prefix in prefixes do
		if string.sub(value, 1, #prefix) == prefix then
			return true
		end
	end
	return false
end

local function checkFile(path: string, pureDir: string)
	local forbidden = FORBIDDEN_PREFIXES_BY_DIR[pureDir]
	local fromDir = dirOf(path)

	for requirePath in string.gmatch(fs.readFile(path), [[require%(["']([^"']+)["']%)]]) do
		if string.sub(requirePath, 1, 1) == "@" then
			table.insert(
				violations,
				`  {path}: requires "{requirePath}" (must stay free of @lune/*)`
			)
		else
			local resolved = resolveRequirePath(fromDir, requirePath)
			if startsWithAny(resolved .. "/", forbidden) then
				table.insert(
					violations,
					`  {path}: requires "{requirePath}" -> {resolved} (crosses a forbidden layer boundary)`
				)
			end
		end
	end
end

local function walk(dir: string, pureDir: string)
	if not fs.isDir(dir) then
		return
	end
	for _, name in fs.readDir(dir) do
		local path = `{dir}/{name}`
		if fs.isDir(path) then
			walk(path, pureDir)
		elseif string.match(path, "%.luau$") ~= nil then
			checkFile(path, pureDir)
		end
	end
end

local function main()
	for _, pureDir in PURE_DIRS do
		walk(pureDir, pureDir)
	end

	if #violations > 0 then
		print("Architecture boundary violations (see CLAUDE.md Hard rules #3):")
		for _, entry in violations do
			print(entry)
		end
		process.exit(1)
	end

	print("OK: domain/ and application/ respect the inward-only dependency rule.")
end

main()
