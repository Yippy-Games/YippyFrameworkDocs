--[[
    Author: Rask/AfraiEda
    Creation Date: 01/06/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local Sounds = {
    BuiltIn = true
}
--= Modules & Config =--

function Sounds:Start()
    self.SoundsChannel = Framework.BuiltInServer.Network.Channel("Sounds")
end

function Sounds:PlayLocalSound(Player: Player, SoundInstance: Sound, Options: { PlaybackSpeed: number })
    if not Player then
        return
    end
    self.SoundsChannel:Fire("PlayLocalSound", Player, SoundInstance, Options)
end

function Sounds:PlayAllLocalSounds(SoundInstance: Sound)
    for _, Player in ipairs(Players:GetPlayers()) do
        self:PlayLocalSound(Player, SoundInstance)
    end
end

return Sounds
