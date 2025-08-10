--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ButtonAnimScale = {}
ButtonAnimScale.__index = ButtonAnimScale
ButtonAnimScale.Tag = "ButtonAnimScale"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ButtonAnimScale.new(ui: GuiButton)
    local self = setmetatable({}, ButtonAnimScale)
    self.UIButton = ui
    self.Goal = self.UIButton:GetAttribute("Scale") or 1.1
    self.GoalClick = self.UIButton:GetAttribute("GoalClick") or 1.05
    self.Scale = Framework.BuiltInClient.UI:CheckUIScale(self.UIButton)
    self.ClickSoundPath = self.UIButton:GetAttribute("ClickSoundPath") or ""

    if self.ClickSoundPath ~= "" then
        self.ClickSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.ClickSoundPath)
    end

    self.UIButton:GetAttributeChangedSignal("SimulateClick"):Connect(function()
        self:MouseButton1Down()
        task.delay(0.1, function()
            self:MouseButton1Up()
        end)
        self.UIButton:SetAttribute("SimulateClick", false)
    end)

    self.MouseEnterEvent = self.UIButton.MouseEnter:Connect(function()
        self:MouseEnter()
    end)

    self.MouseLeaveEvent = self.UIButton.MouseLeave:Connect(function()
        self:MouseLeave()
    end)

    self.MouseUpEvent = self.UIButton.MouseButton1Up:Connect(function()
        self:MouseButton1Up()
    end)

    self.MouseDownEvent = self.UIButton.MouseButton1Down:Connect(function()
        self:MouseButton1Down()
    end)
    return self
end

function ButtonAnimScale:Destroy()
    self.MouseEnterEvent:Disconnect()
    self.MouseLeaveEvent:Disconnect()
    self.MouseUpEvent:Disconnect()
    self.MouseDownEvent:Disconnect()
    self.UIButton = nil
    self.Goal = nil
    self.GoalClick = nil
    self.Scale = nil
end

--= Methods =--

function ButtonAnimScale:Exist()
    return self.UIButton ~= nil
end

function ButtonAnimScale:Enable()
    self.UIButton.Visible = true
end

function ButtonAnimScale:Disable()
    self.UIButton.Visible = false
end

function ButtonAnimScale:MouseEnter()
    if not self:Exist() then
        return
    end
    Framework.BuiltInShared.Tween:InstantTween(
        self.Scale,
        { Time = 0.08, Style = Enum.EasingStyle.Quad },
        { Scale = self.Goal }
    )
end

function ButtonAnimScale:MouseLeave()
    if not self:Exist() then
        return
    end
    Framework.BuiltInShared.Tween:InstantTween(
        self.Scale,
        { Time = 0.08, Style = Enum.EasingStyle.Quad },
        { Scale = 1 }
    )
end

function ButtonAnimScale:MouseButton1Up()
    if not self:Exist() then
        return
    end
    Framework.BuiltInShared.Tween:InstantTween(
        self.Scale,
        { Time = 0.08, Style = Enum.EasingStyle.Quad },
        { Scale = 0.98 * self.GoalClick }
    )
end

function ButtonAnimScale:MouseButton1Down()
    if not self:Exist() then
        return
    end

    if self.ClickSound then
        self.ClickSound:Play()
    end
    Framework.BuiltInShared.Tween:InstantTween(
        self.Scale,
        { Time = 0.08, Style = Enum.EasingStyle.Quad },
        { Scale = 0.98 / self.GoalClick }
    )
end

return ButtonAnimScale
