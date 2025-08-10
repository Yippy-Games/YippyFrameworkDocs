--[[
__  ___                            ______               
\ \/ (_)___  ____  ____  __  __   / ____/___ _____ ___  ___  _____
 \  / / __ \/ __ \/ __ \/ / / /  / / __/ __ / __ __ \/ _ \/ ___/
 / / / /_/ / /_/ / /_/ / /_/ /  / /_/ / /_/ / / / / / /  __(__  )
/_/_/ .___/ .___/ .___/\__, /   \____/\__,_/_/ /_/ /_/\___/____/
   /_/   /_/   /_/    /____/
--]]

--= Root =--
local ButtonShop = {}
ButtonShop.__index = ButtonShop
ButtonShop.Tag = "ButtonShop"
--= Roblox Services =--
local Players = game:GetService("Players")
local ReplicatedFirst = game:GetService("ReplicatedFirst")
local MarketplaceService = game:GetService("MarketplaceService")
--= Modules & Config =--
local Framework = require(ReplicatedFirst.Framework)
--= Constructor =--

function ButtonShop.new(UIButton: GuiButton)
    local self = setmetatable({}, ButtonShop)
    self.UIButton = UIButton
    self.Logger = Framework.BuiltInShared.Logger:GetLogger(self.Tag)
    self.MarketplaceChannel = Framework.BuiltInClient.Network.Channel("Marketplace")
    self.ProductName = self.UIButton:GetAttribute("Product")
    self.PriceTextPath = self.UIButton:GetAttribute("PriceTextPath")
    self.OwnedPath = self.UIButton:GetAttribute("OwnedPath")
    self.DataOwnName = self.UIButton:GetAttribute("DataOwnName")
    self.RegistryProduct, self.Type = self:GetRegistryType()

    if not self.RegistryProduct then
        self.Logger:Warn("No registry found for product.", self.ProductName)
        return self
    end
    if self.OwnedPath then
        self.OwnedUI = Framework.BuiltInShared.Part:findInstanceByPath(self.UIButton, self.OwnedPath)
    end
    if self.PriceTextPath then
        self.PriceTextUI = Framework.BuiltInShared.Part:findInstanceByPath(self.UIButton, self.PriceTextPath)
    end

    self.FirstTimeOfferUI = nil

    self.UIButton:GetAttributeChangedSignal("Product"):Connect(function()
        self.ProductName = self.UIButton:GetAttribute("Product")
        self.RegistryProduct, self.Type = self:GetRegistryType()

        if not self.RegistryProduct then
            return self
        end
        self:SetupPrice()
    end)

    if self.PriceTextUI then
        self:SetupPrice()
    end

    self:OwnedCheck()

    self.UIButton.Activated:Connect(function()
        self:Clicked()
    end)

    Framework.BuiltInClient.Datastore
        :ListenToPrecisePathChanged({
            [1] = "PlayerProfile",
            [2] = "Products",
            [3] = self.RegistryProduct.Name,
        })
        :Connect(function()
            self:OwnedCheck()
        end)

    if self.DataOwnName then
        Framework.BuiltInClient.Datastore
            :ListenToPrecisePathChanged({
                [1] = "PlayerProfile",
                [2] = "Products",
                [3] = self.DataOwnName,
            })
            :Connect(function()
                self:OwnedCheck()
            end)
    end

    Framework.BuiltInClient.Datastore
        :ListenToPrecisePathChanged({
            [1] = "PlayerProfile",
            [2] = "FirstTimeOffers",
            [3] = self.RegistryProduct.Name,
        })
        :Connect(function()
            self:SetupPrice()
        end)
    return self
end

function ButtonShop:Destroy() end

--= Methods =--

function ButtonShop:Clicked()
    if not self.RegistryProduct then
        return
    end
    local Receiver = Players.LocalPlayer

    if self.RegistryProduct.ClientCheck then
        local Result, Message = self.RegistryProduct:ClientCheck(Players.LocalPlayer, Receiver)
        if not Result then
            self.Logger:Warn(string.format("Client check failed: %s", Message or "Unknown"))
            Framework.BuiltInClient.Notifications:Create(
                "Warning",
                Message or "The product is not available for purchase."
            )
            return
        end
    end

    if self:PossesProduct() then
        self.Logger:Warn("User already owns product.")
        Framework.BuiltInClient.Notifications:Create("Warning", "You already own this product.")
        return
    end

    self.MarketplaceChannel:Fire("PromptProduct", self.RegistryProduct.Name)
