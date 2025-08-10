--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ButtonInvite = {}
ButtonInvite.__index = ButtonInvite
ButtonInvite.Tag = "ButtonInvite"

--= Roblox Services =--
local SocialService = game:GetService("SocialService")
local Players = game:GetService("Players")

--= Modules & Config =--

--= Constructor =--

function ButtonInvite.new(UIButton)
    local self = setmetatable({}, ButtonInvite)
    self.UIButton = UIButton

    self.UIButton.Activated:Connect(function()
        self:OpenInviteMenu()
    end)

    return self
end

function ButtonInvite:Destroy()
    if self.connection then
        self.connection:Disconnect()
        self.connection = nil
    end
end

--= Methods =--

function ButtonInvite:OpenInviteMenu()
    local success, errorMessage = pcall(function()
        SocialService:PromptGameInvite(Players.LocalPlayer)
    end)

    if not success then
        warn("Failed to open invite menu: " .. tostring(errorMessage))
    end
end

return ButtonInvite
