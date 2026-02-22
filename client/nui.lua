-- NUI Communication
local isOpen = false

-- Open Shop NUI
RegisterNetEvent('DjonStNix-Shops:client:OpenShop', function(data)
    if isOpen then return end
    
    Bridge.TriggerCallback('DjonStNix-Shops:server:GetShopData', function(result)
        if not result then return end
        
        -- Resolve images for NUI
        for _, item in ipairs(result.items) do
            item.image = Bridge.GetItemImage(item.name)
        end
        result.shopIndex = data.shopIndex

        SetNuiFocus(true, true)
        SendNUIMessage({
            action = "openShop",
            shopData = result,
            config = {
                brandName = Config.BrandName,
                currencyPrefix = Config.CurrencyPrefix
            }
        })
        isOpen = true
    end, data.shopIndex)
end)

-- Close NUI
RegisterNUICallback('close', function(data, cb)
    SetNuiFocus(false, false)
    isOpen = false
    cb('ok')
end)

-- Handle Purchase (Cart Checkout)
RegisterNUICallback('checkout', function(data, cb)
    -- data.cart = { {itemName = "sandwich", amount = 2, shopIndex = 1, itemIndex = 1}, ... }
    if data.cart and #data.cart > 0 then
        for _, item in ipairs(data.cart) do
            TriggerServerEvent('DjonStNix-Shops:server:PurchaseItem', item.shopIndex, item.itemIndex, item.amount)
        end
        Bridge.Notify(nil, "Checkout complete!", "success")
    end
    cb('ok')
end)

-- Proximity Close Thread
CreateThread(function()
    while true do
        Wait(1000)
        if isOpen then
            local ped = PlayerPedId()
            local coords = GetEntityCoords(ped)
            local currentShop = nil
            
            -- Find the shop we are currently interacting with
            -- Note: We should ideally pass the shop coords to this script when opening
            -- For now, we'll check all shop distances
            local tooFar = true
            for _, shop in ipairs(Config.Shops) do
                local dist = #(coords - vector3(shop.coords.x, shop.coords.y, shop.coords.z))
                if dist < (Config.InteractionDistance or 5.0) + 2.0 then
                    tooFar = false
                    break
                end
            end
            
            if tooFar then
                SetNuiFocus(false, false)
                SendNUIMessage({ action = "close" })
                isOpen = false
            end
        end
    end
end)
