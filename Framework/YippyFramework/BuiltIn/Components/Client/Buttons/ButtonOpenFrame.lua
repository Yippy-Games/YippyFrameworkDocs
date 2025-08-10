--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ButtonOpenFrame = {}
ButtonOpenFrame.__index = ButtonOpenFrame
ButtonOpenFrame.Tag = "ButtonOpenFrame"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ButtonOpenFrame.new(ui: GuiButton)
    local self = setmetatable({}, ButtonOpenFrame)
    self.UIButton = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.MainUI = Framework.BuiltInClient.UI:GetRootUI()
    self.Group = self.UIButton:GetAttribute("Group")
    self.FramePath = self.UIButton:GetAttribute("FramePath") or ""
    self.ScrollPath = self.UIButton:GetAttribute("ScrollPath") or ""
    self.ScrollPosition = self.UIButton:GetAttribute("ScrollPosition") or 0
    self.Frame = Framework.BuiltInShared.Part:findInstanceByPath(self.MainUI, self.FramePath)
    self.OpenSoundPath = self.UIButton:GetAttribute("OpenSoundPath") or ""
    self.CloseSoundPath = self.UIButton:GetAttribute("CloseSoundPath") or ""

    if not self.Frame then
        self.Logger:Warn("[TAG ButtonOpenFrame] FramePath is invalid: " .. self.UIButton.Name .. "-" .. self.FramePath)
        return self
    end
    if self.ScrollPath ~= "" then
        self.ScrollFrame = Framework.BuiltInShared.Part:findInstanceByPath(self.MainUI, self.ScrollPath)
    end

    if self.OpenSoundPath ~= "" then
        self.OpenSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.OpenSoundPath)
    end
    if self.CloseSoundPath ~= "" then
        self.CloseSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.CloseSoundPath)
    end

    self.UIButton.Activated:Connect(function()
        self:MouseButton1Up()
    end)
    return self
end

function ButtonOpenFrame:Destroy() end

--= Methods =--

function ButtonOpenFrame:Exist()
    return self.UIButton ~= nil and self.Frame ~= nil
end

function ButtonOpenFrame:MouseButton1Up()
    if not self:Exist() then
        return
    end

    if self.Frame.Visible and Framework.BuiltInClient.UI:GetLastAction() == self.UIButton then
        if self.CloseSound then
            self.CloseSound:Play()
        end
        Framework.BuiltInClient.UI:Close(self.FramePath, self.Group, self.UIButton)
    else
        if self.ScrollFrame and self.Frame.Visible then
            Framework.BuiltInClient.UI:SetLastAction(self.UIButton)
            Framework.BuiltInShared.Tween:InstantTween(
                self.ScrollFrame,
                { Time = 0.125 },
                { CanvasPosition = Vector2.new(0, self.ScrollFrame.AbsoluteCanvasSize.Y * self.ScrollPosition) }
            )
        elseif self.ScrollFrame and not self.Frame.Visible then
            Framework.BuiltInClient.UI:SetLastAction(self.UIButton)
            self.ScrollFrame.CanvasPosition =
                Vector2.new(0, self.ScrollFrame.AbsoluteCanvasSize.Y * self.ScrollPosition)
        end
        if self.OpenSound then
            self.OpenSound:Play()
        end
        Framework.BuiltInClient.UI:Open(self.FramePath, self.Group, self.UIButton)
    end
end

return ButtonOpenFrame
