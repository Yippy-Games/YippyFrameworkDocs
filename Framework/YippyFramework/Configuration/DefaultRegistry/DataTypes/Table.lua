--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local Table = {}
--= Info =--
Table.Index = 5
Table.Name = "Table"

--= Type Definition =--
function Table:Detect(value)
    return type(value) == "table" and not value.__type and getmetatable(value) == nil
end

function Table:GetDefault()
    return {}
end

--= Operations =--
Table.Operations = {
    Set = function(_, value)
        return value
    end,
    
    Insert = function(current, value)
        local newTable = {}
        for k, v in pairs(current) do
            newTable[k] = v
        end
        table.insert(newTable, value)
        return newTable
    end,
    
    Remove = function(current, index)
        local newTable = {}
        for k, v in pairs(current) do
            newTable[k] = v
        end
        table.remove(newTable, index)
        return newTable
    end,
    
    Clear = function(_, _)
        return {}
    end
}

return Table