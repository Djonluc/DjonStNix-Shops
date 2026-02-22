-- ==================================================
-- DJONSTNIX SHOPS - PRODUCT DEFINITIONS
-- ==================================================
-- All items below interface with the dynamic economy engine.
-- elasticity: How much price fluctuates with demand (0.1 = low, 2.0 = high)
-- basePrice: Starting price before multipliers
-- baseStock: Target stock levels for restocking

Config = Config or {}
Config.Products = {
    ["general"] = {
        { name = "sandwich", basePrice = 15, baseStock = 100, elasticity = 0.5, category = "food" },
        { name = "water_bottle", basePrice = 10, baseStock = 100, elasticity = 0.3, category = "drink" },
        { name = "coffee", basePrice = 10, baseStock = 50, elasticity = 0.4, category = "drink" },
        { name = "bandage", basePrice = 50, baseStock = 50, elasticity = 0.8, category = "medical" },
        { name = "lighter", basePrice = 5, baseStock = 50, elasticity = 0.2, category = "item" },
        { name = "phone", basePrice = 850, baseStock = 30, elasticity = 0.5, category = "tech" },
        { name = "radio", basePrice = 250, baseStock = 30, elasticity = 0.5, category = "tech" },
    },
    ["liquor"] = {
        { name = "beer", basePrice = 12, baseStock = 60, elasticity = 0.6, category = "alcohol" },
        { name = "whiskey", basePrice = 25, baseStock = 40, elasticity = 0.7, category = "alcohol" },
        { name = "vodka", basePrice = 30, baseStock = 40, elasticity = 0.8, category = "alcohol" },
    },
    ["tools"] = {
        { name = "weapon_wrench", basePrice = 350, baseStock = 15, elasticity = 0.6, category = "tools" },
        { name = "weapon_hammer", basePrice = 250, baseStock = 15, elasticity = 0.6, category = "tools" },
        { name = "repairkit", basePrice = 750, baseStock = 40, elasticity = 0.8, category = "tools", requiredJob = {["mechanic"] = 0} },
        { name = "binoculars", basePrice = 150, baseStock = 10, elasticity = 0.4, category = "tools" },
    },
    ["armory"] = {
        { name = "weapon_knife", basePrice = 600, baseStock = 10, elasticity = 1.1, category = "weapons" },
        { name = "weapon_pistol", basePrice = 3500, baseStock = 5, elasticity = 1.4, category = "weapons", requiresLicense = "weapon" },
        { name = "pistol_ammo", basePrice = 200, baseStock = 100, elasticity = 0.9, category = "ammo" },
    },
    ["clandestine"] = {
        { name = "radioscanner", basePrice = 8500, baseStock = 2, elasticity = 2.5, category = "illegal" },
        { name = "lockpick", basePrice = 1200, baseStock = 15, elasticity = 1.8, category = "illegal" },
        { name = "screwdriverset", basePrice = 450, baseStock = 10, elasticity = 1.2, category = "illegal" },
    }
}
