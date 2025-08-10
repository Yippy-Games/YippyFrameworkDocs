--[[
    Framework Core Settings
    Contains general framework configuration and BuiltIn module control
--]]

local FrameworkSettings = {}

--= General Framework Settings =--
FrameworkSettings.Name = "Yippy"
FrameworkSettings.Studio = "Yippy Games"
FrameworkSettings.Version = "1.1 ALPHA"
FrameworkSettings.GroupId = 34305087
FrameworkSettings.FrameworkWarning = true

--= BuiltIn Module Loading Configuration =--
FrameworkSettings.BuiltIn = {
    -- Core utilities (load in this order)
    { Name = "Logger" },
    { Name = "Color" },
    { Name = "Part" },
    { Name = "Tween" },
    { Name = "Table" },
    { Name = "Randoms" },
    { Name = "Date" },
    { Name = "Component" },
    { Name = "Event" },
    { Name = "Registry" },
    { Name = "Network" },
    { Name = "Datastore" },

    -- Feature modules
    { Name = "Camera",       Enabled = true },
    { Name = "UI",           Enabled = true },
    { Name = "Notifications",Enabled = true },
    { Name = "Marketplace",  Enabled = true },
    { Name = "GlobalStats",  Enabled = true },
    { Name = "Chat",         Enabled = true },
    { Name = "Cmdr",         Enabled = true },
    { Name = "DebugUI",      Enabled = true },
    { Name = "Sounds",       Enabled = true},
    { Name = "Ragdoll",      Enabled = true},
    { Name = "Animations",   Enabled = true },
    { Name = "Leaderboard",  Enabled = true },
}

return FrameworkSettings
