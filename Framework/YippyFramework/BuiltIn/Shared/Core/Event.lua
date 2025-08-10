--[[
__  ___                            ______
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/ /\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")

--= Modules & Config =--
local Signal = require(ReplicatedFirst.Framework.Extra.Signal)

local Event = {
    BuiltIn = true
}
local signals = {}

local function getOrCreateSignal(name: string)
    if not signals[name] then
        signals[name] = Signal.new()
    end
    return signals[name]
end

function Event:On(name: string, callback: (...any) -> ())
    local signal = getOrCreateSignal(name)
    return signal:Connect(callback)
end

function Event:Once(name: string, callback: (...any) -> ())
    local signal = getOrCreateSignal(name)
    return signal:Once(callback)
end

function Event:Fire(name: string, ...: any)
    local signal = getOrCreateSignal(name)
    signal:Fire(...)
end

function Event:FireDeferred(name: string, ...: any)
    local signal = getOrCreateSignal(name)
    signal:FireDeferred(...)
end

function Event:Wait(name: string)
    local signal = getOrCreateSignal(name)
    return signal:Wait()
end

function Event:DisconnectAll(name: string)
    local signal = signals[name]
    if signal then
        signal:DisconnectAll()
    end
end

function Event:Destroy(name: string)
    local signal = signals[name]
    if signal then
        signal:Destroy()
        signals[name] = nil
    end
end

function Event:HasSignal(name: string)
    return signals[name] ~= nil
end

return Event
