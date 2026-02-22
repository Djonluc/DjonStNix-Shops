local spawnedPeds = {}

local function CreateShopNPC(shop, index)
    local model = GetHashKey(shop.npcModel)
    RequestModel(model)
    while not HasModelLoaded(model) do Wait(0) end
    
    local ped = CreatePed(0, model, shop.coords.x, shop.coords.y, shop.coords.z - 1.0, shop.coords.w, false, false)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    FreezeEntityPosition(ped, true)
    
    if shop.npcScenario then
        TaskStartScenarioInPlace(ped, shop.npcScenario, 0, true)
    end
    
    if Config.UseTarget and Bridge.Target ~= "none" then
        if Bridge.Target == "qb" then
            exports['qb-target']:AddTargetEntity(ped, {
                options = {
                    {
                        type = "client",
                        event = "DjonStNix-Shops:client:OpenShop",
                        icon = Config.TargetIcon,
                        label = "Browse Shop",
                        shopIndex = index
                    }
                    -- Franchise option disabled for now
                },
                distance = Config.InteractionDistance
            })
        elseif Bridge.Target == "ox" then
            exports.ox_target:addLocalEntity(ped, {
                {
                    name = 'djonstnix_shop',
                    label = "Browse Shop",
                    icon = Config.TargetIcon,
                    onSelect = function()
                        TriggerEvent("DjonStNix-Shops:client:OpenShop", {shopIndex = index})
                    end
                }
                -- Franchise option disabled for now
            })
        end
    end
    
    spawnedPeds[index] = ped
end

function DrawText3D(x, y, z, text)
    local onScreen, _x, _y = World3dToScreen2d(x, y, z)
    if onScreen then
        local factor = (string.len(text)) / 370
        SetTextScale(0.35, 0.35)
        SetTextFont(4)
        SetTextProportional(1)
        SetTextColour(255, 255, 255, 215)
        SetTextEntry("STRING")
        SetTextCentre(1)
        AddTextComponentString(text)
        DrawText(_x, _y)
        DrawRect(_x, _y + 0.0125, 0.015 + factor, 0.03, 0, 0, 0, 75)
    end
end

local function OpenNPCMenu(shopIndex)
    local shop = Config.Shops[shopIndex]
    local menuItems = {
        {
            header = "Browse Shop",
            txt = "View our current selection of goods.",
            icon = "fas fa-shopping-basket",
            params = {
                event = "DjonStNix-Shops:client:OpenShop",
                args = { shopIndex = shopIndex }
            }
        },
        {
            header = "Franchise Management",
            txt = "Manage or purchase this shop location.",
            icon = "fas fa-business-time",
            params = {
                event = "DjonStNix-Shops:client:ManageFranchise",
                args = { shopIndex = shopIndex }
            }
        }
    }


    Bridge.ShowContextMenu('npc_interaction_' .. shopIndex, shop.shopName, menuItems)
end

-- Universal Interaction Thread (Target Fallback)
CreateThread(function()
    while true do
        local wait = 1000
        local plyCoords = GetEntityCoords(PlayerPedId())
        
        for index, ped in pairs(spawnedPeds) do
            local npcCoords = GetEntityCoords(ped)
            local dist = #(plyCoords - npcCoords)
            
            if dist < 5.0 then
                wait = 0
                if not Config.UseTarget or Bridge.Target == "none" then
                    DrawText3D(npcCoords.x, npcCoords.y, npcCoords.z + 1.0, "[E] - " .. Config.Shops[index].shopName)
                    if IsControlJustPressed(0, 38) and dist < Config.InteractionDistance then
                        OpenNPCMenu(index)
                    end
                end
            end
        end
        Wait(wait)
    end
end)


-- NPC Proximity logic (Greetings & Facing Player)
CreateThread(function()
    local notifiedPeds = {}
    while true do
        local sleep = 1000
        local plyPed = PlayerPedId()
        local plyCoords = GetEntityCoords(plyPed)
        
        for i, ped in pairs(spawnedPeds) do
            local pedCoords = GetEntityCoords(ped)
            local dist = #(plyCoords - pedCoords)
            
            if dist < 3.0 then
                TaskLookAtEntity(ped, plyPed, 3000, 2048, 3)
                
                if not notifiedPeds[i] and math.random(1, 100) > 90 then
                    local shopName = Config.Shops[i].shopName or Config.BrandName
                    Shared.Notify("Welcome to " .. shopName .. ". How can I help you today?", "primary")
                    notifiedPeds[i] = true
                    SetTimeout(30000, function() notifiedPeds[i] = nil end)
                end
                sleep = 500
            end
        end
        Wait(sleep)
    end
end)

-- Resource Cleanup
AddEventHandler('onResourceStop', function(resourceName)
    if GetCurrentResourceName() == resourceName then
        for _, ped in pairs(spawnedPeds) do
            DeleteEntity(ped)
        end
    end
end)

-- Initial Spawn
CreateThread(function()
    while not Config or not Config.Shops do Wait(100) end
    -- Spawning silenty...
    for i, shop in ipairs(Config.Shops) do
        CreateShopNPC(shop, i)
    end

end)
