--[[
    UI Settings
    Configuration for the user interface system
--]]

local UISettings = {}

--= UI Configuration =--
UISettings.EnabledUICore = {
    Enum.CoreGuiType.Chat,
    Enum.CoreGuiType.Health,
    Enum.CoreGuiType.PlayerList,
}
UISettings.DisabledResetButton = true
UISettings.ScreenSize = Vector2.new(1920, 1080)

return UISettings
