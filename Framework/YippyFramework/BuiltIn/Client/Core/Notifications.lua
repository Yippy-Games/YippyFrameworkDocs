--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Framework =--
local Notifications = {
    BuiltIn = true
}
--= Framework API =--

function Notifications:Start()
    Notifications.Logger = Framework.BuiltInShared.Logger:GetLogger("Notifications")
    Notifications.FrameworkUI = Framework.BuiltInClient.UI:GetFrameworkUI()
    Notifications.NotifUI = Notifications.FrameworkUI.HUD.Notifications
    Notifications.NotifChannel = Framework.BuiltInClient.Network.Channel("NotifChannel")
    Notifications.List = {}
    Notifications.ListData = {}

    Notifications.NotifChannel:On("Notif", function(Type: string, Message: string)
        Notifications:Create(Type, Message)
    end)

    Notifications.NotifChannel:On("Clear", function()
        Notifications:Clear()
    end)
end

function Notifications:Create(Type: string, Message: string)
    if Framework.FrameworkConfig.Settings.Notifications.MaxNotifications <= #Notifications.List then
        Notifications:Remove(Notifications.List[1])
    end

    if not Framework.FrameworkConfig.Settings.Notifications.NotificationsTypes[Type] then
        Notifications.Logger:Warn("Invalid notification type: " .. Type)
        return
    end

    local HasNotif = Notifications:AlreadyExists(Type, Message)
    if HasNotif then
        Notifications:UpdateCount(HasNotif)
        return
    end

    coroutine.wrap(function()
        local Notif = Notifications:CreateUI(Type, Message)
        table.insert(Notifications.List, Notif)
        Notifications.ListData[Notif] = {
            Frame = Notif,
            Type = Type,
            Message = Message,
            Count = 1,
            Duration = Framework.FrameworkConfig.Settings.Notifications.NotificationDuration,
        }
        Notif.UIScale.Scale = 0.91
        Framework.BuiltInClient.UI:RegisterAutoScaleUI(Notif.UIScale, "Rescale", {
            "Scale",
        })
        local Scale = Notif.UIScale.Scale
        Framework.BuiltInShared.Tween:InstantTween(
            Notif.UIScale,
            { Time = 0.25, Style = Enum.EasingStyle.Back, Direction = Enum.EasingDirection.Out },
            { Scale = Scale * 1.157 }
        )

        while Notifications.ListData[Notif] and Notifications.ListData[Notif].Duration > 0 do
            task.wait(0.1)
            local NotifData = Notifications.ListData[Notif]
            if NotifData then
                NotifData.Duration = math.max(0, NotifData.Duration - 0.1)
            end
        end
        Notifications:Remove(Notif)
    end)()
end

function Notifications:AlreadyExists(Type: string, Message: string)
    for _, Notif in ipairs(Notifications.List) do
        if Notifications.ListData[Notif].Type == Type and Notifications.ListData[Notif].Message == Message then
            return Notif
        end
    end
    return nil
end

function Notifications:UpdateCount(Notif: Frame)
    if not Notifications.ListData[Notif] then
        return
    end

    -- Check if Text element exists before trying to update it
    if not Notifications.ListData[Notif].Frame:FindFirstChild("Text") then
        Notifications.ListData[Notif].Duration += 0.2
        Notifications.ListData[Notif].Count += 1
        return -- No text element to update
    end

    Notifications.ListData[Notif].Duration += 0.2
    Notifications.ListData[Notif].Count += 1
    Notifications.ListData[Notif].Frame.Text.Text = Notifications.ListData[Notif].Message
        .. " x"
        .. Notifications.ListData[Notif].Count

    local CurrentGraphemes = Notifications.ListData[Notif].Frame.Text.MaxVisibleGraphemes
    local MessageLength = #Notifications.ListData[Notif].Frame.Text.Text

    if CurrentGraphemes < MessageLength then
        coroutine.wrap(function()
            local TYPEWRITER_DURATION = 0.16
            local characterDelay = TYPEWRITER_DURATION / MessageLength
            local notificationData = Notifications.ListData[Notif] -- Cache the reference

            if not notificationData then
                return -- Exit early if notification is already gone
            end

            for i = CurrentGraphemes + 1, MessageLength do
                -- Check if notification still exists before each update
                if
                    not notificationData
                    or not notificationData.Frame
                    or not notificationData.Frame:FindFirstChild("Text")
                then
                    break -- Exit the loop if notification was destroyed
                end

                notificationData.Frame.Text.MaxVisibleGraphemes = i
                task.wait(characterDelay)
            end
        end)()
    end
end

function Notifications:Clear()
    for _, Notif in ipairs(Notifications.List) do
        Notifications:Remove(Notif)
    end
end

function Notifications:Remove(Notif: Frame)
    local index = table.find(Notifications.List, Notif)
    if not index then
        return
    end

    table.remove(Notifications.List, index)
    if Notifications.ListData[Notif] then
        Notifications.ListData[Notif] = nil
    end

    coroutine.wrap(function()
        Framework.BuiltInShared.Tween:InstantTween(
            Notif.UIScale,
            { Time = 0.23, Style = Enum.EasingStyle.Quad },
            { Scale = 0 }
        )
        task.wait(0.2)
        Notif:Destroy()
    end)()
end

function Notifications:CreateUI(Type: string, Message: string)
    local UI = ReplicatedFirst.FrameworkAssets.UI.Notifications.Notification
    local Clone = UI:Clone()
    Clone.UIScale.Scale = 0
    Clone.Parent = Notifications.NotifUI
    Clone.Icon.Image = Framework.FrameworkConfig.Settings.Notifications.NotificationsTypes[Type].Image
    Clone.BackgroundColor3 = Framework.FrameworkConfig.Settings.Notifications.NotificationsTypes[Type].Color

    coroutine.wrap(function()
        if Message:len() == 0 then
            Clone.Text:Destroy()
        else
            Clone.Text.Text = Message
            Clone.Text.MaxVisibleGraphemes = 0
            local TYPEWRITER_DURATION = 0.16
            local characterDelay = TYPEWRITER_DURATION / #Message
            for i = 1, #Message do
                if Clone:FindFirstChild("Text") then
                    Clone.Text.MaxVisibleGraphemes = i
                    task.wait(characterDelay)
                end
            end
        end
    end)()
    return Clone
end

return Notifications
