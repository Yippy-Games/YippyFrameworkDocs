--[[
    Author: Rask/AfraiEda
    Creation Date: 15/11/2022
--]]

--= Root =--
local Tween = {
    BuiltIn = true
}
local TweenService = game:GetService("TweenService")

local function tweenModelCFrame(model: Model, targetCFrame: CFrame, tweenInfo: TweenInfo): Tween?
    if not model or not model.PrimaryPart then
        return
    end

    local cframeValue = Instance.new("CFrameValue")
    cframeValue.Value = model:GetPivot()

    cframeValue:GetPropertyChangedSignal("Value"):Connect(function()
        if model then
            model:PivotTo(cframeValue.Value)
        end
    end)

    local tween = TweenService:Create(cframeValue, tweenInfo, { Value = targetCFrame })
    tween:Play()

    tween.Completed:Connect(function()
        cframeValue:Destroy()
    end)

    return tween
end

local function tweenModelPosition(model: Model, targetPosition: Vector3, tweenInfo: TweenInfo): Tween?
    if not model or not model.PrimaryPart then
        return
    end

    local vector3Value = Instance.new("Vector3Value")
    vector3Value.Value = model.PrimaryPart.Position

    vector3Value:GetPropertyChangedSignal("Value"):Connect(function()
        if model and model.PrimaryPart then
            local currentOrientation = model.PrimaryPart.CFrame - model.PrimaryPart.Position
            local newCFrame = CFrame.new(vector3Value.Value) * currentOrientation
            model:PivotTo(newCFrame)
        end
    end)

    local tween = TweenService:Create(vector3Value, tweenInfo, { Value = targetPosition })
    tween:Play()

    tween.Completed:Connect(function()
        vector3Value:Destroy()
    end)

    return tween
end

local function tweenModelSize(model: Model, targetSize: number, tweenInfo: TweenInfo): Tween?
    if not model or not model.PrimaryPart then
        return
    end

    local numvalue = Instance.new("NumberValue")
    numvalue.Value = model:GetScale()

    numvalue:GetPropertyChangedSignal("Value"):Connect(function()
        if model and model.PrimaryPart then
            if numvalue.Value <= 0 then
                return
            end
            model:ScaleTo(numvalue.Value)
        end
    end)

    local tween = TweenService:Create(numvalue, tweenInfo, { Value = targetSize })
    tween:Play()

    tween.Completed:Connect(function()
        numvalue:Destroy()
    end)

    return tween
end

function Tween:InstantTweenGradient(gradient: UIGradient, info: TweenInfo, opt: table): Tween?
    -- normalize the info table into a TweenInfo
    info = info or {}
    local time = info.Time or 1
    local style = info.Style or Enum.EasingStyle.Linear
    local direction = info.Direction or Enum.EasingDirection.InOut
    local repeatCount = info.Repeat or 0
    local reverse = info.Reverse or false
    local delay = info.Delay or 0
    local tweenInfo = TweenInfo.new(time, style, direction, repeatCount, reverse, delay)

    -- make sure there is something to tween
    if not opt.Color and not opt.Transparency then
        warn("InstantTweenGradient: must provide opt.Color (ColorSequence) or opt.Transparency (NumberSequence)")
        return nil
    end

    -- cache the original sequences
    local startColorSeq = gradient.Color
    local startTransparencySeq = gradient.Transparency

    -- a hidden alpha value we’ll tween from 0→1
    local alpha = Instance.new("NumberValue")
    alpha.Value = 0

    -- rebuild gradient each time alpha changes
    alpha:GetPropertyChangedSignal("Value"):Connect(function()
        local t = alpha.Value

        if opt.Color then
            -- assume both ColorSequences have the same number/times of keypoints (or else we re-use last)
            local endCS = opt.Color
            local newKeys = {}
            for i, kp in ipairs(startColorSeq.Keypoints) do
                local endKP = endCS.Keypoints[i] or endCS.Keypoints[#endCS.Keypoints]
                local c = kp.Value:Lerp(endKP.Value, t)
                newKeys[#newKeys + 1] = ColorSequenceKeypoint.new(kp.Time, c)
            end
            gradient.Color = ColorSequence.new(newKeys)
        end

        if opt.Transparency then
            local endNS = opt.Transparency
            local newKeys = {}
            for i, kp in ipairs(startTransparencySeq.Keypoints) do
                local endKP = endNS.Keypoints[i] or endNS.Keypoints[#endNS.Keypoints]
                local v = kp.Value + (endKP.Value - kp.Value) * t
                newKeys[#newKeys + 1] = NumberSequenceKeypoint.new(kp.Time, v)
            end
            gradient.Transparency = NumberSequence.new(newKeys)
        end
    end)

    -- fire off the tween
    local tween = TweenService:Create(alpha, tweenInfo, { Value = 1 })
    tween:Play()
    tween.Completed:Connect(function()
        alpha:Destroy()
    end)

    return tween
end

function Tween:InstantTweenModelScale(model: Model, info: TweenInfo, opt: table): Tween?
    opt = opt or {}
    info = info or {}
    info.Time = info.Time or 1
    info.Style = info.Style or Enum.EasingStyle.Linear
    info.Direction = info.Direction or Enum.EasingDirection.InOut
    info.Repeat = info.Repeat or 0
    info.Delay = info.Delay or 0
    info.Reverse = info.Reverse or false

    local tweenInfo = TweenInfo.new(info.Time, info.Style, info.Direction, info.Repeat, info.Reverse, info.Delay)

    if opt.Scale then
        return tweenModelSize(model, opt.Scale, tweenInfo)
    else
        warn("InstantModelTween: No Scale provided in options.")
        return nil
    end
end

-- Modified InstantModelTween function to handle both CFrame and Position
function Tween:InstantModelTween(model: Model, info: TweenInfo, opt: table): Tween?
    opt = opt or {}
    info = info or {}
    info.Time = info.Time or 1
    info.Style = info.Style or Enum.EasingStyle.Linear
    info.Direction = info.Direction or Enum.EasingDirection.InOut
    info.Repeat = info.Repeat or 0
    info.Delay = info.Delay or 0
    info.Reverse = info.Reverse or false

    local tweenInfo = TweenInfo.new(info.Time, info.Style, info.Direction, info.Repeat, info.Reverse, info.Delay)

    if opt.CFrame then
        return tweenModelCFrame(model, opt.CFrame, tweenInfo)
    elseif opt.Position then
        return tweenModelPosition(model, opt.Position, tweenInfo)
    else
        warn("InstantModelTween: No CFrame or Position provided in options.")
        return nil
    end
end

function Tween:InstantTween(Part: Instance, info: TweenInfo, opt: table): Tween
    opt = opt or {}
    info = info or {}
    info.Time = info.Time or 1
    info.Style = info.Style or Enum.EasingStyle.Linear
    info.Direction = info.Direction or Enum.EasingDirection.InOut
    info.Repeat = info.Repeat or 0
    info.Delay = info.Delay or 0
    info.Reverse = info.Reverse or false

    local TweenInfos = TweenInfo.new(info.Time, info.Style, info.Direction, info.Repeat, info.Reverse, info.Delay)
    local Ts = TweenService:Create(Part, TweenInfos, opt)
    Ts:Play()
    return Ts
end

return Tween
