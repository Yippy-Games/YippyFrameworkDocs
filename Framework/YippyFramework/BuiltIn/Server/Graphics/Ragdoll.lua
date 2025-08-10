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
local R6Ragdoll = require(ReplicatedFirst.Framework.Extra.Ragdoll.RagdollR6)
local R15Ragdoll = require(ReplicatedFirst.Framework.Extra.Ragdoll.RagdollR15)
--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local Ragdoll = {
    BuiltIn = true
}
local RagdollTimers = {}
local CharacterVelocity = {}
--= Framework API =--

function Ragdoll:Start()
    Ragdoll.RagdollNetwork = Framework.BuiltInServer.Network.Channel("Ragdoll")
    R15Ragdoll.InitCollisions()
end

--= Methods =--

function Ragdoll:CharacterAdded(_, Character)
    local humanoid = Character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        R15Ragdoll.setupRagdoll(Character)
    end
    Ragdoll:SetupHumanoid(humanoid)
    Ragdoll:BuildCollisionPart(Character)

    local Velocity = Instance.new("LinearVelocity")
    Velocity.ForceLimitsEnabled = true
    Velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    Velocity.Attachment0 = Character.HumanoidRootPart:FindFirstChild("RootAttachment")
    Velocity.MaxForce = 0
    Velocity.Enabled = false
    Velocity.Parent = Character.HumanoidRootPart
    CharacterVelocity[Character] = Velocity

    if not Framework.FrameworkConfig.Settings.Ragdoll.RagdollOnDeath then
        return
    end

    local connection = nil
    connection = Character.Humanoid.Died:Connect(function()
        Character.Humanoid.AutoRotate = false
        Character.Humanoid.PlatformStand = true
        Ragdoll:RagdollCharacter(Character)
        connection:Disconnect()
    end)
end

function Ragdoll:SetupHumanoid(hum)
    if not hum then
        return
    end
    hum.BreakJointsOnDeath = false
    hum.RequiresNeck = false
end

function Ragdoll:BuildCollisionPart(char)
    if not char then
        return
    end
    for _, v in pairs(char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            local p = v:Clone()
            p.Parent = v
            p.CanCollide = false
            p.Massless = true
            p.Size = Vector3.one
            p.Name = "Collide"
            p.Transparency = 1
            p:ClearAllChildren()

            local weld = Instance.new("Weld")
            weld.Parent = p
            weld.Part0 = v
            weld.Part1 = p
        end
    end
end

function Ragdoll:EnableCollisionParts(Char, enabled)
    if not Char then
        return
    end

    for _, v in pairs(Char:GetChildren()) do
        if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
            v.CanCollide = not enabled
            if v:FindFirstChild("Collide") then
                v.Collide.CanCollide = enabled
            end
        end
    end
end

function Ragdoll:BuildNPCRagdoll(Character: Model)
    if not Character then
        return
    end

    local humanoid = Character:FindFirstChild("Humanoid")
    if not humanoid then
        return
    end

    if humanoid.RigType == Enum.HumanoidRigType.R15 then
        R15Ragdoll.setupRagdoll(Character)
    end
    Ragdoll:SetupHumanoid(humanoid)
    Ragdoll:BuildCollisionPart(Character)

    local Velocity = Instance.new("LinearVelocity")
    Velocity.ForceLimitsEnabled = true
    Velocity.RelativeTo = Enum.ActuatorRelativeTo.World
    Velocity.Attachment0 = Character.HumanoidRootPart:FindFirstChild("RootAttachment")
    Velocity.MaxForce = 0
    Velocity.Enabled = false
    Velocity.Parent = Character.HumanoidRootPart
    CharacterVelocity[Character] = Velocity
end

function Ragdoll:RagdollCharacter(Character: Model, Options: table)
    if Character:GetAttribute("Ragdoll") then
        return
    end
    local options = Options or {}

    if not Character then
        return
    end

    local plr = Players:GetPlayerFromCharacter(Character)
    local hum = Character:FindFirstChildOfClass("Humanoid")
    local hrp = Character:FindFirstChild("HumanoidRootPart")
    if not hrp and not hum then
        return
    end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        Ragdoll:EnableCollisionParts(Character, true)
        R15Ragdoll.ragdoll(Character)
    else
        R6Ragdoll:RagdollCharacter(Character)
    end

    if not plr then
        return
    end
    if plr then
        Ragdoll.RagdollNetwork:Fire("Ragdoll", plr, true)
        hum.AutoRotate = false
    else
        hrp:SetNetworkOwner(nil)
        hum.AutoRotate = false
        hum.PlatformStand = true
    end

    if options.Velocity then
        CharacterVelocity[Character].MaxForce = math.huge
        CharacterVelocity[Character].VectorVelocity = options.Velocity
        CharacterVelocity[Character].Enabled = true
        task.delay(0.1, function()
            CharacterVelocity[Character].MaxForce = 0
            CharacterVelocity[Character].Enabled = false
        end)
    end

    if not options.Duration then
        return
    end
    if RagdollTimers[Character] then
        coroutine.close(RagdollTimers[Character])
    end
    RagdollTimers[Character] = coroutine.create(function()
        task.wait(options.Duration)
        Ragdoll:UnragdollCharacter(Character)
    end)
    coroutine.resume(RagdollTimers[Character])
end

function Ragdoll:UnragdollCharacter(Character: Model)
    local plr = Players:GetPlayerFromCharacter(Character)
    local hum = Character:FindFirstChildOfClass("Humanoid")
    local hrp = Character:FindFirstChild("HumanoidRootPart")

    if not Character then
        return
    end
    if not hum then
        return
    end
    if not hrp then
        return
    end

    if not plr then
        return
    end
    if plr then
        Ragdoll.RagdollNetwork:Fire("Ragdoll", plr, false)
    else
        hrp:SetNetworkOwner(nil)
        if hum:GetState() == Enum.HumanoidStateType.Dead then
            return
        end
        hum.PlatformStand = true
        hum:SetStateEnabled(Enum.HumanoidStateType.FallingDown, false)
        hum:ChangeState(Enum.HumanoidStateType.GettingUp)
    end

    if hum.RigType == Enum.HumanoidRigType.R15 then
        Ragdoll:EnableCollisionParts(Character, false)
        R15Ragdoll.unragdoll(Character)
    else
        R6Ragdoll:UnragdollCharacter(Character)
    end

    hum.AutoRotate = true
end

return Ragdoll
