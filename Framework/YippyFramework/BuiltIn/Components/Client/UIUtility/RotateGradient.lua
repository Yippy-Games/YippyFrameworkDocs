--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local RotateGradient = {}
RotateGradient.__index = RotateGradient
RotateGradient.Tag = "RotateGradient"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function RotateGradient.new(ui: UIGradient)
    local self = setmetatable({}, RotateGradient)
    self.UIGradient = ui

    self:Loop()
    return self
end

function RotateGradient:Destroy() end

--= Methods =--

function RotateGradient:Exist()
    return self.UIGradient ~= nil
end

function RotateGradient:Loop()
    while self:Exist() do
        Framework.BuiltInShared.Tween:InstantTween(
            self.UIGradient,
            { Time = 5, Style = Enum.EasingStyle.Linear },
            { Rotation = 360 }
        )
        task.wait(5)
        self.UIGradient.Rotation = 0
    end
end

return RotateGradient
