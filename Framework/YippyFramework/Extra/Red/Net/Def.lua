--!strict

local TypeDefinitions = {}

local Promise = require(script.Parent.Parent.Util.Promise)

export type Server = {
	Name: string,
	FolderInstance: Folder?,

	Fire: (self: Server, Player: Player, EventName: string, ...any) -> (),
	FireAll: (self: Server, EventName: string, ...any) -> (),
	FireAllExcept: (self: Server, Player: Player, EventName: string, ...any) -> (),
	FireList: (self: Server, PlayerList: { Player }, EventName: string, ...any) -> (),
	FireWithFilter: (self: Server, Filter: (Player) -> boolean, EventName: string, ...any) -> (),
	On: (self: Server, EventName: string, Callback: ((Player, ...any) -> ...any)?) -> (),
	Folder: (self: Server, Player: Player?) -> Folder,
	Invoke: (self: Server, Player: Player, EventName: string, ...any) -> Promise.Promise,
}

export type Client = {
	Name: string,
	FolderInstance: Folder?,
	LocalFolderInstance: Folder?,

	Fire: (self: Client, EventName: string, ...any) -> (),
	Invoke: (self: Client, EventName: string, ...any) -> Promise.Promise,
	On: (self: Client, EventName: string, Callback: ((...any) -> ())?) -> (),
	Folder: (self: Client) -> Folder,
	LocalFolder: (self: Client) -> Folder,
}

export type Net = {
	Server: (Name: string, Definitions: { string }?) -> Server,
	Client: (Name: string) -> Client,
	Identifier: (Name: string) -> any,
}

return TypeDefinitions
