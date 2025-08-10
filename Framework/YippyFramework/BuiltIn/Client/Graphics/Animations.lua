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

--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local Animations = {
    BuiltIn = true
}
--= Framework API =--
local LoadedAnimations = {}
local NPCAnimations = {}
local LocalPlayer = Players.LocalPlayer

function Animations:findInstanceByPath(startInstance, path, retryInterval)
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


function Animations:CharacterAdded(Player: Player)
    if Player ~= LocalPlayer then
        return
    end

    Animations.AnimationsNetwork = Framework.BuiltInClient.Network.Channel("Animations")

    Animations.AnimationsNetwork:On("DefaultAnimation", function()
        local Humanoid = LocalPlayer.Character:FindFirstChild("Humanoid")
        if not Humanoid then
            return
        end

        Humanoid:ChangeState(Enum.HumanoidStateType.Landed)
    end)

    local PlayerAnimationsFolder = Animations:findInstanceByPath(
        ReplicatedFirst,
        Framework.FrameworkConfig.Settings.Animations.AnimationsPlayerPath
    )
    self:UnloadAnimations()
    if PlayerAnimationsFolder then
        self:LoadAnimations(PlayerAnimationsFolder)
    end
end

--= Methods =--

function Animations:GetAnimator(entity)
    if typeof(entity) == "Instance" then
        if entity:IsA("Player") then
            local character = entity.Character
            return character
                and character:FindFirstChild("Humanoid")
                and character:FindFirstChild("Humanoid"):FindFirstChild("Animator")
        elseif entity:IsA("Model") then
            return entity:FindFirstChild("Humanoid") and entity:FindFirstChild("Humanoid"):FindFirstChild("Animator")
        elseif entity:IsA("Humanoid") then
            return entity:FindFirstChild("Animator")
        elseif entity:IsA("Animator") then
            return entity
        end
    end
    return nil
end

function Animations:LoadAnimations(source)
    local animator = self:GetAnimator(LocalPlayer)
    if not animator then
        return
    end

    local animations = LoadedAnimations

    local function loadAnimation(animation, name)
        if typeof(animation) == "string" or typeof(animation) == "number" then
            animation = Instance.new("Animation")
            animation.AnimationId = if typeof(animation) == "string" and not animation:match("^rbxassetid://")
                then "rbxassetid://" .. animation
                else animation
        end
        if animation:IsA("Animation") then
            animations[name or animation.Name] = animator:LoadAnimation(animation)
        end
    end

    if typeof(source) == "Instance" then
        if source:IsA("Animation") then
            loadAnimation(source)
        elseif source:IsA("Folder") then
            for _, animation in ipairs(source:GetChildren()) do
                loadAnimation(animation)
            end
        end
    elseif typeof(source) == "string" or typeof(source) == "number" then
        loadAnimation(source, typeof(source) == "string" and source:match("[^/]+$"))
    end

    return animations
end

function Animations:LoadAnimationsFor(entity, source)
    local animator = self:GetAnimator(entity)
    if not animator then
        return
    end

    NPCAnimations[entity] = NPCAnimations[entity] or {}
    local animations = NPCAnimations[entity]

    local function loadAnimation(animation, name)
        local animId = animation
        if typeof(animation) == "string" or typeof(animation) == "number" then
            animation = Instance.new("Animation")

            animation.AnimationId = if typeof(animId) == "string" and not animId:match("^rbxassetid://")
                then "rbxassetid://" .. animId
                else animId
        end
        if animation:IsA("Animation") then
            animations[name or animation.Name] = animator:LoadAnimation(animation)
        end
    end

    if typeof(source) == "Instance" then
        if source:IsA("Animation") then
            loadAnimation(source)
        elseif source:IsA("Folder") then
            for _, animation in ipairs(source:GetChildren()) do
                loadAnimation(animation)
            end
        end
    elseif typeof(source) == "string" or typeof(source) == "number" then
        loadAnimation(source, typeof(source) == "string" and source)
    end

    return animations
end

function Animations:UnloadAnimations()
    for _, animation in pairs(LoadedAnimations) do
        animation:Stop()
        animation:Destroy()
    end
    table.clear(LoadedAnimations)
end

function Animations:UnloadAnimationsFor(entity)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    for _, animation in pairs(animations) do
        animation:Stop()
        animation:Destroy()
    end
    NPCAnimations[entity] = nil
end

function Animations:Play(animationName: string, ...)
    local animation = LoadedAnimations[animationName]
    if animation then
        animation:Stop()
        return animation:Play(...)
    end
end

function Animations:PlayFor(entity, animationName: string, ...)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    -- Stop the currently playing animation if it exists
    if animations.CurrentAnimation and animations[animations.CurrentAnimation] then
        animations[animations.CurrentAnimation]:Stop()
    end

    local animation = animations[animationName]
    if animation then
        -- Save the current animation name for tracking
        animations.CurrentAnimation = animationName
        return animation:Play(...)
    end
end

function Animations:StopAll()
    for _, animation in pairs(LoadedAnimations) do
        animation:Stop()
    end
end

function Animations:StopCurrent()
    local animation = LoadedAnimations[LoadedAnimations.CurrentAnimation]
    if animation then
        animation:Stop()
    end
end

function Animations:StopCurrentFor(entity)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    local animation = animations[animations.CurrentAnimation]
    if animation then
        animation:Stop()
    end
end

function Animations:Stop(animationName: string)
    local animation = LoadedAnimations[animationName]
    if animation then
        animation:Stop()
    end
end

function Animations:StopFor(entity, animationName: string)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:Stop()
    end
end

function Animations:Freeze(animationName: string)
    local animation = LoadedAnimations[animationName]
    if animation then
        animation:SetAttribute("OldSpeed", animation.Speed)
        animation:AdjustSpeed(0)
    end
end

function Animations:FreezeFor(entity, animationName: string)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:SetAttribute("OldSpeed", animation.Speed)
        animation:AdjustSpeed(0)
    end
end

function Animations:Unfreeze(animationName: string)
    local animation = LoadedAnimations[animationName]
    if animation then
        animation:AdjustSpeed(animation:GetAttribute("OldSpeed") or 1)
        animation:SetAttribute("OldSpeed", nil)
    end
end

function Animations:UnfreezeFor(entity, animationName: string)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:AdjustSpeed(animation:GetAttribute("OldSpeed") or 1)
        animation:SetAttribute("OldSpeed", nil)
    end
end

function Animations:SetSpeed(animationName: string, speed: number)
    local animation = LoadedAnimations[animationName]
    if animation then
        animation:AdjustSpeed(speed)
    end
end

function Animations:SetSpeedFor(entity, animationName: string, speed: number)
    local animations = NPCAnimations[entity]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:AdjustSpeed(speed)
    end
end

return Animations
