--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Component = require(ReplicatedFirst.Framework.Extra.Component)

type Middleware = {
    Inbound: ClientMiddleware?,
    Outbound: ClientMiddleware?,
}
type ClientMiddlewareFn = (args: { any }) -> (boolean, ...any)
type ClientMiddleware = { ClientMiddlewareFn }
type PerServiceMiddleware = { [string]: Middleware }
type ControllerDef = {
    Name: string,
    [any]: any,
}
type Controller = {
    Name: string,
    [any]: any,
}
type Service = {
    [any]: any,
}
type FrameworkOptions = {
    ServicePromises: boolean,
    Middleware: Middleware?,
    PerServiceMiddleware: PerServiceMiddleware?,
}
local defaultOptions: FrameworkOptions = {
    ServicePromises = true,
    Middleware = nil,
    PerServiceMiddleware = {},
}
local selectedOptions = nil
local FrameworkClient = {}

FrameworkClient.Player = Players.LocalPlayer
FrameworkClient.Util = (script.Parent.Extra :: Instance).Parent

local Definitions = require(script.Parent.Definitions)
local Promise = require(script.Parent.Extra.Promise)
local Comm = require(script.Parent.Extra.Comm)
local ClientComm = Comm.ClientComm

local controllers: { [string]: Controller } = {}
local services: { [string]: Service } = {}
local servicesFolder = nil

local started = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")

local function DoesControllerExist(controllerName: string): boolean
    local controller: Controller? = controllers[controllerName]
    return controller ~= nil
end

local function GetServicesFolder()
    if not servicesFolder then
        servicesFolder = (ReplicatedStorage :: Instance):WaitForChild("Services")
    end
    return servicesFolder
end

local function GetMiddlewareForService(serviceName: string)
    local FrameworkMiddleware = if selectedOptions.Middleware ~= nil then selectedOptions.Middleware else {}
    local serviceMiddleware = selectedOptions.PerServiceMiddleware[serviceName]
    return if serviceMiddleware ~= nil then serviceMiddleware else FrameworkMiddleware
end

local function BuildService(serviceName: string)
    local folder = GetServicesFolder()
    local middleware = GetMiddlewareForService(serviceName)
    local clientComm = ClientComm.new(folder, selectedOptions.ServicePromises, serviceName)
    local service = clientComm:BuildObject(middleware.Inbound, middleware.Outbound)
    services[serviceName] = service
    return service
end

