-- Global table for owned shops
local OwnedShops = {}

-- ==================================================
-- PERSISTENCE HELPERS (MySQL)
-- ==================================================
local function LoadFranchises()
    MySQL.query('SELECT * FROM djonstnix_shops_franchises', {}, function(results)
        if results then
            for _, row in ipairs(results) do
                OwnedShops[row.shop_index] = {
                    owner = row.owner_identifier,
                    level = row.level,
                    markup = row.markup,
                    profit = row.profit,
                    advertised = row.advertised == 1 or row.advertised == true
                }
            end
            print("^4["..Config.BrandName.." Franchise]^7 Data loaded from database.")
        end
    end)
end

local function SaveFranchise(shopIndex)
    local shop = OwnedShops[shopIndex]
    if not shop then return end
    
    MySQL.update('INSERT INTO djonstnix_shops_franchises (shop_index, owner_identifier, level, markup, profit, advertised) VALUES (?, ?, ?, ?, ?, ?) ON DUPLICATE KEY UPDATE owner_identifier = ?, level = ?, markup = ?, profit = ?, advertised = ?', 
    {shopIndex, shop.owner, shop.level, shop.markup, shop.profit, shop.advertised and 1 or 0, shop.owner, shop.level, shop.markup, shop.profit, shop.advertised and 1 or 0})
end

-- Initialize
CreateThread(function()
    Wait(2000) -- Wait for DB
    LoadFranchises()
end)


-- Buy Franchise Event
RegisterNetEvent('DjonStNix-Shops:server:BuyFranchise', function(shopIndex)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    
    if OwnedShops[shopIndex] then
        Bridge.Notify(src, "This shop is already owned!", "error")
        return
    end
    
    if Bridge.RemoveMoney(src, 'bank', Config.FranchisePrice, "djonstnix-franchise-buy") then
        OwnedShops[shopIndex] = {
            owner = identifier,
            level = 1,
            markup = 0.0,
            profit = 0
        }
        SaveFranchise(shopIndex)
        Bridge.Notify(src, "You now own this shop franchise!", "success")
    else
        Bridge.Notify(src, "Insufficient funds in bank!", "error")
    end
end)

-- Update Franchise Markup
RegisterNetEvent('DjonStNix-Shops:server:UpdateFranchise', function(shopIndex, markup)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    local shop = OwnedShops[shopIndex]
    
    if not shop or shop.owner ~= identifier then return end
    
    local maxLimit = Config.FranchiseLevels[shop.level].maxMarkup
    if markup > maxLimit then markup = maxLimit end
    
    shop.markup = markup
    SaveFranchise(shopIndex)
    Bridge.Notify(src, "Shop markup updated to " .. (markup * 100) .. "%", "success")
end)


-- Withdraw Profit
RegisterNetEvent('DjonStNix-Shops:server:WithdrawProfit', function(shopIndex)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    local shop = OwnedShops[shopIndex]
    
    if not shop or shop.owner ~= identifier then return end
    
    local amount = shop.profit
    if amount <= 0 then
        Bridge.Notify(src, "No profit to withdraw!", "error")
        return
    end
    
    shop.profit = 0
    SaveFranchise(shopIndex)
    Bridge.AddMoney(src, 'bank', amount, "djonstnix-franchise-withdrawal")
    Bridge.Notify(src, "Withdrawn " .. Shared.GetFormattedPrice(amount) .. " to your bank.", "success")
end)

-- GET FRANCHISE INFO CALLBACK
Bridge.CreateCallback('DjonStNix-Shops:server:GetFranchiseInfo', function(source, cb, shopIndex)
    cb(OwnedShops[shopIndex])
end)

Bridge.CreateCallback('DjonStNix-Shops:server:GetAllShopStatus', function(source, cb)
    cb(OwnedShops)
end)


-- Advertise Franchise
RegisterNetEvent('DjonStNix-Shops:server:AdvertiseFranchise', function(shopIndex)
    local src = source
    local identifier = Bridge.GetIdentifier(src)
    local shop = OwnedShops[shopIndex]
    
    if not shop or shop.owner ~= identifier then return end
    
    if Bridge.RemoveMoney(src, 'bank', Config.AdvertisePrice or 5000, "djonstnix-franchise-adv") then
        shop.advertised = true
        SaveFranchise(shopIndex)
        TriggerClientEvent('DjonStNix-Shops:client:UpdateBlips', -1)
        Bridge.Notify(src, "Advertising campaign started! Your shop is now highlighted on the map.", "success")
        
        -- Reset after 1 hour (Optional)
        SetTimeout(3600000, function()
            if OwnedShops[shopIndex] then
                OwnedShops[shopIndex].advertised = false
                SaveFranchise(shopIndex)
                TriggerClientEvent('DjonStNix-Shops:client:UpdateBlips', -1)
            end
        end)
    else
        Bridge.Notify(src, "Insufficient funds to start advertising!", "error")
    end
end)
