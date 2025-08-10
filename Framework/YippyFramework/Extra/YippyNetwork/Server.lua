local Server = {}
Server.__index = {}

function Server:Initialize()
	self.RemoteEvent.OnServerEvent:Connect(function(player, channelName, event, ...)
		self:Emit(channelName, event, player, ...)
	end)

	self.RemoteFunction.OnServerInvoke = function(player, channelName, event, ...)
		return self:Emit(channelName, event, player, ...)
	end
end

function Server:Fire(event, player, ...)
	self.RemoteEvent:FireClient(player, self.Channel, event, ...)
end

function Server:FireAll(event, ...)
	self.RemoteEvent:FireAllClients(self.Channel, event, ...)
end

function Server:FireList(event, players, ...)
	for _, player in ipairs(players) do
		self:Fire(event, player, ...)
	end
end

function Server:FireAllExcept(event, exceptionPlayer, ...)
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if player ~= exceptionPlayer then
			self:Fire(event, player, ...)
		end
	end
end

function Server:FireWithFilter(event, filterFunction, ...)
	for _, player in ipairs(game:GetService("Players"):GetPlayers()) do
		if filterFunction(player) then
			self:Fire(event, player, ...)
		end
	end
end

return Server
