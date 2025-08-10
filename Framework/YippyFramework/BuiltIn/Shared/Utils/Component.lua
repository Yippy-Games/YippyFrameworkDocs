local Component = {
    BuiltIn = true
}

--//Services
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--//Modules
local Components = require(ReplicatedFirst.Framework.Extra.Component)

function Component:GetInstanceByTag(Instances: Instance, Tag: string): any
    local Comp = Components.FromTag(Tag)
    if not Comp then
        return
    end
    return Comp:GetFromInstance(Instances)
end

function Component:GetInstanceByTagUntil(Instances: Instance, Tag: string): any
    repeat
        task.wait()
    until Components.FromTag(Tag)
    local Comp = Components.FromTag(Tag)
    if not Comp then
        return
    end
    return Comp:GetFromInstance(Instances)
end

return Component
