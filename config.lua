Config = Config or {}
Config.Debug = false -- Set to true for deep logging

-- ==================================================
-- DJONSTNIX SHOPS - PRODUCT DEFINITIONS
-- ==================================================
Config.Products = {
    ["general"] = {
        { name = "sandwich", basePrice = 3.50, baseStock = 50, elasticity = 0.5, category = "food" },
        { name = "water_bottle", basePrice = 2.00, baseStock = 50, elasticity = 0.3, category = "drink" },
        { name = "coffee", basePrice = 2.50, baseStock = 25, elasticity = 0.4, category = "drink" },
        { name = "bandage", basePrice = 4.99, baseStock = 25, elasticity = 0.8, category = "medical" },
        { name = "lighter", basePrice = 1.99, baseStock = 25, elasticity = 0.2, category = "item" },
        { name = "phone", basePrice = 1199.99, baseStock = 15, elasticity = 0.5, category = "tech" },
        { name = "radio", basePrice = 149.99, baseStock = 15, elasticity = 0.5, category = "tech" },
    },
    ["liquor"] = {
        { name = "beer", basePrice = 2.99, baseStock = 30, elasticity = 0.6, category = "alcohol" },
        { name = "whiskey", basePrice = 14.99, baseStock = 20, elasticity = 0.7, category = "alcohol" },
        { name = "vodka", basePrice = 12.99, baseStock = 20, elasticity = 0.8, category = "alcohol" },
    },
    ["tools"] = {
        { name = "weapon_wrench", basePrice = 12.50, baseStock = 7, elasticity = 0.6, category = "tools" },
        { name = "weapon_hammer", basePrice = 9.99, baseStock = 7, elasticity = 0.6, category = "tools" },
        { name = "repairkit", basePrice = 24.95, baseStock = 20, elasticity = 0.8, category = "tools", requiredJob = {["mechanic"] = 0} },
        { name = "binoculars", basePrice = 29.99, baseStock = 5, elasticity = 0.4, category = "tools" },
    },
    ["armory"] = {
        { name = "weapon_knife", basePrice = 19.99, baseStock = 5, elasticity = 1.1, category = "weapons" },
        { name = "weapon_pistol", basePrice = 450.00, baseStock = 2, elasticity = 1.4, category = "weapons", requiresLicense = "weapon" },
        { name = "pistol_ammo", basePrice = 1.25, baseStock = 500, elasticity = 0.9, category = "ammo" }, -- Per round price
    },
    ["clandestine"] = {
        { name = "radioscanner", basePrice = 349.99, baseStock = 1, elasticity = 2.5, category = "illegal" },
        { name = "lockpick", basePrice = 45.00, baseStock = 7, elasticity = 1.8, category = "illegal" },
        { name = "screwdriverset", basePrice = 12.50, baseStock = 5, elasticity = 1.2, category = "illegal" },
    }
}

-- ==================================================
-- SYSTEM BRANDING & FRAMEWORK
-- ==================================================
Config.BrandName = "DjonStNix Shops"
Config.CurrencyPrefix = "$"

-- Framework Settings (Set to "auto" to detect, or "qb" / "esx")
Config.Framework = "auto"
Config.Inventory = "auto" -- "auto", "qb", "ox", "qs"
Config.Target = "auto" -- "auto", "qb", "ox", "none"

-- Interaction Settings
Config.UseTarget = true
Config.TargetIcon = "fas fa-shopping-basket"
Config.InteractionDistance = 2.5

-- Toggles
Config.UseGreetings = true
Config.UseBranding = true

-- ==================================================
-- GLOBAL ECONOMY ENGINE SETTINGS
-- ==================================================
Config.InitialInflation = 1.0
Config.InflationMoneySupplyThreshold = 10000000 -- Global money after which inflation scales
Config.InflationGrowthRate = 0.001 -- Growth per 100k over threshold
Config.InflationDecayRate = 0.0001 -- Natural hourly decay
Config.DemandIncreaseFactor = 0.01 -- Price jump per purchase
Config.DemandCoolDownRate = 0.005 -- Demand decay per hour

-- Safety Caps (Prevents prices from getting too ridiculous)
Config.MaxInflationMultiplier = 3.0 -- Caps global inflation at 300%
Config.MaxDemandMultiplier = 2.0    -- Caps individual item popularity jump at 200%
Config.MaxTotalMultiplier = 6.0      -- Absolute ceiling for combined multipliers (Safety Lock)

