--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Framework =--
local Notifications = {
    BuiltIn = true
}
--= Framework API =--

function Notifications:Start()
    Notifications.Logger = Framework.BuiltInShared.Logger:GetLogger("Notifications")
    Notifications.NotifChannel = Framework.BuiltInServer.Network.Channel("NotifChannel")
end

function Notifications:Create(Player: Player, Type: string, Message: string)
    Notifications.NotifChannel:Fire("Notif", Player, Type, Message)
end

function Notifications:CreateAll(Type: string, Message: string)
    for _, Player in ipairs(game:GetService("Players"):GetPlayers()) do
        Notifications:Create(Player, Type, Message)
    end
end

function Notifications:Clear(Player: Player)
    Notifications.NotifChannel:Fire("Clear", Player)
end

return Notifications
