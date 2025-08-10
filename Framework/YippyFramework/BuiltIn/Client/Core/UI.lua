--[[
    Author: Rask/AfraiEda
    Creation Date: 01/06/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local CollectionService = game:GetService("CollectionService")
local Players = game:GetService("Players")
local StarterGui = game:GetService("StarterGui")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TextService = game:GetService("TextService")
--= Framework =--
local UI = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--
local Player = Players.LocalPlayer
--= Variables =--

--[UI Methods]--

function UI:findInstanceByPath(startInstance, path, retryInterval)
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

function UI:EnableUsefullCore()
    StarterGui:SetCoreGuiEnabled(Enum.CoreGuiType.All, false)

    for _, Core in pairs(Framework.FrameworkConfig.Settings.UI.EnabledUICore) do
        StarterGui:SetCoreGuiEnabled(Core, true)
    end
end

function UI:GetRootUI()
    return UI.UIGlobalList["Main"]
end

function UI:GetFrameworkUI()
    return UI.UIGlobalList["Framework"]
end

function UI:CloseGroupFrame(Group)
    local CurrentFrame = self:GetGroup(Group)
    if CurrentFrame then
        self:Close(CurrentFrame, Group)
    end
end

function UI:GetGroup(Group: string)
    return StarterGui:GetAttribute(Group .. "CurrentlyOpen")
end

function UI:SetGroup(Group: string, Path: string)
    StarterGui:SetAttribute(Group .. "CurrentlyOpen", Path)
end

function UI:UnsetGroup(Group: string)
    StarterGui:SetAttribute(Group .. "CurrentlyOpen", nil)
end

function UI:ProcessNextAnimation(Group)
    local queue = self.AnimationQueue[Group]
    if queue and #queue > 0 and not StarterGui:GetAttribute(Group .. "CurrentlyAnim") then
        local nextAnimation = table.remove(queue, 1)
        nextAnimation()
    end
end

function UI:CloseCurrentFrame(Group)
    Group = Group or "Main"
    local CurrentFrame = self:GetGroup(Group)
    if CurrentFrame then
        self:Close(CurrentFrame, Group)
    end
end

function UI:GetLastAction()
    return self.LastAction
end

function UI:SetLastAction(Action)
    self.LastAction = Action
end

function UI:GetLastOpenedFrame()
    return self.CurrentOpenFrame
end

function UI:Close(Path, Group, Action)
    Group = Group or "Main"
    if not self.AnimationQueue[Group] then
        self.AnimationQueue[Group] = {}
    end
    table.insert(self.AnimationQueue[Group], function()
        local Frame = UI:findInstanceByPath(UI.UIGlobalList["Main"], Path)
        if not Frame or Frame.Visible == false then
            return
        end
        StarterGui:SetAttribute(Group .. "CurrentlyAnim", true)
        StarterGui:SetAttribute(Group .. "CurrentlyAnim", nil)
        self:UnsetGroup(Group)
        StarterGui:SetAttribute("OpenedFrame", nil)
        Frame.Visible = false
        self.CurrentOpenFrame = nil
        if Action then
            self.LastAction = Action
        end
        self:ProcessNextAnimation(Group)
    end)
    self:ProcessNextAnimation(Group)
end

function UI:Open(Path, Group, Action)
    Group = Group or "Main"
    if not self.AnimationQueue[Group] then
        self.AnimationQueue[Group] = {}
    end
    table.insert(self.AnimationQueue[Group], function()
        local Frame = UI:findInstanceByPath(UI.UIGlobalList["Main"], Path)
        if not Frame then
            warn("Frame not found", Path, Group)
            return
        end
        if self:GetGroup(Group) then
            local GroupToClose = self:GetGroup(Group)
            if GroupToClose then
                self:Close(GroupToClose, Group)
            end
        end
        self:SetGroup(Group, Path)
        Frame.Visible = true
        self.CurrentOpenFrame = Frame
        self.LastAction = Action
        StarterGui:SetAttribute(Group .. "CurrentlyAnim", true)
        Frame.Position = Frame.Position + UDim2.new(0, 0, -0.05, 0)
        Framework.BuiltInShared.Tween:InstantTween(
            Frame,
            { Time = 0.18, Style = Enum.EasingStyle.Circular, Direction = Enum.EasingDirection.Out },
            { Position = Frame.Position + UDim2.new(0, 0, 0.05, 0) }
        )
        task.wait(0.18)
        StarterGui:SetAttribute(Group .. "CurrentlyAnim", nil)
        self:ProcessNextAnimation(Group)
    end)
    self:ProcessNextAnimation(Group)
end

function UI:tweenOutOfScreen(Element: Instance)
    local position = Element.Position
    local size = Element.Size
    local xScale = position.X.Scale
    local yScale = position.Y.Scale

    local distanceToLeft = xScale
    local distanceToRight = 1 - xScale
    local distanceToTop = yScale
    local distanceToBottom = 1 - yScale

    local nearestEdge
    local nearestDistance = math.min(distanceToLeft, distanceToRight, distanceToTop, distanceToBottom)

    if nearestDistance == distanceToLeft then
        nearestEdge = "left"
    elseif nearestDistance == distanceToRight then
        nearestEdge = "right"
    elseif nearestDistance == distanceToTop then
        nearestEdge = "top"
    else
        nearestEdge = "bottom"
    end

    local targetPosition
    if nearestEdge == "left" then
        targetPosition = UDim2.new(-size.X.Scale - 0.01, 0, yScale, 0)
    elseif nearestEdge == "right" then
        targetPosition = UDim2.new(1 + size.X.Scale + 0.01, 0, yScale, 0)
    elseif nearestEdge == "top" then
        targetPosition = UDim2.new(xScale, 0, -size.Y.Scale - 0.01, 0)
    else
        targetPosition = UDim2.new(xScale, 0, 1 + size.Y.Scale + 0.01, 0)
    end

    Element:TweenPosition(targetPosition, Enum.EasingDirection.Out, Enum.EasingStyle.Quad, 0.22, true)
end

function UI:TweenScale(Element: Instance, Scale: number, Time: number)
    local UIScale = Framework.BuiltInClient.UI:CheckUIScale(Element)
    local scale = Scale or 1

    if scale > 0 then
        Element.Visible = true
    end

    if Time == 0 then
        UIScale.Scale = scale
        if scale == 0 then
            Element.Visible = false
        end
        return
    end

    Framework.BuiltInShared.Tween:InstantTween(
        UIScale,
        { Time = Time, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
        { Scale = scale }
    )
    task.delay(Time, function()
        if scale == 0 then
            Element.Visible = false
        end
    end)
end

function UI:TweenTransparencyGroup(Element: Instance, Transparency: number, Time: number)
    local function tweenTransparency(Elem: Instance)
        if Elem:IsA("Frame") then
            Framework.BuiltInShared.Tween:InstantTween(
                Elem,
                { Time = Time, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
                { BackgroundTransparency = Transparency }
            )
        elseif Elem:IsA("TextLabel") or Element:IsA("TextButton") then
            Framework.BuiltInShared.Tween:InstantTween(
                Elem,
                { Time = Time, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
                { TextTransparency = Transparency }
            )
        elseif Elem:IsA("ImageLabel") or Element:IsA("ImageButton") then
            Framework.BuiltInShared.Tween:InstantTween(
                Elem,
                { Time = Time, Style = Enum.EasingStyle.Quad, Direction = Enum.EasingDirection.Out },
                { ImageTransparency = Transparency }
            )
        end
    end

    if Transparency == 0 then
        Element.Visible = true
    end
    tweenTransparency(Element)
    for _, element in pairs(Element:GetDescendants()) do
        tweenTransparency(element)
    end
    task.delay(Time, function()
        if Transparency == 1 then
            Element.Visible = false
        end
    end)
end

function UI:CheckUIScale(Instances: Instance)
    if not Instances then
        return
    end
    if Instances:FindFirstChildOfClass("UIScale") then
        return Instances:FindFirstChildOfClass("UIScale")
    else
        local Scale = Instance.new("UIScale")
        Scale.Parent = Instances
        return Scale
    end
end

function UI:CheckUIGradient(Instances: Instance)
    if not Instances then
        return
    end
    if Instances:FindFirstChildOfClass("UIGradient") then
        return Instances:FindFirstChildOfClass("UIGradient")
    else
        local Scale = Instance.new("UIGradient")
        Scale.Parent = Instances
        return Scale
    end
end

function UI:ScaleTextOffset(Text: string, FontFace: Font, MaxLettersPerLine: number, SizeScale: number, Options: table)
    Text = Text or ""
    local opts = Options or {}
    local lineCap = math.max(1, MaxLettersPerLine)
    local params = self._boundsParams

    if not params then
        params = Instance.new("GetTextBoundsParams")
        params.Size = 20
        params.Width = math.huge
        self._boundsParams = params
    end

    params.Font = FontFace
    params.Text = Text
    local chunk = Text:sub(1, lineCap)
    params.Text = chunk
    local ok, dim = pcall(TextService.GetTextBoundsAsync, TextService, params)
    local maxLineWidth = ok and dim.X or (#chunk * params.Size)

    local totalHeight
    if opts.NoHeight then
        totalHeight = opts.CurrentHeight
        if not totalHeight then
            params.Text = "X"
            local _, hVec = pcall(TextService.GetTextBoundsAsync, TextService, params)
            totalHeight = hVec and hVec.Y or params.Size
        end
    else
        local numLines = math.ceil(#Text / lineCap)
        params.Text = "X"
        local _, hVec = pcall(TextService.GetTextBoundsAsync, TextService, params)
        local lineH = hVec and hVec.Y or params.Size
        totalHeight = lineH * numLines
    end

    return UDim2.fromOffset(maxLineWidth * SizeScale, totalHeight * SizeScale)
end

--= Size scale/offset methods =--

function UI:GetAverage(vector: Vector2): number
    return (vector.X + vector.Y) / 2
end

function UI:ConvertBasedOnScreenSize(Value: number)
    if Value == 0 then
        return 0
    end

    local vp = Framework.BuiltInClient.Camera:GetViewportSize()
    local CurrentScreen = UI:GetAverage(vp)
    local Ratio = Value / self.ScreenRefSize
    return CurrentScreen * Ratio
end

--= Main UI =--
function UI:LoadUI()
    local MainAssetsFolder = UI:findInstanceByPath(ReplicatedFirst, "Assets/UI/Main")
    assert(MainAssetsFolder, "Didn't find 'Main' in ReplicatedFirst/Assets/UI/Main")

    local FrameworkAssetsFolder =
        UI:findInstanceByPath(ReplicatedFirst, "FrameworkAssets/UI/Main")
    assert(FrameworkAssetsFolder, "Didn't find 'Main' in ReplicatedFirst/FrameworkAssets/UI/Main")

    UI.UIGlobalList = {
        ["Main"] = {},
        ["Framework"] = {},
    }

    local MaxMainDisplayOrder = 0

    for _, ScreenGui in MainAssetsFolder:GetChildren() do
        local ClonedScreenGui = ScreenGui:Clone()
        ClonedScreenGui.Parent = Player.PlayerGui
        ClonedScreenGui.Name = ClonedScreenGui.Name .. "Main"
        MaxMainDisplayOrder = math.max(MaxMainDisplayOrder, ClonedScreenGui.DisplayOrder)
        self:ApplyChanges(ClonedScreenGui)
        for _, Child in ClonedScreenGui:GetChildren() do
            UI.UIGlobalList["Main"][Child.Name] = Child
        end
    end

    for _, ScreenGui in FrameworkAssetsFolder:GetChildren() do
        local ClonedScreenGui = ScreenGui:Clone()
        ClonedScreenGui.Parent = Player.PlayerGui
        ClonedScreenGui.Name = ClonedScreenGui.Name .. "Framework"
        ClonedScreenGui.DisplayOrder = ClonedScreenGui.DisplayOrder + MaxMainDisplayOrder
        self:ApplyChanges(ClonedScreenGui)
        for _, Child in ClonedScreenGui:GetChildren() do
            UI.UIGlobalList["Framework"][Child.Name] = Child
        end
    end
end

function UI:ApplyChanges(MainUI: Instance)
    for _, Element in pairs(MainUI:GetDescendants()) do
        if Element:IsA("UIStroke") then
            CollectionService:AddTag(Element, "UIStroke")
        elseif Element:IsA("ScrollingFrame") then
            CollectionService:AddTag(Element, "AutoScrollingFrame")
        end
    end
end

function UI:CustomMouseLeave(Instances: Instance, Callback: () -> ())
    self._customHoverRegistry[Instances] = Callback
end

function UI:LoadCustomEvents()
    self._customHoverRegistry = {}

    RunService.Heartbeat:Connect(function()
        local pos = UserInputService:GetMouseLocation()
        local guiInset = game:GetService("GuiService"):GetGuiInset()
        local x, y = pos.X, pos.Y - guiInset.Y
        local hovered = Player.PlayerGui:GetGuiObjectsAtPosition(x, y)

        for frame, callback in pairs(self._customHoverRegistry) do
            if frame.Visible == false then
                callback()
                continue
            end

            local absPos = frame.AbsolutePosition
            local absSize = frame.AbsoluteSize

            local inside = x >= absPos.X and x <= absPos.X + absSize.X and y >= absPos.Y and y <= absPos.Y + absSize.Y

            if not inside then
                callback()
                continue
            end

            local frameGui = frame:FindFirstAncestorOfClass("ScreenGui")
            local frameOrder = frameGui and frameGui.DisplayOrder or 0

            local isObscured = false
            for _, guiObj in ipairs(hovered) do
                if guiObj == frame or guiObj:IsDescendantOf(frame) then
                    continue
                end

                local topGui = guiObj:FindFirstAncestorOfClass("ScreenGui")
                local topOrder = topGui and topGui.DisplayOrder or 0

                local isTransparent = guiObj:IsA("Frame") and guiObj.BackgroundTransparency >= 1
                local isInactive = not guiObj.Visible

                if topOrder > frameOrder and not isTransparent and not isInactive then
                    isObscured = true
                    break
                end
            end

            if isObscured then
                callback()
            end
        end
    end)
end

function UI:Start()
    UI.AnimationQueue = {}
    self.ScreenRefSize = self:GetAverage(Framework.FrameworkConfig.Settings.UI.ScreenSize)

    --= UI =--

    UI:LoadUI()
    self:LoadCustomEvents()
    UI:EnableUsefullCore()

    --= Reset Button =--

    if Framework.FrameworkConfig.Settings.UI.DisabledResetButton then
        local coreCall
        do
            function coreCall(method, ...)
                local result = {}
                while task.wait() do
                    local success, _ = pcall(StarterGui[method], StarterGui, ...)
                    if success then
                        break
                    end
                    RunService.Stepped:Wait()
                end
                return unpack(result)
            end
        end
        coreCall("SetCore", "ResetButtonCallback", false)
    end
end

return UI
