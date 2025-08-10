--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local Players = game:GetService("Players")
local UIS = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local Iris = require(ReplicatedFirst.Framework.Extra.Iris).Init()
--= Framework =--
local DebugUI = {
    BuiltIn = true
}
--= Framework API =--
function DebugUI:Start(Linker: table)
    self.Linker = Linker
    self.Activate = false

    if not Framework.FrameworkConfig.Settings.DebugUI.DebugUIEnabled then
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("DebugUI is disabled. Check settings.")
        end
        return
    end

    if not DebugUI:HasPermissions() then
        return
    end

    if RunService:IsStudio() then
        Iris.UpdateGlobalConfig(Iris.TemplateConfig.StudioStyle)
    else
        Iris.UpdateGlobalConfig(Iris.TemplateConfig.GameStyle)
    end

    self:Create()

    if self.Linker and not self.Linker.Render then
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("DebugUI has a linker but no Render function.")
        end
    end

    if self.Linker and self.Linker.Init then
        self.Linker:Init()
    end

    UIS.InputBegan:Connect(function(input)
        if input.KeyCode == Framework.FrameworkConfig.Settings.DebugUI.DebugUIKey then
            self.Activate = not self.Activate
        end
    end)
end

function DebugUI:HasPermissions()
    local GroupRole
    local success, _ = pcall(function()
        GroupRole = Players.LocalPlayer:GetRankInGroup(Framework.FrameworkConfig.Settings.FrameworkSettings.GroupId)
    end)
    if not success then
        return false
    end
    if RunService:IsStudio() or GroupRole >= Framework.FrameworkConfig.Settings.DebugUI.DebugUIRankRequired then
        return true
    end
    return false
end

function DebugUI:RenderDefault()
    Iris.Window({
        [Iris.Args.Window.Title] = Framework.FrameworkConfig.Settings.FrameworkSettings.Name
            .. " Framework - GameVer."
            .. game.PlaceVersion,
        [Iris.Args.Window.NoClose] = true,
    }, { size = Vector2.new(450, 500), position = Vector2.new(1470, 220) })
    Iris.CollapsingHeader({ "General" }, { isUncollapsed = true })
    Iris.SeparatorText({ "Information" })
    Iris.Text({ "FPS : " .. (Framework.BuiltInClient.GlobalStats:GetInfo("FPS") or "0") })
    Iris.Text({ "Ping : " .. (Framework.BuiltInClient.GlobalStats:GetInfo("Ping") or "0") .. "ms" })
    Iris.Text({ "Country : " .. (Framework.BuiltInClient.GlobalStats:GetInfo("Country") or "Unknown") })
    Iris.End()
end

function DebugUI:Create()
    Iris:Connect(function()
        if self.Activate then
            self:RenderDefault()
            if self.Linker and self.Linker.Render then
                self.Linker:Render(Iris)
            end
            Iris.End()
        end
    end)
end

return DebugUI
