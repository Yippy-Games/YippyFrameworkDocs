--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \ 
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / /  __/
\/_/_/\___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/
         /_/   /_/    /____/                                
--]]

local FloatingStars = {}
FloatingStars.__index = FloatingStars
FloatingStars.Tag = "FloatingStars"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)

function FloatingStars.new(UI: UIBase)
    local self = setmetatable({}, FloatingStars)
    self.UIFrame = UI
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.FrameEventPath = UI:GetAttribute("FrameEventPath")
    self.Duration = UI:GetAttribute("Duration") or 1.3
    self.Interval = UI:GetAttribute("Interval") or 1.2
    self.MaxScale = UI:GetAttribute("MaxScale") or Vector2.new(2, 2)
    self.FloatingStarsColor = UI:GetAttribute("FloatingStarsColor") or Color3.fromRGB(255, 255, 255)
    self.ZIndex = UI:GetAttribute("ZIndex") or 1

    local RandomDelay = Framework.BuiltInShared.Randoms:RandomDecimals(0, 1)
    task.wait(RandomDelay)

    self:Animations()
    return self
end

function FloatingStars:Destroy()
    self.UIFrameEvent = nil
end

function FloatingStars:Exist()
    return self.UIFrame ~= nil and self.UIFrame.Parent ~= nil
end

function FloatingStars:Animations()
    coroutine.wrap(function()
        while self:Exist() do
            coroutine.wrap(function()
                local star = Instance.new("ImageLabel")
                star.Name = "FloatingStar"
                star.BackgroundTransparency = 1
                star.ScaleType = Enum.ScaleType.Fit
                star.Image = "rbxassetid://119906071070758"
                star.AnchorPoint = Vector2.new(0.5, 0.5)
                star.Size = UDim2.new(0.1, 0, 0.1, 0)
                star.ImageColor3 = self.FloatingStarsColor
                star.Position = UDim2.new(math.random(), 0, math.random(), 0)
                star.Parent = self.UIFrame
                star.ZIndex = self.ZIndex

                local scale = Instance.new("UIScale")
                scale.Scale = 0
                scale.Parent = star

                Framework.BuiltInShared.Tween:InstantTween(scale, { Time = self.Duration / 10 }, {
                    Scale = math.random(self.MaxScale.X, self.MaxScale.Y),
                })
                task.wait(self.Duration / 10)
                Framework.BuiltInShared.Tween:InstantTween(scale, { Time = self.Duration }, {
                    Scale = 0,
                })
                task.wait(self.Duration)
                star:Destroy()
            end)()
            task.wait(self.Interval)
        end
    end)()
end

return FloatingStars
