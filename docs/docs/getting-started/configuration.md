---
sidebar_position: 4
---

# Configuration

Learn how to configure Yippy Framework to match your game's needs and enable/disable specific modules.

## Framework Settings

The main configuration file is located at:
```
YippyFramework/Configuration/Settings/FrameworkSettings.lua
```

### Basic Configuration

```lua
local FrameworkSettings = {}

-- Basic framework information
FrameworkSettings.Name = "YourGameName"        -- Your game's name
FrameworkSettings.Studio = "YourStudioName"    -- Your studio name
FrameworkSettings.Version = "1.0.0"            -- Your game version
FrameworkSettings.GroupId = 12345678           -- Your Roblox group ID
FrameworkSettings.FrameworkWarning = true      -- Show framework startup message

return FrameworkSettings
```

### Module Configuration

Control which built-in modules are loaded:

```lua
FrameworkSettings.BuiltIn = {
    -- Core modules (always loaded)
    { Name = "Logger" },
    { Name = "Color" },
    { Name = "Part" },
    { Name = "Tween" },
    { Name = "Table" },
    { Name = "Randoms" },
    { Name = "Date" },
    { Name = "Component" },
    { Name = "Event" },
    { Name = "Registry" },
    { Name = "Network" },
    { Name = "Datastore" },

    -- Optional modules (can be disabled)
    { Name = "Camera",        Enabled = true },
    { Name = "UI",            Enabled = true },
    { Name = "Notifications", Enabled = true },
    { Name = "Marketplace",   Enabled = true },
    { Name = "GlobalStats",   Enabled = true },
    { Name = "Chat",          Enabled = false },  -- Disabled
    { Name = "Cmdr",          Enabled = true },
    { Name = "DebugUI",       Enabled = true },
    { Name = "Sounds",        Enabled = true },
    { Name = "Ragdoll",       Enabled = false },  -- Disabled
    { Name = "Animations",    Enabled = true },
    { Name = "Leaderboard",   Enabled = true },
}
```

## Module-Specific Configuration

### Logger Configuration

```lua
-- YippyFramework/BuiltIn/Logger/Settings.lua
local LoggerSettings = {}

LoggerSettings.LogLevel = "DEBUG"        -- DEBUG, INFO, WARN, ERROR
LoggerSettings.EnableConsole = true     -- Print to console
LoggerSettings.EnableDataStore = false  -- Save logs to DataStore
LoggerSettings.MaxLogs = 1000           -- Maximum logs to keep

return LoggerSettings
```

### Datastore Configuration

```lua
-- YippyFramework/BuiltIn/Datastore/Settings.lua
local DatastoreSettings = {}

DatastoreSettings.UseProfileService = true      -- Use ProfileService for data
DatastoreSettings.DataStoreName = "PlayerData"  -- DataStore name
DatastoreSettings.AutoSave = true              -- Enable auto-save
DatastoreSettings.AutoSaveInterval = 60        -- Save every 60 seconds

-- Default player data template
DatastoreSettings.Template = {
    Level = 1,
    Experience = 0,
    Currency = 100,
    Inventory = {},
    Settings = {
        Music = true,
        SFX = true,
    }
}

return DatastoreSettings
```

### UI Configuration

```lua
-- YippyFramework/BuiltIn/UI/Settings.lua
local UISettings = {}

UISettings.Theme = "Modern"              -- UI theme
UISettings.Animations = true            -- Enable UI animations
UISettings.SoundEffects = true          -- UI sound effects
UISettings.MobileOptimized = true       -- Mobile-friendly UI

return UISettings
```

### Network Configuration

```lua
-- YippyFramework/BuiltIn/Network/Settings.lua
local NetworkSettings = {}

NetworkSettings.UseUnreliableEvents = false  -- Use UnreliableRemoteEvents
NetworkSettings.RateLimitEnabled = true      -- Enable rate limiting
NetworkSettings.MaxRequestsPerMinute = 100   -- Rate limit threshold
NetworkSettings.CompressionEnabled = false   -- Enable data compression

return NetworkSettings
```

## Environment-Specific Configuration

### Development vs Production

```lua
local RunService = game:GetService("RunService")

local FrameworkSettings = {}

if RunService:IsStudio() then
    -- Development settings
    FrameworkSettings.FrameworkWarning = true
    FrameworkSettings.BuiltIn = {
        -- Enable all modules for testing
        { Name = "DebugUI", Enabled = true },
        { Name = "Cmdr", Enabled = true },
        -- ... other modules
    }
else
    -- Production settings
    FrameworkSettings.FrameworkWarning = false
    FrameworkSettings.BuiltIn = {
        -- Disable debug modules in production
        { Name = "DebugUI", Enabled = false },
        { Name = "Cmdr", Enabled = false },
        -- ... other modules
    }
end

return FrameworkSettings
```

