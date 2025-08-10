--[[
    Author: Rask/AfraiEda
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Cmdr = {
    BuiltIn = true
}
--= Modules & Config =--
local CmdrPackage = require(ReplicatedFirst.Framework.Extra.Cmdr)
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--
--= Functions =--

function Cmdr:Start()
    if not Framework.FrameworkConfig.Settings.Cmdr.CmdrEnabled then
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("Cmdr is disabled. Check settings.")
        end
        return
    end
    CmdrPackage:RegisterTypesInCustom(Framework.FrameworkConfig.Cmdr.Types)
    CmdrPackage:RegisterCommmandsInCustom(
        Framework.FrameworkConfig.Cmdr.CommandsConfig,
        Framework.FrameworkConfig.Cmdr.CommandsFunctions
    )
    CmdrPackage:RegisterDefaultCommands()
    CmdrPackage:RegisterHooksInCustom(Framework.FrameworkConfig.Cmdr.Hooks)
end

return Cmdr
