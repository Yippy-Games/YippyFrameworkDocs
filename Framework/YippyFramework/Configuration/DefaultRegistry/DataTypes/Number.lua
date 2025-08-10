--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local Number = {}
--= Info =--
Number.Index = 3
Number.Name = "Number"


--= Type Definition =--
function Number:Detect(value)
    return type(value) == "number"
end

function Number:GetDefault()
    return 0
end

--= Operations =--
Number.Operations = {
    Set = function(_, value)
        return value
    end,
    
    Add = function(current, value)
        return current + value
    end,
    
    Subtract = function(current, value)
        return current - value
    end,
    
    Multiply = function(current, value)
        return current * value
    end,
    
    Divide = function(current, value)
        if value == 0 then
            return current
        end
        return current / value
    end
}

return Number