--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ToolTipsTile = {}
ToolTipsTile.__index = ToolTipsTile
ToolTipsTile.Tag = "ToolTipsTile"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ToolTipsTile.new(UI: UIBase)
    local self = setmetatable({}, ToolTipsTile)
    self.UI = UI
    local TextAttribute = UI:GetAttribute("ToolTipTitle") or "?"

    if Framework.BuiltInClient.Camera:GetCurrentInput() == "Touch" then
        return self
    end

    Framework.BuiltInClient.UI:RegisterTooltip(self.UI, "SimpleTitle", {
        ["1"] = {
            Value = TextAttribute,
        },
    })

    return self
end

function ToolTipsTile:Destroy() end

--= Methods =--

return ToolTipsTile
