

-- Purchase Menu (Input)
RegisterNetEvent('DjonStNix-Shops:client:PurchaseMenu', function(data)
    Bridge.Input("Buying " .. data.label, {
        {
            text = "Quantity",
            name = "amount",
            type = "number",
            isRequired = true
        }
    }, function(input)
        local amount = tonumber(input.amount or input[1]) -- Handle both named (QB) and indexed (OX) results
        if amount and amount > 0 then
            TriggerServerEvent('DjonStNix-Shops:server:PurchaseItem', data.shopIndex, data.itemIndex, amount)
        else
            Bridge.Notify(nil, "Invalid quantity!", "error")
        end
    end)
end)


-- Franchise Management Menu
RegisterNetEvent('DjonStNix-Shops:client:ManageFranchise', function(data)
    local shopIndex = data.shopIndex
    
    Bridge.TriggerCallback('DjonStNix-Shops:server:GetFranchiseInfo', function(franchise)
        local menuItems = {
            {
                header = Config.BrandName .. " Franchise Management",
                isMenuHeader = true
            }
        }
        
        if not franchise then
            table.insert(menuItems, {
                header = "Purchase Franchise",
                txt = "Cost: " .. Shared.GetFormattedPrice(Config.FranchisePrice) .. " | Be your own boss!",
                params = {
                    isServer = true,
                    event = "DjonStNix-Shops:server:BuyFranchise",
                    args = shopIndex
                }
            })
        else
            local Player = Bridge.GetPlayerData()
            if franchise.owner == Player.citizenid then
                table.insert(menuItems, {
                    header = "Current Profit: " .. Shared.GetFormattedPrice(franchise.profit),
                    txt = "Click to withdraw to your bank account.",
                    params = {
                        isServer = true,
                        event = "DjonStNix-Shops:server:WithdrawProfit",
                        args = shopIndex
                    }
                })
                table.insert(menuItems, {
                    header = "Set Markup (Current: " .. (franchise.markup * 100) .. "%)",
                    txt = "Adjust your profit margins.",
                    icon = "fas fa-chart-line",
                    params = {
                        event = "DjonStNix-Shops:client:SetMarkupMenu",
                        args = { shopIndex = shopIndex, level = franchise.level }
                    }
                })
                table.insert(menuItems, {
                    header = "Advertise Shop (" .. Shared.GetFormattedPrice(Config.AdvertisePrice) .. ")",
                    txt = "Highlight your shop on the map for 1 hour.",
                    icon = "fas fa-ad",
                    params = {
                        isServer = true,
                        event = "DjonStNix-Shops:server:AdvertiseFranchise",
                        args = shopIndex
                    }
                })
            else
                table.insert(menuItems, {
                    header = "Franchise Owned",
                    txt = "This location is currently occupied by another franchisee.",
                    icon = "fas fa-lock",
                    disabled = true
                })
            end
        end
        
        Bridge.ShowContextMenu('franchise_menu', Config.BrandName .. " Franchise Management", menuItems)
    end, shopIndex)
end)


RegisterNetEvent('DjonStNix-Shops:client:SetMarkupMenu', function(data)
    local levelData = Config.FranchiseLevels[data.level]
    Bridge.Input("Adjust Markup (%)", {
        {
            text = "Enter percentage (Max: " .. (levelData.maxMarkup * 100) .. "%)",
            name = "markup",
            type = "number",
            isRequired = true
        }
    }, function(input)
        local percent = tonumber(input.markup or input[1])
        if percent then
            TriggerServerEvent('DjonStNix-Shops:server:UpdateFranchise', data.shopIndex, percent / 100)
        end
    end)
end)
