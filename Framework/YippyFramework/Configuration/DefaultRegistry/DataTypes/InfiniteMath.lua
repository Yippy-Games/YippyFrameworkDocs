--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local InfiniteMath = {}
--= Services =--
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Framework = require(ReplicatedFirst.Framework)
local InfiniteMathLib = require(ReplicatedFirst.Framework.Extra.InfiniteMath)
--= Info =--
InfiniteMath.Index = 2
InfiniteMath.Name = "InfiniteMath"


--= Type Definition =--
function InfiniteMath:Detect(value)
    return type(value) == "table" and value.first ~= nil and value.second ~= nil and getmetatable(value) ~= nil
end

function InfiniteMath:Encode(value)
    return {
        __type = "InfiniteMath",
        first = value.first,
        second = value.second
    }
end

function InfiniteMath:Decode(data)
    if data.__type == "InfiniteMath" then
        return InfiniteMathLib.new({data.first, data.second})
    end
    return data
end

function InfiniteMath:GetDefault()
    return InfiniteMathLib.new(0)
end

function InfiniteMath:Create(value)
    local infiniteMathValue = InfiniteMathLib.new(value or 0)
    return self:Encode(infiniteMathValue)
end

--= Operations =--
InfiniteMath.Operations = {
    Set = function(_, value)
        return value
    end,
    
    Add = function(current, value)
        if type(value) == "number" then
            value = InfiniteMathLib.new(value)
        end
        
        return current + value
    end,
    
    Subtract = function(current, value)
        if type(value) == "number" then
            value = InfiniteMathLib.new(value)
        end
        return current - value
    end,
    
    Multiply = function(current, value)
        if type(value) == "number" then
            value = InfiniteMathLib.new(value)
        end
        return current * value
    end,
    
    Divide = function(current, value)
        if type(value) == "number" then
            value = InfiniteMathLib.new(value)
        end
        return current / value
    end
}

return InfiniteMath