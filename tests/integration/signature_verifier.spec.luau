--!strict
local serde = require("@lune/serde")

local expect = require("../support/expect")
local testing = require("../support/testing")

local signatureVerifier = require("../../src/infrastructure/webhooks/signature_verifier")

testing.describe("infrastructure/webhooks signature verifier")

testing.test("verifies a correctly signed body", function()
	local secret = "shh-secret"
	local body = '{"user_id":1}'
	local verifier = signatureVerifier.new(secret)

	expect.that(verifier.verify(body, serde.hmac("sha256", body, secret))).toBeTruthy()
end)

testing.test("rejects a body with the wrong signature", function()
	local verifier = signatureVerifier.new("shh-secret")

	expect.that(verifier.verify('{"user_id":1}', "not-the-right-signature")).toBeFalsy()
end)

testing.test("rejects an empty signature", function()
	local verifier = signatureVerifier.new("shh-secret")

	expect.that(verifier.verify('{"user_id":1}', "")).toBeFalsy()
end)

return {}