### Game-Specific Configuration

```lua
-- Different configurations for different game types

-- For a RPG game
FrameworkSettings.BuiltIn = {
    { Name = "Datastore", Enabled = true },     -- Player progression
    { Name = "Leaderboard", Enabled = true },   -- Player rankings
    { Name = "Animations", Enabled = true },    -- Character animations
    { Name = "UI", Enabled = true },            -- Inventory, menus
    { Name = "Sounds", Enabled = true },        -- Audio feedback
    { Name = "Chat", Enabled = true },          -- Player communication
    { Name = "Marketplace", Enabled = true },   -- In-game purchases
}

-- For a racing game
FrameworkSettings.BuiltIn = {
    { Name = "Camera", Enabled = true },        -- Dynamic camera
    { Name = "Sounds", Enabled = true },        -- Engine sounds
    { Name = "Leaderboard", Enabled = true },   -- Race times
    { Name = "UI", Enabled = true },            -- HUD elements
    { Name = "GlobalStats", Enabled = true },   -- Race statistics
    { Name = "Chat", Enabled = false },         -- Less important
    { Name = "Marketplace", Enabled = true },   -- Car purchases
}
```

## Custom Module Configuration

### Adding Custom Settings

Create settings files for your custom modules:

```lua
-- ServerStorage/Modules/MyModule/Settings.lua
local MyModuleSettings = {}

MyModuleSettings.Feature1Enabled = true
MyModuleSettings.MaxPlayers = 50
MyModuleSettings.UpdateInterval = 5

return MyModuleSettings
```

### Loading Custom Settings

```lua
-- In your custom module
local Framework = require(game.ReplicatedFirst.Framework)
local MyModuleSettings = require(script.Settings)

local MyModule = Framework.CreateService {
    Name = "MyModule",
    Settings = MyModuleSettings
}

function MyModule:Start()
    if self.Settings.Feature1Enabled then
        self:EnableFeature1()
    end
end
```

## Advanced Configuration

### Dynamic Configuration

```lua
-- Load configuration from external sources
local HttpService = game:GetService("HttpService")

local function loadRemoteConfig()
    local success, config = pcall(function()
        return HttpService:GetAsync("https://yourapi.com/config")
    end)
    
    if success then
        return HttpService:JSONDecode(config)
    end
    
    return nil -- Fallback to default config
end

local remoteConfig = loadRemoteConfig()
if remoteConfig then
    -- Apply remote configuration
    for moduleName, settings in pairs(remoteConfig.modules) do
        -- Update module settings
    end
end
```

### Feature Flags

```lua
-- Use feature flags for gradual rollouts
local FeatureFlags = {
    NEW_UI_SYSTEM = true,
    EXPERIMENTAL_PHYSICS = false,
    BETA_FEATURES = false,
}

-- In your service
function MyService:Start()
    if FeatureFlags.NEW_UI_SYSTEM then
        self:LoadNewUI()
    else
        self:LoadLegacyUI()
    end
end
```

## Configuration Validation

```lua
-- Validate configuration at startup
local function validateConfig(config)
    assert(type(config.Name) == "string", "Framework name must be a string")
    assert(type(config.Version) == "string", "Version must be a string")
    assert(type(config.GroupId) == "number", "GroupId must be a number")
    
    for _, module in ipairs(config.BuiltIn) do
        assert(type(module.Name) == "string", "Module name must be a string")
        if module.Enabled ~= nil then
            assert(type(module.Enabled) == "boolean", "Module.Enabled must be boolean")
        end
    end
end

validateConfig(FrameworkSettings)
```

## Best Practices

### 📋 Configuration Guidelines

1. **Keep settings organized** - Group related settings together
2. **Use descriptive names** - Make settings self-documenting
3. **Provide defaults** - Always have fallback values
4. **Validate inputs** - Check configuration at startup
5. **Document settings** - Comment complex configurations

### 🔧 Performance Considerations

1. **Disable unused modules** - Reduces memory footprint
2. **Tune auto-save intervals** - Balance data safety vs performance
3. **Limit rate limiting** - Don't make it too restrictive
4. **Consider mobile devices** - Optimize for lower-end hardware

### 🛡️ Security Considerations

1. **Don't expose sensitive data** - Keep API keys server-side
2. **Validate user inputs** - Sanitize configuration from external sources
3. **Use proper permissions** - Limit who can modify configurations
4. **Audit configuration changes** - Log important setting modifications

## Next Steps

Now that you understand configuration:

- 🏗️ **[Learn about Services](/docs/getting-started/quick-start)** - Create your first service
- 🎮 **[Explore Controllers](/docs/getting-started/quick-start)** - Handle client-side logic
- 🧩 **[Use Built-in Modules](/docs/examples)** - See real-world examples
