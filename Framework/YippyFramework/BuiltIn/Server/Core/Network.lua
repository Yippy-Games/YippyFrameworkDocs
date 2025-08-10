--[[
    Author: Rask/AfraiEda
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Networking = {
    BuiltIn = true
}
--= Modules & Config =--
local YippyNetwork = require(ReplicatedFirst.Framework.Extra.YippyNetwork)
--= Constants =--

--= Functions =--

function Networking.Channel(Name: string)
    return YippyNetwork.Channel(Name)
end

return Networking
