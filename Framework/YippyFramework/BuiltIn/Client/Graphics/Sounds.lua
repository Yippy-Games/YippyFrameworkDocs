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
local SoundService = game:GetService("SoundService")
--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local Sounds = {
    BuiltIn = true
}
--= Modules & Config =--

function Sounds:Start()
    self.SoundsChannel = Framework.BuiltInClient.Network.Channel("Sounds")

    self.SoundsChannel:On("PlayLocalSound", function(SoundInstance: Sound, Options: { PlaybackSpeed: number })
        self:PlayLocalSound(SoundInstance, Options)
    end)
end

function Sounds:PlayLocalSound(SoundInstance: Sound, Options: { PlaybackSpeed: number })
    local Options = Options or {}
    local tempSound = SoundInstance:Clone()
    tempSound.PlaybackSpeed = Options.PlaybackSpeed or 1
    tempSound.Parent = SoundService
    tempSound:Play()
    tempSound.Ended:Wait()
    tempSound:Destroy()
end

return Sounds
