--[[
    Author: Rask/AfraiEda
    Creation Date: 19/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Datastore = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local ReplicaController = require(ReplicatedFirst.Framework.Extra.ReplicaService)
local Signal = require(ReplicatedFirst.Framework.Extra.Signal)
--= Constants =--
--= Variables =--
Datastore._datareceived = false
Datastore._rawdata = nil
Datastore._decodeddata = nil
Datastore.DataChanged = Signal.new()
Datastore._replica = nil
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

--= Job API =--

function Datastore:Start()
    ReplicaController.ReplicaOfClassCreated("DataSystem", function(replica)
        self:HandlePlayerDataCreation(replica)
    end)

    ReplicaController.RequestData()
    self:WaitForDataReceived()
end

--= Replica Creation Handlers =--

function Datastore:HandlePlayerDataCreation(replica)
    if not replica then
        return
    end

    self._replica = replica

    replica:AddCleanupTask(function()
        self._rawdata = nil
        self._decodeddata = nil
        self._replica = nil
    end)

    self._datareceived = true
    self._rawdata = replica.Data
    self._decodeddata = self:DecodeDataFromStorage(replica.Data)

    replica:ConnectOnClientEvent(function(eventType, eventData)
        if eventType == "AtomicDataChange" then
            self:HandleAtomicDataChange(eventData)
        end
    end)
end

function Datastore:WaitForDataReceived()
    repeat
        task.wait()
    until self._datareceived
end

--= Data Handlers =--

function Datastore:HandleAtomicDataChange(eventData)
    local pathArray = eventData.pathArray
    local result = Framework.BuiltInShared.Table:FindNestedValue(self._rawdata, table.concat(pathArray, "/"))
    if result then
        result.ref[result.key] = eventData.value
    end
    
    self._decodeddata = self:DecodeDataFromStorage(self._rawdata)
    
    local serverChangeInfo = {
        oldValue = self:DecodeDataFromStorage(eventData.changeInfo.oldValue),
        newValue = self:DecodeDataFromStorage(eventData.changeInfo.newValue),
        operationType = eventData.changeInfo.operationType,
        difference = eventData.changeInfo.difference and self:DecodeDataFromStorage(eventData.changeInfo.difference) or nil,
        changeType = eventData.changeInfo.changeType,
    }
    
    self:ClientDataChanged(pathArray, serverChangeInfo)
end

function Datastore:ClearTablePath(Path: table, selects: number?)
    return { select(selects, unpack(Path)) }
end

--= Class API =--

function Datastore:ClientDataChanged(Path: table, serverChangeInfo: any?)
    self:FireChange(self.DataChanged, self:ClearTablePath(Path, 1), self._decodeddata, serverChangeInfo)
end

function Datastore:Get(Path: string)
    if not self._decodeddata then
        return nil
    end
    
    local Paths = string.split(Path, "/")
    local Data = self._decodeddata
    for _, path in ipairs(Paths) do
        Data = Data[path]
        if Data == nil then
            break
        end
    end
    return Data
end

function Datastore:GetData()
    return self._decodeddata
end

function Datastore:Exists(Path: string)
    return self:Get(Path) ~= nil
end

function Datastore:FireChange(signal: RBXScriptSignal, Path: table, DataTableRef: table, serverChangeInfo: any?)
    local result = Framework.BuiltInShared.Table:FindNestedValue(DataTableRef, table.concat(Path, "/"))

    if result then
        signal:Fire(table.concat(Path, "/"), result.ref[result.key], Path, serverChangeInfo)
    end
end

--= Modern Listen API =--

export type ClientListenOptions = {
    path: string?,
    filter: ((event: ClientDataChangeEvent) -> boolean)? 
}

export type ClientDataChangeEvent = {
    path: string,
    pathArray: {string},
    newValue: any,
    oldValue: any?,
    changeInfo: {
        oldValue: any?,
        newValue: any,
        operationType: string,
        difference: any?,
        changeType: string, 
    }
}

export type ClientListenConnection = {
    disconnect: () -> ()
}

function Datastore:Listen(options: ClientListenOptions, callback: (event: ClientDataChangeEvent) -> ()): ClientListenConnection
    local connection = self.DataChanged:Connect(function(changedPath, newValue, pathArray, serverChangeInfo)
        if options.path and changedPath ~= options.path then
            return
        end
        
        local changeInfo
        local oldValue
        
        if serverChangeInfo then
            changeInfo = serverChangeInfo
            oldValue = serverChangeInfo.oldValue
        else
            warn("Client datastore: No server changeInfo available - this indicates a synchronization issue")
            return
        end
        
        local event: ClientDataChangeEvent = {
            path = changedPath,
            pathArray = pathArray,
            newValue = newValue,
            oldValue = oldValue,
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

return Datastore