Config.VolatilitySettings = {
    ["standard"] = 0.05, -- 5% price jitter
    ["volatile"] = 0.15, -- 15% price jitter
    ["extreme"] = 0.30   -- 30% price jitter (Blackmarket)
}

-- ==================================================
-- AREA BEHAVIOR DEFINITIONS
-- ==================================================
Config.AreaTypes = {
    ["premium"] = { priceMultiplier = 1.30, restockRate = 1.8 },
    ["city"] = { priceMultiplier = 1.05, restockRate = 1.0 },
    ["suburban"] = { priceMultiplier = 0.95, restockRate = 0.8 },
    ["rural"] = { priceMultiplier = 0.80, restockRate = 0.6 },
    ["blackmarket"] = { priceMultiplier = 2.50, restockRate = 0.2, volatility = "extreme" }
}

-- ==================================================
-- DJONSTNIX SHOP NETWORK (Expanded)
-- ==================================================
Config.Shops = {
    -- 24/7 Supermarkets
    { shopName = "DjonStNix 24/7 - Legion Square", coords = vector4(24.47, -1346.62, 29.5, 271.66), areaType = "city", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Banham Canyon", coords = vector4(-3039.54, 584.38, 7.91, 17.27), areaType = "suburban", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Barbareno Rd", coords = vector4(-3242.97, 1000.01, 12.83, 357.57), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Paleto Bay", coords = vector4(1728.8, 6415.5, 35.04, 245.0), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Sandy Shores", coords = vector4(1960.0, 3740.0, 32.34, 301.0), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Senora Fwy", coords = vector4(549.13, 2670.85, 42.16, 99.39), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Grapeseed", coords = vector4(2677.47, 3279.76, 55.24, 335.08), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Tataviam Mt", coords = vector4(2556.6, 380.8, 108.6, 356.6), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },
    { shopName = "DjonStNix 24/7 - Clinton Ave", coords = vector4(372.6, 326.9, 103.5, 253.7), areaType = "suburban", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 52, color = 2, scale = 0.6 } },

    -- LTD Gasoline
    { shopName = "DjonStNix LTD - Davis", coords = vector4(-47.0, -1758.2, 29.4, 45.0), areaType = "city", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 361, color = 5, scale = 0.6 } },
    { shopName = "DjonStNix LTD - Rockford Hills", coords = vector4(-706.0, -913.9, 19.2, 88.0), areaType = "premium", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 361, color = 5, scale = 0.6 } },
    { shopName = "DjonStNix LTD - Tongva Hills", coords = vector4(-1820.0, 794.0, 138.0, 135.4), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 361, color = 5, scale = 0.6 } },
    { shopName = "DjonStNix LTD - Mirror Park", coords = vector4(1164.7, -322.9, 69.2, 101.7), areaType = "suburban", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 361, color = 5, scale = 0.6 } },
    { shopName = "DjonStNix LTD - Grapeseed", coords = vector4(1697.8, 4922.9, 42.0, 324.7), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 361, color = 5, scale = 0.6 } },

    -- Rob's Liquor
    { shopName = "DjonStNix Liquor - Little Seoul", coords = vector4(-1221.5, -908.1, 12.3, 35.4), areaType = "city", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 93, color = 47, scale = 0.6 } },
    { shopName = "DjonStNix Liquor - Morningwood", coords = vector4(-1486.5, -377.6, 40.1, 139.5), areaType = "suburban", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 93, color = 47, scale = 0.6 } },
    { shopName = "DjonStNix Liquor - Chumash", coords = vector4(-2966.3, 391.4, 15.0, 87.4), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 93, color = 47, scale = 0.6 } },
    { shopName = "DjonStNix Liquor - Route 68", coords = vector4(1165.1, 2710.8, 38.1, 179.4), areaType = "rural", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 93, color = 47, scale = 0.6 } },
    { shopName = "DjonStNix Liquor - Murrieta Hts", coords = vector4(1134.2, -982.9, 46.4, 277.2), areaType = "city", npcModel = "mp_m_shopkeep_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["general"], blip = { id = 93, color = 47, scale = 0.6 } },

    -- Ammu-Nation
    { shopName = "DjonStNix Armory - Rockford Hills", coords = vector4(-661.9, -933.5, 21.8, 177.0), areaType = "premium", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Cypress Flats", coords = vector4(809.6, -2159.1, 29.6, 1.4), areaType = "city", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Sandy Shores", coords = vector4(1692.6, 3761.3, 34.7, 227.6), areaType = "rural", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Paleto Bay", coords = vector4(-331.2, 6085.3, 31.4, 228.0), areaType = "rural", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Hawick", coords = vector4(253.6, -51.0, 69.9, 72.9), areaType = "suburban", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Pillbox Hill", coords = vector4(23.0, -1105.6, 29.8, 162.9), areaType = "city", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Tataviam Mt", coords = vector4(2567.4, 292.5, 108.7, 349.6), areaType = "rural", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Route 68", coords = vector4(-1118.5, 2700.0, 18.5, 221.8), areaType = "rural", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - La Mesa", coords = vector4(841.9, -1035.3, 28.1, 1.5), areaType = "city", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Morningwood", coords = vector4(-1304.1, -395.1, 36.7, 75.0), areaType = "suburban", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },
    { shopName = "DjonStNix Armory - Gt Ocean Hwy", coords = vector4(-3173.3, 1088.8, 20.8, 244.1), areaType = "rural", npcModel = "s_m_y_ammucity_01", npcScenario = "WORLD_HUMAN_COP_IDLES", items = Config.Products["armory"], blip = { id = 110, color = 1, scale = 0.6 } },

    -- Clandestine & Tools
    -- Black markets require a VPN to access and DO NOT have map blips.
    { shopName = "DjonStNix Clandestine - Sandy Shores", coords = vector4(1959.0, 3740.0, 32.3, 300.0), areaType = "blackmarket", npcModel = "G_M_Y_Lost_01", npcScenario = "WORLD_HUMAN_SMOKING", items = Config.Products["clandestine"], requiresAccessItem = "vpn" },
    { shopName = "DjonStNix Clandestine - LS Sewers", coords = vector4(746.07, -1004.83, 22.86, 271.74), areaType = "blackmarket", npcModel = "g_m_y_famca_01", npcScenario = "WORLD_HUMAN_DRUG_DEALER", items = Config.Products["clandestine"], requiresAccessItem = "vpn" },
    { shopName = "DjonStNix Clandestine - Empty Warehouse", coords = vector4(973.86, -2147.28, 29.47, 269.83), areaType = "blackmarket", npcModel = "g_m_m_chiboss_01", npcScenario = "WORLD_HUMAN_STAND_MOBILE", items = Config.Products["clandestine"], requiresAccessItem = "vpn" },

    { shopName = "DjonStNix Supply - Davis", coords = vector4(47.2, -1748.8, 29.6, 50.0), areaType = "city", npcModel = "s_m_m_autoshop_01", npcScenario = "WORLD_HUMAN_CLIPBOARD", items = Config.Products["tools"], blip = { id = 566, color = 64, scale = 0.6 } },
    { shopName = "DjonStNix Supply - Grapeseed", coords = vector4(2747.7, 3472.8, 55.6, 255.0), areaType = "rural", npcModel = "s_m_m_autoshop_01", npcScenario = "WORLD_HUMAN_CLIPBOARD", items = Config.Products["tools"], blip = { id = 566, color = 64, scale = 0.6 } },
    { shopName = "DjonStNix Supply - Paleto Bay", coords = vector4(-421.8, 6136.1, 31.8, 228.2), areaType = "rural", npcModel = "s_m_m_autoshop_01", npcScenario = "WORLD_HUMAN_CLIPBOARD", items = Config.Products["tools"], blip = { id = 566, color = 64, scale = 0.6 } }
}


-- ==================================================
-- PLAYER FRANCHISE SYSTEM (UNDER DEVELOPMENT)
-- Note: This system is currently disabled in fxmanifest.lua
-- ==================================================
Config.FranchisePrice = 75000 -- Initial investment
Config.AdvertisePrice = 5000 -- Price for 1 hour of map highlighting
Config.FranchiseLevels = {
    [1] = { maxMarkup = 0.20, stockCapacity = 1.0, perks = "Standard Revenue" },
    [2] = { maxMarkup = 0.35, stockCapacity = 1.5, perks = "Expanded Stock & Priority Restock" },
    [3] = { maxMarkup = 0.50, stockCapacity = 2.5, perks = "Maximum Markup & Inflation Shield" },
}
