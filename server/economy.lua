Economy = {}
Economy.GlobalInflation = Config.InitialInflation
Economy.ItemDemand = {}
Economy.GlobalMoneySupply = 0

local ShopStocks = {}

-- Initialize Economy
local function InitEconomy()
    local shopCount = 0
    local itemCount = 0
    for i, shop in ipairs(Config.Shops) do
        ShopStocks[i] = {}
        shopCount = shopCount + 1
        for j, item in ipairs(shop.items) do
            local variance = math.random(-10, 10)
            ShopStocks[i][j] = math.max(0, item.baseStock + variance)
            itemCount = itemCount + 1
            if not Economy.ItemDemand[item.name] then
                Economy.ItemDemand[item.name] = 1.0
            end
        end
    end
    -- Initialized silently, summary in main.lua
end

-- Final Price Formula
Economy.CalculatePrice = function(item, shopIndex, itemIndex)
    local shop = Config.Shops[shopIndex]
    local area = Config.AreaTypes[shop.areaType]
    
    local demandMultiplier = Economy.ItemDemand[item.name] or 1.0
    
    -- Scarcity
    local stock = (ShopStocks[shopIndex] and ShopStocks[shopIndex][itemIndex]) or item.baseStock
    local scarcityMultiplier = 1.0
    if stock < (item.baseStock * 0.1) then
        scarcityMultiplier = 1.5
    elseif stock == 0 then
        scarcityMultiplier = 2.0
    end
    
    local locationMultiplier = (area and area.priceMultiplier) or 1.0
    local inflationMultiplier = Economy.GlobalInflation or 1.0
    
    local totalMultiplier = demandMultiplier * scarcityMultiplier * locationMultiplier * inflationMultiplier
    
    -- Level 3: Hard Safety Ceiling
    if totalMultiplier > (Config.MaxTotalMultiplier or 6.0) then
        totalMultiplier = Config.MaxTotalMultiplier
    end

    local finalPrice = item.basePrice * totalMultiplier
    
    local volatilityType = area.volatility or "standard"
    local volatilityChance = Config.VolatilitySettings[volatilityType] or 0.05
    if math.random() < 0.1 then
        local adjustment = 1.0 + (math.random() * volatilityChance * 2 - volatilityChance)
        finalPrice = finalPrice * adjustment
    end
    
    return math.ceil(finalPrice)
end

-- Update Money Supply and Inflation
local function UpdateInflation()
    local totalMoney = 0
    local players = Bridge.GetPlayers()
    for _, id in ipairs(players) do
        local data = Bridge.GetPlayerData(id)
        if data and data.money then
            totalMoney = totalMoney + (data.money.cash or 0) + (data.money.bank or 0)
        end
    end
    
    Economy.GlobalMoneySupply = totalMoney
    
    if totalMoney > Config.InflationMoneySupplyThreshold then
        local excess = (totalMoney - Config.InflationMoneySupplyThreshold) / 100000
        Economy.GlobalInflation = math.min(Config.MaxInflationMultiplier or 3.0, Config.InitialInflation + (excess * Config.InflationGrowthRate))
    else
        Economy.GlobalInflation = math.max(Config.InitialInflation, Economy.GlobalInflation - Config.InflationDecayRate)
    end
end

-- Item Demand Decay
local function DecelerateDemand()
    for itemName, multiplier in pairs(Economy.ItemDemand) do
        if multiplier > 1.0 then
            Economy.ItemDemand[itemName] = math.max(1.0, multiplier - Config.DemandCoolDownRate)
        end
    end
end

Economy.GetStock = function(shopIdx, itemIdx) return ShopStocks[shopIdx][itemIdx] end
Economy.SetStock = function(shopIdx, itemIdx, val) ShopStocks[shopIdx][itemIdx] = val end

Economy.RegisterPurchase = function(itemName)
    Economy.ItemDemand[itemName] = math.min(Config.MaxDemandMultiplier or 2.0, (Economy.ItemDemand[itemName] or 1.0) + Config.DemandIncreaseFactor)
end

-- ==================================================
-- PERSISTENCE HELPERS (MySQL)
-- ==================================================
local function LoadEconomy()
    -- Load Inflation
    MySQL.query('SELECT inflation FROM djonstnix_shops_economy WHERE id = 1', {}, function(result)
        if result and result[1] then
            Economy.GlobalInflation = result[1].inflation
            if Config.Debug then
                print(("^5[DjonStNix Debug]^7 Inflation loaded: ^3%s^7"):format(Economy.GlobalInflation))
            end
        end
    end)

    -- Load Demand
    MySQL.query('SELECT item_name, demand_multiplier FROM djonstnix_shops_demand', {}, function(results)
        if results then
            for _, row in ipairs(results) do
                Economy.ItemDemand[row.item_name] = row.demand_multiplier
            end
            if Config.Debug then
                print("^5[DjonStNix Debug]^7 Demand multipliers loaded")
            end
        end
    end)

    -- Load Stock (Per Shop)
    MySQL.query('SELECT shop_index, item_name, current_stock FROM djonstnix_shops_stock', {}, function(results)
        if results then
            for _, row in ipairs(results) do
                if ShopStocks[row.shop_index] then
                    -- Find item index in Config.Shops
                    local shop = Config.Shops[row.shop_index]
                    if shop then
                        for j, item in ipairs(shop.items) do
                            if item.name == row.item_name then
                                ShopStocks[row.shop_index][j] = row.current_stock
                                break
                            end
                        end
                    end
                end
            end
            -- Silently loaded
        end
    end)
end

local function SaveEconomy()
    -- Save Inflation
    MySQL.update('UPDATE djonstnix_shops_economy SET inflation = ? WHERE id = 1', {Economy.GlobalInflation})

    -- Save Demand (Batch update would be better, but simple loop for now)
    for name, multiplier in pairs(Economy.ItemDemand) do
        MySQL.update('INSERT INTO djonstnix_shops_demand (item_name, demand_multiplier) VALUES (?, ?) ON DUPLICATE KEY UPDATE demand_multiplier = ?', {name, multiplier, multiplier})
    end

    -- Save Stock (Per Shop)
    for i, stocks in pairs(ShopStocks) do
        local shop = Config.Shops[i]
        if shop then
            for j, stockVal in pairs(stocks) do
                local item = shop.items[j]
                if item then
                    MySQL.update('INSERT INTO djonstnix_shops_stock (shop_index, item_name, current_stock) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE current_stock = ?', {i, item.name, stockVal, stockVal})
                end
            end
        end
    end
end

-- Threads
CreateThread(function()
    InitEconomy()
    Wait(1000) -- Small delay to ensure DB is ready
    LoadEconomy()
    
    local saveCounter = 0
    while true do
        Wait(60000 * 5) -- Every 5 minutes
        UpdateInflation()
        DecelerateDemand()
        
        saveCounter = saveCounter + 1
        if saveCounter >= 6 then -- Every 30 minutes save to DB
            SaveEconomy()
            saveCounter = 0
        end
    end
end)
