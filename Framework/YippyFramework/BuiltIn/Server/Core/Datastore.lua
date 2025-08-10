--[[
    Author: Rask/AfraiEda
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Datastore = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local Signal = require(ReplicatedFirst.Framework.Extra.Signal)
local ReplicaService = require(ReplicatedFirst.Framework.Extra.ReplicaService)
local ProfileService = require(ReplicatedFirst.Framework.Extra.profileservice)
--= Constants =--
Datastore.GameProfileStore =
    ProfileService.GetProfileStore(Framework.FrameworkConfig.Settings.Datastore.Key, Framework.FrameworkConfig.Settings.Datastore.Data)
--= Variables =--
Datastore.DataChanged = Signal.new()
local ClassToken = ReplicaService.NewClassToken("DataSystem")
local Profiles = {}
local ReplicaProfiles = {}
local DecodedData = {}
--= Helper Functions =--

function Datastore:GetTypeHandler(value)
    local dataTypes = Framework.BuiltInShared.Registry:GetRegistryModuleList("DataTypes")
    if not dataTypes then 
        return nil 
    end
    
    local sortedTypes = {}
    for _, typeHandler in pairs(dataTypes) do
        table.insert(sortedTypes, typeHandler)
    end
    
    table.sort(sortedTypes, function(a, b)
        return (a.Index or 999) < (b.Index or 999)
    end)
    
    for _, typeHandler in ipairs(sortedTypes) do
        if typeHandler.Detect and typeHandler:Detect(value) then
            return typeHandler
        end
    end
    return nil
end

function Datastore:EncodeDataForStorage(data)
    if type(data) ~= "table" then
        local typeHandler = self:GetTypeHandler(data)
        if typeHandler and typeHandler.Encode then
            return typeHandler:Encode(data)
        end
        return data
    end
    
    local typeHandler = self:GetTypeHandler(data)
    if typeHandler and typeHandler.Encode then
        return typeHandler:Encode(data)
    end
    
    local encoded = {}
    for key, value in pairs(data) do
        encoded[key] = self:EncodeDataForStorage(value)
    end
    return encoded
end

function Datastore:DecodeDataFromStorage(data)
    if type(data) ~= "table" then
        return data
    end
    
    if data.__type then
        local dataTypes = Framework.BuiltInShared.Registry:GetRegistryModuleList("DataTypes")
        if dataTypes then
            for _, typeHandler in pairs(dataTypes) do
                if typeHandler.Name == data.__type and typeHandler.Decode then
                    return typeHandler:Decode(data)
                end
            end
        end
        return data
    end
    
    local decoded = {}
    for key, value in pairs(data) do
        decoded[key] = self:DecodeDataFromStorage(value)
    end
    return decoded
end

function Datastore:ProcessValues(Player: Player, Paths: table, operation, operationType: string?)
    local Replica = ReplicaProfiles[Player]
    local RawData = Profiles[Player].Data
    local DecodedPlayerData = DecodedData[Player]

    if not Replica or not RawData or not DecodedPlayerData then
        return
    end

    for Path, Value in pairs(Paths) do
        local DecodedResult = Framework.BuiltInShared.Table:FindNestedValue(DecodedPlayerData, Path)
        if DecodedResult then
            local oldDecodedValue = DecodedResult.ref[DecodedResult.key]
            
            local typeHandler = self:GetTypeHandler(oldDecodedValue)
            if not typeHandler then
                typeHandler = self:GetTypeHandler(Value)
            end
            local newDecodedValue
            
            if typeHandler and typeHandler.Operations and typeHandler.Operations[operationType] then
                newDecodedValue = typeHandler.Operations[operationType](oldDecodedValue, Value)
                DecodedResult.ref[DecodedResult.key] = newDecodedValue
            else
                operation(DecodedResult, Value)
                newDecodedValue = DecodedResult.ref[DecodedResult.key]
            end

            local RawResult = Framework.BuiltInShared.Table:FindNestedValue(RawData, Path)
            if RawResult then
                RawResult.ref[RawResult.key] = self:EncodeDataForStorage(newDecodedValue)
            end

            local changeInfo = {
                oldValue = oldDecodedValue,
                newValue = newDecodedValue,
                operationType = operationType or "set",
            }

            if typeHandler and typeHandler.Operations and typeHandler.Operations.Subtract then
                local success, diff = pcall(function()
                    return typeHandler.Operations.Subtract(newDecodedValue, oldDecodedValue)
                end)
                if success then
                    changeInfo.difference = diff
                    changeInfo.changeType = "modified"
                end
            elseif type(oldDecodedValue) == "number" and type(newDecodedValue) == "number" then
                changeInfo.difference = newDecodedValue - oldDecodedValue
                if changeInfo.difference > 0 then
                    changeInfo.changeType = "increment"
                elseif changeInfo.difference < 0 then
                    changeInfo.changeType = "decrement"
                else
                    changeInfo.changeType = "unchanged"
                end
            else
                changeInfo.changeType = "modified"
                changeInfo.difference = nil
            end

            Replica:FireClient(Player, "AtomicDataChange", {
                path = Path,
                pathArray = string.split(Path, "/"),
                value = RawResult.ref[RawResult.key],
                changeInfo = {
                    oldValue = self:EncodeDataForStorage(changeInfo.oldValue),
                    newValue = self:EncodeDataForStorage(changeInfo.newValue),
                    operationType = changeInfo.operationType,
                    difference = changeInfo.difference and self:EncodeDataForStorage(changeInfo.difference) or nil,
                    changeType = changeInfo.changeType,
                }
            })
            Datastore.DataChanged:Fire(Player, Path, newDecodedValue, string.split(Path, "/"), changeInfo)
        end
    end
end

--= Listen API =--

export type ListenOptions = {
    player: Player?,
    path: string?,
    filter: ((event: DataChangeEvent) -> boolean)?
}

export type DataChangeEvent = {
    player: Player,
    path: string,
    pathArray: {string},
    newValue: any,
    oldValue: any,
    changeInfo: {
        oldValue: any,
        newValue: any,
        operationType: string,
        difference: any?,
        changeType: string,
    }
}

export type ListenConnection = {
    disconnect: () -> ()
}

function Datastore:Listen(options: ListenOptions, callback: (event: DataChangeEvent) -> ()): ListenConnection
    local connection = self.DataChanged:Connect(function(changedPlayer, changedPath, newValue, pathArray, changeInfo)
        if options.player and changedPlayer ~= options.player then
            return
        end
        
        if options.path and changedPath ~= options.path then
            return
        end
        
        local event: DataChangeEvent = {
            player = changedPlayer,
            path = changedPath,
            pathArray = pathArray,
            newValue = newValue,
            oldValue = changeInfo.oldValue,
            changeInfo = changeInfo
        }
        
        if options.filter and not options.filter(event) then
            return
        end
        
        callback(event)
    end)
    
    return {
        disconnect = function()
            connection:Disconnect()
        end
    }
end

--//Getters

function Datastore:GetData(Player: Player)
    if not Player then
        return
    end

    if DecodedData[Player] ~= nil then
        return DecodedData[Player]
    end
end

function Datastore:Get(Player: Player, Path: string)
    if not Player or not DecodedData[Player] then
        return
    end
    
    local Data = DecodedData[Player]
    local Paths = string.split(Path, "/")
    for _, path in ipairs(Paths) do
        Data = Data[path]
        if Data == nil then
            break
        end
    end
    return Data
end

function Datastore:Exists(Player: Player, Path: string)
    return self:Get(Player, Path) ~= nil
end

function Datastore:RegisterDynamicOperations()
    local dataTypes = Framework.BuiltInShared.Registry:GetRegistryModuleList("DataTypes")
    if not dataTypes then
        return
    end
    
    local allOperations = {}
    
    for _, typeHandler in pairs(dataTypes) do
        if typeHandler.Operations then
            for operationName, _ in pairs(typeHandler.Operations) do
                allOperations[operationName] = true
            end
        end
    end
    
    for operationName, _ in pairs(allOperations) do
        if not self[operationName] then
            self[operationName] = function(self, Player, Path, Value)
                if not Player or not Profiles[Player] then
                    return
                end
                
                self:ProcessValues(Player, { [Path] = Value }, function(Result, Value)
                    Result.ref[Result.key] = Value
                end, operationName)
            end
            
            local batchName = operationName .. "Many"
            if not self[batchName] then
                self[batchName] = function(self, Player, Paths)
                    if not Player or not Profiles[Player] then
                        return
                    end
                    
                    self:ProcessValues(Player, Paths, function(Result, Value)
                        Result.ref[Result.key] = Value
                    end, operationName)
                end
            end
        end
    end
end

--//Setup

function Datastore:CreateReplicaData(Player, PlayerProfile)
    local Replica = ReplicaService.NewReplica({
        ClassToken = ClassToken,
        Tags = { Player = Player },
        Data = PlayerProfile.Data,
        Replication = Player,
    })

    return Replica
end

function Datastore:PlayerAdded(Player: Player)
    local profile = Datastore.GameProfileStore:LoadProfileAsync("Player_" .. Player.UserId, "ForceLoad")

    if profile ~= nil then
        profile:AddUserId(Player.UserId)
        profile:Reconcile()

        profile:ListenToRelease(function()
            Profiles[Player] = nil
            ReplicaProfiles[Player] = nil
            DecodedData[Player] = nil
            Player:Kick("Datastore Error A1")
        end)

        if Player:IsDescendantOf(Players) == true then
            Profiles[Player] = profile
            
            DecodedData[Player] = self:DecodeDataFromStorage(profile.Data)
            
            ReplicaProfiles[Player] = Datastore:CreateReplicaData(Player, profile)
            return true
        else
            profile:Release()
        end
    else
        Player:Kick("Datastore Error A2")
    end
end

function Datastore:PlayerRemoving(Player: Player)
    local PlayerProfile = Profiles[Player]

    if PlayerProfile then
        PlayerProfile:Release()
    end

    if ReplicaProfiles[Player] then
        ReplicaProfiles[Player]:Destroy()
    end
    
    DecodedData[Player] = nil
    Profiles[Player] = nil
    ReplicaProfiles[Player] = nil
end

--= Development Helpers =--
function Datastore:GetAvailableOperations()
    local dataTypes = Framework.BuiltInShared.Registry:GetRegistryModuleList("DataTypes")
    if not dataTypes then
        return {}
    end
    
    local operations = {}
    for _, typeHandler in pairs(dataTypes) do
        if typeHandler.TypeDef then
            operations[typeHandler.Name] = typeHandler.TypeDef.Operations
        end
    end
    
    return operations
end

function Datastore:Start()
    self:RegisterDynamicOperations()
    
    game:BindToClose(function()
        for _, player in Players:GetPlayers() do
            Datastore:PlayerRemoving(player)
        end
    end)
end

return Datastore
