local Part = {
    BuiltIn = true
}

local TweenUtils = require(script.Parent.Tween)

function Part:anchor(model: Model): nil
    for _, part in ipairs(Part.getDescendantsOfClass(model, "BasePart")) do
        part.Anchored = true
    end
end

function Part:SetCanCollide(Model: Model, CanCollide: boolean)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CanCollide = CanCollide
        end
    end
end

function Part:SetTool(Model: Model, bool: boolean)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.Anchored = bool
            v.Massless = not bool
        end
    end
end

function Part:SetTransparency(Model: Model, Transparency: number)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            v:SetAttribute("OldTransparency", v.Transparency)
            v.Transparency = Transparency
        elseif v:IsA("Beam") or v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("BillboardGui") then
            v:SetAttribute("OldEnabled", v.Enabled)
            v.Enabled = false
        end
    end
end

function Part:ResetTransparency(Model: Model)
    for _, v in pairs(Model:GetDescendants()) do
        if (v:IsA("BasePart") or v:IsA("Decal")) and v:GetAttribute("OldTransparency") then
            v.Transparency = v:GetAttribute("OldTransparency")
        elseif
            (v:IsA("Beam") or v:IsA("ParticleEmitter") or v:IsA("PointLight") or v:IsA("BillboardGui"))
            and v:GetAttribute("OldEnabled")
        then
            v.Enabled = v:GetAttribute("OldEnabled")
        end
    end
end

function Part:getMassModel(model)
    assert(model and model:IsA("Model"), "Model argument of getMass must be a model.")
    local mass = 0
    for _, v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            mass += v.AssemblyMass
        end
    end
    return mass
end

function Part:SetCollisionGroup(Model: Model, Group: string)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") then
            v.CollisionGroup = Group
        end
    end
end

function Part:HideModel(Model: Model)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            if v.Transparency < 1 then
                v:SetAttribute("OldTransparency", v.Transparency)
                v.Transparency = 1
            else
                v:SetAttribute("OldTransparency", 1) -- Keep track of already fully transparent parts
            end
        elseif v:IsA("ParticleEmitter") or v:IsA("Beam") then
            v:SetAttribute("OldEnabled", v.Enabled)
            v.Enabled = false
        end
    end
end

function Part:ShowModel(Model: Model)
    if Model == nil then
        return
    end

    for _, v in pairs(Model:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") or v:IsA("Texture") then
            local oldTransparency = v:GetAttribute("OldTransparency")
            if oldTransparency ~= nil then
                v.Transparency = oldTransparency
            end
        elseif v:IsA("ParticleEmitter") or v:IsA("Beam") then
            local oldEnabled = v:GetAttribute("OldEnabled")
            if oldEnabled ~= nil then
                v.Enabled = oldEnabled
            end
        end
    end
end

function Part:TweenTransparencyModel(mod, transparency, times)
    if mod == nil then
        return
    end

    for _, v in pairs(mod:GetDescendants()) do
        if v.Name == "HumanoidRootPart" then
            continue
        end
        if v:IsA("BasePart") or v:IsA("Decal") then
            TweenUtils:InstantTween(v, { Time = times, Style = Enum.EasingStyle.Quad }, { Transparency = transparency })
        end
    end
end

function Part:FindRandomPositionInPart(Part: Part)
    if Part == nil then
        return
    end

    local Size = Part.Size
    local Position = Part.Position
    local X = math.random(-Size.X / 2, Size.X / 2)
    local Z = math.random(-Size.Z / 2, Size.Z / 2)

    return Vector3.new(Position.X + X, Position.Y, Position.Z + Z)
end

function Part:LocalTranspenracyModel(mod, transparency)
    if mod == nil then
        return
    end

    for _, v in pairs(mod:GetDescendants()) do
        if v:IsA("BasePart") or v:IsA("Decal") then
            TweenUtils:InstantTween(
                v,
                { Time = 0.2, Style = Enum.EasingStyle.Quad },
                { LocalTransparencyModifier = transparency }
            )
        end
    end
end

function Part:findInstanceByNameInChild(parent: Instance, name: string)
    if parent.Name == name then
        return parent
    end
    for _, child in ipairs(parent:GetChildren()) do
        local foundInstance = Part:findInstanceByNameInChild(child, name)
        if foundInstance then
            return foundInstance
        end
    end
    return nil
end

function Part:findInstanceByPath(startInstance, path, retryInterval)
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

function Part:GetPathByInstance(Start: Instance, End: Instance)
    if Start == nil or End == nil then
        return
    end
    local Path = ""
    local Current = End
    repeat
        if Current == Start then
            return Path
        end
        Path = Current.Name .. "/" .. Path
        Current = Current.Parent
    until Current == nil
    return nil
end

function Part:Dist(part, part2)
    if part == nil or part2 == nil then
        return 0
    end

    return (part.Position - part2.Position).Magnitude
end

function Part:SetNetworkModel(model, network)
    if model:IsA("BasePart") then
        if network == "auto" then
            model:SetNetworkOwner()
        else
            model:SetNetworkOwner(network)
        end
    end
    for _, v in pairs(model:GetDescendants()) do
        if v:IsA("BasePart") then
            if network == "auto" then
                v:SetNetworkOwner()
            else
                v:SetNetworkOwner(network)
            end
        end
    end
end

function Part:Exist(model: Model)
    if model == nil then
        return false
    end
    if model.PrimaryPart == nil then
        return false
    end

    return true
end

function Part:UntilExist(model: Model)
    if model == nil then
        return false
    end
    repeat
        task.wait()
    until model.PrimaryPart ~= nil

    return true
end

function Part:unanchor(model: Model): nil
    for _, part in ipairs(model:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Anchored = false
        end
    end
end

function Part.weld(main: BasePart, ...): nil
    local parts = { ... }

    for _, part in ipairs(parts) do
        if part ~= main then
            local weld = Instance.new("WeldConstraint")
            weld.Part0 = main
            weld.Part1 = part
            weld.Parent = part
        end
    end
end

function Part:makeMotor6D(part0: BasePart, part1: BasePart): Motor6D
    local motor6D = Instance.new("Motor6D")
    motor6D.Part0 = part0
    motor6D.Part1 = part1
    motor6D.Parent = part0
    return motor6D
end

function Part:getChildrenOfClass(container: Instance, class: string): { Instance }
    local instances = {}

    for _, instance in ipairs(container:GetChildren()) do
        if instance:IsA(class) then
            table.insert(instances, instance)
        end
    end

    return instances
end

function Part:getDescendantsOfClass(container: Instance, class: string): { Instance }
    local instances = {}

    for _, instance in ipairs(container:GetDescendants()) do
        if instance:IsA(class) then
            table.insert(instances, instance)
        end
    end

    return instances
end

return Part
