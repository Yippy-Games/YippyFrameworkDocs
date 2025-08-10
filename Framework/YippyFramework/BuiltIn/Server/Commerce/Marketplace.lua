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
local PURCHASE_ID_MEMORY = 50
local PendingPurchaseArgs = {}
--= Framework API =--

function Marketplace:Start()
    Marketplace.MarketplaceChannel = Framework.BuiltInServer.Network.Channel("Marketplace")
    Marketplace.Logger = Framework.BuiltInShared.Logger:GetLogger("Marketplace")
    Marketplace.MarketplaceChannel:On("PromptProduct", function(Player: Player, ProductName: string, ...)
        Marketplace:PromptProduct(Player, ProductName, ...)
    end)

    MarketplaceService.ProcessReceipt = Marketplace.ProcessReceipt
    MarketplaceService.PromptGamePassPurchaseFinished:Connect(
        function(Player: Player, ProductId: number, WasPurchased: boolean)
            if WasPurchased then
                local Registry =
                    Framework.BuiltInShared.Registry:GetModuleByParams("Gamepasses", "ProductId", ProductId)
                if not Registry then
                    Marketplace.Logger:Warn("No registry found for product.")
                    return
                end
                Marketplace.MarketplaceChannel:Fire("SuccessPurchase", Player, Registry.Name)
                Marketplace:GrantGamepasses(Player, Registry)
            end
        end
    )
end

function Marketplace:PlayerAdded(Player: Player)
    local Data = Framework.BuiltInServer.Datastore:GetData(Player)
    if Data == nil then
        return
    end

    local GamepassesRegistryList = Framework.BuiltInShared.Registry:GetRegistryModuleList("Gamepasses")
    if GamepassesRegistryList == nil then
        return
    end
    for _, Product in pairs(GamepassesRegistryList) do
        if
            Data.PlayerProfile.Products[Product.Name]
            or MarketplaceService:UserOwnsGamePassAsync(Player.UserId, Product.ProductId)
        then
            Marketplace:GrantGamepasses(Player, Product)
        end
    end
end

--= Methods =--

function Marketplace:PromptProduct(Player: Player, ProductName: string, ...)
    local RegistryProduct, Type = Marketplace:GetRegistryType(ProductName)

    if RegistryProduct.ServerCheck then
        local Result, Message = RegistryProduct:ServerCheck(Player, ...)
        if not Result then
            Framework.BuiltInServer.Notifications:Create(Player, "Warning", Message)
            return
        end
    end

    if RegistryProduct then
        if Type == "DevProduct" then
            local productIdToPrompt = RegistryProduct.ProductId
            if RegistryProduct.FirstTimeOfferId and RegistryProduct.FirstTimeOfferPrice then
                if not Marketplace:HasRedeemedFirstTimeOffer(Player, ProductName) then
                    productIdToPrompt = RegistryProduct.FirstTimeOfferId
                end
            end
            MarketplaceService:PromptProductPurchase(Player, productIdToPrompt)
        elseif Type == "Gamepasses" then
            MarketplaceService:PromptGamePassPurchase(Player, RegistryProduct.ProductId)
        end
        Marketplace.MarketplaceChannel:Fire("PromptProduct", Player, ProductName)
        local key = tostring(Player.UserId) .. "_" .. ProductName
        PendingPurchaseArgs[key] = { ... }
    else
        Marketplace.Logger:Warn("No registry found for product.")
    end
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

function Marketplace:GrantGamepasses(Player: Player, Registry: ModuleScript)
    coroutine.wrap(function()
        if not Registry.Redeem then
            self.Logger:Warn(string.format("Redeem function not found for product %s", Registry.Name))
            return
        end
        local Data = Framework.BuiltInServer.Datastore:GetData(Player)
        if not Data then
            return
        end

        local FirstimeGrant = true
        if Data.PlayerProfile.Products[Registry.Name] then
            FirstimeGrant = false
        end

        local args = { Marketplace:GetPendingArgs(Player, Registry.Name) }
        Registry:Redeem(Player, Data, FirstimeGrant, table.unpack(args))

        Framework.BuiltInServer.Datastore:InsertEntry(Player, "PlayerProfile/Products", Registry.Name, true)
        if FirstimeGrant then
            Framework.BuiltInServer.Notifications:Create(
                Player,
                "Success",
                "You have successfully purchased " .. Registry.Name .. "."
            )
        end
    end)()
