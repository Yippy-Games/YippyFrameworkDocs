local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Framework = require(ReplicatedFirst.Framework)

return function(_context, player: Player, specificKey)
    print("Printing data of player " .. player.Name)
    if specificKey == "" then
        specificKey = nil
    end

    if not Framework.BuiltInServer.Datastore:GetData(player) then
        return "Player does not have a profile"
    end
    local data = Framework.BuiltInServer.Datastore:GetData(player)

    print(data)
end
