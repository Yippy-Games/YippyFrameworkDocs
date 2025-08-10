--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local AnimationNPC = {}
AnimationNPC.__index = AnimationNPC
AnimationNPC.Tag = "AnimationNPC"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function AnimationNPC.new(Model: Model)
    local self = setmetatable({}, AnimationNPC)
    self.Model = Model
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(AnimationNPC.Tag)
    self.AnimationPath = self.Model:GetAttribute("AnimationPath")

    if not self.AnimationPath then
        self.Logger:Warn("[AnimationNPC] No animation path set for model: " .. self.Model.Name)
        return
    end

    if not ReplicatedFirst.Assets:FindFirstChild("Animations") then
        self.Logger:Error("[AnimationNPC] Animations folder not found in ReplicatedFirst")
        return
    end

    self.AnimationInstance =
        Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst.Assets.Animations, self.AnimationPath)
    if not self.AnimationInstance then
        self.Logger:Error("[AnimationNPC] Animation instance not found in ReplicatedFirst")
        return
    end

    self.Animations = Framework.BuiltInClient.Animations:LoadAnimationsFor(Model, self.AnimationInstance)
    Framework.BuiltInClient.Animations:PlayFor(Model, self.AnimationInstance.Name)

    return self
end

function AnimationNPC:Destroy() end

--= Methods =--

return AnimationNPC
