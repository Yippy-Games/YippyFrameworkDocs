--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ZoneOpenFrame = {}
ZoneOpenFrame.__index = ZoneOpenFrame
ZoneOpenFrame.Tag = "ZoneOpenFrame"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
--= Modules & Config =--
local Zone = require(ReplicatedFirst.Framework.Extra.Zoneplus)
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ZoneOpenFrame.new(Part: Instance)
    local self = setmetatable({}, ZoneOpenFrame)
    self.Part = Part
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.MainUI = Framework.BuiltInClient.UI:GetRootUI()
    self.FramePath = Part:GetAttribute("FramePath") or ""
    self.Group = Part:GetAttribute("Group")
    self.CloseOnExit = Part:GetAttribute("CloseOnExit") or false
    self.Frame = Framework.BuiltInShared.Part:findInstanceByPath(self.MainUI, self.FramePath)
    self.OpenSoundPath = Part:GetAttribute("OpenSoundPath") or ""
    self.CloseSoundPath = Part:GetAttribute("CloseSoundPath") or ""

    if not self.FramePath then
        self.Logger:Warn("[TAG ZoneOpenFrame] FramePath is invalid: " .. Part.Name .. "-" .. self.FramePath)
        return self
    end
    if self.OpenSoundPath ~= "" then
        self.OpenSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.OpenSoundPath)
    end
    if self.CloseSoundPath ~= "" then
        self.CloseSound = Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.CloseSoundPath)
    end

    self.Zone = Zone.new(Part)

    self.EnterEvent = self.Zone.playerEntered:Connect(function(player)
        self:PlayerEnteredZone(player)
    end)

    self.ExitEvent = self.Zone.playerExited:Connect(function(player)
        if self.CloseOnExit then
            self:PlayerExitedZone(player)
        end
    end)

    return self
end

function ZoneOpenFrame:Destroy()
    if self.Zone then
        self.Zone:destroy()
        self.Zone = nil
    end
    self.EnterEvent:Disconnect()
    self.ExitEvent:Disconnect()
end

--= Methods =--

function ZoneOpenFrame:Exist()
    return self.Frame ~= nil
end

function ZoneOpenFrame:PlayerEnteredZone(player: Player)
    if not self:Exist() then
        return
    end
    if player ~= Players.LocalPlayer then
        return
    end
    if self.OpenSound then
        self.OpenSound:Play()
    end
    Framework.BuiltInClient.UI:Open(self.FramePath, self.Group)
end

function ZoneOpenFrame:PlayerExitedZone(player: Player)
    if not self:Exist() then
        return
    end
    if player ~= Players.LocalPlayer then
        return
    end

    if self.Frame.Visible then
        if self.CloseSound then
            self.CloseSound:Play()
        end
        Framework.BuiltInClient.UI:Close(self.FramePath, self.Group)
    end
end

return ZoneOpenFrame
