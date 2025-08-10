--[[
__  ___                              ______r
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ZoneProduct = {}
ZoneProduct.__index = ZoneProduct
ZoneProduct.Tag = "ZoneProduct"
--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
local ZonePlus = require(ReplicatedFirst.Framework.Extra.Zoneplus)
--= Constructor =--

function ZoneProduct.new(Zone: Part)
    local self = setmetatable({}, ZoneProduct)

    local ProductName = Zone:GetAttribute("ProductName")
    if not ProductName then
        error("ZoneProduct: Zone must have a ProductName attribute")
    end

    self.Zone = ZonePlus.new(Zone)
    self.ProductName = ProductName
    self.lastPromptTime = {}
    self.debounceTime = 1

    self.Zone.playerEntered:Connect(function(player)
        self:HandlePlayerEntered(player)
    end)
    return self
end

function ZoneProduct:HandlePlayerEntered(player)
    -- Only handle local player
    if player ~= Players.LocalPlayer then
        return
    end

    -- Debounce check
    local currentTime = tick()
    if self.lastPromptTime[player] and (currentTime - self.lastPromptTime[player]) < self.debounceTime then
        return
    end
    self.lastPromptTime[player] = currentTime

    -- Check if player already owns the product
    if Framework.BuiltInClient.Marketplace:PossesProduct(self.ProductName) then
        Framework.BuiltInClient.Notifications:Create("Warning", "You already own this product!")
        return
    end

    -- Prompt the product purchase
    Framework.BuiltInClient.Marketplace:PromptProduct(self.ProductName)
end

function ZoneProduct:Destroy()
    if self.Zone then
        self.Zone:destroy()
    end
    self.lastPromptTime = {}
end

--= Methods =--

return ZoneProduct
