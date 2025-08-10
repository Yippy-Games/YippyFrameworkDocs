--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local Rotate360 = {}
Rotate360.__index = Rotate360
Rotate360.Tag = "Rotate360"

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--

--= Variables =--

--= Job API =--

--= Constructor =--

function Rotate360.new(UI: GuiObject)
    local self = setmetatable({}, Rotate360)
    self._ui = UI
    self._speed = self._ui:GetAttribute("Speed") or 2

    self:Update()
    return self
end

function Rotate360:Destroy() end

--= Events =--

function Rotate360:Update()
    while self._ui and self._ui.Parent do
        Framework.BuiltInShared.Tween:InstantTween(
            self._ui,
            { Time = self._speed, Style = Enum.EasingStyle.Linear },
            { Rotation = 360 }
        )
        task.wait(self._speed)
        self._ui.Rotation = 0
    end
end
return Rotate360
