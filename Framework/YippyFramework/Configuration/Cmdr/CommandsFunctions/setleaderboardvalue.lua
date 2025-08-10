local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Framework = require(ReplicatedFirst.Framework)

return function(_, players, leaderboard, value)
    for _, player in pairs(players) do
        local leaderboardInstance = Framework.BuiltInServer.Leaderboard:GetLeaderboard(leaderboard)
        if not leaderboardInstance then
            return ("Leaderboard %s does not exist."):format(leaderboard)
        end
        leaderboardInstance:SetValue(player, value)
    end
    return ("Set the value of the leaderboard for %d players."):format(#players)
end
