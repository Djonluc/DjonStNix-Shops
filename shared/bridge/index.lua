Bridge = Bridge or {}
Bridge.Framework = "none"
Bridge.Inventory = "none"
Bridge.Target = "none"
Bridge.Ready = false

local function WaitUntilReady()
    local attempts = 0
    while not Bridge.Ready do
        Wait(10)
        attempts = attempts + 1
        if attempts > 100 then break end
    end
end

local QBCore = nil
local ESX = nil

-- ==================================================
-- AUTO-DETECTION
-- ==================================================
local function DetectEnvironment()
    -- Framework Detection
    if Config.Framework == "qb" or (Config.Framework == "auto" and GetResourceState('qb-core') == 'started') then
        Bridge.Framework = "qb"
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == "esx" or (Config.Framework == "auto" and GetResourceState('es_extended') == 'started') then
        Bridge.Framework = "esx"
        ESX = exports['es_extended']:getSharedObject()
    elseif Config.Framework == "ox" or (Config.Framework == "auto" and GetResourceState('ox_core') == 'started') then
        Bridge.Framework = "ox"
    end

    -- Inventory Detection
    if Config.Inventory == "ox" or (Config.Inventory == "auto" and GetResourceState('ox_inventory') == 'started') then
        Bridge.Inventory = "ox"
    elseif Config.Inventory == "qs" or (Config.Inventory == "auto" and GetResourceState('qs-inventory') == 'started') then
        Bridge.Inventory = "qs"
    elseif Config.Inventory == "qb" or (Config.Inventory == "auto" and Bridge.Framework == "qb") then
        Bridge.Inventory = "qb"
    end

    -- Target Detection
    if Config.Target == "qb" or (Config.Target == "auto" and GetResourceState('qb-target') == 'started') then
        Bridge.Target = "qb"
    elseif Config.Target == "ox" or (Config.Target == "auto" and GetResourceState('ox_target') == 'started') then
        Bridge.Target = "ox"
    end
end

if Config and Config.Framework then
    DetectEnvironment()
    Bridge.Ready = true
else
    CreateThread(function()
        local attempts = 0
        while not Config or not Config.Framework do 
            Wait(10) 
            attempts = attempts + 1
            if attempts > 100 then break end
        end
        DetectEnvironment()
        Bridge.Ready = true

    end)
end

-- ==================================================
-- SHARED WRAPPERS
-- ==================================================
Bridge.GetPlayer = function(source)
    WaitUntilReady()
    if Bridge.Framework == "qb" then
        return QBCore.Functions.GetPlayer(source)
    elseif Bridge.Framework == "esx" then
        return ESX.GetPlayerFromId(source)
    end
end

Bridge.GetPlayerFromIdentifier = function(identifier)
    if Bridge.Framework == "qb" then
        return QBCore.Functions.GetPlayerByCitizenId(identifier)
    elseif Bridge.Framework == "esx" then
        return ESX.GetPlayerFromIdentifier(identifier)
    end
end

Bridge.GetPlayers = function()
    if Bridge.Framework == "qb" then
        return QBCore.Functions.GetPlayers()
    elseif Bridge.Framework == "esx" then
        return ESX.GetPlayers()
    end
    return {}
end

Bridge.Notify = function(source, msg, type)
    if IsDuplicityVersion() then
        if Bridge.Framework == "qb" then
            TriggerClientEvent('QBCore:Notify', source, msg, type)
        elseif Bridge.Framework == "esx" then
            TriggerClientEvent('esx:showNotification', source, msg)
        end
    else
        if Bridge.Framework == "qb" then
            QBCore.Functions.Notify(msg, type)
        elseif Bridge.Framework == "esx" then
            ESX.ShowNotification(msg)
        elseif Bridge.Framework == "ox" then
            exports.ox_lib:notify({title = Config.BrandName, description = msg, type = type})
        end
    end
end

Bridge.ProgressBar = function(name, label, duration, options, anim, prop, done, cancel)
    if Bridge.Framework == "qb" then
        QBCore.Functions.Progressbar(name, label, duration, options.useLib, options.canCancel, options.disable, anim, prop, {}, done, cancel)
    elseif GetResourceState('ox_lib') == 'started' then
        if exports.ox_lib:progressBar({
            duration = duration,
            label = label,
            useLib = options.useLib,
            canCancel = options.canCancel,
            disable = options.disable,
            anim = anim,
            prop = prop
        }) then
            done()
        else
            cancel()
        end
    else
        -- Fallback to basic wait or other UI
        Wait(duration)
        done()
    end
end

