oxItems = {}
qsItems = {}

CreateThread(function()
    if Config.Inventory == 'ox_inventory' then
        for item, data in pairs(exports.ox_inventory:Items()) do
            oxItems[item] = deepCopy(data)
        end
    end

    if Config.Inventory == 'qs-inventory' then
        for item, data in pairs(exports['qs-inventory']:GetItemList()) do
            qsItems[item] = deepCopy(data)
        end
    end
end)

-- Functions

---@param text string
---@param type string
---@param timer number
function notify(text, type, timer)
    if Config.Notify == 'qb' then
        TriggerEvent('QBCore:Notify', text, type, timer or 3500)
    elseif Config.Notify == 'esx' then
        TriggerEvent('esx:showNotification', text, type, timer or 3500)
    elseif Config.Notify == 'lib' then
        if type == 'info' then type = 'inform' end
        lib.notify({title = type:upper(), description = text, type = type, duration = timer or 3500})
    else
        -- add a custom notification 

    end
end


---@param text string
---@param timer number
function progressBar(text, timer)
    if Config.ProgressBar == 'lib' then
        lib.progressBar({duration = timer, label = text, useWhileDead = false, canCancel = false})
    elseif Config.ProgressBar == 'qb' then
        -- Make sure your framework QBCore
        Core.Functions.Progressbar(text:lower(), text, timer, false, false, {
            disableMovement = true, disableCarMovement = true, disableMouse = false, disableCombat = true,
        }, {}, {}, {}, {}, {}) 
    elseif Config.ProgressBar == 'esx' then
        -- Make sure your framework ESX
        Core.Progressbar(text, timer,{
            FreezePlayer = false, animation = {}, onFinish = function() end
        })
    else
        -- add a custom progressbar

    end
end


---@param item string
---@return table
function getItemInfo(item)
    if Config.Inventory == 'qb-inventory' then
        return Core.Shared.Items[item]
    elseif Config.Inventory == 'ox_inventory' then
        return oxItems[item]
    elseif Config.Inventory == 'qs-inventory' then
        return qsItems[item]
    end
end


---@param bool boolean
function setInvenBusy(bool)
    if Config.Inventory == 'qb-inventory' or Config.Inventory == 'ps-inventory' then
        LocalPlayer.state:set('inv_busy', bool, false)
    elseif Config.Inventory == 'ox_inventory' then
        LocalPlayer.state:set('invBusy', bool, false)
    elseif Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:setInventoryDisabled(bool)
    elseif Config.Inventory == 'codem-inventory' then

        -- my be this not work
        LocalPlayer.state:set('inv_busy', bool, false)
        LocalPlayer.state:set('invBusy', bool, false)
        
    end
end

-- Events
RegisterNetEvent('sf_camerasecurity:client:notify', notify)

-- Callbacks
lib.callback.register('sf_camerasecurity:Server:GetItemsOX', function(item)
    return getItemInfo(item)
end)
