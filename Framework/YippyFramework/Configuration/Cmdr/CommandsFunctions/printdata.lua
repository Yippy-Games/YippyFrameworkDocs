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

    local function printDataRecursively(Data, prefix, targetKey)
        prefix = prefix or ""
        for key, value in pairs(Data) do
            local fullKey = prefix .. key

            local shouldPrint = not targetKey
                or fullKey == targetKey
                or (targetKey and string.find(fullKey, "^" .. targetKey .. "%."))

            if shouldPrint then
                if type(value) == "table" then
                    printDataRecursively(value, fullKey .. ".", targetKey)
                else
                    print(fullKey .. ": " .. tostring(value))
                end
            elseif targetKey and string.find(targetKey, "^" .. fullKey .. "%.") then
                -- If the current key is a parent of the target key, continue searching
                if type(value) == "table" then
                    printDataRecursively(value, fullKey .. ".", targetKey)
                end
            end
        end
    end

    printDataRecursively(data, "", specificKey)
end
