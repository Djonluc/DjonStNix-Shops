-- DjonStNix Shops - Map Blip Implementation
local activeBlips = {}

-- Create Blips with Advertising Support
function CreateShopBlips(statuses)
    -- Clear existing blips
    for _, blip in pairs(activeBlips) do
        RemoveBlip(blip)
    end
    activeBlips = {}

    if not Config.Shops then return end

    for i, shop in ipairs(Config.Shops) do
        if shop.blip and shop.blip.id > 0 then
            local blip = AddBlipForCoord(shop.coords.x, shop.coords.y, shop.coords.z)
            SetBlipSprite(blip, shop.blip.id)
            SetBlipDisplay(blip, 4)
            SetBlipScale(blip, shop.blip.scale or 0.6)
            SetBlipColour(blip, shop.blip.color or 2)
            SetBlipAsShortRange(blip, true)
            
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(shop.shopName or Config.BrandName)
            EndTextCommandSetBlipName(blip)

             -- Apply Advertising Effects
            if statuses and statuses[i] and statuses[i].advertised then
                SetBlipScale(blip, (shop.blip.scale or 0.6) * 1.5)
                SetBlipFlashes(blip, true)
                -- Optional: change color if advertised
                SetBlipColour(blip, 5) -- Yellow/Gold for advertised
            end
            
            activeBlips[i] = blip
        end
    end

end

-- Refresh Blips Event
RegisterNetEvent('DjonStNix-Shops:client:UpdateBlips', function()
    Bridge.TriggerCallback('DjonStNix-Shops:server:GetAllShopStatus', function(statuses)
        CreateShopBlips(statuses or {})
    end)
end)

-- Initialize blips
CreateThread(function()
    while not Config or not Config.Shops do Wait(100) end
    Wait(1000)
    -- Initializing silenty...
    TriggerEvent('DjonStNix-Shops:client:UpdateBlips')
end)

-- Export for manual refresh
exports('RefreshBlips', function()
    TriggerEvent('DjonStNix-Shops:client:UpdateBlips')
end)
