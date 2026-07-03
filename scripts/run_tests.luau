--!strict
-- Full regression suite entry point (run under Lune). Loads every spec — unit, integration,
-- and e2e — then exits non-zero if any test failed.

local process = require("@lune/process")

require("../tests/unit/domain/roblox_entities.spec")
require("../tests/unit/application/get_user_profile.spec")
require("../tests/unit/application/handle_user_joined.spec")
require("../tests/unit/application/publish_place.spec")
require("../tests/integration/open_cloud_client.spec")
require("../tests/integration/place_publisher.spec")
require("../tests/integration/signature_verifier.spec")
require("../tests/e2e/api_roblox_router.spec")
require("../tests/e2e/webhooks_roblox_router.spec")
require("../tests/e2e/http_app_error_boundary.spec")

local testing = require("../tests/support/testing")

local failures = testing.run()
if failures > 0 then
	process.exit(1)
end
