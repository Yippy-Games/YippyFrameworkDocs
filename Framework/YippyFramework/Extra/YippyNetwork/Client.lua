local Client = {}
Client.__index = {}

local Promise = require(script.Parent.Promise)

function Client:Initialize()
	self.RemoteEvent.OnClientEvent:Connect(function(channelName, event, ...)
		self:Emit(channelName, event, ...)
	end)
end

function Client:Fire(event, ...)
	self.RemoteEvent:FireServer(self.Channel, event, ...)
end

function Client:Invoke(event, ...)
	local args = { ... }
	return Promise.new(function(resolve, reject)
		local success, results = pcall(function()
			return { self.RemoteFunction:InvokeServer(self.Channel, event, unpack(args)) }
		end)
		if success then
			resolve(table.unpack(results))
		else
			reject(table.unpack(results))
		end
	end)
end

return Client
