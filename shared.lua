Shared = {}

-- 🏪 Startup Banner
CreateThread(function()
    while not Config or not Config.BrandName do Wait(10) end
    print("^4╔══════════════════════════════════════════╗^7")
    print("^4║^7  🏪  ^3" .. Config.BrandName .. "^7  v5.0.0              ^4║^7")
    print("^4║^7  💻  Developer: ^3DjonStNix^7          ^4║^7")
    print("^4║^7  🌐  github.com/Djonluc                ^4║^7")
    print("^4║^7  💬  discord.gg/s7GPUHWrS7             ^4║^7")
    print("^4╚══════════════════════════════════════════╝^7")
end)

-- Branded notification helper
Shared.Notify = function(msg, type)
    local prefix = "["..Config.BrandName.."] "
    if IsDuplicityVersion() then
        -- Server side notification logic (can be expanded for specific frameworks)
        -- Placeholder for server-side print or triggered client event
        print(prefix .. msg)
    else
        -- Client side notification logic (QBCore)
        Bridge.Notify(nil, prefix .. msg, type or "primary") -- nil source for client
    end
end

-- Calculation Helpers
Shared.GetFormattedPrice = function(price)
    return Config.CurrencyPrefix .. string.format("%.2f", price)
end

-- Validate items
Shared.IsValidItem = function(itemName)
    -- This could hook into QBCore.Shared.Items if needed
    return true
end
