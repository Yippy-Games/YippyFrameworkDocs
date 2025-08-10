local ReplicatedFirst = game:GetService("ReplicatedFirst")
local RunService = game:GetService("RunService")
local Framework = require(ReplicatedFirst.Framework)

return function(registry)
    registry:RegisterHook("BeforeRun", function(context)
        local GroupRole
        local success, _ = pcall(function()
            GroupRole = context.Executor:GetRankInGroup(Framework.FrameworkConfig.Settings.FrameworkSettings.GroupId)
        end)
        if not success then
            return
        end
        if not RunService:IsStudio() and GroupRole < Framework.FrameworkConfig.Settings.Cmdr.CmdrRankRequired then
            return "You don't have permissions to run this command"
        end
    end)
end
