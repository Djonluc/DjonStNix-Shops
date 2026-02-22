Shared = {}



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
