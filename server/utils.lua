---@param source number
---@param item string
---@param amount number
---@param info table
function addItem(source, item, amount, info)
    if Config.Inventory == 'qb-inventory' then
        TriggerClientEvent('qb-inventory:client:ItemBox', source, Core.Shared.Items[item], "add", amount)
        exports['qb-inventory']:AddItem(source, item, amount, nil, info)              
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:AddItem(source, item, amount, info)
    elseif Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:AddItem(source, item, amount, nil, info)
    elseif Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:AddItem(source, item, amount, nil, info)
    elseif Config.Inventory == 'ps-inventory' then 
        exports['ps-inventory']:AddItem(source, item, amount, nil, info)
    end 
end


---@param source number
---@param item string
---@param amount number
function removeItem(source, item, amount)
    if Config.Inventory == 'qb-inventory' then
        TriggerClientEvent('qb-inventory:client:ItemBox', source, Core.Shared.Items[item], "remove", amount)
        exports['qb-inventory']:RemoveItem(source, item, amount)
    elseif Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:RemoveItem(source, item, amount)
    elseif Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:RemoveItem(source, item, amount)
    elseif Config.Inventory == 'codem-inventory' then
        exports['codem-inventory']:RemoveItem(source, item, amount)
    elseif Config.Inventory == 'ps-inventory' then 
        exports['ps-inventory']:RemoveItem(source, item, amount)
    end
end


---@param source number
---@param item string
---@param amount number
---@return boolean
function hasItem(source, item, amount)
    if Config.Inventory == 'qb-inventory' then
        local itemAmount = 0
        local items = exports['qb-inventory']:GetItemsByName(source, item)    
        if items and #items > 0 then           
            for k,v in pairs(items) do
                itemAmount += v.amount
            end
        end

        return itemAmount >= amount
    elseif Config.Inventory == 'ox_inventory' then        
        local itemsCount = exports.ox_inventory:GetItemCount(source, item)
        if itemsCount and itemsCount >= amount then
            return true
        end
        return false
    elseif Config.Inventory == 'qs-inventory' then
        local itemAmount = exports['qs-inventory']:GetItemTotalAmount(source, item)
        if itemAmount and itemAmount >= amount then
            return true
        end
        return false
    elseif Config.Inventory == 'codem-inventory' then
        return exports['codem-inventory']:HasItem(source, item, amount)
    elseif Config.Inventory == 'ps-inventory' then 
        return exports['ps-inventory']:HasItem(source, item, amount)
    end
end


---@param item string
---@param data table
function createUsableItem(itemName, useData)
    if Config.Inventory == 'qb-inventory' then
        if Config.Framework == 'QBCore' then
            Core.Functions.CreateUseableItem(itemName, function(source, item)
                useData.onUse(source, item.info)
            end)
        end   
    elseif Config.Inventory == 'ox_inventory' then
        exports('cam_'..itemName, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                useData.onUse(inventory.id, itemSlot.metadata)
            end
        end)
    elseif Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:CreateUsableItem(itemName, function(source, item)
            useData.onUse(source, item.info)
        end)
    elseif Config.Inventory == 'codem-inventory' then
        if Config.Framework == 'QBCore' then
            Core.Functions.CreateUseableItem(itemName, function(source, item)
                useData.onUse(source, item.info)
            end)
        elseif Config.Framework == 'ESX' then
            Core.RegisterUsableItem(itemName, function(source, item)
                useData.onUse(source, item?.info)
            end)
        end  
    elseif Config.Inventory == 'ps-inventory' then   
        if Config.Framework == 'QBCore' then
            Core.Functions.CreateUseableItem(itemName, function(source, item)
                useData.onUse(source, item.info)
            end)
        end 
    end
end
