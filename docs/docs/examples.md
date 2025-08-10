---
sidebar_position: 10
---

# Examples

Real-world examples and code patterns to help you build amazing games with Yippy Framework.

## 🎮 Complete Game Examples

### Simple Clicker Game

A complete implementation of a cookie clicker-style game:

```lua
-- ServerScriptService/Services/ClickerService.lua
local Framework = require(game.ReplicatedFirst.Framework)

local ClickerService = Framework.CreateService {
    Name = "ClickerService"
}

function ClickerService:Start()
    Framework.Network:Listen("Click", function(player)
        local data = Framework.Datastore:Get(player, "PlayerData")
        data.Clicks = data.Clicks + 1
        data.Currency = data.Currency + data.ClickValue
        
        -- Notify client of update
        Framework.Network:Fire(player, "CurrencyUpdate", data.Currency)
        
        return data.Currency
    end)
    
    Framework.Network:Listen("BuyUpgrade", function(player, upgradeId)
        return self:PurchaseUpgrade(player, upgradeId)
    end)
end

function ClickerService:PurchaseUpgrade(player, upgradeId)
    local data = Framework.Datastore:Get(player, "PlayerData")
    local upgrade = self:GetUpgrade(upgradeId)
    
    if data.Currency >= upgrade.Cost then
        data.Currency = data.Currency - upgrade.Cost
        data.ClickValue = data.ClickValue + upgrade.ClickIncrease
        
        Framework.Network:Fire(player, "UpgradePurchased", upgradeId)
        return true
    end
    
    return false
end

function ClickerService:GetUpgrade(upgradeId)
    local upgrades = {
        ["cursor"] = { Cost = 10, ClickIncrease = 1 },
        ["grandma"] = { Cost = 100, ClickIncrease = 5 },
        ["factory"] = { Cost = 1000, ClickIncrease = 20 }
    }
    return upgrades[upgradeId]
end

return ClickerService
```

```lua
-- StarterPlayerScripts/Controllers/ClickerController.lua
local Framework = require(game.ReplicatedFirst.Framework)

local ClickerController = Framework.CreateController {
    Name = "ClickerController"
}

function ClickerController:Start()
    self:SetupUI()
    self:ConnectEvents()
end

function ClickerController:SetupUI()
    local screenGui = Framework.UI:CreateScreenGui("ClickerUI")
    
    -- Main click button
    self.clickButton = Framework.UI:CreateButton(screenGui, {
        Size = UDim2.new(0, 200, 0, 200),
        Position = UDim2.new(0.5, -100, 0.5, -100),
        Text = "🍪",
        TextSize = 50
    })
    
    -- Currency display
    self.currencyLabel = Framework.UI:CreateLabel(screenGui, {
        Size = UDim2.new(0, 300, 0, 50),
        Position = UDim2.new(0.5, -150, 0, 20),
        Text = "Cookies: 0",
        TextSize = 24
    })
    
    -- Upgrade shop
    self:CreateUpgradeShop(screenGui)
end

function ClickerController:ConnectEvents()
    self.clickButton.Activated:Connect(function()
        self:OnClick()
    end)
    
    Framework.Network:Connect("CurrencyUpdate", function(newCurrency)
        self:UpdateCurrency(newCurrency)
    end)
end

function ClickerController:OnClick()
    -- Visual feedback
    Framework.Tween:Play(self.clickButton, "bounce")
    Framework.Sounds:Play("click")
    
    -- Send to server
    Framework.Network:Request("Click")
end

return ClickerController
```

### Multiplayer Racing Game

Core racing game mechanics:

```lua
-- ServerScriptService/Services/RaceService.lua
local Framework = require(game.ReplicatedFirst.Framework)

local RaceService = Framework.CreateService {
    Name = "RaceService"
}

function RaceService:Start()
    self.races = {}
    self.playerTimes = {}
    
    self:SetupEvents()
    self:StartRaceLoop()
end

function RaceService:SetupEvents()
    Framework.Network:Listen("JoinRace", function(player)
        return self:AddPlayerToRace(player)
    end)
    
    Framework.Network:Listen("FinishRace", function(player, time)
        return self:RecordFinishTime(player, time)
    end)
end

function RaceService:AddPlayerToRace(player)
    local currentRace = self:GetCurrentRace()
    if currentRace and currentRace.Status == "Waiting" then
        table.insert(currentRace.Players, player)
        Framework.Network:FireAll("PlayerJoinedRace", player.Name)
        
        if #currentRace.Players >= 4 then
            self:StartRace(currentRace)
        end
        
        return true
    end
    return false
end

function RaceService:StartRace(race)
    race.Status = "Racing"
    race.StartTime = tick()
    
    -- Teleport players to start line
    for _, player in ipairs(race.Players) do
        self:TeleportToStart(player)
    end
    
    -- Countdown
    Framework.Network:FireClients(race.Players, "StartCountdown")
    
    wait(3)
    Framework.Network:FireClients(race.Players, "RaceStart")
end

return RaceService
```

