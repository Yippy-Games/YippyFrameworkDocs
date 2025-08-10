--[[
__  ___                              ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Modules & Config =--

--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local Animations = {
    BuiltIn = true
}
--= Framework API =--
local PlayerAnimations = {}
local SavedDefaultAnimations = {}
local NPCAnimations = {}

function Animations:CharacterAdded(Player: Player, Character: Model)
    Animations.AnimationsNetwork = Framework.BuiltInServer.Network.Channel("Animations")
    local PlayerAnimationsFolder = Framework.BuiltInShared.Part:findInstanceByPath(
        ReplicatedFirst,
        Framework.FrameworkConfig.Settings.Animations.AnimationsPlayerPath
    )
    self:ListenAnimateChange(Player, Character)

    self:UnloadAnimations(Player)
    if PlayerAnimationsFolder then
        self:LoadAnimations(Player, PlayerAnimationsFolder)
    end
end

--= Methods =--

function Animations:ListenAnimateChange(Player: Player, Character: Model)
    local Animate = Character:FindFirstChild("Animate")
    if not Animate then
        return
    end

    local Humanoid = Character:FindFirstChild("Humanoid")
    if not Humanoid then
        return
    end

    spawn(function()
        for _, v in pairs(Animate:GetChildren()) do
            for _, anim in pairs(v:GetChildren()) do
                if anim:IsA("Animation") then
                    spawn(function()
                        anim:GetPropertyChangedSignal("AnimationId"):Connect(function()
                            Animations.AnimationsNetwork:Fire("DefaultAnimation", Player)
                        end)
                    end)
                end
            end
        end
    end)
end

function Animations:GetAnimator(entity: Instance)
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

function Animations:ChangeDefaultAnimation(entity: Instance, Type: string, source: any)
    local animator = self:GetAnimator(entity)
    if not animator then
        return
    end

    local function getanimationId(src: any)
        if typeof(src) == "string" or typeof(src) == "number" then
            return if typeof(src) == "string" and not src:match("^rbxassetid://") then "rbxassetid://" .. src else src
        end
        return src.AnimationId
    end

    if entity:IsA("Player") then
        entity = entity.Character
    end
    local animationId = getanimationId(source)
    if not animationId then
        return
    end
    local Animate = entity:FindFirstChild("Animate")
    if not Animate then
        return
    end

    if not SavedDefaultAnimations[entity] then
        SavedDefaultAnimations[entity] = {}
    end

    if Type == "Walk" then
        SavedDefaultAnimations[entity].Walk = {
            ["Reference"] = Animate.walk.WalkAnim,
            ["AnimationId"] = Animate.walk.WalkAnim.AnimationId,
        }
        Animate.walk.WalkAnim.AnimationId = animationId
    elseif Type == "Run" then
        SavedDefaultAnimations[entity].Run = {
            ["Reference"] = Animate.run.RunAnim,
            ["AnimationId"] = Animate.run.RunAnim.AnimationId,
        }
        Animate.run.RunAnim.AnimationId = animationId
    elseif Type == "Idle" then
        SavedDefaultAnimations[entity].Idle = {
            ["Reference"] = Animate.idle.Animation1,
            ["AnimationId"] = Animate.idle.Animation1.AnimationId,
        }
        Animate.idle.Animation1.AnimationId = animationId
        Animate.idle.Animation2.AnimationId = animationId
    elseif Type == "Fall" then
        SavedDefaultAnimations[entity].Fall = {
            ["Reference"] = Animate.fall.FallAnim,
            ["AnimationId"] = Animate.fall.FallAnim.AnimationId,
        }
        Animate.fall.FallAnim.AnimationId = animationId
    elseif Type == "Jump" then
        SavedDefaultAnimations[entity].Jump = {
            ["Reference"] = Animate.jump.JumpAnim,
            ["AnimationId"] = Animate.jump.JumpAnim.AnimationId,
        }
        Animate.jump.JumpAnim.AnimationId = animationId
    elseif Type == "Swim" then
        SavedDefaultAnimations[entity].Swim = {
            ["Reference"] = Animate.swim.Swim,
            ["AnimationId"] = Animate.swim.Swim.AnimationId,
        }
        Animate.swim.Swim.AnimationId = animationId
    elseif Type == "SwimIdle" then
        SavedDefaultAnimations[entity].SwimIdle = {
            ["Reference"] = Animate.swimidle.SwimIdle,
            ["AnimationId"] = Animate.swimidle.SwimIdle.AnimationId,
        }
        Animate.swimidle.SwimIdle.AnimationId = animationId
    elseif Type == "Climb" then
        SavedDefaultAnimations[entity].Climb = {
            ["Reference"] = Animate.climb.ClimbAnim,
            ["AnimationId"] = Animate.climb.ClimbAnim.AnimationId,
        }
        Animate.climb.ClimbAnim.AnimationId = animationId
    elseif Type == "Sit" then
        SavedDefaultAnimations[entity].Sit = {
            ["Reference"] = Animate.sit.SitAnim,
            ["AnimationId"] = Animate.sit.SitAnim.AnimationId,
        }
        Animate.sit.SitAnim.AnimationId = animationId
    end
end

function Animations:RevertDefaultAnimation(entity: Instance, type: string?)
    local Player = Players:GetPlayerFromCharacter(entity)
    if not Player and not entity:IsA("Player") then
        return
    end

    local Character = if entity:IsA("Player") then entity.Character else entity
    local Animate = Character:FindFirstChild("Animate")
    if not Animate then
        return
    end

    if not SavedDefaultAnimations[entity] then
        return
    end

    for _, anim in pairs(SavedDefaultAnimations[entity]) do
        if type then
            if anim:match(type) then
                anim.Reference.AnimationId = anim.AnimationId
            end
        else
            anim.Reference.AnimationId = anim.AnimationId
        end
    end
end

function Animations:LoadAnimations(entity: Instance, source: Instance)
    local animator = self:GetAnimator(entity)
    if not animator then
        return
    end

    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId] or {}

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
        loadAnimation(source, typeof(source) == "string" and source:match("[^/]+$"))
    end

    PlayerAnimations[playerId] = animations
    return animations
end

function Animations:UnloadAnimations(entity: Instance)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    for _, animation in pairs(animations) do
        animation:Stop()
        animation:Destroy()
    end

    PlayerAnimations[playerId] = nil
end

function Animations:Play(entity, animationName: string, ...)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        animations = self:LoadAnimations(entity)
        if not animations then
            return
        end
    end

    local animation = animations[animationName]
    if animation then
        animation:Stop()
        return animation:Play(...)
    end
end

function Animations:StopAll(entity)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    for _, animation in pairs(animations) do
        animation:Stop()
    end
end

function Animations:StopCurrent(entity)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    animations[animations.CurrentAnimation]:Stop()
end

function Animations:Stop(entity, animationName: string)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:Stop()
    end
end

function Animations:Freeze(entity, animationName: string)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    local animation = animations[animationName]

    if animation then
        animation:SetAttribute("OldSpeed", animation.Speed)
        animation:AdjustSpeed(0)
    end
end

function Animations:Unfreeze(entity, animationName: string)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    local animation = animations[animationName]

    if animation then
        animation:AdjustSpeed(animation:GetAttribute("OldSpeed") or 1)
        animation:SetAttribute("OldSpeed", nil)
    end
end

function Animations:SetSpeed(entity, animationName: string, speed: number)
    local playerId = if typeof(entity) == "Instance" and entity:IsA("Player") then entity.UserId else tostring(entity)
    local animations = PlayerAnimations[playerId]
    if not animations then
        return
    end

    local animation = animations[animationName]
    if animation then
        animation:AdjustSpeed(speed)
    end
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

return Animations
