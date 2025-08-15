---
sidebar_position: 5
---

# Built-ins

Built-in modules are pre-made systems that handle common game functionality. They're automatically loaded and ready to use without any setup required.

## What are Built-ins?

Built-ins are production-ready modules that provide:
- **Data management** (ProfileService, ReplicaService)
- **UI systems** (notifications, menus, scaling)
- **Networking** (channels, middleware)
- **Commerce** (marketplace, gamepasses)
- **Graphics** (ragdoll, animations, sounds)
- **Developer tools** (debugging, command system)

## Accessing Built-ins

Built-ins are accessed through the Framework namespace:

```lua
-- Client-side built-ins
Framework.BuiltInClient.Datastore:Listen(...)
Framework.BuiltInClient.UI:Open("MenuName")
Framework.BuiltInClient.Notifications:Create("Success", "Done!")

-- Server-side built-ins
Framework.BuiltInServer.Datastore:SetAsync(player, "coins", 100)
Framework.BuiltInServer.Marketplace:PromptPurchase(player, "gamepass_vip")

-- Shared built-ins (available on both)
Framework.BuiltInShared.Logger:GetLogger("MyService")
Framework.BuiltInShared.Table:DeepCopy(myTable)
```

## Core Built-ins

### 💾 Datastore
Handles all player data with ProfileService integration:
```lua
-- Listen for data changes
Framework.BuiltInClient.Datastore:Listen({
    path = "PlayerProfile/Coins"
}, function(event)
    print("Coins updated:", event.newValue)
end)
```

### UI
Complete UI management system:
```lua
-- Open/close UI
Framework.BuiltInClient.UI:Open("ShopMenu")
Framework.BuiltInClient.UI:Close("ShopMenu")

-- Scale UI elements
Framework.BuiltInClient.UI:TweenScale(element, 1.2, 0.3)
```

### 🔔 Notifications
Toast-style notifications:
```lua
Framework.BuiltInClient.Notifications:Create("Success", "Level up!")
Framework.BuiltInClient.Notifications:Create("Error", "Not enough coins")
Framework.BuiltInClient.Notifications:Create("Info", "New quest available")
```

### 🌐 Network
Simplified networking with channels:
```lua
-- Create a channel
local MyChannel = Framework.BuiltInClient.Network.Channel("MyChannel")

-- Send data
MyChannel:Fire("UpdateScore", newScore)

-- Listen for data
MyChannel:On("ScoreUpdated", function(score)
    updateUI(score)
end)
```

### 🛒 Marketplace
Handle purchases and gamepasses:
```lua
-- Prompt purchase
Framework.BuiltInClient.Marketplace:PromptProduct("VIPGamepass")

-- Check ownership
if Framework.BuiltInClient.Marketplace:PossesProduct("VIPGamepass") then
    -- Give VIP benefits
end
```

## Available Categories

- **Core**: Datastore, UI, Network, Notifications
- **Commerce**: Marketplace integration
- **Graphics**: Ragdoll, Animations, Camera, Sounds  
- **Social**: Chat, Leaderboard systems
- **Tools**: Debug UI, Global Stats, Command system

## Built-in Configuration

Built-ins can be configured through the framework settings. Each built-in can be:
- **Enabled/Disabled** - Turn modules on or off
- **Customized** - Override default behaviors
- **Extended** - Add your own functionality

---

**Previous:** [← Controllers](./controllers) | **Next:** [Components →](./components)
