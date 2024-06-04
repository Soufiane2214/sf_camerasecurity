oxItems = {}

CreateThread(function()
    if Config.Inventory == 'ox_inventory' then
        for item, data in pairs(exports.ox_inventory:Items()) do
            oxItems[item] = deepCopy(data)
        end
    end
end)

-- Functions
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

function getItemInfo(item)
    if Config.Inventory == 'qb-inventory' then
        return Core.Shared.Items[item]
    elseif Config.Inventory == 'ox_inventory' then
        return oxItems[item]
    end
end

-- Events
RegisterNetEvent('sf_camerasecurity:client:notify', notify)

-- Callbacks
lib.callback.register('sf_camerasecurity:Server:GetItemsOX', function(item)
    return getItemInfo(item)
end)
