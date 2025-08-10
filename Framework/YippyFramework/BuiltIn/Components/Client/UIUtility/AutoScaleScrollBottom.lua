--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local AutoScaleScrollBottom = {}
AutoScaleScrollBottom.__index = AutoScaleScrollBottom
AutoScaleScrollBottom.Tag = "AutoScaleScrollBottom"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function AutoScaleScrollBottom.new(ScrollingFrame: Frame)
    local self = setmetatable({}, AutoScaleScrollBottom)
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.ScrollingFrame = ScrollingFrame
    self.UIListLayout = self.ScrollingFrame:WaitForChild("UIListLayout")

    if not self.UIListLayout then
        self.Logger:Error("[AutoScaleScrollBottom] UIListLayout not found")
        return
    end

    self.UIListLayout.Changed:Connect(function()
        self:AdjustScale()
    end)

    self:AdjustScale()
    return self
end

function AutoScaleScrollBottom:Destroy() end

function AutoScaleScrollBottom:AdjustScale()
    self.ScrollingFrame.CanvasSize = UDim2.fromOffset(0, self.ScrollingFrame.UIListLayout.AbsoluteContentSize.Y + 10)
end

return AutoScaleScrollBottom
