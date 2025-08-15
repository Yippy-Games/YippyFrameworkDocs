---
sidebar_position: 6
---

# 🧩 Components

Components are modular, reusable pieces of functionality that can be attached to game objects. They follow an Entity-Component-System (ECS) pattern for clean, organized code.

## What are Components?

Components in YippyFramework are:
- **Reusable modules** that add functionality to objects
- **Instance-based** - attached to specific Roblox instances
- **Lifecycle managed** - automatically initialized and cleaned up
- **Event-driven** - respond to instance changes
- **Composable** - multiple components can work together

## Creating a Component

Components are created as modules with specific lifecycle methods:

```lua
local HealthComponent = {}
HealthComponent.__index = HealthComponent

-- Constructor
function HealthComponent.new(instance)
    local self = setmetatable({}, HealthComponent)
    
    self.Instance = instance
    self.MaxHealth = 100
    self.CurrentHealth = 100
    
    return self
end

-- Called when component starts
function HealthComponent:Start()
    print("Health component started for", self.Instance.Name)
    
    -- Set up health display
    self:CreateHealthBar()
end

-- Called when component is destroyed
function HealthComponent:Destroy()
    if self.HealthBar then
        self.HealthBar:Destroy()
    end
end

-- Component methods
function HealthComponent:TakeDamage(amount)
    self.CurrentHealth = math.max(0, self.CurrentHealth - amount)
    self:UpdateHealthBar()
    
    if self.CurrentHealth <= 0 then
        self:OnDeath()
    end
end

function HealthComponent:CreateHealthBar()
    -- Create UI health bar above character
end

function HealthComponent:OnDeath()
    -- Handle death logic
    self.Instance.Humanoid.PlatformStand = true
end

return HealthComponent
```

## Component System

The framework automatically manages components through tags:

```lua
-- Tag an instance to add a component
CollectionService:AddTag(npc, "HealthComponent")

-- The component will be automatically created and started
-- When the tag is removed, the component is destroyed
```

## Built-in Component Support

YippyFramework includes a component system that:
- **Auto-scans** for tagged instances
- **Manages lifecycle** (creation, starting, destruction)
- **Handles cleanup** when instances are destroyed
- **Supports inheritance** and component composition

## Using Components

### Adding Components
```lua
local CollectionService = game:GetService("CollectionService")

-- Add component to an NPC
CollectionService:AddTag(workspace.NPC, "HealthComponent")
CollectionService:AddTag(workspace.NPC, "AIComponent")

-- Components are automatically created and started
```

### Accessing Components
```lua
-- Get component from an instance
local healthComponent = ComponentManager:GetComponent(npc, "HealthComponent")
if healthComponent then
    healthComponent:TakeDamage(25)
end
```

### Component Communication
```lua
-- Components can reference each other
function AIComponent:Start()
    self.HealthComponent = ComponentManager:GetComponent(self.Instance, "HealthComponent")
end

function AIComponent:OnHealthChanged()
    if self.HealthComponent.CurrentHealth < 50 then
        self:FleeFromCombat()
    end
end
```

## Best Practices

- **Single responsibility**: Each component should handle one specific functionality
- **Loose coupling**: Components should be independent when possible
- **Use tags**: Let the framework manage component lifecycle through tags
- **Clean up**: Always clean up resources in the Destroy method
- **Event-driven**: Use signals/events for component communication

## Common Component Types

- **HealthComponent** - Manages HP and damage
- **MovementComponent** - Handles character movement
- **InventoryComponent** - Item storage and management
- **InteractionComponent** - Player interaction zones
- **EffectComponent** - Visual effects and animations

---

**Previous:** [← Built-ins](./built-ins) | **Next:** [VS Code Snippets →](./vscode-snippets)
