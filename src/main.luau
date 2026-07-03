--!strict
-- Entry point: serves the REST API and inbound webhook routes over HTTP.

local net = require("@lune/net")

local app = require("./interfaces/http/app")
local dependencies = require("./interfaces/dependencies")
local settings = require("./infrastructure/config/settings")

local config = settings.load()
local routes = dependencies.buildRoutes(config)

net.serve(config.port, app.handler(routes))

print(`retro-blackness listening on :{config.port}`)
