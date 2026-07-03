--!strict
-- Minimal pure-Luau test registry + runner. Pure by design: it uses only base-library
-- globals (no @lune/*), so the same specs run both under Lune (full suite) and under the
-- bare Luau VM with `--coverage` (domain + application subset).

local protected = require("./protected")

local testing = {}

type Case = { name: string, run: () -> () }

local cases: { Case } = {}
local currentSuite = ""

function testing.describe(name: string)
	currentSuite = name
end

function testing.test(name: string, run: () -> ())
	local fullName = if currentSuite ~= "" then `{currentSuite} > {name}` else name
	table.insert(cases, { name = fullName, run = run })
end

-- Runs every registered case, prints a report, and returns the number of failures.
function testing.run(): number
	local failures = 0
	for _, case in cases do
		local ok, err = protected.run(case.run)
		if ok then
			print(`  PASS  {case.name}`)
		else
			failures += 1
			print(`  FAIL  {case.name}`)
			print(`        {tostring(err)}`)
		end
	end
	print(`\n{#cases - failures}/{#cases} passed`)
	return failures
end

return testing
