---
sidebar_position: 3
---

# Services

Services are server-side modules that handle game logic, data management, and player interactions. They form the backbone of your game's server architecture.

## What are Services?

Services in YippyFramework are singleton modules that:
- Run on the server only
- Handle business logic and data processing
- Can communicate with clients through remote events/functions
- Manage game state and player data
- Are automatically initialized when the framework starts

## Creating a Service

Use the `Framework.CreateService()` function to create a new service:

```lua
local MyGameService = Framework.CreateService({
    Name = "MyGameService",
    
    -- Client interface (methods clients can call)
    Client = {
        GetPlayerStats = function(self, player)
            return self:GetStats(player)
        end
    }
})

function MyGameService:Init()
    -- Initialize your service here
    -- This runs before Start()
    print("MyGameService initialized")
end

function MyGameService:Start()
    -- Start your service logic
    -- Access other services here
    self.DataService = Framework.GetService("DataService")
end

return MyGameService
```

## Service Lifecycle

1. **Init()** - Called first, use for initialization
2. **Start()** - Called after all services are initialized
3. **PlayerAdded(player)** - Called when a player joins
4. **PlayerRemoving(player)** - Called when a player leaves

## Client Communication

Services can expose methods to clients through the `Client` table:

```lua
-- Server
Client = {
    PurchaseItem = function(self, player, itemId)
        -- Validate and process purchase
        return success, message
    end
}

-- Client calls this via:
-- Framework.GetService("ShopService"):PurchaseItem("sword_001")
```

## Best Practices

- **Single Responsibility**: Each service should handle one main concern
- **Use Init() for setup**: Don't access other services in Init()
- **Use Start() for logic**: Access other services and start main logic here
- **Validate client input**: Always validate data from clients
- **Error handling**: Wrap risky operations in pcall()

---

**Next:** [Controllers →](./controllers)