## 🛠️ Common Patterns

### Data Management Pattern

```lua
-- Robust player data handling
local DataService = Framework.CreateService {
    Name = "DataService"
}

function DataService:Start()
    self.playerData = {}
    self:SetupPlayerEvents()
end

function DataService:SetupPlayerEvents()
    local Players = game:GetService("Players")
    
    Players.PlayerAdded:Connect(function(player)
        self:LoadPlayerData(player)
    end)
    
    Players.PlayerRemoving:Connect(function(player)
        self:SavePlayerData(player)
    end)
end

function DataService:LoadPlayerData(player)
    local data = Framework.Datastore:Get(player, "PlayerData")
    
    -- Validate and migrate data if needed
    data = self:ValidateData(data)
    data = self:MigrateData(data)
    
    self.playerData[player] = data
    
    -- Notify other services
    Framework.Event:Fire("PlayerDataLoaded", player, data)
end

function DataService:ValidateData(data)
    local defaults = {
        Level = 1,
        Experience = 0,
        Currency = 100,
        Inventory = {},
        Statistics = {
            PlayTime = 0,
            LastLogin = os.time()
        }
    }
    
    -- Merge with defaults
    for key, defaultValue in pairs(defaults) do
        if data[key] == nil then
            data[key] = defaultValue
        end
    end
    
    return data
end

function DataService:MigrateData(data)
    -- Handle data structure changes between versions
    if not data._version then
        data._version = 1
    end
    
    if data._version < 2 then
        -- Migration from v1 to v2
        data.NewField = "DefaultValue"
        data._version = 2
    end
    
    return data
end

return DataService
```

### Event-Driven Architecture

```lua
-- Using events for loose coupling between services
local QuestService = Framework.CreateService {
    Name = "QuestService"
}

function QuestService:Start()
    self:SetupEventListeners()
end

function QuestService:SetupEventListeners()
    -- Listen for player actions
    Framework.Event:Connect("EnemyKilled", function(player, enemyType)
        self:CheckKillQuests(player, enemyType)
    end)
    
    Framework.Event:Connect("ItemCollected", function(player, itemId)
        self:CheckCollectionQuests(player, itemId)
    end)
    
    Framework.Event:Connect("LevelUp", function(player, newLevel)
        self:CheckLevelQuests(player, newLevel)
    end)
end

function QuestService:CheckKillQuests(player, enemyType)
    local playerQuests = self:GetPlayerQuests(player)
    
    for _, quest in ipairs(playerQuests) do
        if quest.Type == "Kill" and quest.Target == enemyType then
            quest.Progress = quest.Progress + 1
            
            if quest.Progress >= quest.Requirement then
                self:CompleteQuest(player, quest)
            else
                self:UpdateQuestProgress(player, quest)
            end
        end
    end
end

return QuestService
```

### UI Component Pattern

```lua
-- Reusable UI components
local ShopController = Framework.CreateController {
    Name = "ShopController"
}

function ShopController:Start()
    self:CreateShopUI()
end

function ShopController:CreateShopUI()
    local screenGui = Framework.UI:CreateScreenGui("ShopUI")
    
    -- Main shop frame
    self.shopFrame = Framework.UI:CreateFrame(screenGui, {
        Size = UDim2.new(0, 600, 0, 400),
        Position = UDim2.new(0.5, -300, 0.5, -200),
        Visible = false
    })
    
    -- Create item slots
    self.itemSlots = {}
    for i = 1, 12 do
        local slot = self:CreateItemSlot(i)
        table.insert(self.itemSlots, slot)
    end
    
    -- Setup navigation
    self:CreateNavigation()
end

function ShopController:CreateItemSlot(index)
    local slot = Framework.UI:CreateFrame(self.shopFrame, {
        Size = UDim2.new(0, 90, 0, 90),
        Position = self:GetSlotPosition(index)
    })
    
    local itemImage = Framework.UI:CreateImageLabel(slot, {
        Size = UDim2.new(1, -10, 1, -30),
        Position = UDim2.new(0, 5, 0, 5)
    })
    
    local priceLabel = Framework.UI:CreateLabel(slot, {
        Size = UDim2.new(1, 0, 0, 20),
        Position = UDim2.new(0, 0, 1, -20),
        TextSize = 14
    })
    
    local buyButton = Framework.UI:CreateButton(slot, {
        Size = UDim2.new(1, 0, 0, 25),
        Position = UDim2.new(0, 0, 1, -25),
        Text = "BUY"
    })
    
    buyButton.Activated:Connect(function()
        self:PurchaseItem(index)
    end)
    
    return {
        Frame = slot,
        Image = itemImage,
        Price = priceLabel,
        Button = buyButton
    }
end

return ShopController
```

