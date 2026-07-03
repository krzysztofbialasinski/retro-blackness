--!strict
-- Quality gate: run the pure-Luau coverage entry under the bare Luau VM, then enforce a
-- minimum line-coverage threshold over the domain + application layers.
--
-- Coverage is measured only for the pure layers (no @lune/* dependencies) because bare
-- `luau --coverage` cannot load Lune's standard libraries. Infrastructure and interfaces
-- are exercised by the Lune test suite for correctness but excluded from this percentage.

local fs = require("@lune/fs")
local process = require("@lune/process")

local THRESHOLD = 80
local INCLUDE_PREFIXES = { "./src/domain/", "./src/application/" }

local function isIncluded(path: string): boolean
	for _, prefix in INCLUDE_PREFIXES do
		if string.sub(path, 1, #prefix) == prefix then
			return true
		end
	end
	return false
end

-- Parses LCOV text, returning hit and total line counts for included source files.
local function parseLcov(text: string): (number, number)
	local hitLines = 0
	local totalLines = 0
	local includeCurrent = false

	for line in string.gmatch(text, "[^\r\n]+") do
		local sourceFile = string.match(line, "^SF:(.+)$")
		if sourceFile ~= nil then
			includeCurrent = isIncluded(sourceFile)
		elseif includeCurrent then
			local hits = string.match(line, "^DA:%d+,(%d+)$")
			if hits ~= nil then
				totalLines += 1
				if tonumber(hits) > 0 then
					hitLines += 1
				end
			end
		end
	end

	return hitLines, totalLines
end

local function main()
	local coverageRun = process.exec("luau", { "--coverage", "scripts/coverage_entry.luau" })
	if not coverageRun.ok then
		print(coverageRun.stdout)
		print(coverageRun.stderr)
		error("coverage run failed")
	end

	local hitLines, totalLines = parseLcov(fs.readFile("coverage.out"))
	if totalLines == 0 then
		error("no coverage data found for domain/application layers")
	end

	local percent = (hitLines / totalLines) * 100
	print(
		string.format(
			"Coverage (domain + application): %.1f%% (%d/%d lines)",
			percent,
			hitLines,
			totalLines
		)
	)
	if percent < THRESHOLD then
		error(string.format("coverage %.1f%% is below the required %d%%", percent, THRESHOLD))
	end
	print("OK")
end

main()
