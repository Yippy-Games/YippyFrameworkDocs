--[[
    Chat Settings
    Configuration for the chat system
--]]

local ChatSettings = {}

--= Chat Configuration =--
ChatSettings.ChatRanks = {
    Owner = {
        Name = "[Owner]",
        Color = Color3.fromRGB(255, 0, 0),
        Layer = 1,
        Type = "GroupRank",
        Params = {
            Rank = 250,
        },
    },
    Premium = {
        Name = "",
        Color = Color3.fromRGB(161, 154, 154),
        Layer = 0,
        Type = "Premium",
    },
}
ChatSettings.DisplayPremiumRanks = true

return ChatSettings
