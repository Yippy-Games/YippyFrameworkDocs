--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local String = {}
--= Info =--
String.Index = 4
String.Name = "String"

--= Type Definition =--
function String:Detect(value)
    return type(value) == "string"
end

function String:GetDefault()
    return ""
end

--= Operations =--
String.Operations = {
    Set = function(_, value)
        return tostring(value)
    end,
}

return String