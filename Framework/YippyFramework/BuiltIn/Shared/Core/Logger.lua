--[[
    Author: Rask/AfraiEda and Assxios yo
    Creation Date: 16/05/2023

    Description:
        No description provided.

    Documentation:
        No documentation provided.
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
--= Framework =--
local Logger = {
    BuiltIn = true
}
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constants =--
Logger.levelList = Framework.FrameworkConfig.Settings.Logger.LoggerLevelList
Logger.Level = Framework.FrameworkConfig.Settings.Logger.LoggerLevel
--= Variables =--
Logger.loggers = {}

--= Functions =--

-- Function to serialize wether object is a table or else. It also checks for already seen objects to avoid
-- cycle table reference (which would cause an infinite loop) and depth for cleaner printing
-- TODO: is it possible to make the output collaspable just like the real print function??
local function serialize(obj, seen, depth)
    depth = depth or 0
    local padding = string.rep("  ", depth)

    -- If type is nil (not sure if necessary but can't hurt)
    if obj == nil then
        return "\"nil\""
    -- If type is a table
    elseif type(obj) == "table" then
        if seen[obj] then
            return "\"*** cycle table reference detected ***\""
        end

        seen[obj] = true
        local str
        if depth == 0 then
            str = "\n{\n"
        else
            str = "{\n"
        end
        local keys = {}
        for k in pairs(obj) do
            keys[#keys + 1] = k
        end
        table.sort(keys, function(a, b)
            return tostring(a) < tostring(b)
        end) -- Sort keys for consistent ordering
        for _, k in ipairs(keys) do
            local v = obj[k]
            str = str
                .. padding
                .. "  ["
                .. serialize(k, seen, depth + 1)
                .. "] = "
                .. serialize(v, seen, depth + 1)
                .. ",\n"
        end
        str = str .. padding .. "}"
        seen[obj] = nil
        return str

    -- If Type is a function
    elseif type(obj) == "function" then
        return "\"function\""

    -- If Type is a userdata (specific to roblox)
    elseif type(obj) == "userdata" then
        -- Safe handling for userdata in Roblox, could not find a better way to do this
        if pcall(function()
            return obj.Name
        end) then
            return "\"Instance: " .. obj.ClassName .. " - " .. obj.Name .. "\""
        else
            return "\"" .. tostring(obj) .. "\""
        end

    -- Everything else
    else
        return "\"" .. tostring(obj) .. "\""
    end
end

-- Generic function to handle logging with verbosity check
local function logMessage(namespace, level, verbosity, func, ...)
    local args = { ... }
    local messageParts = {}

    if Logger.levelList[level] >= verbosity then
        for _, obj in ipairs(args) do
            table.insert(messageParts, serialize(obj, {}))
        end
        local formattedMessage = string.format("[%s - %s]: %s", namespace, level, table.concat(messageParts, " "))
        func(formattedMessage)
    end
end

function Logger:GetLogger(namespace)
    if not self.loggers[namespace] then
        local verbosity = self.Level

        self.loggers[namespace] = {
            Debug = function(_, ...)
                logMessage(namespace, "DEBUG", verbosity, print, ...)
            end,
            Info = function(_, ...)
                logMessage(namespace, "INFO", verbosity, print, ...)
            end,
            Warn = function(_, ...)
                logMessage(namespace, "WARN", verbosity, warn, ...)
            end,
            Error = function(_, ...)
                logMessage(namespace, "ERROR", verbosity, error, ...)
            end,
            Fatal = function(_, ...)
                logMessage(namespace, "FATAL", verbosity, error, ...)
            end,
        }
    end

    return self.loggers[namespace]
end

return Logger
