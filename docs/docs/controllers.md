---
sidebar_position: 4
---

# Controllers

Controllers are client-side modules that handle user interface, input, and client-specific game logic. They manage the player's experience and communicate with server services.

## What are Controllers?

Controllers in YippyFramework are client-side modules that:
- Run on each client individually
- Handle UI interactions and player input
- Manage client-side game state
- Communicate with server services
- Control visual effects and animations

## Creating a Controller

Use the `Framework.CreateController()` function to create a new controller:

```lua
local PlayerController = Framework.CreateController({
    Name = "PlayerController"
})

function PlayerController:Init()
    -- Initialize your controller
    -- Set up UI, bind events
    print("PlayerController initialized")
end

function PlayerController:Start()
    -- Start controller logic
    -- Access services and other controllers
    self.GameService = Framework.GetService("GameService")
    
    -- Access built-ins
    Framework.BuiltInClient.UI:Open("MainMenu")
end

return PlayerController
```

## Controller Lifecycle

1. **Init()** - Called first, use for setup and UI creation
2. **Start()** - Called after initialization, access services here
3. **PlayerAdded(player)** - Called when any player joins (if implemented)
4. **PlayerRemoving(player)** - Called when any player leaves (if implemented)

## Accessing Services

Controllers can call server services through the network:

```lua
function PlayerController:BuyItem(itemId)
    local success, message = Framework.GetService("ShopService"):PurchaseItem(itemId)
    
    if success then
        Framework.BuiltInClient.Notifications:Create("Success", "Item purchased!")
    else
        Framework.BuiltInClient.Notifications:Create("Error", message)
    end
end
```

## Working with Built-ins

Controllers frequently use built-in client modules:

```lua
function PlayerController:Start()
    -- UI Management
    Framework.BuiltInClient.UI:Open("HUD")
    
    -- Data listening
    Framework.BuiltInClient.Datastore:Listen({
        path = "PlayerProfile/Level"
    }, function(event)
        self:UpdateLevelDisplay(event.newValue)
    end)
    
    -- Notifications
    Framework.BuiltInClient.Notifications:Create("Info", "Welcome!")
end
```

## Best Practices

- **Handle UI logic**: Controllers should manage all UI interactions
- **Validate locally**: Check inputs before sending to server
- **Use built-ins**: Leverage framework's UI, notifications, and data systems
- **Separate concerns**: Keep different UI areas in separate controllers
- **Error handling**: Always handle network call failures gracefully

---

**Previous:** [← Services](./services) | **Next:** [Built-ins →](./built-ins)