function FrameworkClient.CreateController(controllerDef: ControllerDef): Controller
    assert(type(controllerDef) == "table", `Controller must be a table; got {type(controllerDef)}`)
    assert(type(controllerDef.Name) == "string", `Controller.Name must be a string; got {type(controllerDef.Name)}`)
    assert(#controllerDef.Name > 0, "Controller.Name must be a non-empty string")
    assert(not DoesControllerExist(controllerDef.Name), `Controller {controllerDef.Name} already exists`)
    local controller = controllerDef :: Controller
    controllers[controller.Name] = controller
    return controller
end

function FrameworkClient.AddControllers(parent: Instance): { Controller }
    local addedControllers = {}
    for _, v in parent:GetChildren() do
        if not v:IsA("ModuleScript") then
            continue
        end
        table.insert(addedControllers, require(v))
    end
    return addedControllers
end

function FrameworkClient.AddControllersDeep(parent: Instance): { Controller }
    local addedControllers = {}
    for _, v in parent:GetDescendants() do
        if not v:IsA("ModuleScript") then
            continue
        end
        table.insert(addedControllers, require(v))
    end
    return addedControllers
end

function FrameworkClient.GetService(serviceName: string): Service
    local service = services[serviceName]
    if service then
        return service
    end
    assert(started, "Cannot call GetService until Framework has been started")
    assert(type(serviceName) == "string", `ServiceName must be a string; got {type(serviceName)}`)
    return BuildService(serviceName)
end

function FrameworkClient.GetController(controllerName: string): Controller
    local controller = controllers[controllerName]
    if controller then
        return controller
    end
    assert(started, "Cannot call GetController until Framework has been started")
    assert(type(controllerName) == "string", `ControllerName must be a string; got {type(controllerName)}`)
    error(`Could not find controller "{controllerName}". Check to verify a controller with this name exists.`, 2)
end

function FrameworkClient:LoadAllConfigurations()
    FrameworkClient.FrameworkConfig = {} :: Definitions.FrameworkConfig

    local function GetPathByInstance(startInstance, targetInstance)
        local pathSegments = {}
        local currentInstance = targetInstance

        while currentInstance ~= nil and currentInstance ~= startInstance do
            table.insert(pathSegments, 1, currentInstance.Name)
            currentInstance = currentInstance.Parent
        end

        if currentInstance == startInstance then
            return table.concat(pathSegments, "/")
        else
            return nil
        end
    end

    local function ShallowMerge(defaultConfig, newConfig)
        if typeof(newConfig) ~= "table" then
            return newConfig
        end
        if typeof(defaultConfig) ~= "table" then
            return newConfig
        end

        for key, value in pairs(newConfig) do
            defaultConfig[key] = value
        end

        return defaultConfig
    end

    local function LoadModularSettings(settingsFolder)
        local modularSettings = {}
        
        if not settingsFolder or not settingsFolder:IsA("Folder") then
            return modularSettings
        end
        
        for _, child in ipairs(settingsFolder:GetChildren()) do
            if child:IsA("ModuleScript") then
                local success, settingsModule = pcall(require, child)
                if success and type(settingsModule) == "table" then
                    local categoryName = child.Name
                    modularSettings[categoryName] = settingsModule
                end
            end
        end
        
        return modularSettings
    end

    local function SelectConfigurations(configFolder, newConfigFolder, isRoot)
        local resultConfig = {}

        local childNames = {}
        for _, child in ipairs(configFolder:GetChildren()) do
            childNames[child.Name] = true
        end
        if newConfigFolder then
            for _, child in ipairs(newConfigFolder:GetChildren()) do
                childNames[child.Name] = true
            end
        end

        for childName, _ in pairs(childNames) do
            local defaultChild = configFolder:FindFirstChild(childName)
            local newChild = newConfigFolder and newConfigFolder:FindFirstChild(childName) or nil

            if isRoot then
                -- Special handling for Settings folder - load modular settings
                if childName == "Settings" then
                    local defaultSettings = defaultChild and defaultChild:IsA("Folder") and LoadModularSettings(defaultChild) or {}
                    local overrideSettings = newChild and newChild:IsA("Folder") and LoadModularSettings(newChild) or {}
                    
                    -- Merge override settings into default settings
                    local finalSettings = defaultSettings
                    for key, value in pairs(overrideSettings) do
                        if type(value) == "table" and type(finalSettings[key]) == "table" then
                            -- Deep merge for category objects
                            finalSettings[key] = ShallowMerge(finalSettings[key], value)
                        else
                            -- Direct override for simple values
                            finalSettings[key] = value
                        end
                    end
                    
                    resultConfig[childName] = finalSettings
                elseif
                    (defaultChild and defaultChild:IsA("ModuleScript")) or (newChild and newChild:IsA("ModuleScript"))
                then
                    local defaultConfig = defaultChild and require(defaultChild) or {}
                    local newConfig = newChild and require(newChild) or {}

                    if defaultConfig and newConfig then
                        resultConfig[childName] = ShallowMerge(defaultConfig, newConfig)
                    elseif newConfig then
                        resultConfig[childName] = newConfig
                    elseif defaultConfig then
                        resultConfig[childName] = defaultConfig
                    end
                elseif (defaultChild and defaultChild:IsA("Folder")) or (newChild and newChild:IsA("Folder")) then
                    local defaultSubFolder = defaultChild and defaultChild:IsA("Folder") and defaultChild
                        or Instance.new("Folder")
                    local newSubFolder = newChild and newChild:IsA("Folder") and newChild or nil

                    resultConfig[childName] = SelectConfigurations(defaultSubFolder, newSubFolder, false)
                end
            else
                if
                    (defaultChild and defaultChild:IsA("ModuleScript")) or (newChild and newChild:IsA("ModuleScript"))
                then
                    local finalChild = newChild or defaultChild
                    local startInstance = finalChild.Parent
                    local path = GetPathByInstance(startInstance, finalChild)

                    resultConfig[childName] = {
                        ["StartInstance"] = startInstance,
                        ["Path"] = path,
                    }
                elseif (defaultChild and defaultChild:IsA("Folder")) or (newChild and newChild:IsA("Folder")) then
                    local defaultSubFolder = defaultChild and defaultChild:IsA("Folder") and defaultChild
                        or Instance.new("Folder")
                    local newSubFolder = newChild and newChild:IsA("Folder") and newChild or nil

                    resultConfig[childName] = SelectConfigurations(defaultSubFolder, newSubFolder, false)
                end
            end
        end

        return resultConfig
    end

    local defaultSettingsFolder = script.Parent.Configuration
    local newSettingsFolder = nil
    if ReplicatedFirst:FindFirstChild("Settings") then
        if ReplicatedFirst.Settings:FindFirstChild("Configuration") then
            newSettingsFolder = ReplicatedFirst.Settings:FindFirstChild("Configuration")
        end
    end
    FrameworkClient.FrameworkConfig = SelectConfigurations(defaultSettingsFolder, newSettingsFolder, true)
end

function FrameworkClient:DebugFramework(Message: string)
    warn(
        string.format(
            "[%s - %s] %s",
            FrameworkClient.FrameworkConfig.Settings.FrameworkSettings.Name,
            FrameworkClient.FrameworkConfig.Settings.FrameworkSettings.Version,
            Message
        )
    )
end

function FrameworkClient:LoadBuiltIn()
    FrameworkClient.BuiltInClient = {} :: Definitions.BuiltInClient
    FrameworkClient.BuiltInShared = {} :: Definitions.BuiltInShared

    if ReplicatedFirst:FindFirstChild("Settings") then
        if
            not (
                ReplicatedFirst.Settings:FindFirstChild("BuiltIn")
                and ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Client")
            ) and FrameworkClient.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning
        then
            FrameworkClient:DebugFramework(
                "No 'BuiltIn/Client' folder found in ReplicatedFirst for Framework. Using default settings."
            )
        end
    end

    local defaultBuiltInClientFolder = script.Parent.BuiltIn.Client
    local defaultBuiltInSharedFolder = script.Parent.BuiltIn.Shared
    local overriddenBuiltInClientFolder = nil
    local overriddenBuiltInSharedFolder = nil

    if ReplicatedFirst:FindFirstChild("Settings") then
        if ReplicatedFirst.Settings:FindFirstChild("BuiltIn") then
            overriddenBuiltInClientFolder = ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Client")
            overriddenBuiltInSharedFolder = ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Shared")
        end
    end

    -- Get the new config-based settings
    local builtInConfig = FrameworkClient.FrameworkConfig.Settings.FrameworkSettings.BuiltIn or {}
    local loadOrder = FrameworkClient.FrameworkConfig.Settings.FrameworkSettings.BuiltInLoadOrder or {}
    local processedModules = {}

    -- Helper function to recursively find all ModuleScripts and collect them with flattened names
    local function collectModules(folder)
        local modules = {}
        local function scan(currentFolder)
            for _, child in pairs(currentFolder:GetChildren()) do
                if child:IsA("ModuleScript") then
                    if not modules[child.Name] then
                        modules[child.Name] = child
                    end
                elseif child:IsA("Folder") then
                    scan(child)
                end
            end
        end
        scan(folder)
        return modules
    end

    -- Helper function to check if a module is enabled in config
    local function isModuleEnabled(moduleName)
        for _, config in ipairs(builtInConfig) do
            if config.Name == moduleName then
                -- If Enabled is not specified, default to true
                return config.Enabled ~= false
            end
        end
        return true -- Default to enabled if not specified
    end

    local function loadModule(moduleName, moduleInstance, overriddenModuleInstance, targetTable)
        if moduleInstance and moduleInstance:IsA("ModuleScript") then
            -- Check if module is enabled in config first (before requiring)
            if not isModuleEnabled(moduleName) then
                return
            end

            -- Require the module once and check BuiltIn flag
            local success, builtInModule = pcall(require, moduleInstance)
            if not success then
                warn(`Failed to require BuiltIn module "{moduleName}": {builtInModule}`)
                return
            end

            -- Check if module has BuiltIn flag
            if type(builtInModule) ~= "table" or builtInModule.BuiltIn ~= true then
                return
            end

            local overriddenModule = nil
            if overriddenModuleInstance and overriddenModuleInstance:IsA("ModuleScript") then
                overriddenModule = require(overriddenModuleInstance)
            end

            targetTable[moduleName] = builtInModule

            coroutine.wrap(function()
                if builtInModule.Start then
                    builtInModule:Start(overriddenModule)
                end
            end)()

            processedModules[moduleName] = true
        end
    end

    -- Collect all available modules from both folders (recursively)
    local clientModules = collectModules(defaultBuiltInClientFolder)
    local sharedModules = collectModules(defaultBuiltInSharedFolder)
    local overriddenClientModules = overriddenBuiltInClientFolder and collectModules(overriddenBuiltInClientFolder) or {}
    local overriddenSharedModules = overriddenBuiltInSharedFolder and collectModules(overriddenBuiltInSharedFolder) or {}

    -- First pass: Load modules in config order (only enabled ones)
    for _, config in ipairs(builtInConfig) do
        local moduleName = config.Name
        local enabled = config.Enabled ~= false -- Default to true if not specified
        if enabled and not processedModules[moduleName] then
            local moduleInstance = clientModules[moduleName]
            local overriddenModuleInstance = overriddenClientModules[moduleName]
            local targetTable = FrameworkClient.BuiltInClient

            if not moduleInstance then
                moduleInstance = sharedModules[moduleName]
                overriddenModuleInstance = overriddenSharedModules[moduleName]
                targetTable = FrameworkClient.BuiltInShared
            end

            if moduleInstance then
                loadModule(moduleName, moduleInstance, overriddenModuleInstance, targetTable)
            end
        end
    end

    -- Legacy support: Load modules from old BuiltInLoadOrder if they exist
    for _, moduleName in ipairs(loadOrder) do
        if not processedModules[moduleName] then
            local moduleInstance = clientModules[moduleName]
            local overriddenModuleInstance = overriddenClientModules[moduleName]
            local targetTable = FrameworkClient.BuiltInClient

            if not moduleInstance then
                moduleInstance = sharedModules[moduleName]
                overriddenModuleInstance = overriddenSharedModules[moduleName]
                targetTable = FrameworkClient.BuiltInShared
            end

            if moduleInstance then
                loadModule(moduleName, moduleInstance, overriddenModuleInstance, targetTable)
            end
        end
    end

    -- Second pass: Load remaining enabled modules alphabetically
    local function loadRemainingModules(modules, overriddenModules, targetTable)
        local moduleNames = {}
        for moduleName in pairs(modules) do
            if not processedModules[moduleName] then
                table.insert(moduleNames, moduleName)
            end
        end
        table.sort(moduleNames) -- Alphabetical order

        for _, moduleName in ipairs(moduleNames) do
            local moduleInstance = modules[moduleName]
            local overriddenModuleInstance = overriddenModules[moduleName]
            loadModule(moduleName, moduleInstance, overriddenModuleInstance, targetTable)
        end
    end

    -- Load shared modules first (including utils) so client modules can depend on them
    loadRemainingModules(sharedModules, overriddenSharedModules, FrameworkClient.BuiltInShared)
    
    -- Load client modules after shared modules are available
    loadRemainingModules(clientModules, overriddenClientModules, FrameworkClient.BuiltInClient)
end

function FrameworkClient:ManagePlayerRemoving(Player: Player)
    for _, controller in controllers do
        if type(controller.FrameworkPlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(controller.Name)
                controller:PlayerRemoving(Player)
            end)
        end
    end

    for Name, BuiltIn in pairs(FrameworkClient.BuiltInClient) do
        if type(BuiltIn.PlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerRemoving(Player)
            end)
        end
    end

    for Name, BuiltIn in pairs(FrameworkClient.BuiltInShared) do
        if type(BuiltIn.PlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerRemoving(Player)
            end)
        end
    end
end

function FrameworkClient:ManageCharacter(Player: Player, Character: Model, controller: Controller)
    if type(controller.FrameworkCharacterAdded) == "function" then
        task.spawn(function()
            debug.setmemorycategory(controller.Name)
            controller:CharacterAdded(Player, Character)
        end)
    end
end

function FrameworkClient:ManagePlayerAdded(Player: Player)
    for _, controller in controllers do
        if type(controller.FrameworkPlayerAdded) == "function" then
            task.spawn(function()
                debug.setmemorycategory(controller.Name)
                controller:PlayerAdded(Player)
            end)
        end

        if Player.Character then
            FrameworkClient:ManageCharacter(Player, Player.Character, controller)
        end
        Player.CharacterAdded:Connect(function(Character: Model)
            FrameworkClient:ManageCharacter(Player, Character, controller)
        end)
    end

    for Name, BuiltIn in pairs(FrameworkClient.BuiltInClient) do
        if type(BuiltIn.PlayerAdded) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerAdded(Player)
            end)
        end

        if Player.Character then
            if type(BuiltIn.CharacterAdded) == "function" then
                task.spawn(function()
                    debug.setmemorycategory(Name)
                    BuiltIn:CharacterAdded(Player, Player.Character)
                end)
            end
        end
        Player.CharacterAdded:Connect(function(Character: Model)
            if type(BuiltIn.CharacterAdded) == "function" then
                task.spawn(function()
                    debug.setmemorycategory(Name)
                    BuiltIn:CharacterAdded(Player, Character)
                end)
            end
        end)
    end

    for Name, BuiltIn in pairs(FrameworkClient.BuiltInShared) do
        if type(BuiltIn.PlayerAdded) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerAdded(Player)
            end)
        end

        if Player.Character then
            if type(BuiltIn.CharacterAdded) == "function" then
                task.spawn(function()
                    debug.setmemorycategory(Name)
                    BuiltIn:CharacterAdded(Player, Player.Character)
                end)
            end
        end
        Player.CharacterAdded:Connect(function(Character: Model)
            if type(BuiltIn.CharacterAdded) == "function" then
                task.spawn(function()
                    debug.setmemorycategory(Name)
                    BuiltIn:CharacterAdded(Player, Character)
                end)
            end
        end)
    end