end

function ButtonShop:GetRegistryType()
    local DevProducts = Framework.BuiltInShared.Registry:GetModuleByName("DevProducts", self.ProductName)
    local Gamepasses = Framework.BuiltInShared.Registry:GetModuleByName("Gamepasses", self.ProductName)

    if DevProducts then
        return DevProducts, "DevProduct"
    elseif Gamepasses then
        return Gamepasses, "Gamepasses"
    end
end

function ButtonShop:OwnedCheck()
    if not self.RegistryProduct then
        return
    end

    local Data = Framework.BuiltInClient.Datastore:GetData()

    if
        Data
            and Data.PlayerProfile
            and Data.PlayerProfile.Products
            and Data.PlayerProfile.Products[self.RegistryProduct.Name]
        or self.DataOwnName and Data.PlayerProfile.Products[self.DataOwnName]
    then
        if self.PriceTextUI then
            self.PriceTextUI.Text = "Owned"
        end
        if self.OwnedUI then
            self.OwnedUI.Visible = true
        end
        return
    end

    local success, ownsGamePass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, self.RegistryProduct.ProductId)
    end)

    if success then
        if ownsGamePass then
            if self.PriceTextUI then
                self.PriceTextUI.Text = "Owned"
            end
            if self.OwnedUI then
                self.OwnedUI.Visible = true
            end
        end
    else
        self.Logger:Warn("Failed to check if user owns gamepass.")
    end
end

function ButtonShop:PossesProduct()
    if not self.RegistryProduct then
        return
    end
    local Data = Framework.BuiltInClient.Datastore:GetData()

    if
        Data
            and Data.PlayerProfile
            and Data.PlayerProfile.Products
            and Data.PlayerProfile.Products[self.RegistryProduct.Name]
        or self.DataOwnName and Data.PlayerProfile.Products[self.DataOwnName]
    then
        return true
    end

    local success, ownsGamePass = pcall(function()
        return MarketplaceService:UserOwnsGamePassAsync(Players.LocalPlayer.UserId, self.RegistryProduct.ProductId)
    end)

    if success then
        if ownsGamePass then
            return true
        end
    else
        self.Logger:Warn("Failed to check if user owns gamepass.")
    end
    return false
end

function ButtonShop:SetupPrice()
    if not self.RegistryProduct then
        return
    end
    if not self.PriceTextUI then
        return
    end
    local Data = Framework.BuiltInClient.Datastore:GetData()

    if
        Data
        and Data.PlayerProfile
        and Data.PlayerProfile.Products
        and Data.PlayerProfile.Products[self.RegistryProduct.Name]
    then
        self.PriceTextUI.Text = "Owned"
        return
    end

    if self.RegistryProduct.FirstTimeOfferId and self.RegistryProduct.FirstTimeOfferPrice then
        local hasRedeemedFirstTimeOffer = false
        if Data and Data.PlayerProfile and Data.PlayerProfile.FirstTimeOffers then
            hasRedeemedFirstTimeOffer = Data.PlayerProfile.FirstTimeOffers[self.RegistryProduct.Name] == true
        end

        if not hasRedeemedFirstTimeOffer then
            self.PriceTextUI.Text = "" .. self.RegistryProduct.FirstTimeOfferPrice

            if not self.FirstTimeOfferUI then
                local offerTemplate = ReplicatedFirst.Assets.UI.FirstTimeOffer.Offer
                self.FirstTimeOfferUI = offerTemplate:Clone()
                self.FirstTimeOfferUI.Parent = self.UIButton

                local originalPriceText = self.FirstTimeOfferUI.OriginalPrice
                if originalPriceText then
                    originalPriceText.Text = "" .. (self.RegistryProduct.PriceInRobux or "??")
                end
            end
            return
        end
    end

    if self.FirstTimeOfferUI then
        self.FirstTimeOfferUI:Destroy()
        self.FirstTimeOfferUI = nil
    end

    self.PriceTextUI.Text = "" .. self.RegistryProduct.PriceInRobux or "??"
end

return ButtonShop
