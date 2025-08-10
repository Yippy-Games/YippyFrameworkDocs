--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local AutoScaleGridScrolling = {}
AutoScaleGridScrolling.__index = AutoScaleGridScrolling
AutoScaleGridScrolling.Tag = "AutoScaleGridScrolling"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function AutoScaleGridScrolling.new(GridFrame: Frame)
    local self = setmetatable({}, AutoScaleGridScrolling)
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.GridFrame = GridFrame
    self.ScrollingFramePath = GridFrame:GetAttribute("ScrollingFramePath")
    self.AutoScaleFrames = {}

    if not self.ScrollingFramePath then
        self.Logger:Error("[TAG AutoScaleGridScrolling] ScrollingFramePath is not set")
        return self
    end

    if self.ScrollingFramePath then
        self.ScrollingFrame =
            Framework.BuiltInShared.Part:findInstanceByPath(self.GridFrame, self.ScrollingFramePath)
        self.UIListLayout = self.ScrollingFrame:FindFirstChildOfClass("UIListLayout")
        if not self.ScrollingFrame then
            self.Logger:Error("[TAG AutoScaleGridScrolling] ScrollingFrame is not found")
            return self
        end
    end

    if self.GridFrame:FindFirstChildOfClass("UIGridLayout") then
        self.GridLayout = self.GridFrame:FindFirstChildOfClass("UIGridLayout")
        self.BaseSize = self.GridLayout.AbsoluteContentSize.Y
    else
        self.Logger:Error("[TAG AutoScaleGridScrolling] GridFrame does not have a UIGridLayout")
        return self
    end
    self.FillingGridFrame = self:CreateFillGridFrame()

    self.GridLayout.Changed:Connect(function()
        self:AdjustScale()
    end)

    self:AdjustScale()
    return self
end

function AutoScaleGridScrolling:Destroy()
    if self.FillingGridFrame and self.FillingGridFrame.Parent then
        self.FillingGridFrame:Destroy()
        self.FillingGridFrame = nil
    end
end

function AutoScaleGridScrolling:CreateFillGridFrame()
    local frame = Instance.new("Frame")
    frame.Name = "FillingGrid"
    frame.Size = UDim2.new(1, 0, 0, 0)
    frame.AnchorPoint = Vector2.new(0.5, 0.5)
    frame.BackgroundColor3 = Color3.fromRGB(173, 142, 142)
    frame.BackgroundTransparency = 1
    frame.LayoutOrder = self.GridFrame.LayoutOrder + 1
    frame.Parent = self.ScrollingFrame

    self:AdjustFollowingFramesLayoutOrder(frame, 1)
    return frame
end

function AutoScaleGridScrolling:AdjustScale()
    self.FillingGridFrame.Size =
        UDim2.new(1, 0, 0, self.GridLayout.AbsoluteContentSize.Y - self.GridFrame.AbsoluteSize.Y)
end

function AutoScaleGridScrolling:AdjustFollowingFramesLayoutOrder(frame, rowsAdded)
    local baseLayoutOrder = self.GridFrame.LayoutOrder
    local startingAutoScaleLayoutOrder = baseLayoutOrder + 1

    for _, child in ipairs(self.ScrollingFrame:GetChildren()) do
        if child ~= self.GridFrame and child ~= frame then
            if child:IsA("GuiObject") and child.LayoutOrder >= startingAutoScaleLayoutOrder then
                child.LayoutOrder = child.LayoutOrder + rowsAdded
            end
        end
    end

    frame.LayoutOrder = baseLayoutOrder + 1
end

return AutoScaleGridScrolling
