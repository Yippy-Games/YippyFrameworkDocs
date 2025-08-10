--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ButtonCloseFrame = {}
ButtonCloseFrame.__index = ButtonCloseFrame
ButtonCloseFrame.Tag = "ButtonCloseFrame"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ButtonCloseFrame.new(ui: GuiButton)
    local self = setmetatable({}, ButtonCloseFrame)
    self.UIButton = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.MainUI = Framework.BuiltInClient.UI:GetRootUI()
    self.Group = self.UIButton:GetAttribute("Group")
    self.FramePath = self.UIButton:GetAttribute("FramePath") or ""
    self.Frame = Framework.BuiltInShared.Part:findInstanceByPath(self.MainUI, self.FramePath)
    self.CloseSoundPath = self.UIButton:GetAttribute("CloseSoundPath") or ""

    if not self.Frame then
        self.Logger:Warn("[TAG ButtonCloseFrame] FramePath is invalid: " .. self.UIButton.Name .. "-" .. self.FramePath)
        return self
    end

    if self.CloseSoundPath ~= "" then
        self.CloseSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.CloseSoundPath)
    end

    self.UIButton.Activated:Connect(function()
        self:MouseButton1Up()
    end)

    return self
end

function ButtonCloseFrame:Destroy() end

--= Methods =--

function ButtonCloseFrame:Exist()
    return self.UIButton ~= nil and self.Frame ~= nil
end

function ButtonCloseFrame:MouseButton1Up()
    if not self:Exist() then
        return
    end
    if self.Frame.Visible then
        if self.CloseSound then
            self.CloseSound:Play()
        end
        Framework.BuiltInClient.UI:Close(self.FramePath, self.Group)
    end
end

return ButtonCloseFrame
