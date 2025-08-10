--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local StarterPlayer = game:GetService("StarterPlayer")
-- DefaultSettings will be loaded from the modular Settings folder during LoadAllConfigurations
local Definitions = require(script.Parent.Definitions)
local Component = require(ReplicatedFirst.Framework.Extra.Component)

type Middleware = {
    Inbound: ServerMiddleware?,
    Outbound: ServerMiddleware?,
}
type ServerMiddlewareFn = (player: Player, args: { any }) -> (boolean, ...any)
type ServerMiddleware = { ServerMiddlewareFn }
type ServiceDef = {
    Name: string,
    Client: { [any]: any }?,
    Middleware: Middleware?,
    [any]: any,
}
type Service = {
    Name: string,
    Client: ServiceClient,
    FrameworkComm: any,
    [any]: any,
}
type ServiceClient = {
    Server: Service,
    [any]: any,
}
type FrameworkOptions = {
    Middleware: Middleware?,
}
local defaultOptions: FrameworkOptions = {
    Middleware = nil,
}

local selectedOptions = nil
local FrameworkServer = {}

FrameworkServer.Util = (script.Parent.Extra :: Instance).Parent

local SIGNAL_MARKER = newproxy(true)
getmetatable(SIGNAL_MARKER).__tostring = function()
    return "SIGNAL_MARKER"
end

local UNRELIABLE_SIGNAL_MARKER = newproxy(true)
getmetatable(UNRELIABLE_SIGNAL_MARKER).__tostring = function()
    return "UNRELIABLE_SIGNAL_MARKER"
end

local PROPERTY_MARKER = newproxy(true)
getmetatable(PROPERTY_MARKER).__tostring = function()
    return "PROPERTY_MARKER"
end

local FrameworkRepServiceFolder = Instance.new("Folder")
FrameworkRepServiceFolder.Name = "Services"

local Promise = require(script.Parent.Extra.Promise)
local Comm = require(script.Parent.Extra.Comm)
local ServerComm = Comm.ServerComm

local services: { [string]: Service } = {}
local started = false
local startedComplete = false
local onStartedComplete = Instance.new("BindableEvent")

local function DoesServiceExist(serviceName: string): boolean
    local service: Service? = services[serviceName]
    return service ~= nil
end

