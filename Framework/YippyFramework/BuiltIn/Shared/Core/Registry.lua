--[[
__  ___                            ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Registry = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Framework API =--

function Registry:Start()
    Registry.Registries = {}
    local registryFolders = {}

    if ReplicatedFirst.Shared and ReplicatedFirst.Shared:FindFirstChild("Registry") then
        for _, folder in ipairs(ReplicatedFirst.Shared.Registry:GetChildren()) do
            if folder:IsA("Folder") then
                registryFolders[folder.Name] = folder
            end
        end
    else
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("Registry folder not found. Check settings.")
        end
    end

    -- Add Framework DefaultRegistry folders (like DataTypes)
    if ReplicatedFirst.Framework.Configuration:FindFirstChild("DefaultRegistry") then
        for _, folder in ipairs(ReplicatedFirst.Framework.Configuration.DefaultRegistry:GetChildren()) do
            if folder:IsA("Folder") then
                registryFolders[folder.Name] = folder
            end
        end
    end

    if ReplicatedFirst:FindFirstChild("Settings") and ReplicatedFirst.Settings:FindFirstChild("Configuration") then
        if not ReplicatedFirst.Settings.Configuration:FindFirstChild("Products") then
            if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
                Framework:DebugFramework("Registry for products not found. Check settings.")
            end
            return
        end
        if ReplicatedFirst.Settings.Configuration.Products:FindFirstChild("DevProducts") then
            registryFolders["DevProducts"] = ReplicatedFirst.Settings.Configuration.Products.DevProducts
        end
        if ReplicatedFirst.Settings.Configuration.Products:FindFirstChild("Gamepasses") then
            registryFolders["Gamepasses"] = ReplicatedFirst.Settings.Configuration.Products.Gamepasses
        end
    else
        if Framework.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning then
            Framework:DebugFramework("Registry for products not found. Check settings.")
        end
    end

    for registryName, folder in pairs(registryFolders) do
        self:CreateRegistry(registryName, folder)
    end
end

function Registry:CreateRegistry(registryName: string, folder: Instance)
    if not folder or not folder:IsA("Folder") then
        warn("Invalid folder for registry:", registryName)
        return
    end

    local registry = {
        Modules = {},
        Data = {},
    }

    for _, moduleScript in ipairs(folder:GetChildren()) do
        if moduleScript:IsA("ModuleScript") then
            local module = require(moduleScript)
            module.Name = moduleScript.Name

            registry.Modules[module.Name] = module
            registry.Data[module.Name] = {
                Name = module.Name,
                Index = module.Index,
            }
        end
    end

    table.sort(registry.Modules, function(a, b)
        return a.Index < b.Index
    end)

    table.sort(registry.Data, function(a, b)
        return a.Index < b.Index
    end)

    self.Registries[registryName] = registry
end

function Registry:GetModuleByName(registryName: string, moduleName: string)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end
    return registry.Modules[moduleName]
end

function Registry:GetModuleByIndex(registryName: string, index: number)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end

    for _, module in pairs(registry.Modules) do
        if module.Index == index then
            return module
        end
    end
end

function Registry:GetDataByName(registryName: string, dataName: string)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end
    return registry.Data[dataName]
end

function Registry:GetDataByIndex(registryName: string, index: number)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end

    for _, data in pairs(registry.Data) do
        if data.Index == index then
            return data
        end
    end
end

function Registry:GetRegistryModuleList(registryName: string)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end
    return registry.Modules
end

function Registry:GetRegistryDataList(registryName: string)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end
    return registry.Data
end

function Registry:GetModuleByParams(registryName: string, key: string, value: any)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end

    for _, module in pairs(registry.Modules) do
        if module[key] == value then
            return module
        end
    end
end

function Registry:GetDataByParams(registryName: string, key: string, value: any)
    local registry = self.Registries[registryName]
    if not registry then
        return nil
    end

    for _, data in pairs(registry.Data) do
        if data[key] == value then
            return data
        end
    end
end

return Registry
