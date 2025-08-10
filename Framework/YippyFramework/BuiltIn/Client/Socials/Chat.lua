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
local TextChatService = game:GetService("TextChatService")
local Players = game:GetService("Players")
--= Framework =--
local Chat = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)

function Chat:Start()
    self.ChatNetwork = Framework.BuiltInClient.Network.Channel("Chat")

    self.ChatNetwork:On("DisplayServerMessage", function(
        Message: string,
        Params: {
            Sender: string,
            Color: Color3,
        }
    )
        self:DisplayServerMessage(Message, Params)
    end)

    TextChatService.OnIncomingMessage = function(message: TextChatMessage)
        return self:ReceiveMessage(message)
    end
end

function Chat:ReceiveMessage(message: TextChatMessage)
    if not message then
        return
    end
    if not message.TextSource then
        return
    end

    local props = Instance.new("TextChatMessageProperties")
    local Player = Players:GetPlayerByUserId(message.TextSource.UserId)

    if Player == nil then
        return
    end

    props.PrefixText = self:GetRanksPrefix(Player) .. message.PrefixText

    return props
end

function Chat:GetRanksPrefix(Player: Player)
    return Player:GetAttribute("ChatPrefix") or ""
end

function Chat:DisplayServerMessage(
    Message: string,
    Params: {
        Sender: string,
        Color: Color3,
    }
)
    local Hex = Framework.BuiltInShared.Color:toHex(Params.Color)
    local Text = ""
    if Params.Sender == "" then
        Text = "<font color='" .. Hex .. "'>" .. Message .. "</font>"
    else
        Text = "<font color='" .. Hex .. "'>" .. Params.Sender .. ": " .. Message .. "</font>"
    end

    game.TextChatService.TextChannels.RBXGeneral:DisplaySystemMessage(Text)
end

return Chat