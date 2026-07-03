--!strict
-- Pure-Luau entry point for coverage measurement via `luau --coverage`.
-- It requires ONLY the domain + application specs, which have no @lune/* dependencies,
-- so it runs under the bare Luau VM. Infrastructure/interfaces are exercised separately
-- by the Lune test suite (scripts/run_tests.luau) but excluded from the coverage gate.

require("../tests/unit/domain/roblox_entities.spec")
require("../tests/unit/application/get_user_profile.spec")
require("../tests/unit/application/handle_user_joined.spec")
require("../tests/unit/application/publish_place.spec")

local testing = require("../tests/support/testing")

local failures = testing.run()
assert(failures == 0, `{failures} test(s) failed`)
