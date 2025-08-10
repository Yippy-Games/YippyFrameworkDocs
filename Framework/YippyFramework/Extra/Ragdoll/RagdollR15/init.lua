local ReplicatedFirst = game:GetService("ReplicatedFirst")
local PhysicsService = game:GetService("PhysicsService")

local AssetsFramework = ReplicatedFirst.FrameworkAssets
local constraints = AssetsFramework.Ragdoll:WaitForChild("Constraints") :: Folder
local ncConstraints = constraints:WaitForChild("NoCollisionConstraints") :: Folder
local mechanicalConstraints = constraints:WaitForChild("MechanicalConstraints") :: Folder

local module = {
	BallSocketFriction = 30,
}

local collisionGroupMap = {}
local collisionGroup = "Ragdoll"

function module.InitCollisions()
	PhysicsService:RegisterCollisionGroup(collisionGroup)
	PhysicsService:CollisionGroupSetCollidable(collisionGroup, collisionGroup, false)
end

function module.setupRagdoll(rig: Model)
	local hum = rig:FindFirstChild("Humanoid") :: Humanoid
	hum.BreakJointsOnDeath = false
	hum.RequiresNeck = false

	local folder = rig:FindFirstChild("RagdollConstraints") or Instance.new("Folder")
	folder.Name = "RagdollConstraints"
	folder:ClearAllChildren()

	-- Set-up the NoCollisionConstraints
	local nccs = ncConstraints:Clone()
	for _, v in nccs:GetChildren() do
		v.Part0 = rig:WaitForChild(v:GetAttribute("Part0"))
		v.Part1 = rig:WaitForChild(v:GetAttribute("Part1"))
	end

	-- Set-up the Hinge/BallSocket Constraints
	local mechanicalConstraints = mechanicalConstraints:Clone()
	for _, v in mechanicalConstraints:GetChildren() do
		v.Attachment0 = rig:WaitForChild(v:GetAttribute("Attachment0Parent")):WaitForChild(v:GetAttribute("Attachment"))
		v.Attachment1 = rig:WaitForChild(v:GetAttribute("Attachment1Parent")):WaitForChild(v:GetAttribute("Attachment"))
		if v:IsA("BallSocketConstraint") then
			v.MaxFrictionTorque = module.BallSocketFriction
		end
	end

	-- Mark the toggleable Motor6Ds
	local motors = Instance.new("Folder")
	motors.Name = "Motor6Ds"
	for _, v in rig:GetDescendants() do
		if v:IsA("Motor6D") and not v.Name:find("Root") then
			local val = Instance.new("ObjectValue")
			val.Name = v.Name
			val.Value = v
			val.Parent = motors
		end
	end

	rig.Destroying:Once(function()
		collisionGroupMap[rig] = nil
	end)

	mechanicalConstraints.Parent = folder
	motors.Parent = folder
	nccs.Parent = folder
	folder.Parent = rig
end

function module.ragdoll(rig: Model)
	local hrp = rig.HumanoidRootPart
	hrp.CanCollide = false
	hrp.Massless = true
	rig.Humanoid:ChangeState(Enum.HumanoidStateType.Physics)

	for _, child in ipairs(rig.RagdollConstraints.Motor6Ds:GetChildren()) do
		local motor = child:IsA("ObjectValue") and child.Value or child
		if motor and motor:IsA("Motor6D") then
			motor.Enabled = false
		end
	end
	collisionGroupMap[rig] = hrp.CollisionGroup
	for _, v: BasePart in rig:GetDescendants() do
		if v:IsA("BasePart") then
			v.CollisionGroup = "Ragdoll"
		end
	end
end

function module.unragdoll(rig: Model)
	local hrp = rig.HumanoidRootPart
	hrp.CanCollide = true
	hrp.Massless = false
	rig.Humanoid:ChangeState(Enum.HumanoidStateType.GettingUp)

	for _, child in ipairs(rig.RagdollConstraints.Motor6Ds:GetChildren()) do
		local motor = child:IsA("ObjectValue") and child.Value or child
		if motor and motor:IsA("Motor6D") then
			motor.Enabled = true
		end
	end
	
	local collisionGroup = collisionGroupMap[rig]
	if collisionGroup then
		for _, v: BasePart in rig:GetDescendants() do
			if v:IsA("BasePart") then
				v.CollisionGroup = collisionGroup
			end
		end
		collisionGroupMap[rig] = nil
	end
end

return module