## 🎯 Specialized Use Cases

### Real-time Combat System

```lua
local CombatService = Framework.CreateService {
    Name = "CombatService"
}

function CombatService:Start()
    self.activeCombat = {}
    self:SetupCombatEvents()
end

function CombatService:SetupCombatEvents()
    Framework.Network:Listen("Attack", function(player, targetPlayer)
        return self:ProcessAttack(player, targetPlayer)
    end)
    
    Framework.Network:Listen("UseAbility", function(player, abilityId, target)
        return self:UseAbility(player, abilityId, target)
    end)
end

function CombatService:ProcessAttack(attacker, target)
    -- Validate attack
    if not self:CanAttack(attacker, target) then
        return false
    end
    
    -- Calculate damage
    local damage = self:CalculateDamage(attacker, target)
    
    -- Apply damage
    self:DealDamage(target, damage)
    
    -- Notify clients
    Framework.Network:FireAll("AttackPerformed", {
        Attacker = attacker.Name,
        Target = target.Name,
        Damage = damage
    })
    
    return true
end

function CombatService:CalculateDamage(attacker, target)
    local attackerData = Framework.Datastore:Get(attacker, "PlayerData")
    local targetData = Framework.Datastore:Get(target, "PlayerData")
    
    local baseDamage = attackerData.Stats.Attack
    local defense = targetData.Stats.Defense
    
    local damage = math.max(1, baseDamage - defense)
    
    -- Add randomness
    damage = damage * (0.8 + math.random() * 0.4)
    
    return math.floor(damage)
end

return CombatService
```

### Economy System

```lua
local EconomyService = Framework.CreateService {
    Name = "EconomyService"
}

function EconomyService:Start()
    self.marketData = {}
    self:LoadMarketData()
    self:StartMarketUpdates()
end

function EconomyService:StartMarketUpdates()
    spawn(function()
        while true do
            self:UpdateMarketPrices()
            wait(300) -- Update every 5 minutes
        end
    end)
end

function EconomyService:UpdateMarketPrices()
    for itemId, data in pairs(self.marketData) do
        -- Simulate market fluctuations
        local change = (math.random() - 0.5) * 0.1 -- ±10% change
        data.Price = math.max(1, data.Price * (1 + change))
        
        -- Update supply/demand
        data.Supply = math.max(0, data.Supply - data.Demand * 0.1)
        data.Demand = math.max(1, data.Demand + math.random(-5, 5))
    end
    
    -- Notify all players
    Framework.Network:FireAll("MarketUpdate", self.marketData)
end

return EconomyService
```

## 📱 Mobile-Specific Examples

### Touch-Optimized Controls

```lua
local MobileController = Framework.CreateController {
    Name = "MobileController"
}

function MobileController:Start()
    local UserInputService = game:GetService("UserInputService")
    
    if UserInputService.TouchEnabled then
        self:SetupTouchControls()
    end
end

function MobileController:SetupTouchControls()
    -- Virtual joystick for movement
    self.joystick = Framework.UI:CreateJoystick({
        Position = UDim2.new(0, 50, 1, -150),
        Size = UDim2.new(0, 100, 0, 100)
    })
    
    -- Action buttons
    self.actionButtons = {}
    local buttonConfigs = {
        { Name = "Jump", Position = UDim2.new(1, -70, 1, -150) },
        { Name = "Attack", Position = UDim2.new(1, -70, 1, -220) },
        { Name = "Interact", Position = UDim2.new(1, -140, 1, -150) }
    }
    
    for _, config in ipairs(buttonConfigs) do
        local button = Framework.UI:CreateButton(nil, {
            Size = UDim2.new(0, 60, 0, 60),
            Position = config.Position,
            Text = config.Name
        })
        
        self.actionButtons[config.Name] = button
        self:ConnectActionButton(button, config.Name)
    end
end

return MobileController
```

