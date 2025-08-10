--[[
    Logger Settings
    Configuration for the logging system
--]]

local LoggerSettings = {}

--= Logger Configuration =--
LoggerSettings.LoggerLevelList = {
    DEBUG = 1,
    INFO = 2,
    WARN = 3,
    ERROR = 4,
    FATAL = 5,
}
LoggerSettings.LoggerLevel = LoggerSettings.LoggerLevelList.DEBUG

return LoggerSettings
