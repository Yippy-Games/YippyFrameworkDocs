local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local IsServer = RunService:IsServer()
local NetworkHandler = require(script:WaitForChild(IsServer and "Server" or "Client"))

local Network = setmetatable({
	RemoteEvent = IsServer and Instance.new("RemoteEvent", ReplicatedStorage)
		or ReplicatedStorage:WaitForChild("RemoteEvent"),
	RemoteFunction = IsServer and Instance.new("RemoteFunction", ReplicatedStorage)
		or ReplicatedStorage:WaitForChild("RemoteFunction"),
	Channels = {},
}, { __index = NetworkHandler })

function Network:MergeChannel(...)
	local new = {}

	for _, object in pairs({ ... }) do
		for index, value in pairs(object) do
			new[index] = value
		end
	end

	return new
end

function Network:init(files)
	self.files = files
end

function Network.Channel(channelName)
	if Network.Channels[channelName] then
		return Network.Channels[channelName]
	else
		local createdChannel =
			setmetatable(Network:MergeChannel(Network, { Channel = channelName }), { __index = NetworkHandler })

		function createdChannel:On(event, fct)
			self[event] = fct
		end

		function createdChannel:Broadcast(event, ...)
			if self[event] then
				return self[event](...)
			end
		end

		Network.Channels[channelName] = createdChannel
		return createdChannel
	end
end

function Network:Emit(channelName, event, ...)
	local channel = Network.Channels[channelName]
	if channel then
		return channel:Broadcast(event, ...)
	end
end

Network:Initialize()

return Network
