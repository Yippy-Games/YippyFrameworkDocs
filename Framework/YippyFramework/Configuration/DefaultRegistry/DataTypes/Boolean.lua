--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local Boolean = {}
--= Info =--
Boolean.Index = 1
Boolean.Name = "Boolean"

--= Type Definition =--
function Boolean:Detect(value)
    return type(value) == "boolean"
end

function Boolean:GetDefault()
    return false
end

--= Operations =--
Boolean.Operations = {
    Set = function(_, value)
        return not not value
    end,
    
    Toggle = function(current, _)
        return not current
    end,
}

return Boolean