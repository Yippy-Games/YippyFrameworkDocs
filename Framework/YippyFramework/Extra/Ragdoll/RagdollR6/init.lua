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
--= Modules & Config =--
--= Framework =--
local Framework = require(ReplicatedFirst.Framework)
local RagdollR6 = {}
--= Framework API =--
local R6Offsets = {
	Head = {
		Joint = "Neck",
		CFrame = {
			CFrame.new(0, 1, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
			CFrame.new(0, -0.5, 0, 0, -1, 0, 1, 0, -0, 0, 0, 1),
		},
	},
	HumanoidRootPart = {
		Joint = "HumanoidRootPart",
		CFrame = { CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0), CFrame.new(0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0) },
	},
	["Right Arm"] = {
		Joint = "Default",
		CFrame = {
			CFrame.new(1.3, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
			CFrame.new(-0.2, 0.75, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1),
		},
	},
	["Left Arm"] = {
		Joint = "Default",
		CFrame = {
			CFrame.new(-1.3, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
			CFrame.new(0.2, 0.75, 0, -1, 0, 0, 0, -1, 0, 0, 0, 1),
		},
	},
	["Right Leg"] = {
		Joint = "Default",
		CFrame = {
			CFrame.new(0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
	},
	["Left Leg"] = {
		Joint = "Default",
		CFrame = {
			CFrame.new(-0.5, -1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
			CFrame.new(0, 1, 0, 0, 1, -0, -1, 0, 0, 0, 0, 1),
		},
	},
}

function RagdollR6:BuildJoints(char)
	local hrp = char:FindFirstChild("HumanoidRootPart")
	local humanoid = char:FindFirstChild("Humanoid")
	if not humanoid then
		return
	end

	for _, v in pairs(char:GetDescendants()) do
		if
			not v:IsA("BasePart")
			or v:FindFirstAncestorOfClass("Acesssory")
			or v.Name == "Handle"
			or v.Name == "Torso"
			or v.Name == "HumanoidRootPart"
		then
			continue
		end
		if not R6Offsets[v.Name] then
			continue
		end

		local a0: Attachment, a1: Attachment = Instance.new("Attachment"), Instance.new("Attachment")
		local joint = Instance.new("BallSocketConstraint") --// Pas exactement comme lui mais manque d'info

		a0.Name = "RAGDOLL_ATTACHENT"
		a0.Parent = v
		a0.CFrame = R6Offsets[v.Name].CFrame[2]

		a1.Name = "RAGDOLL_ATTACHMENT"
		a1.Parent = hrp
		a1.CFrame = R6Offsets[v.Name].CFrame[1]

		joint.Name = "RAGDOLL_CONSTRAINT"
		joint.Parent = v
		joint.Attachment0 = a0
		joint.Attachment1 = a1

		v.Massless = true
	end
end

function RagdollR6:DestroyJoints(char)
	if not char then
		return
	end
	local HumanoidRootPart = char:FindFirstChild("HumanoidRootPart")
	if not HumanoidRootPart then
		return
	end

	HumanoidRootPart.Massless = false
	for _, v in pairs(char:GetDescendants()) do
		if v.Name == "RAGDOLL_ATTACHMENT" or v.Name == "RAGDOLL_CONSTRAINT" then
			v:Destroy()
		end

		if
			not v:IsA("BasePart")
			or v:FindFirstAncestorOfClass("Accessory")
			or v.Name == "Torso"
			or v.Name == "Head"
		then
			continue
		end
	end
end

function RagdollR6:EnableMotor6D(char, enabled)
	if not char then
		return
	end

	for _, v in pairs(char:GetDescendants()) do
		if v.Name == "Handle" or v.Name == "RootJoint" or v.Name == "Neck" then
			continue
		end
		if v:IsA("Motor6D") then
			v.Enabled = enabled
		end
		if v:IsA("BasePart") then
			v.CollisionGroup = if enabled then "Character" else "RagdollR6"
		end
	end
end

function RagdollR6:BuildCollisionPart(char)
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

function RagdollR6:EnableCollisionParts(Char, enabled)
	if not Char then
		return
	end

	for _, v in pairs(Char:GetChildren()) do
		if v:IsA("BasePart") and v.Name ~= "HumanoidRootPart" then
			v.CanCollide = not enabled
			v.Collide.CanCollide = enabled
		end
	end
end

function RagdollR6:RagdollCharacter(Character)
	if Character:GetAttribute("RagdollR6") then
		return
	end

	if not Character then
		return
	end

	local hum = Character:FindFirstChildOfClass("Humanoid")
	local hrp = Character:FindFirstChild("HumanoidRootPart")
	if not hrp and not hum then
		return
	end

	RagdollR6:EnableMotor6D(Character, false)
	RagdollR6:BuildJoints(Character)
	RagdollR6:EnableCollisionParts(Character, true)
end

function RagdollR6:UnragdollCharacter(char)
	local hum = char:FindFirstChildOfClass("Humanoid")
	local hrp = char:FindFirstChild("HumanoidRootPart")

	if not char then
		return
	end
	if not hum then
		return
	end
	if not hrp then
		return
	end

	RagdollR6:DestroyJoints(char)
	RagdollR6:EnableMotor6D(char, true)
	RagdollR6:EnableCollisionParts(char, false)

	hum.AutoRotate = true
end

return RagdollR6
