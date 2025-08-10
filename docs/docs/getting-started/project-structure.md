---
sidebar_position: 3
---

# Project Structure

Understanding how to organize your Roblox project with Yippy Framework will help you build maintainable and scalable games.

## Recommended Structure

Here's the recommended folder structure for a Yippy Framework project:

```
📁 Your Game
├── 📁 ReplicatedFirst
│   └── 📁 Framework                 <- Yippy Framework core
│       ├── 📁 YippyFramework
│       ├── 📁 Client-Initialization
│       └── 📁 Server-Initialization
├── 📁 ReplicatedStorage
│   ├── 📁 Shared                   <- Code shared between server/client
│   │   ├── 📁 Modules
│   │   ├── 📁 Data
│   │   └── 📁 Configurations
│   └── 📁 Assets                   <- Game assets
│       ├── 📁 UI
│       ├── 📁 Models
│       └── 📁 Sounds
├── 📁 ServerScriptService
│   ├── 📁 Services                 <- Your server services
│   │   ├── 📄 PlayerService.lua
│   │   ├── 📄 DataService.lua
│   │   └── 📄 GameService.lua
│   └── 📁 Modules                  <- Server-only modules
├── 📁 ServerStorage
│   ├── 📁 Data                     <- Server data and configs
│   ├── 📁 Tools
│   └── 📁 Maps
└── 📁 StarterPlayer
    └── 📁 StarterPlayerScripts
        ├── 📁 Controllers          <- Your client controllers
        │   ├── 📄 PlayerController.lua
        │   ├── 📄 UIController.lua
        │   └── 📄 InputController.lua
        └── 📁 Modules              <- Client-only modules
```

## Framework Location

### ReplicatedFirst/Framework
The framework **must** be placed in `ReplicatedFirst` to ensure it loads before any game scripts:

```
ReplicatedFirst/Framework/
├── YippyFramework/              <- Core framework code
│   ├── init.lua                 <- Main entry point
│   ├── FrameworkServer.lua      <- Server-side framework
│   ├── FrameworkClient.lua      <- Client-side framework
│   ├── BuiltIn/                 <- Built-in modules
│   └── Configuration/           <- Framework settings
├── Client-Initialization/       <- Client startup scripts
└── Server-Initialization/       <- Server startup scripts
```

## Services Organization

### ServerScriptService/Services
Place your server services here. Each service should handle a specific aspect of your game:

```lua
-- PlayerService.lua - Handle player-related logic
-- DataService.lua - Manage player data
-- GameService.lua - Core game mechanics
-- ShopService.lua - In-game purchases
-- LeaderboardService.lua - Player rankings
```

### Service Naming Convention
- Use descriptive names ending with "Service"
- One responsibility per service
- Group related functionality

## Controllers Organization

### StarterPlayerScripts/Controllers
Place your client controllers here. Controllers handle client-side logic:

```lua
-- PlayerController.lua - Player state management
-- UIController.lua - User interface logic
-- InputController.lua - Input handling
-- CameraController.lua - Camera controls
-- SoundController.lua - Audio management
```

### Controller Naming Convention
- Use descriptive names ending with "Controller"
- Handle specific client functionality
- Keep controllers focused and lightweight

## Shared Code

### ReplicatedStorage/Shared
Code that both server and client need access to:

```
Shared/
├── Modules/
│   ├── GameConstants.lua        <- Game-wide constants
│   ├── Utilities.lua           <- Helper functions
│   └── Enums.lua               <- Custom enumerations
├── Data/
│   ├── ItemData.lua            <- Item definitions
│   └── ConfigData.lua          <- Configuration data
└── Configurations/
    ├── RemoteEvents.lua        <- Event definitions
    └── Settings.lua            <- Shared settings
```

## Assets Organization

### ReplicatedStorage/Assets
Organize your game assets logically:

```
Assets/
├── UI/
│   ├── Icons/
│   ├── Backgrounds/
│   └── Frames/
├── Models/
│   ├── Weapons/
│   ├── Buildings/
│   └── Characters/
└── Sounds/
    ├── Music/
    ├── SFX/
    └── Voice/
```

## Configuration Files

### Framework Configuration
Customize framework behavior in `YippyFramework/Configuration/`:

```lua
-- FrameworkSettings.lua
local FrameworkSettings = {}

FrameworkSettings.Name = "YourGame"
FrameworkSettings.Version = "1.0.0"
FrameworkSettings.FrameworkWarning = true

-- Enable/disable built-in modules
FrameworkSettings.BuiltIn = {
    { Name = "Logger" },
    { Name = "Datastore" },
    { Name = "UI", Enabled = true },
    { Name = "Camera", Enabled = true },
    -- ... more modules
}

return FrameworkSettings
```

### Game Configuration
Create configuration files for your game:

```lua
-- ReplicatedStorage/Shared/Configurations/GameSettings.lua
local GameSettings = {}

GameSettings.MaxPlayers = 50
GameSettings.RoundDuration = 300
GameSettings.StartingCurrency = 100

return GameSettings
```

## Best Practices

### 📁 Folder Organization
- Keep related files together
- Use clear, descriptive names
- Maintain consistent naming conventions
- Don't nest folders too deeply (max 3-4 levels)

### 🏷️ Naming Conventions
- **Services**: `PlayerService`, `DataService`
- **Controllers**: `UIController`, `InputController`
- **Modules**: `GameConstants`, `PlayerData`
- **Assets**: `sword_icon`, `background_main`

### 📦 Module Structure
```lua
-- Standard module template
local Module = {}

-- Dependencies
local Framework = require(game.ReplicatedFirst.Framework)

-- Constants
local CONSTANT_VALUE = 100

-- Module implementation
function Module.doSomething()
    -- Implementation
end

return Module
```

### 🔄 Code Reusability
- Place shared utilities in `ReplicatedStorage/Shared`
- Create reusable components for common functionality
- Use the framework's built-in modules when possible
- Avoid duplicating code between services and controllers

## Migration from Other Frameworks

If you're migrating from another framework:

1. **Map existing structure** to Yippy Framework conventions
2. **Convert services** to use Yippy's service pattern
3. **Update module requires** to use framework references
4. **Test incrementally** as you migrate each component

## Next Steps

Now that you understand the structure:

- 🏗️ **[Create your first service](/docs/core-concepts/services)**
- 🎮 **[Build a controller](/docs/core-concepts/controllers)**
- ⚙️ **[Configure the framework](/docs/getting-started/configuration)**