-- ==================================================
-- ITEM & MONEY WRAPPERS
-- ==================================================
Bridge.AddMoney = function(source, type, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return end
    
    if Bridge.Framework == "qb" then
        Player.Functions.AddMoney(type == "bank" and "bank" or "cash", amount, reason)
    elseif Bridge.Framework == "esx" then
        Player.addAccountMoney(type == "bank" and "bank" or "money", amount)
    end
end

Bridge.RemoveMoney = function(source, type, amount, reason)
    local Player = Bridge.GetPlayer(source)
    if not Player then return end
    
    if Bridge.Framework == "qb" then
        return Player.Functions.RemoveMoney(type == "bank" and "bank" or "cash", amount, reason)
    elseif Bridge.Framework == "esx" then
        local account = type == "bank" and "bank" or "money"
        if Player.getAccount(account).money >= amount then
            Player.removeAccountMoney(account, amount)
            return true
        end
    end
    return false
end

Bridge.AddItem = function(source, item, amount)
    local Player = Bridge.GetPlayer(source)
    if not Player then return end

    if Bridge.Inventory == "ox" then
        exports.ox_inventory:AddItem(source, item, amount)
    elseif Bridge.Framework == "qb" then
        Player.Functions.AddItem(item, amount)
    elseif Bridge.Framework == "esx" then
        Player.addInventoryItem(item, amount)
    end
end

-- ==================================================
-- PLAYER DATA WRAPPERS
-- ==================================================
Bridge.GetPlayerData = function(source)
    local Player = Bridge.GetPlayer(source)
    if not Player then return {} end

    if Bridge.Framework == "qb" then
        return Player.PlayerData
    elseif Bridge.Framework == "esx" then
        local data = {}
        data.job = { name = Player.job.name, grade = { level = Player.job.grade } }
        data.citizenid = Player.identifier
        data.money = { bank = Player.getAccount('bank').money, cash = Player.getAccount('money').money }
        -- ESX metadata usually handled via ox_lib or similar, or specific tables
        data.metadata = {} -- Placeholder
        return data
    end
end

Bridge.HasJob = function(source, job, grade)
    local data = Bridge.GetPlayerData(source)
    if not data or not data.job then return false end
    return data.job.name == job and (not grade or data.job.grade.level >= grade)
end

Bridge.HasLicense = function(source, license)
    local data = Bridge.GetPlayerData(source)
    if Bridge.Framework == "qb" then
        return data.metadata and data.metadata["licences"] and data.metadata["licences"][license]
    elseif Bridge.Framework == "esx" then
        -- ESX License detection (usually requires esx_license)
        local has = false
        if Bridge.Framework == "esx" then
            -- We'll just return true for now or implement a more robust check if needed
            -- Triggering a callback might be better but here we need sync
            return true 
        end
    end
    return false
end
-- ==================================================
-- CALLBACK WRAPPERS
-- ==================================================
Bridge.CreateCallback = function(name, cb)
    WaitUntilReady()
    if Bridge.Framework == "qb" then
        QBCore.Functions.CreateCallback(name, cb)
    elseif Bridge.Framework == "esx" then
        ESX.RegisterServerCallback(name, cb)
    end
end

Bridge.TriggerCallback = function(name, ...)
    WaitUntilReady()
    if Bridge.Framework == "qb" then
        QBCore.Functions.TriggerCallback(name, ...)
    elseif Bridge.Framework == "esx" then
        ESX.TriggerServerCallback(name, ...)
    end
end

Bridge.GetIdentifier = function(source)
    local data = Bridge.GetPlayerData(source)
    return data.citizenid
end

Bridge.AddCommand = function(name, help, params, cb, role)
    if Bridge.Framework == "qb" then
        QBCore.Commands.Add(name, help, params, true, cb, role or "admin")
    elseif Bridge.Framework == "esx" then
        ESX.RegisterCommand(name, role or "admin", cb, true, {help = help, arguments = params})
    end
end

-- ==================================================
-- IMAGE & ASSET WRAPPERS
-- ==================================================
Bridge.GetItemImage = function(itemName)
    local image = itemName .. ".png" -- Default fallback
    
    if Bridge.Framework == "qb" and QBCore and QBCore.Shared and QBCore.Shared.Items[itemName] then
        image = QBCore.Shared.Items[itemName].image or (itemName .. ".png")
    end

    -- Construct NUI path based on inventory
    if Bridge.Inventory == "ox" then
        return "nui://ox_inventory/web/images/" .. image
    elseif Bridge.Inventory == "qs" then
        return "nui://qs-inventory/html/img/" .. image
    else
        -- Default to qb-inventory
        return "nui://qb-inventory/html/images/" .. image
    end
end

-- ==================================================
-- UI WRAPPERS (qb-menu/input vs ox_lib)
-- ==================================================
Bridge.ShowContextMenu = function(id, title, items)
    if GetResourceState('ox_lib') == 'started' then
        local options = {}
        for _, item in ipairs(items) do
            if not item.isMenuHeader then
                -- Auto-resolve image if only itemName is provided in 'image' field
                local finalImage = item.image
                if finalImage and not string.find(finalImage, ":") then
                    finalImage = Bridge.GetItemImage(finalImage)
                end

                table.insert(options, {
                    title = item.header,
                    description = item.txt,
                    icon = item.icon,
                    disabled = item.disabled,
                    image = finalImage, -- Support for item images
                    metadata = item.metadata, -- Extra data support
                    onSelect = function()
                        if item.params and item.params.event then
                            TriggerEvent(item.params.event, item.params.args)
                        end
                    end
                })
            end
        end
        lib.registerContext({
            id = id,
            title = title,
            options = options
        })
        lib.showContext(id)
    else
        -- Fallback to qb-menu
        -- qb-menu uses "icon" for the image path if it's a URL/NUI path
        local menu = {}
        for _, item in ipairs(items) do
            local finalIcon = item.icon
            if item.image then
                if not string.find(item.image, ":") then
                    finalIcon = Bridge.GetItemImage(item.image)
                else
                    finalIcon = item.image
                end
            end

            table.insert(menu, {
                header = item.header,
                txt = item.txt,
                icon = finalIcon,
                disabled = item.disabled,
                params = item.params
            })
        end
        exports['qb-menu']:openMenu(menu)
    end
end

Bridge.Input = function(header, fields, cb)
    if GetResourceState('ox_lib') == 'started' then
        local rows = {}
        for _, field in ipairs(fields) do
            table.insert(rows, {
                type = field.type or 'input',
                label = field.text,
                placeholder = field.placeholder,
                default = field.default
            })
        end
        local input = lib.inputDialog(header, rows)
        if input then
            cb(input)
        end
    else
        -- Fallback to qb-input
        local input = exports['qb-input']:ShowInput({
            header = header,
            submitText = "Submit",
            inputs = fields
        })
        if input then
            cb(input)
        end
    end
end
