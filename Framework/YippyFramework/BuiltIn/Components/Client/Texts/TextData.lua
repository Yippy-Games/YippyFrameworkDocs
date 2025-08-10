--[[
__  ___                            ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / /_/ /_/ /_/ / /_/ / /_/ /  /_/ / /_/ / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local TextData = {}
TextData.__index = TextData
TextData.Tag = "TextData"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local FormatNumber = require(ReplicatedFirst.Framework.Extra.formatnumber)
--= Donation Animation Config =--
local DONATE_MAX_ICONS = 40
local DONATE_MIN_DISTANCE = 0.2
local DONATE_DELAY_MIN = 0.04
local DONATE_DELAY_MAX = 0.045
local DONATE_APPEAR_TIME = 0.05
local DONATE_MOVE_SPEED = 2.5
local DONATE_SIZEICON = UDim2.new(0.1, 0, 0.1, 0)
local DONATE_BOUNCE_TIME = 0.05
--= Helpers: linear and bezier =--
local function Lerp(a, b, t)
    return a + (b - a) * t
end
local function QuadBezier2D(p0, p1, p2, t)
    local x1 = Lerp(p0.X, p1.X, t)
    local y1 = Lerp(p0.Y, p1.Y, t)
    local x2 = Lerp(p1.X, p2.X, t)
    local y2 = Lerp(p1.Y, p2.Y, t)
    return Vector2.new(Lerp(x1, x2, t), Lerp(y1, y2, t))
end

--= Constructor =--
function TextData.new(ui)
    local self = setmetatable({}, TextData)
    self.TextUI = ui
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.DataPath = ui:GetAttribute("DataPath")
    self.Prefix = ui:GetAttribute("Prefix") or ""
    self.Suffix = ui:GetAttribute("Suffix") or ""
    self.Format = ui:GetAttribute("Format") or false
    self.CompactFormat = ui:GetAttribute("CompactFormat") or false
    self.TypeDisplay = ui:GetAttribute("TypeDisplay") or "Number"
    self.Space = ui:GetAttribute("Space") or false
    self.IconPath = ui:GetAttribute("IconPath")
    self.Animation = ui:GetAttribute("Animation") or "None"
    self.HUDPath = ui:GetAttribute("HUDPath")
    self.HolderPath = ui:GetAttribute("HolderPath")
    self.AnimationTarget = ui:GetAttribute("AnimationTarget") or UDim2.new(0.5, 0, 0.5, 0)
    self.XRandomRange = ui:GetAttribute("XRandomRange") or Vector2.new(0.45, 0.95)
    self.YRandomRange = ui:GetAttribute("YRandomRange") or Vector2.new(0.1, 0.9)
    self.PlusTextPath = ui:GetAttribute("PlusTextPath")
    self.plsDonateSoundPath = ui:GetAttribute("plsDonateSoundPath")

    self._plusAccum = 0
    self._animQueue = {}
    self._isAnimating = false
    self.FakeDisplay = ui:GetAttribute("FakeDisplay") or false
    self._fakeTickThread = nil
    self._lastRealValue = 0

    if self.plsDonateSoundPath then
        self.plsDonateSound =
            Framework.BuiltInShared.Part:findInstanceByPath(ReplicatedFirst, self.plsDonateSoundPath)
    end
    if self.PlusTextPath then
        self.PlusText = Framework.BuiltInShared.Part:findInstanceByPath(ui, self.PlusTextPath)
    end
    if self.IconPath then
        self.Icon = Framework.BuiltInShared.Part:findInstanceByPath(ui, self.IconPath)
    end
    if self.HUDPath then
        self.HUD = Framework.BuiltInShared.Part:findInstanceByPath(ui, self.HUDPath)
    end
    if self.HolderPath then
        self.Holder = Framework.BuiltInShared.Part:findInstanceByPath(ui, self.HolderPath)
    end

    if not self.DataPath then
        self.Logger:Warn("[TextData] Missing DataPath on " .. ui.Name)
        return self
    end

    -- local initVal = tonumber(Framework.BuiltInClient.Datastore:GetValueFromPath(self.DataPath)) or 0
    -- self._lastValue = initVal
    -- self._lastRealValue = initVal
    -- self:Update(initVal)
    -- self.Listen = Framework.BuiltInClient.Datastore:ListenToPathChanged(self.DataPath):Connect(function(_, v)
    --     self:Update(tonumber(v) or 0)
    -- end)
    return self
end

function TextData:Destroy()
    if self.Listen then
        self.Listen:Disconnect()
    end
    if self._fakeTickThread then
        task.cancel(self._fakeTickThread)
        self._fakeTickThread = nil
    end
end

function TextData:getRandomPos()
    local tx, ty = self.Holder.Position.X.Scale, self.Holder.Position.Y.Scale
    for _ = 1, 10 do
        local x = Framework.BuiltInShared.Randoms:RandomDecimals(self.XRandomRange.X, self.XRandomRange.Y)
        local y = Framework.BuiltInShared.Randoms:RandomDecimals(self.YRandomRange.X, self.YRandomRange.Y)
        if (Vector2.new(x, y) - Vector2.new(tx, ty)).Magnitude >= DONATE_MIN_DISTANCE then
            return Vector2.new(x, y)
        end
    end
    return Vector2.new(tx, ty)
end

function TextData:genPositions(count)
    local pts = {}
    for i = 1, count do
        local chosen
        for _ = 1, 20 do
            local cand = self:getRandomPos()
            local ok = true
            for _, p in ipairs(pts) do
                if (cand - p).Magnitude < DONATE_MIN_DISTANCE then
                    ok = false
                    break
                end
            end
            if ok then
                chosen = cand
                break
            end
        end
        pts[i] = chosen or self:getRandomPos()
    end
    return pts
end

function TextData:internalUpdateText(val)
    local d = self:GetRealValue(val)
    if self.Space then
        self.TextUI.Text = self.Prefix .. " " .. d .. " " .. self.Suffix
    else
        self.TextUI.Text = self.Prefix .. d .. self.Suffix
    end
end

function TextData:bounceHolder()
    if not self.Holder then
        return
    end
    local us = Framework.BuiltInClient.UI:CheckUIScale(self.Holder)
    if self.plsDonateSound then
        game.SoundService:PlayLocalSound(self.plsDonateSound)
    end
    Framework.BuiltInShared.Tween:InstantTween(us, { Time = DONATE_BOUNCE_TIME }, { Scale = 1.2 })
    task.delay(DONATE_BOUNCE_TIME, function()
        Framework.BuiltInShared.Tween:InstantTween(us, { Time = DONATE_BOUNCE_TIME }, { Scale = 1 })
    end)
end

function TextData:UpdatePlusText(val)
    local UIScale = Framework.BuiltInClient.UI:CheckUIScale(self.PlusText)

    self._plusAccum = self._plusAccum + val

    if self.PlusText.Visible == false then
        self.PlusText.Visible = true
        Framework.BuiltInShared.Tween:InstantTween(UIScale, { Time = 0.1 }, { Scale = 1 })
    end

    self.PlusText.Text = "+" .. self._plusAccum
    local curenttick = tick()
    self.LastPlusUpdate = curenttick

    task.spawn(function()
        task.wait(1)
        if self.LastPlusUpdate == curenttick then
            Framework.BuiltInShared.Tween:InstantTween(UIScale, { Time = 0.1 }, { Scale = 0 })
            task.delay(0.1, function()
                self.PlusText.Visible = false
                self._plusAccum = 0
            end)
        end
    end)
end

function TextData:spawnDonateIcon(startVec, rewardCB)
    if not self.Icon or not self.HUD then
        return
    end
    local clone = self.Icon:Clone()
    clone.Name = "DonateIcon"
    clone.ZIndex = self.Icon.ZIndex + 1
    clone.Parent = self.HUD
    clone.Size = DONATE_SIZEICON
    clone.Position = UDim2.new(startVec.X, 0, startVec.Y, 0)

    local UIScale = Framework.BuiltInClient.UI:CheckUIScale(clone)
    UIScale.Scale = 0

    Framework.BuiltInShared.Tween:InstantTween(UIScale, { Time = DONATE_APPEAR_TIME }, { Scale = 1 })

    local p0 = startVec
    local p2 = Vector2.new(self.AnimationTarget.X.Scale, self.AnimationTarget.Y.Scale)
    local mid = (p0 + p2) * 0.5
        + Vector2.new(
            Framework.BuiltInShared.Randoms:RandomDecimals(-0.2, 0.2),
            Framework.BuiltInShared.Randoms:RandomDecimals(-0.2, 0.2)
        )
    mid = Vector2.new(math.clamp(mid.X, 0.05, 0.95), math.clamp(mid.Y, 0.05, 0.95))

    local dist = (p2 - p0).Magnitude
    local dur = dist / DONATE_MOVE_SPEED

    task.spawn(function()
        local elapsed = 0
        while elapsed < dur and clone.Parent do
            local dt = task.wait()
            elapsed = elapsed + dt
            local t = math.clamp(elapsed / dur, 0, 1)
            local pos2 = QuadBezier2D(p0, mid, p2, t)
            clone.Position = UDim2.new(pos2.X, 0, pos2.Y, 0)
        end
        if clone.Parent then
            clone:Destroy()
        end
        rewardCB()
    end)
end

function TextData:addToAnimQueue(animType, ...)
    local args = { ... }
    table.insert(self._animQueue, { type = animType, args = args })
    self:processAnimQueue()
end

function TextData:processAnimQueue()
    if self._isAnimating or #self._animQueue == 0 then
        return
    end

    self._isAnimating = true
    local anim = table.remove(self._animQueue, 1)

    if anim.type == "donate" then
        local oldV, newV = unpack(anim.args)
        self:_animateDonate(oldV, newV, function()
            self._isAnimating = false
            self:processAnimQueue()
        end)
    elseif anim.type == "pop" then
        self:_popAnimate(function()
            self._isAnimating = false
            self:processAnimQueue()
        end)
    end
end

function TextData:_animateDonate(oldV, newV, callback)
    local gain = newV - oldV
    if gain <= 0 then
        callback()
        return
    end

    local disp = oldV
    self:internalUpdateText(disp)

    local segs = math.clamp(math.floor(math.sqrt(gain) * 1.6), 1, DONATE_MAX_ICONS)
    local positions = self:genPositions(segs)

    local increments, delays = {}, {}
    for i = 1, segs do
        local cumulNow = math.floor(i * gain / segs)
        local cumulPrev = math.floor((i - 1) * gain / segs)
        increments[i] = cumulNow - cumulPrev
        delays[i] = Framework.BuiltInShared.Randoms:RandomDecimals(DONATE_DELAY_MIN, DONATE_DELAY_MAX) * i
    end

    local total = 0

    for i = 1, segs do
        local inc = increments[i]
        local dly = delays[i]
        local pos = positions[i]

        task.delay(dly, function()
            self:spawnDonateIcon(pos, function()
                disp = disp + inc
                self:UpdatePlusText(inc)
                self:internalUpdateText(disp)
                self:bounceHolder()
                total = total + 1
                if total == segs then
                    callback()
                end
            end)
        end)
    end
end

function TextData:AnimateDonate(oldV, newV)
    self:addToAnimQueue("donate", oldV, newV)
    self._lastValue = newV
end

function TextData:_popAnimate(callback)
    local us = Framework.BuiltInClient.UI:CheckUIScale(self.TextUI)
    Framework.BuiltInShared.Tween:InstantTween(us, { Time = 0.1 }, { Scale = 1.2 })
    task.delay(0.2, function()
        Framework.BuiltInShared.Tween:InstantTween(us, { Time = 0.1 }, { Scale = 1 })
        task.delay(0.1, callback)
    end)
end

--= Methods =--

function TextData:startFakeTick()
    if self._fakeTickThread then
        task.cancel(self._fakeTickThread)
    end

    self._fakeTickThread = task.spawn(function()
        while true do
            self._lastValue = self._lastValue + 1
            self:internalUpdateText(self._lastValue)
            task.wait(1)
        end
    end)
end

function TextData:Update(v)
    local val = tonumber(v) or 0
    self._lastRealValue = val

    if self.TypeDisplay == "Date" and self.FakeDisplay then
        if not self._fakeTickThread then
            self._lastValue = val
            self:startFakeTick()
        end
        return
    end

    if
        self.TypeDisplay == "Number"
        and self.Animation == "plsDonate"
        and self.Icon
        and self._lastValue
        and val > self._lastValue
    then
        local success = pcall(function()
            self:AnimateDonate(self._lastValue, val)
        end)
        if not success then
            self:internalUpdateText(val)
        end
    else
        if self.TextUI:GetAttribute("Animation") == "Pop" then
            self:addToAnimQueue("pop")
        end
        self:internalUpdateText(val)
    end
    self._lastValue = val
end

function TextData:GetRealValue(v)
    if self.TypeDisplay == "Number" then
        if self.Format then
            if self.CompactFormat then
                return FormatNumber.Simple.FormatCompact(v, ".##")
            else
                return FormatNumber.Simple.Format(v)
            end
        end
        return v
    elseif self.TypeDisplay == "Date" then
        return Framework.BuiltInShared.Date:convertToHMS(v)
    end
end

function TextData:PopAnimate()
    self:addToAnimQueue("pop")
end

return TextData