## 🧪 Testing Examples

### Unit Testing with Framework

```lua
-- Testing services and modules
local TestRunner = {}

function TestRunner:RunTests()
    self:TestDataService()
    self:TestCombatSystem()
    self:TestEconomyCalculations()
end

function TestRunner:TestDataService()
    local success, error = pcall(function()
        local testPlayer = game:GetService("Players"):CreateLocalPlayer()
        
        -- Test data loading
        local data = Framework.Datastore:Get(testPlayer, "TestData")
        assert(data ~= nil, "Data should not be nil")
        
        -- Test data validation
        assert(data.Level >= 1, "Level should be at least 1")
        assert(type(data.Currency) == "number", "Currency should be a number")
        
        Framework.Logger:Info("DataService tests passed")
    end)
    
    if not success then
        Framework.Logger:Error("DataService test failed: " .. error)
    end
end

return TestRunner
```

## 📚 Integration Examples

### Third-Party Service Integration

```lua
-- Integrating with external APIs
local AnalyticsService = Framework.CreateService {
    Name = "AnalyticsService"
}

function AnalyticsService:Start()
    self.httpService = game:GetService("HttpService")
    self.apiKey = "your-api-key"
    self.events = {}
    
    self:SetupEventTracking()
    self:StartEventBatching()
end

function AnalyticsService:TrackEvent(eventName, properties)
    table.insert(self.events, {
        Name = eventName,
        Properties = properties,
        Timestamp = os.time()
    })
end

function AnalyticsService:SendEvents()
    if #self.events == 0 then return end
    
    local eventData = {
        Events = self.events,
        GameId = game.GameId,
        PlaceId = game.PlaceId
    }
    
    local success, response = pcall(function()
        return self.httpService:PostAsync(
            "https://analytics-api.example.com/events",
            self.httpService:JSONEncode(eventData),
            Enum.HttpContentType.ApplicationJson
        )
    end)
    
    if success then
        self.events = {} -- Clear sent events
        Framework.Logger:Info("Analytics events sent successfully")
    else
        Framework.Logger:Warn("Failed to send analytics: " .. tostring(response))
    end
end

return AnalyticsService
```

## 🎨 Advanced UI Examples

### Dynamic Inventory System

```lua
local InventoryController = Framework.CreateController {
    Name = "InventoryController"
}

function InventoryController:Start()
    self:CreateInventoryUI()
    self:SetupDragAndDrop()
end

function InventoryController:CreateInventoryUI()
    self.inventoryGui = Framework.UI:CreateScreenGui("InventoryUI")
    
    -- Create grid of slots
    self.slots = {}
    for row = 1, 6 do
        self.slots[row] = {}
        for col = 1, 8 do
            local slot = self:CreateInventorySlot(row, col)
            self.slots[row][col] = slot
        end
    end
end

function InventoryController:CreateInventorySlot(row, col)
    local slot = Framework.UI:CreateFrame(self.inventoryGui, {
        Size = UDim2.new(0, 50, 0, 50),
        Position = UDim2.new(0, 10 + (col-1) * 55, 0, 10 + (row-1) * 55),
        BackgroundColor3 = Color3.new(0.2, 0.2, 0.2)
    })
    
    local itemImage = Framework.UI:CreateImageLabel(slot, {
        Size = UDim2.new(1, -4, 1, -4),
        Position = UDim2.new(0, 2, 0, 2),
        BackgroundTransparency = 1
    })
    
    return {
        Frame = slot,
        Image = itemImage,
        Item = nil
    }
end

return InventoryController
```

These examples demonstrate the power and flexibility of Yippy Framework. Use them as starting points for your own game development projects!

## Next Steps

Ready to build your own game?

- 🚀 **[Get Started](/docs/getting-started/installation)** - Set up the framework
- 📖 **[Getting Started](/docs/getting-started/quick-start)** - Learn the fundamentals  
- 🧩 **[Project Structure](/docs/getting-started/project-structure)** - Organize your code
- 🔧 **[Configuration](/docs/getting-started/configuration)** - Customize the framework