end

function Marketplace:GrantProduct(Player: Player, Registry: ModuleScript)
    coroutine.wrap(function()
        local Data = Framework.BuiltInServer.Datastore:GetData(Player)
        if Data == nil then
            return
        end
        if Registry.Redeem ~= nil then
            local args = { Marketplace:GetPendingArgs(Player, Registry.Name) }
            Registry:Redeem(Player, Data, table.unpack(args))

            Framework.BuiltInServer.Notifications:Create(
                Player,
                "Success",
                "You have successfully purchased " .. Registry.Name .. "."
            )
        else
            Marketplace.Logger:Warn(string.format("Redeem function not found for product %s", Registry.Name))
        end
    end)()
end

function Marketplace.ProcessReceipt(receipt_info: table)
    local Player = Players:GetPlayerByUserId(receipt_info.PlayerId)
    if Player == nil then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
    local Registry =
        Framework.BuiltInShared.Registry:GetModuleByParams("DevProducts", "ProductId", receipt_info.ProductId)
    local isFirstTimeOffer = false

    if Registry == nil then
        Registry = Framework.BuiltInShared.Registry:GetModuleByParams(
            "DevProducts",
            "FirstTimeOfferId",
            receipt_info.ProductId
        )
        isFirstTimeOffer = true
    end

    if Registry == nil then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end

    local profile = Framework.BuiltInServer.Datastore:GetPlayerProfileAsync(Player)
    if profile ~= nil then
        return Marketplace:PurchaseIdCheckAsync(profile, receipt_info.PurchaseId, function()
            Marketplace.MarketplaceChannel:Fire("SuccessPurchase", Player, Registry.Name)
            Marketplace:GrantProduct(Player, Registry)

            if isFirstTimeOffer then
                Framework.BuiltInServer.Datastore:InsertEntry(
                    Player,
                    "PlayerProfile/FirstTimeOffers",
                    Registry.Name,
                    true
                )
            end
        end)
    else
        return Enum.ProductPurchaseDecision.NotProcessedYet
    end
end

function Marketplace:PurchaseIdCheckAsync(profile: table, purchase_id: string, grant_product_callback)
    if profile:IsActive() ~= true then
        return Enum.ProductPurchaseDecision.NotProcessedYet
    else
        local meta_data = profile.MetaData

        local local_purchase_ids = meta_data.MetaTags.ProfilePurchaseIds
        if local_purchase_ids == nil then
            local_purchase_ids = {}
            meta_data.MetaTags.ProfilePurchaseIds = local_purchase_ids
        end

        if table.find(local_purchase_ids, purchase_id) == nil then
            while #local_purchase_ids >= PURCHASE_ID_MEMORY do
                table.remove(local_purchase_ids, 1)
            end
            table.insert(local_purchase_ids, purchase_id)
            task.spawn(grant_product_callback)
        end

        local result = nil

        local function check_latest_meta_tags()
            local saved_purchase_ids = meta_data.MetaTagsLatest.ProfilePurchaseIds
            if saved_purchase_ids ~= nil and table.find(saved_purchase_ids, purchase_id) ~= nil then
                result = Enum.ProductPurchaseDecision.PurchaseGranted
            end
        end

        check_latest_meta_tags()

        local meta_tags_connection = profile.MetaTagsUpdated:Connect(function()
            check_latest_meta_tags()
            if profile:IsActive() == false and result == nil then
                result = Enum.ProductPurchaseDecision.NotProcessedYet
            end
        end)

        while result == nil do
            task.wait()
        end
        meta_tags_connection:Disconnect()
        return result
    end
end

function Marketplace:GetPendingArgs(Player: Player, ProductName: string)
    local key = tostring(Player.UserId) .. "_" .. ProductName
    local args = PendingPurchaseArgs[key]
    PendingPurchaseArgs[key] = nil
    return table.unpack(args or {})
end

function Marketplace:HasRedeemedFirstTimeOffer(Player: Player, ProductName: string): boolean
    local Data = Framework.BuiltInServer.Datastore:GetData(Player)
    if not Data then
        return false
    end

    return Data.PlayerProfile.FirstTimeOffers[ProductName] == true
end

return Marketplace
