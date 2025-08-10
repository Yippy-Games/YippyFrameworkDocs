--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Roblox Services =--
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local Players = game:GetService("Players")
local MarketplaceService = game:GetService("MarketplaceService")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Framework =--
local Marketplace = {
    BuiltIn = true
}
--= Framework API =--

function Marketplace:Start()
    Marketplace.MarketplaceChannel = Framework.BuiltInClient.Network.Channel("Marketplace")
    Marketplace.Logger = Framework.BuiltInShared.Logger:GetLogger("Marketplace")

    Marketplace.MarketplaceChannel:On("PromptProduct", function(_: string)
        ReplicatedFirst.FrameworkAssets.Sounds.ShopPrompt:Play()
    end)

    Marketplace.MarketplaceChannel:On("SuccessPurchase", function(_: string)
        ReplicatedFirst.FrameworkAssets.Sounds.PurchaseShop:Play()
    end)
end

--= Methods =--

function Marketplace:PromptProduct(ProductName: string, ...)
    local Player = Players.LocalPlayer
    if not Player then
        return
    end
    local Registry = self:GetRegistryType(ProductName)
    if not Registry then
        return
    end
    if Marketplace:PossesProduct(ProductName) then
        return
    end
    Marketplace.MarketplaceChannel:Fire("PromptProduct", Registry.Name, ...)
end

function Marketplace:GetRegistryType(ProductName: string)
    local DevProducts = Framework.BuiltInShared.Registry:GetModuleByName("DevProducts", ProductName)
    local Gamepasses = Framework.BuiltInShared.Registry:GetModuleByName("Gamepasses", ProductName)

    if DevProducts then
        return DevProducts, "DevProduct"
    elseif Gamepasses then
        return Gamepasses, "Gamepasses"
    end
end

function Marketplace:PossesProduct(ProductName: string)
    local Data = Framework.BuiltInClient.Datastore:GetData()
    if not Data then
        return false
    end

    local RegistryProduct, _ = self:GetRegistryType(ProductName)
    if not RegistryProduct then
        return false
    end

    if
        Data
        and Data.PlayerProfile
        and Data.PlayerProfile.Products
        and Data.PlayerProfile.Products[RegistryProduct.Name]
    then
        return true
    end

    local success, ownsGamePass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, RegistryProduct.ProductId)
    end)

    if success then
        if ownsGamePass then
            return true
        end
    else
        Marketplace.Logger:Warn("Failed to check if user owns gamepass.")
    end
    return false
end

return Marketplace
