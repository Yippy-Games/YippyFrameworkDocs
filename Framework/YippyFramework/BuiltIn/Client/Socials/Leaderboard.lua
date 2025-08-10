--[[
__  ___                              ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Framework =--
local Leaderboard = {
    BuiltIn = true
}
local LB = {}
LB.__index = LB

function Leaderboard:Start(Linker: table)
    self.Linker = Linker
    for _, cfg in pairs(Framework.FrameworkConfig.Settings.Leaderboards.LeaderboardsRegistry or {}) do
        task.spawn(function()
            LB.new(cfg)
        end)
    end
end

--= Leaderboard Class =--

function Leaderboard:findInstanceByPath(startInstance, path, retryInterval)
    if startInstance == nil or path == nil then
        error("[findInstanceByPath] startInstance and path are required")
    end

    local segments = string.split(path, "/")
    local maxRetries = 3
    retryInterval = retryInterval or 1

    local function getChild(parent, key)
        if typeof(parent) == "Instance" then
            return parent:FindFirstChild(key)
        elseif typeof(parent) == "table" then
            return parent[key]
        end
    end

    for _ = 1, maxRetries do
        local current = startInstance

        for _, part in ipairs(segments) do
            if part == ".." then
                current = typeof(current) == "Instance" and current.Parent or nil
            elseif part ~= "." then
                current = getChild(current, part)
            end

            if current == nil then
                task.wait(retryInterval)
                break
            end
        end

        if current ~= nil then
            return current
        end
    end

    return nil
end

function LB.new(cfg)
    local self = setmetatable({}, LB)
    self.Config = cfg
    self.Model = cfg.ModelPath and Leaderboard:findInstanceByPath(game, cfg.ModelPath)
    self.CurrentMode = "AllTime"
    self.AvailableModes = {}
    self.NPCTPPath = cfg.NPCTPPath and Leaderboard:findInstanceByPath(game, cfg.NPCTPPath)

    self.PlayersHolder = nil
    if Leaderboard.Linker and Leaderboard.Linker.GetHolderFrame then
        self.PlayersHolder = Leaderboard.Linker:GetHolderFrame(self.Model)
    else
        self.PlayersHolder = self.Model.Leaderboard.Frame.Players
    end

    if self.NPCTPPath then
        local NPC = ReplicatedFirst.FrameworkAssets.Models.Leaderboard.NPC:Clone()
        NPC:PivotTo(self.NPCTPPath.CFrame)
        NPC.Parent = game.Workspace
        self.NPC = NPC

        self.NPCTPPath.Transparency = 1

        if cfg.AnimationID then
            Framework.BuiltInClient.Animations:LoadAnimationsFor(NPC, cfg.AnimationID)
            Framework.BuiltInClient.Animations:PlayFor(NPC, cfg.AnimationID)
        end
    end
    self.LastTopPlayer = nil

    if Leaderboard.Linker and Leaderboard.Linker.CreateLBVisual then
        Leaderboard.Linker:CreateLBVisual(self.Model, self.PlayersHolder)
    end

    task.spawn(function()
        while self.Model and self.Model.Parent do
            self:_updateDisplay()
            task.wait(1)
        end
    end)

    return self
end

function LB:UpdateTopPlayerAppearance(userId)
    local success, playerAppearance = pcall(function()
        return Players:GetHumanoidDescriptionFromUserId(tonumber(userId))
    end)
    if success then
        self.NPC.Humanoid:ApplyDescription(playerAppearance)
    end
end

function LB:_switchMode(newMode)
    if newMode == self.CurrentMode then
        return
    end

    self.CurrentMode = newMode
    self:_updateAllButtonVisuals()
    self:_updateDisplay()
end

function LB:_updateButtonVisuals(button, isActive)
    button.BackgroundColor3 = isActive and Color3.fromRGB(37, 37, 37) or Color3.fromRGB(255, 255, 255)
end

function LB:_updateAllButtonVisuals()
    local buttonsHolder = self.Model.Leaderboard.Frame.Buttons
    if not buttonsHolder then
        return
    end

    for _, button in ipairs(buttonsHolder:GetChildren()) do
        if button:IsA("GuiButton") or (button:IsA("Frame") and button:FindFirstChildOfClass("GuiButton")) then
            local modeName = button.Name
            self:_updateButtonVisuals(button, modeName == self.CurrentMode)
        end
    end
end

function LB:_updateDisplay()
    if not self.PlayersHolder  then
        return
    end
    local TopPlayer = nil

    for _, frame in ipairs(self.PlayersHolder:GetChildren()) do
        if  frame.Name:find("Item%-") then
            local category = frame:GetAttribute("Category")
            local isActive = frame:GetAttribute("Active")
            local shouldShow = false

            if category and isActive then
                if category == self.CurrentMode then
                    shouldShow = true
                end

                if frame:GetAttribute("Top") == true and shouldShow then
                    TopPlayer = frame:GetAttribute("UserId")
                end
            end

            frame.Visible = shouldShow
        end
    end

    if TopPlayer and TopPlayer ~= self.LastTopPlayer then
        self:UpdateTopPlayerAppearance(TopPlayer)
        self.LastTopPlayer = TopPlayer
    end
end
--= Helper Methods =--

function LB:getCurrentMode()
    return self.CurrentMode
end

function LB:getAvailableModes()
    return self.AvailableModes
end

function LB:switchToMode(mode)
    if table.find(self.AvailableModes, mode) then
        self:_switchMode(mode)
        return true
    end
    return false
end

return Leaderboard
