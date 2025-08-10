--[[
    Notifications Settings
    Configuration for the notification system
--]]

local NotificationsSettings = {}

--= Notifications Configuration =--
NotificationsSettings.MaxNotifications = 4
NotificationsSettings.NotificationDuration = 3
NotificationsSettings.NotificationsTypes = {
    ["Success"] = {
        ["Image"] = "rbxassetid://116394389177910",
        ["Color"] = Color3.fromRGB(0, 195, 255),
    },
    ["Error"] = {
        ["Image"] = "rbxassetid://118730580747201",
        ["Color"] = Color3.fromRGB(250, 64, 88),
    },
    ["Info"] = {
        ["Image"] = "rbxassetid://80352425398004",
        ["Color"] = Color3.fromRGB(47, 53, 66),
    },
    ["Warning"] = {
        ["Image"] = "rbxassetid://125080076275976",
        ["Color"] = Color3.fromRGB(255, 165, 0),
    },
}

return NotificationsSettings
