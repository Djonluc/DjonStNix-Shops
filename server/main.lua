-- Get All shop data including dynamic prices
Bridge.CreateCallback('DjonStNix-Shops:server:GetShopData', function(source, cb, shopIndex)
    local shop = Config.Shops[shopIndex]
    if not shop then 
        return cb(nil) 
    end
    
    local clientData = {
        name = shop.shopName,
        items = {}
    }
    
    for i, item in ipairs(shop.items) do
        local finalPrice = Economy.CalculatePrice(item, shopIndex, i)
        local stock = Economy.GetStock(shopIndex, i)
        
        table.insert(clientData.items, {
            name = item.name,
            label = item.label or item.name, -- Use manual label if provided
            price = finalPrice,
            stock = stock,
            index = i,
            requiresLicense = item.requiresLicense or nil
        })
    end
    
    cb(clientData)
end)

-- Main Purchase Event
RegisterNetEvent('DjonStNix-Shops:server:PurchaseItem', function(shopIndex, itemIndex, amount)
    local src = source
    local playerData = Bridge.GetPlayerData(src)
    if not playerData then return end
    
    local shop = Config.Shops[shopIndex]
    local itemData = shop.items[itemIndex]
    if not itemData then return end
    
    -- Recalculate price server-side (NEVER trust client)
    local serverPrice = Economy.CalculatePrice(itemData, shopIndex, itemIndex)
    local totalPrice = serverPrice * amount
    local currentStock = Economy.GetStock(shopIndex, itemIndex)
    
    if Config.Debug then
        print(("^5[DjonStNix Debug]^7 Purchase Attempt | Player: ^3%s^7 | Item: ^3%s^7 | Amount: ^3%s^7 | Price: ^3%s^7"):format(src, itemData.name, amount, totalPrice))
    end
    
    -- Validation
    if amount <= 0 then return end
    
    -- Level 1: Stock Check
    if currentStock < amount then
        Bridge.Notify(src, "Not enough stock available!", "error")
        return
    end

    -- Level 2: Job/License Requirement Validation
    if itemData.requiredJob then
        if not Bridge.HasJob(src, itemData.requiredJob.name, itemData.requiredJob.grade) then
            Bridge.Notify(src, "You don't have the required job for this!", "error")
            return
        end
    end

    if itemData.requiresLicense then
        if not Bridge.HasLicense(src, itemData.requiresLicense) then
            Bridge.Notify(src, "You don't have the required license: " .. itemData.requiresLicense, "error")
            return
        end
    end
    
    -- Level 3: Payment
    if Bridge.RemoveMoney(src, 'cash', totalPrice, "djonstnix-shop-purchase") or Bridge.RemoveMoney(src, 'bank', totalPrice, "djonstnix-shop-purchase") then
        -- Payment Successful
    else
        Bridge.Notify(src, "You don't have enough money!", "error")
        return
    end
    
    -- Update Economy
    Economy.SetStock(shopIndex, itemIndex, currentStock - amount)
    Economy.RegisterPurchase(itemData.name)
    
    -- Add Item
    Bridge.AddItem(src, itemData.name, amount)
    
    Bridge.Notify(src, "Purchased " .. amount .. "x for " .. Shared.GetFormattedPrice(totalPrice), "success")
end)

-- Admin Commands
Bridge.AddCommand("setinflation", "Set global inflation (Admin Only)", {{name="value", help="Inflation multiplier (e.g. 1.2)"}}, function(source, args)
    local val = tonumber(args[1])
    if val then
        local maxInf = Config.MaxInflationMultiplier or 3.0
        val = math.min(maxInf, math.max(Config.InitialInflation or 1.0, val))
        Economy.GlobalInflation = val
        Shared.Notify("Global inflation set to " .. val, "success")
    end
end, "admin")

Bridge.AddCommand("testeconomy", "Log economy status", {}, function(source, args)
    print("^5[DjonStNix]^7 ─────────────────────────────")
    print("^5[DjonStNix]^7 Economy Status Report")
    print("^5[DjonStNix]^7 ─────────────────────────────")
    print(("^5[DjonStNix]^7 Inflation: ^3%s^7"):format(Economy.GlobalInflation))
    print(("^5[DjonStNix]^7 Money Supply: ^3$%s^7"):format(Economy.GlobalMoneySupply))
    for name, dem in pairs(Economy.ItemDemand) do
        print(("^5[DjonStNix]^7   📦 %s | Demand: ^3%s^7"):format(name, string.format("%.2f", dem)))
    end
    print("^5[DjonStNix]^7 ─────────────────────────────")
    print("^5[DjonStNix]^7 ─────────────────────────────")
end, "admin")

-- System Ready
CreateThread(function()
    while not Config or not Config.Shops or not Bridge.Ready do Wait(10) end
    Wait(2000) -- Allow other modules to init
    
    local framework = Bridge.Framework:gsub("^%l", string.upper)
    local inventory = (Bridge.Inventory or "auto"):gsub("^%l", string.upper)
    local target = (Bridge.Target or "none"):gsub("^%l", string.upper)
    local database = GetResourceState('oxmysql') == 'started' and "oxmysql (Connected)" or "none"
    local shopCount = #Config.Shops
    local npcCount = shopCount -- Standard architecture
    local blipCount = shopCount

    print("^5[DjonStNix Shops]^7 v5.0.0 Starting...")

    print(("^5[DjonStNix]^7 Framework: ^3%s^7 | Inventory: ^3%s^7 | Target: ^3%s^7 | SQL: ^3%s^7")
        :format(framework, inventory, target, database))

    print(("^5[DjonStNix]^7 Loaded ^3%s^7 shops | ^3%s^7 NPCs | ^3%s^7 blips")
        :format(shopCount, npcCount, blipCount))

    print("^2[DjonStNix]^7 System Ready.")
end)
