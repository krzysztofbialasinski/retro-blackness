--!strict
-- Inbound webhook payload shapes.

local schemas = {}

export type UserJoinedWebhookPayload = {
	user_id: number,
	universe_id: number,
	place_id: number,
}

return schemas
