---
sidebar_position: 2
---

# Quick Start

Get up and running with Yippy Framework in just a few minutes! This guide will show you how to create your first service and controller.

## Your First Service

Services run on the server and handle game logic, data processing, and server-side events.

### Create a Service

1. **Create a new script** in `ServerStorage` or `ServerScriptService`
2. **Name it** `MyFirstService`
3. **Add the following code:**

```lua
--[[
   __  ___                              ______
  \  \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
   \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ `__ \/ _ \/ ___/
   / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
  /_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
     /_/   /_/   /_/    /____/
--]]

-- Get the framework
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Framework = require(ReplicatedFirst.Framework)

-- Create your service
local MyFirstService = Framework.CreateService {
    Name = "MyFirstService"
}

-- This runs when the service starts
function MyFirstService:Start()
    print("🎉 My first service started!")
    
    -- Your service logic here
    self:SetupPlayerEvents()
end

-- Example method
function MyFirstService:SetupPlayerEvents()
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        print("Player joined:", player.Name)
    end)
end

-- Custom methods
function MyFirstService:SayHello(playerName)
    return "Hello, " .. playerName .. "!"
end

return MyFirstService
```

## Your First Controller

Controllers run on the client and handle user input, UI updates, and client-side logic.

### Create a Controller

1. **Create a LocalScript** in `StarterPlayerScripts`
2. **Name it** `MyFirstController`
3. **Add the following code:**

```lua
--[[
   __  ___                              ______
  \  \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
   \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ `__ \/ _ \/ ___/
   / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
  /_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
     /_/   /_/   /_/    /____/
--]]

-- Get the framework
local ReplicatedFirst = game:GetService('ReplicatedFirst')
local Framework = require(ReplicatedFirst.Framework)

-- Create your controller
local MyFirstController = Framework.CreateController {
    Name = "MyFirstController"
}

-- This runs when the controller starts
function MyFirstController:Start()
    print("🎮 My first controller started!")
    
    -- Your client logic here
    self:SetupInput()
end

-- Example method
function MyFirstController:SetupInput()
    local UserInputService = game:GetService("UserInputService")
    
    UserInputService.InputBegan:Connect(function(input)
        if input.KeyCode == Enum.KeyCode.H then
            print("Hello key pressed!")
        end
    end)
end

return MyFirstController
```

## Communication Between Service and Controller

Use the Network module to communicate between server and client:

### Service Side (Server)

```lua
function MyFirstService:Start()
    -- Listen for client requests
    Framework.Network:Listen("SayHello", function(player, message)
        return self:SayHello(player.Name)
    end)
end
```

### Controller Side (Client)

```lua
function MyFirstController:Start()
    -- Send request to server
    local response = Framework.Network:Request("SayHello", "Hello Server!")
    print("Server responded:", response)
end
```

## Using Built-in Modules

Access any built-in module through the framework:

```lua
function MyFirstService:Start()
    -- Use the Logger module
    Framework.Logger:Info("Service started successfully!")
    
    -- Use the Color module
    local redColor = Framework.Color.new(255, 0, 0)
    
    -- Use the Datastore module
    local playerData = Framework.Datastore:Get(player, "PlayerData")
end
```

## Testing Your Setup

1. **Run your game** in Roblox Studio
2. **Check the output** for your print statements
3. **Test interactions** by pressing the H key (from the controller example)

You should see:
```
🎉 My first service started!
🎮 My first controller started!
```

## What's Next?

Now that you have the basics working:

- 📚 **[Learn Core Concepts](/docs/core-concepts/services)** - Understand services, controllers, and components
- 🧩 **[Explore Built-in Modules](/docs/modules/logger)** - Discover what's available
- 🎯 **[See Examples](/docs/examples)** - Real-world usage patterns
- ⚙️ **[Configure Framework](/docs/getting-started/configuration)** - Customize to your needs

## Code Snippets

Speed up development with our VS Code snippets:

- Type `yippyservice` for service template
- Type `yippycontroller` for controller template  
- Type `yippycomponent` for component template

Happy coding! 🚀
