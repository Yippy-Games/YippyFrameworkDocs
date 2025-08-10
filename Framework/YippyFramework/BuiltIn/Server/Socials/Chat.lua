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
local Players = game:GetService("Players")
--= Framework =--
local Chat = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)

function Chat:Start()
    self.ChatNetwork = Framework.BuiltInServer.Network.Channel("Chat")
    self.PlayersRanks = {}

    Players.PlayerMembershipChanged:Connect(function(Player)
        if Player.MembershipType == Enum.MembershipType.Premium then
            self:GiveRank(Player, "Premium")
        else
            self:RemoveRank(Player, "Premium")
        end
    end)
end

function Chat:PlayerAdded(Player: Player)
    if not self.PlayersRanks[Player] then
        self.PlayersRanks[Player] = {}
    end

    if Player.MembershipType == Enum.MembershipType.Premium then
        self:GiveRank(Player, "Premium")
    end
    self:CheckGroupRanks(Player)
end

function Chat:CheckGroupRanks(Player: Player)
    local PlayerRank = nil

    local Success = pcall(function()
        PlayerRank = Player:GetRankInGroup(Framework.FrameworkConfig.Settings.FrameworkSettings.GroupId)
    end)
    if Success and PlayerRank ~= nil and typeof(PlayerRank) == "number" then
        local HighestQualifyingRank = nil
        local HighestQualifyingRankData = nil
        local HighestQualifyingRankName = nil
        for RankName, RankData in pairs(Framework.FrameworkConfig.Settings.Chat.ChatRanks) do
            if not RankData.Type == "GroupRank" then
                continue
            end
            if not RankData.Params or not RankData.Params.Rank then
                continue
            end
            if PlayerRank >= RankData.Params.Rank then
                if not HighestQualifyingRank or RankData.Params.Rank > HighestQualifyingRank then
                    HighestQualifyingRank = RankData.Params.Rank
                    HighestQualifyingRankData = RankData
                    HighestQualifyingRankName = RankName
                end
            end
        end
        if HighestQualifyingRankData then
            self:GiveRank(Player, HighestQualifyingRankName)
        end
    end
end

function Chat:GiveRank(Player: Player, Rank: string, RankData: table?)
    if RankData and not Framework.FrameworkConfig.Settings.Chat.ChatRanks[Rank] then
        self:CreateRank(Rank, RankData)
    end
    
    if not self.PlayersRanks[Player] then
        self.PlayersRanks[Player] = {}
    end
    table.insert(self.PlayersRanks[Player], {
        Rank = Rank,
    })
    self:ResortRankOrder(Player)
    self:UpdatePlayerChatPrefix(Player)
end

function Chat:RemoveRank(Player: Player, Rank: string)
    if not self.PlayersRanks[Player] then
        return
    end

    for i, RankObject in ipairs(self.PlayersRanks[Player]) do
        if RankObject.Rank == Rank then
            table.remove(self.PlayersRanks[Player], i)
            break
        end
    end

    self:UpdatePlayerChatPrefix(Player)
end

function Chat:ResortRankOrder(Player: Player)
    local Ranks = self.PlayersRanks[Player]

    for i = 1, #Ranks do
        Ranks[i]._originalIndex = i
    end
    
    table.sort(Ranks, function(a, b)
        local aLayer = math.huge
        if Framework.FrameworkConfig.Settings.Chat.ChatRanks and Framework.FrameworkConfig.Settings.Chat.ChatRanks[a.Rank] then
            aLayer = Framework.FrameworkConfig.Settings.Chat.ChatRanks[a.Rank].Layer
        end
        
        local bLayer = math.huge
        if Framework.FrameworkConfig.Settings.Chat.ChatRanks and Framework.FrameworkConfig.Settings.Chat.ChatRanks[b.Rank] then
            bLayer = Framework.FrameworkConfig.Settings.Chat.ChatRanks[b.Rank].Layer
        end
        
        if aLayer == bLayer then
            return a._originalIndex < b._originalIndex
        end
        return aLayer < bLayer
    end)

    for i = 1, #Ranks do
        Ranks[i]._originalIndex = nil
    end
    
    self.PlayersRanks[Player] = Ranks
end

function Chat:GetPlayerRankByType(Player: Player, Type: string)
    if not self.PlayersRanks[Player] then
        return nil, nil
    end
    
    for _, RankObject in ipairs(self.PlayersRanks[Player]) do
        local RankName = RankObject.Rank
        local RankData = Framework.FrameworkConfig.Settings.Chat.ChatRanks[RankName]
        if RankData and RankData.Type == Type then
            return RankData, RankObject
        end
    end
    
    return nil, nil
end

function Chat:HasPlayerRankOfType(Player: Player, Type: string)
    if not self.PlayersRanks[Player] then
        return false
    end
    
    for _, RankObject in ipairs(self.PlayersRanks[Player]) do
        local RankName = RankObject.Rank
        local RankData = Framework.FrameworkConfig.Settings.Chat.ChatRanks[RankName]
        if RankData and RankData.Type == Type then
            return true
        end
    end
    
    return false
end

function Chat:CreateRank(RankName: string, RankData: table)
    Framework.FrameworkConfig.Settings.Chat.ChatRanks[RankName] = {
        Name = RankData.Name or RankName,
        Color = RankData.Color or Color3.fromRGB(255, 255, 255),
        Layer = RankData.Layer or 1,
        Params = RankData.Params or nil,
        Type = RankData.Type or "None",
    }
end

function Chat:UpdatePlayerChatPrefix(Player: Player)
    local Prefix = ""

    if not self.PlayersRanks[Player] then
        Player:SetAttribute("ChatPrefix", Prefix)
        return
    end

    for _, RankObject in ipairs(self.PlayersRanks[Player]) do
        local RankName = RankObject.Rank
        local RankData = Framework.FrameworkConfig.Settings.Chat.ChatRanks[RankName]
        if RankData then
            Prefix = Prefix
                .. "<font color='"
                .. Framework.BuiltInShared.Color:toHex(RankData.Color)
                .. "'>"
                .. RankData.Name
                .. "</font>"
                .. " "
        end
    end

    Player:SetAttribute("ChatPrefix", Prefix)
end

function Chat:SendServerMessage(
    Message: string,
    Params: {
        Sender: string,
        Color: Color3,
    }
)
    Params = Params or {}
    Params.Sender = Params.Sender or ""
    Params.Color = Params.Color or Color3.fromRGB(255, 255, 255)

    self.ChatNetwork:FireAll("DisplayServerMessage", Message, Params)
end

return Chat