function FrameworkServer.CreateService(serviceDef: ServiceDef): Service
    assert(type(serviceDef) == "table", `Service must be a table; got {type(serviceDef)}`)
    assert(type(serviceDef.Name) == "string", `Service.Name must be a string; got {type(serviceDef.Name)}`)
    assert(#serviceDef.Name > 0, "Service.Name must be a non-empty string")
    assert(not DoesServiceExist(serviceDef.Name), `Service "{serviceDef.Name}" already exists`)
    local service = serviceDef
    service.FrameworkComm = ServerComm.new(FrameworkRepServiceFolder, serviceDef.Name)
    if type(service.Client) ~= "table" then
        service.Client = { Server = service }
    else
        if service.Client.Server ~= service then
            service.Client.Server = service
        end
    end
    services[service.Name] = service
    return service
end

function FrameworkServer.AddServices(parent: Instance): { Service }
    local addedServices = {}
    for _, v in parent:GetChildren() do
        if not v:IsA("ModuleScript") then
            continue
        end
        table.insert(addedServices, require(v))
    end
    return addedServices
end

function FrameworkServer.AddServicesDeep(parent: Instance): { Service }
    local addedServices = {}
    for _, v in parent:GetDescendants() do
        if not v:IsA("ModuleScript") then
            continue
        end
        table.insert(addedServices, require(v))
    end
    return addedServices
end

function FrameworkServer.GetService(serviceName: string): Service
    assert(started, "Cannot call GetService until Framework has been started")
    assert(type(serviceName) == "string", `ServiceName must be a string; got {type(serviceName)}`)
    return assert(services[serviceName], `Could not find service "{serviceName}"`) :: Service
end

function FrameworkServer.CreateSignal()
    return SIGNAL_MARKER
end

function FrameworkServer.CreateUnreliableSignal()
    return UNRELIABLE_SIGNAL_MARKER
end

function FrameworkServer.CreateProperty(initialValue: any)
    return { PROPERTY_MARKER, initialValue }
end

function FrameworkServer:LoadAllConfigurations()
    FrameworkServer.FrameworkConfig = {} :: Definitions.FrameworkConfig

            if not ReplicatedFirst:FindFirstChild("Settings") then
            warn("No settings found in ReplicatedFirst for Framework. Using default settings.")
        else
            if not ReplicatedFirst.Settings:FindFirstChild("Configuration") then
                warn("No 'Configuration' settings folder in ReplicatedFirst for Framework. Using default settings.")
            end
        end

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
                else
                    warn("Unsupported item type for '" .. childName .. "' at root level.")
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
                else
                    warn("Unsupported item type for '" .. childName .. "' inside folder.")
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
    FrameworkServer.FrameworkConfig = SelectConfigurations(defaultSettingsFolder, newSettingsFolder, true)
end

function FrameworkServer:DebugFramework(Message: string)
    warn(
        string.format(
            "[%s - %s] %s",
            FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.Name,
            FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.Version,
            Message
        )
    )
end

function FrameworkServer:LoadBuiltIn()
    FrameworkServer.BuiltInServer = {} :: Definitions.BuiltInServer
    FrameworkServer.BuiltInShared = {} :: Definitions.BuiltInShared

    if ReplicatedFirst:FindFirstChild("Settings") then
        if
            not ReplicatedFirst.Settings:FindFirstChild("BuiltIn")
            and FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning
        then
            FrameworkServer:DebugFramework(
                "No 'BuiltIn' settings folder in ReplicatedFirst for Framework. Using default settings."
            )
        end

        if
            not (
                ReplicatedFirst.Settings:FindFirstChild("BuiltIn")
                and ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Server")
            ) and FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.FrameworkWarning
        then
            FrameworkServer:DebugFramework(
                "No 'BuiltIn/Server' folder found in ReplicatedFirst for Framework. Using default settings."
            )
        end
    end

    local defaultBuiltInServerFolder = script.Parent.BuiltIn.Server
    local defaultBuiltInSharedFolder = script.Parent.BuiltIn.Shared
    local overriddenBuiltInServerFolder = nil
    local overriddenBuiltInSharedFolder = nil

    if ReplicatedFirst:FindFirstChild("Settings") then
        if ReplicatedFirst.Settings:FindFirstChild("BuiltIn") then
            overriddenBuiltInServerFolder = ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Server")
            overriddenBuiltInSharedFolder = ReplicatedFirst.Settings.BuiltIn:FindFirstChild("Shared")
        end
    end

    -- Get the new config-based settings
    local builtInConfig = FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.BuiltIn or {}
    local loadOrder = FrameworkServer.FrameworkConfig.Settings.FrameworkSettings.BuiltInLoadOrder or {}
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
    local serverModules = collectModules(defaultBuiltInServerFolder)
    local sharedModules = collectModules(defaultBuiltInSharedFolder)
    local overriddenServerModules = overriddenBuiltInServerFolder and collectModules(overriddenBuiltInServerFolder) or {}
    local overriddenSharedModules = overriddenBuiltInSharedFolder and collectModules(overriddenBuiltInSharedFolder) or {}

    -- First pass: Load modules in config order (only enabled ones)
    for _, config in ipairs(builtInConfig) do
        local moduleName = config.Name
        local enabled = config.Enabled ~= false -- Default to true if not specified
        if enabled and not processedModules[moduleName] then
            local moduleInstance = serverModules[moduleName]
            local overriddenModuleInstance = overriddenServerModules[moduleName]
            local targetTable = FrameworkServer.BuiltInServer

            if not moduleInstance then
                moduleInstance = sharedModules[moduleName]
                overriddenModuleInstance = overriddenSharedModules[moduleName]
                targetTable = FrameworkServer.BuiltInShared
            end

            if moduleInstance then
                loadModule(moduleName, moduleInstance, overriddenModuleInstance, targetTable)
            end
        end
    end

    -- Legacy support: Load modules from old BuiltInLoadOrder if they exist
    for _, moduleName in ipairs(loadOrder) do
        if not processedModules[moduleName] then
            local moduleInstance = serverModules[moduleName]
            local overriddenModuleInstance = overriddenServerModules[moduleName]
            local targetTable = FrameworkServer.BuiltInServer

            if not moduleInstance then
                moduleInstance = sharedModules[moduleName]
                overriddenModuleInstance = overriddenSharedModules[moduleName]
                targetTable = FrameworkServer.BuiltInShared
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

    -- Load shared modules first (including utils) so server modules can depend on them
    loadRemainingModules(sharedModules, overriddenSharedModules, FrameworkServer.BuiltInShared)
    
    -- Load server modules after shared modules are available
    loadRemainingModules(serverModules, overriddenServerModules, FrameworkServer.BuiltInServer)
end

function FrameworkServer:ManagePlayerRemoving(Player: Player)
    for _, service in services do
        if type(service.PlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(service.Name)
                service:PlayerRemoving(Player)
            end)
        end
    end

    for Name, BuiltIn in pairs(FrameworkServer.BuiltInServer) do
        if type(BuiltIn.PlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerRemoving(Player)
            end)
        end
    end

    for Name, BuiltIn in pairs(FrameworkServer.BuiltInShared) do
        if type(BuiltIn.PlayerRemoving) == "function" then
            task.spawn(function()
                debug.setmemorycategory(Name)
                BuiltIn:PlayerRemoving(Player)
            end)
        end
    end
end

function FrameworkServer:LoadStarterScripts()
    for _, script in ReplicatedFirst.FrameworkAssets.Scripts:GetChildren() do
        local scriptclone = script:Clone()
        scriptclone.Enabled = true
        scriptclone.Parent = StarterPlayer.StarterCharacterScripts
    end
end

function FrameworkServer:ManageCharacter(Player: Player, Character: Model, Service: Service)
    if type(Service.CharacterAdded) == "function" then
        task.spawn(function()
            debug.setmemorycategory(Service.Name)
            Service:CharacterAdded(Player, Character)
        end)
    end
end

function FrameworkServer:ManagePlayerAdded(Player: Player)
    for _, service in services do
        if type(service.PlayerAdded) == "function" then
            task.spawn(function()
                debug.setmemorycategory(service.Name)
                service:PlayerAdded(Player)
            end)
        end

        if Player.Character then
            FrameworkServer:ManageCharacter(Player, Player.Character, service)
        end
        Player.CharacterAdded:Connect(function(Character: Model)
            FrameworkServer:ManageCharacter(Player, Character, service)
        end)
    end

    for Name, BuiltIn in pairs(FrameworkServer.BuiltInServer) do
        if Name == "Datastore" then
            continue
        end
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

    for Name, BuiltIn in pairs(FrameworkServer.BuiltInShared) do
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

function FrameworkServer.Start(options: FrameworkOptions?)
    if started then
        return Promise.reject("Framework already started")
    end
    started = true

    FrameworkServer:LoadStarterScripts()

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

    FrameworkServer:LoadBuiltIn()
    FrameworkServer.FrameworkChannel = FrameworkServer.BuiltInServer.Network.Channel("Framework")

    return Promise.new(function(resolve)
        local FrameworkMiddleware = if selectedOptions.Middleware ~= nil then selectedOptions.Middleware else {}

        -- Bind remotes:
        for _, service in services do
            local middleware = if service.Middleware ~= nil then service.Middleware else {}
            local inbound = if middleware.Inbound ~= nil then middleware.Inbound else FrameworkMiddleware.Inbound
            local outbound = if middleware.Outbound ~= nil then middleware.Outbound else FrameworkMiddleware.Outbound
            service.Middleware = nil
            for k, v in service.Client do
                if type(v) == "function" then
                    service.FrameworkComm:WrapMethod(service.Client, k, inbound, outbound)
                elseif v == SIGNAL_MARKER then
                    service.Client[k] = service.FrameworkComm:CreateSignal(k, false, inbound, outbound)
                elseif v == UNRELIABLE_SIGNAL_MARKER then
                    service.Client[k] = service.FrameworkComm:CreateSignal(k, true, inbound, outbound)
                elseif type(v) == "table" and v[1] == PROPERTY_MARKER then
                    service.Client[k] = service.FrameworkComm:CreateProperty(k, v[2], inbound, outbound)
                end
            end
        end

        -- Init:
        local promisesInitServices = {}
        for _, service in services do
            if FrameworkServer.BuiltInShared.Logger then
                service.Logger = FrameworkServer.BuiltInShared.Logger:GetLogger(service.Name)
            end
            if type(service.Init) == "function" then
                table.insert(
                    promisesInitServices,
                    Promise.new(function(r)
                        debug.setmemorycategory(service.Name)
                        service:Init()
                        r()
                    end)
                )
            end
        end

        resolve(Promise.all(promisesInitServices))
    end):andThen(function()
        -- Start:
        Component.Auto(ReplicatedFirst.Framework.BuiltIn.Components.Server)

        FrameworkServer.FrameworkChannel:On("PlayerHasLoaded", function(player)
            for _, service in services do
                if type(service.PlayerHasLoaded) == "function" then
                    task.spawn(function()
                        debug.setmemorycategory(service.Name)
                        service:PlayerHasLoaded(player)
                    end)
                end
            end
        end)
        for _, service in services do
            if type(service.Start) == "function" then
                task.spawn(function()
                    if FrameworkServer.BuiltInShared.Logger and service.Logger then
                        service.Logger:Debug(service.Name .. " has started.")
                    end
                    debug.setmemorycategory(service.Name)
                    service:Start()
                end)
            end
        end

        startedComplete = true
        onStartedComplete:Fire()

        task.defer(function()
            onStartedComplete:Destroy()
        end)

        Players.PlayerAdded:Connect(function(player)
            task.spawn(function()
                for Name, builtIn in pairs(FrameworkServer.BuiltInServer) do
                    if type(builtIn.PlayerAdded) == "function" and Name == "Datastore" then
                        if builtIn:PlayerAdded(player) then
                            FrameworkServer:ManagePlayerAdded(player)
                        end
                    end
                end
            end)
        end)

        Players.PlayerRemoving:Connect(function(player)
            FrameworkServer:ManagePlayerRemoving(player)
        end)

        for _, player in pairs(Players:GetPlayers()) do
            task.spawn(function()
                for Name, builtIn in pairs(FrameworkServer.BuiltInServer) do
                    if type(builtIn.PlayerAdded) == "function" and Name == "Datastore" then
                        if builtIn:PlayerAdded(player) then
                            FrameworkServer:ManagePlayerAdded(player)
                        end
                    end
                end
            end)
        end

        -- Expose service remotes to everyone:
        FrameworkRepServiceFolder.Parent = ReplicatedStorage
    end)
end

--[=[
	@return Promise
	Returns a promise that is resolved once Framework has started. This is useful
	for any code that needs to tie into Framework services but is not the script
	that called `Start`.
	```lua
	Framework.OnStart():andThen(function()
		local MyService = Framework.Services.MyService
		MyService:DoSomething()
	end):catch(warn)
	```
]=]
function FrameworkServer.OnStart()
    if startedComplete then
        return Promise.resolve()
    else
        return Promise.fromEvent(onStartedComplete.Event)
    end
end

return FrameworkServer
