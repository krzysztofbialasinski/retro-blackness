--!strict
-- A use case is a single application operation: a function from a request to a response.
-- Luau uses structural typing, so the contract is expressed as a function type.

local useCase = {}

export type UseCase<Request, Response> = (request: Request) -> Response

return useCase