end

function FrameworkClient.Start(options: FrameworkOptions?)
    if started then
        return Promise.reject("Framework already started")
    end

    FrameworkClient:LoadBuiltIn()
    FrameworkClient.FrameworkChannel = FrameworkClient.BuiltInClient.Network.Channel("Framework")
    FrameworkClient.BuiltInClient.Datastore:WaitForDataReceived()
    started = true

    if options == nil then
        selectedOptions = defaultOptions
    else
        assert(typeof(options) == "table", `FrameworkOptions should be a table or nil; got {typeof(options)}`)
        selectedOptions = options
        for k, v in defaultOptions do
            if selectedOptions[k] == nil then
                selectedOptions[k] = v
            end
        end
    end
    if type(selectedOptions.PerServiceMiddleware) ~= "table" then
        selectedOptions.PerServiceMiddleware = {}
    end

    return Promise.new(function(resolve)
        -- Init:
        local promisesStartControllers = {}

        for _, controller in controllers do
            if FrameworkClient.BuiltInShared.Logger then
                controller.Logger = FrameworkClient.BuiltInShared.Logger:GetLogger(controller.Name)
            end
            if type(controller.Init) == "function" then
                table.insert(
                    promisesStartControllers,
                    Promise.new(function(r)
                        debug.setmemorycategory(controller.Name)
                        controller:Init()
                        r()
                    end)
                )
            end
        end

        resolve(Promise.all(promisesStartControllers))
    end):andThen(function()
        -- Start:
        Component.Auto(ReplicatedFirst.Framework.BuiltIn.Components.Client)
        for _, controller in controllers do
            if type(controller.Start) == "function" then
                task.spawn(function()
                    if FrameworkClient.BuiltInShared.Logger and controller.Logger then
                        controller.Logger:Debug(controller.Name .. " has started.")
                    end
                    debug.setmemorycategory(controller.Name)
                    controller:Start()
                end)
            end
        end

        FrameworkClient.FrameworkChannel:Fire("PlayerHasLoaded")

        Players.PlayerAdded:Connect(function(player)
            FrameworkClient:ManagePlayerAdded(player)
        end)

        Players.PlayerRemoving:Connect(function(player)
            FrameworkClient:ManagePlayerRemoving(player)
        end)

        for _, player in pairs(Players:GetPlayers()) do
            FrameworkClient:ManagePlayerAdded(player)
        end

        startedComplete = true
        onStartedComplete:Fire()

        task.defer(function()
            onStartedComplete:Destroy()
        end)
    end)
end

function FrameworkClient.OnStart()
    if startedComplete then
        return Promise.resolve()
    else
        return Promise.fromEvent(onStartedComplete.Event)
    end
end

return FrameworkClient
