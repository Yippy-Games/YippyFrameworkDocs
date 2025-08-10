--!strict

local TypeDefinitions = {}

local Promise = require(script.Parent.Promise)

export type Server = {
	Fire: (self: Server, EventName: string, Player: Player, ...any) -> (),
	FireAll: (self: Server, EventName: string, ...any) -> (),
	FireAllExcept: (self: Server, EventName: string, ExceptionPlayer: Player, ...any) -> (),
	FireList: (self: Server, EventName: string, Players: { Player }, ...any) -> (),
	FireWithFilter: (self: Server, EventName: string, FilterFunction: (Player) -> boolean, ...any) -> (),
	On: (self: Server, EventName: string, Callback: ((Player, ...any) -> ...any)?) -> (),
}

export type Client = {
	Fire: (self: Client, EventName: string, ...any) -> (),
	Invoke: (self: Client, EventName: string, ...any) -> Promise.Promise,
	On: (self: Client, EventName: string, Callback: ((...any) -> ())?) -> (),
}

return TypeDefinitions
