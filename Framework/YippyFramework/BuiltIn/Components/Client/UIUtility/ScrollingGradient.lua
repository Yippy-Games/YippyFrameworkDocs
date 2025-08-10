--[[
__  ___                            ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ScrollingGradient = {}
ScrollingGradient.__index = ScrollingGradient
ScrollingGradient.Tag = "ScrollingGradient"

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)

--= Constants =--
local DEFAULT_DURATION = 8 -- Slower default speed
local DEFAULT_OFFSET = Vector2.new(0, 0) -- Left to right

--= Constructor =--
function ScrollingGradient.new(ui: UIGradient)
    local self = setmetatable({}, ScrollingGradient)
    self.UIGradient = ui

    -- Configure attributes with defaults
    self.Duration = ui:GetAttribute("Duration") or DEFAULT_DURATION
    self.Offset = ui:GetAttribute("Offset") or DEFAULT_OFFSET

    self.ScaleFactor = 1

    -- Start from further left and animate to further right for smoother transition
    self.UIGradient.Offset = Vector2.new(-2 * self.ScaleFactor, 0)

    self:StartScrolling()
    return self
end

function ScrollingGradient:Destroy()
    self.Running = false
end

--= Methods =--
function ScrollingGradient:Exist()
    return self.UIGradient ~= nil
end

function ScrollingGradient:StartScrolling()
    self.Running = true

    task.spawn(function()
        while self.Running and self:Exist() do
            local tween = Framework.BuiltInShared.Tween:InstantTween(self.UIGradient, {
                Time = self.Duration,
                Style = Enum.EasingStyle.Linear,
            }, {
                Offset = Vector2.new(1 * self.ScaleFactor, 0),
            })

            tween.Completed:Wait()

            if self.Running and self:Exist() then
                self.UIGradient.Offset = Vector2.new(-2 * self.ScaleFactor, 0)
            end
        end
    end)
end

return ScrollingGradient
