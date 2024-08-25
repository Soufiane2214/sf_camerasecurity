local StoredCams = {}
local SQL_Table = 'sf_cams'

-- Functions
local function SQLInsert()
    local checkSQL = MySQL.query.await("SHOW TABLES LIKE 'sf_cams'", {})

    if next(checkSQL) then return end

    MySQL.query.await([[CREATE TABLE IF NOT EXISTS `sf_cams` (
        `id` int(11) NOT NULL AUTO_INCREMENT,
        `name` longtext DEFAULT NULL,
        `setting` longtext DEFAULT NULL,
        `coords` longtext DEFAULT NULL,
        `rot` longtext DEFAULT NULL,
        PRIMARY KEY (`id`) USING BTREE
    ) ENGINE=InnoDB AUTO_INCREMENT=34 DEFAULT CHARSET=latin1 COLLATE=latin1_swedish_ci ROW_FORMAT=DYNAMIC;]], {})
end

-- Threads
CreateThread(function()
    SQLInsert()
    
    -- Waiting load table

	MySQL.Async.fetchAll('SELECT * FROM '..SQL_Table..'', {
	}, function (result)
		StoredCams = result
	end)
end)

-- Events
RegisterNetEvent('sf_camerasecurity:Server:FixCameraByID',function(id)
    local src = source
    for k, v in pairs(StoredCams) do   
        if v.id == id then 
            local Setting = json.decode(v.setting)
            Setting.Broken = 0
            StoredCams[k].setting = json.encode(Setting)

            if not Config.AutoRepairCameras then
                MySQL.update.await('UPDATE '..SQL_Table..' SET setting = ? WHERE id = ?', {StoredCams[k].setting, v.id})
            end
            
            if tonumber(Setting.ShowProp) == 1 then
                TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, Setting.Prop, Setting.PropCoords.Coords, Setting.PropCoords.Rotation, id, true)
            else
                TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, Setting.Prop, Setting.PropCoords.Coords, Setting.PropCoords.Rotation, id, false)
            end
            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Camera Repaired Successfully', 'success', 5000)
            break
        end
    end
end)

RegisterNetEvent('sf_camerasecurity:Server:SaveNewCam',function(name, setting, coords, rot, item, signalcode)
    local src = source
    local Player = getPlayer(src)
    if not Player then return end

    if setting.Type == 'Personal' then
        setting.owned = getIdenti(src)
    end

    MySQL.insert('INSERT INTO '..SQL_Table..' (name, setting, coords, rot) VALUES (?, ?, ?, ?)', {
        name, json.encode(setting), coords, rot
    }, function(id)
        StoredCams[#StoredCams+1] = {name = name, setting = json.encode(setting), coords = coords, rot = rot, id = id}
        if Config.Inventory == 'qb-inventory' then
            if Config.Framework == 'QBCore' then
                Player.Functions.RemoveItem(item, 1)
                TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[item], "remove", 1)
            end       
        elseif Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:RemoveItem(src, item, 1)
        elseif Config.Inventory == 'qs-inventory' then
            exports['qs-inventory']:RemoveItem(src, item, 1)
        end
        if tonumber(setting.ShowProp) == 1 then
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, setting.Prop, setting.PropCoords.Coords, setting.PropCoords.Rotation, id, true)
        else
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, setting.Prop, setting.PropCoords.Coords, setting.PropCoords.Rotation, id, false)
        end
        if setting.Type == 'Signal' then
            SetTimeout(2000, function()
                local info = {signal = signalcode}
                if Config.Inventory == 'qb-inventory' then
                    if Config.Framework == 'QBCore' then
                        Player.Functions.AddItem(Config.CameraSignalPaper, 1, false, info)
                        TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[Config.CameraSignalPaper], "add", 1)  
                    end               
                elseif Config.Inventory == 'ox_inventory' then
                    exports.ox_inventory:AddItem(src, Config.CameraSignalPaper, 1, info)
                elseif Config.Inventory == 'qs-inventory' then
                    exports['qs-inventory']:AddItem(src, Config.CameraSignalPaper, 1, nil, info)
                end                        
            end) 
        end     
        TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Camera Added Successfully', 'success', 5000)
    end)   
end)

RegisterNetEvent('sf_camerasecurity:Server:RemoveStaticCam',function(id)
    local src = source
    local Player = getPlayer(src)
    if not Player then return end
    MySQL.query('DELETE FROM '..SQL_Table..' WHERE id = ?', {id})
    for k, v in pairs(StoredCams) do
        local Setting = json.decode(v.setting) 
        if v.id == id then 
            if Setting.Type == 'Job' then
                for i,s in pairs(Config.JobItems) do
                    if type(Setting.Job) == 'table' then
                        local loopbreak = false
                        for n,m in pairs(Setting.Job) do
                            if type(s.Job) == 'table' then
                                for t,p in pairs(s.Job) do
                                    if m == p then
                                        SetTimeout(2000, function()
                                            if Config.Inventory == 'qb-inventory' then
                                                if Config.Framework == 'QBCore' then
                                                    Player.Functions.AddItem(s.ItemName, 1)
                                                    TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[s.ItemName], "add", 1)  
                                                end                                      
                                            elseif Config.Inventory == 'ox_inventory' then
                                                exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                            elseif Config.Inventory == 'qs-inventory' then
                                                exports['qs-inventory']:AddItem(src, s.ItemName, 1)
                                            end                                  
                                        end) 
                                        loopbreak = true
                                        break
                                    end
                                    if loopbreak then break end
                                end
                            else
                                if m == s.Job then
                                    SetTimeout(2000, function()
                                        if Config.Inventory == 'qb-inventory' then
                                            if Config.Framework == 'QBCore' then
                                                Player.Functions.AddItem(s.ItemName, 1)
                                                TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[s.ItemName], "add", 1)  
                                            end                                      
                                        elseif Config.Inventory == 'ox_inventory' then
                                            exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                        elseif Config.Inventory == 'qs-inventory' then
                                            exports['qs-inventory']:AddItem(src, s.ItemName, 1)
                                        end                                  
                                    end) 
                                    break
                                end
                            end                            
                        end
                    else
                        local loopbreak = false
                        if type(s.Job) == 'table' then
                            for t,p in pairs(s.Job) do
                                if Setting.Job == p then
                                    SetTimeout(2000, function()
                                        if Config.Inventory == 'qb-inventory' then
                                            if Config.Framework == 'QBCore' then
                                                Player.Functions.AddItem(s.ItemName, 1)
                                                TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[s.ItemName], "add", 1)  
                                            end                                      
                                        elseif Config.Inventory == 'ox_inventory' then
                                            exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                        elseif Config.Inventory == 'qs-inventory' then
                                            exports['qs-inventory']:AddItem(src, s.ItemName, 1)
                                        end                                  
                                    end) 
                                    loopbreak = true
                                    break
                                end
                                if loopbreak then break end
                            end
                        else
                            if Setting.Job == s.Job then
                                SetTimeout(2000, function()
                                    if Config.Inventory == 'qb-inventory' then
                                        if Config.Framework == 'QBCore' then
                                            Player.Functions.AddItem(s.ItemName, 1)
                                            TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[s.ItemName], "add", 1)  
                                        end                                      
                                    elseif Config.Inventory == 'ox_inventory' then
                                        exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                    elseif Config.Inventory == 'qs-inventory' then
                                        exports['qs-inventory']:AddItem(src, s.ItemName, 1)
                                    end                                  
                                end) 
                                break
                            end
                        end       
                    end   
                end           
            elseif Setting.Type == 'Signal' then
                SetTimeout(2000, function()
                    if Config.Inventory == 'qb-inventory' then
                        if Config.Framework == 'QBCore' then
                            Player.Functions.AddItem(Config.SignalItem.ItemName, 1)
                            TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[Config.SignalItem.ItemName], "add", 1) 
                        end                      
                    elseif Config.Inventory == 'ox_inventory' then
                        exports.ox_inventory:AddItem(src, Config.SignalItem.ItemName, 1)
                    elseif Config.Inventory == 'qs-inventory' then
                        exports['qs-inventory']:AddItem(src, Config.SignalItem.ItemName, 1)
                    end                
                end)        
            end
            StoredCams[k] = nil 
            if tonumber(Setting.ShowProp) == 1 then
                TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), true)
            else
                TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), false)
            end    
            break
        end 
    end  
    TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Camera Removed Successfully', 'success', 5000)
end)

RegisterNetEvent('sf_camerasecurity:Server:BuyItem',function(typePay, price, item, amountItem)
    local src = source
    local Player = getPlayer(src)
    if not Player then return end

    price *= amountItem
    
    if hasMoney(src, typePay, price) then
        removeMoney(src, typePay, price)
        if Config.Inventory == 'qb-inventory' then
            if Config.Framework == 'QBCore' then
                Player.Functions.AddItem(item, amountItem)
                TriggerClientEvent('inventory:client:ItemBox', src, Core.Shared.Items[item], "add", amountItem)
                TriggerClientEvent('sf_camerasecurity:client:notify', src, '('..Core.Shared.Items[item].label..') bought successfully', 'success')
            end        
        elseif Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:AddItem(src, item, amountItem)
            local labelItem = lib.callback.await('sf_camerasecurity:Server:GetItemsOX', src, item).label
            TriggerClientEvent('sf_camerasecurity:client:notify', src, '('..labelItem..') bought successfully', 'success')
        elseif Config.Inventory == 'qs-inventory' then
            exports['qs-inventory']:AddItem(src, item, amountItem)
            local labelItem = exports['qs-inventory']:GetItemLabel(item)
            TriggerClientEvent('sf_camerasecurity:client:notify', src, '('..labelItem..') bought successfully', 'success')
        end             
    else
        TriggerClientEvent('sf_camerasecurity:client:notify', src, 'No enough money', 'error')
    end
end)

-- CallBacks
lib.callback.register('sf_camerasecurity:Server:GetStaticCams', function(source)
    return StoredCams, getIdenti(source)
end)

lib.callback.register('sf_camerasecurity:Server:RegenerateSignal',function(source, id, newSignal)
    local src = source
    for k, v in pairs(StoredCams) do   
        if v.id == id then 
            local setting = json.decode(v.setting)
            setting.Signal = newSignal
            StoredCams[k].setting = json.encode(setting)

            if not Config.AutoRepairCameras then
                MySQL.update.await('UPDATE '..SQL_Table..' SET setting = ? WHERE id = ?', {json.encode(setting), id})
            end
            
            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Camera Signal Changed', 'success', 5000)
            break
        end
    end

    return StoredCams, getIdenti(source)
end)

lib.callback.register('sf_camerasecurity:Server:HasItem', function(source, item)
    if Config.Inventory == 'qb-inventory' then
        if Config.Framework == 'QBCore' then
            local Player = getPlayer(source)
            if Player then
                return Player.Functions.GetItemByName(item)
            end  

            return nil
        end       
    elseif Config.Inventory == 'ox_inventory' then        
        return exports.ox_inventory:GetSlotWithItem(source, item)
    elseif Config.Inventory == 'qs-inventory' then
        local hasItem = exports['qs-inventory']:GetItemTotalAmount(source, item)
        if hasItem and hasItem >= 1 then
            return true
        end
        return false
    end
end)

lib.callback.register('sf_camerasecurity:Server:BrokeCamera', function(source, id)
    local Broken = 'false'
    for k, v in pairs(StoredCams) do
        local Setting = json.decode(v.setting) 
        if v.id == id then 
            if Setting.Type == 'Job' and tonumber(Setting.Broken) == 0 then
                Setting.Broken = 1
                StoredCams[k].setting = json.encode(Setting) 
                Broken = 'true'

                if not Config.AutoRepairCameras then
                    MySQL.update.await('UPDATE '..SQL_Table..' SET setting = ? WHERE id = ?', {StoredCams[k].setting, StoredCams[k].id})
                end
                
                TriggerClientEvent('sf_camerasecurity:Client:CrashCamera', -1, tonumber(v.id))
                if tonumber(Setting.ShowProp) == 1 then
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), true)
                else
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), false)
                end 
            elseif Setting.Type == 'Signal' and tonumber(Setting.Broken) == 0 then
                MySQL.query('DELETE FROM '..SQL_Table..' WHERE id = ?', {id})
                StoredCams[k] = nil
                TriggerClientEvent('sf_camerasecurity:Client:CrashCamera', -1, tonumber(v.id))
                if tonumber(Setting.ShowProp) == 1 then
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), true)
                else
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), false)
                end              
                Broken = 'true'
            elseif Setting.Type == 'Personal' and tonumber(Setting.Broken) == 0 then
                Setting.Broken = 1
                StoredCams[k].setting = json.encode(Setting) 
                Broken = 'true'
                
                if not Config.AutoRepairCameras then
                    MySQL.update.await('UPDATE '..SQL_Table..' SET setting = ? WHERE id = ?', {StoredCams[k].setting, StoredCams[k].id})
                end
                
                TriggerClientEvent('sf_camerasecurity:Client:CrashCamera', -1, tonumber(v.id))
                if tonumber(Setting.ShowProp) == 1 then
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), true)
                else
                    TriggerClientEvent('sf_camerasecurity:Client:RemovePropCamera', -1, tonumber(v.id), false)
                end 
            end        
            break
        end 
    end  
    return Broken
end)

-- Usables
CreateThread(function()
    if Config.Inventory == 'ox_inventory' then
        exports('cam_'..Config.RemoteTablet, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                TriggerClientEvent('sf_camerasecurity:Client:ConnectCamBySignal', inventory.id)
            end
        end)
        exports('cam_'..Config.TabletCamViewJobs, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                TriggerClientEvent('sf_camerasecurity:Client:OpenStaticCams', inventory.id)
            end
        end)
        exports('cam_'..Config.CameraSignalPaper, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                TriggerClientEvent('sf_camerasecurity:Client:GetSignalPaper', inventory.id, itemSlot.metadata.signal)
            end
        end)
        exports('cam_'..Config.SignalItem.NameItem, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', inventory.id, 'Signal', false, itemSlot.name)
            end
        end)
        exports('cam_'..Config.PersonalCamera.NameItem, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', inventory.id, 'Personal', false, itemSlot.name)
            end
        end)
        exports('cam_'..Config.PersonalCamera.TabletItem, function(event, item, inventory, slot, data)
            if event == 'usingItem' then
                TriggerClientEvent('sf_camerasecurity:Client:OpenPersonalCamera', inventory.id)
            end
        end)
    
        -- Camera Job Items 
        for k,v in pairs(Config.JobItems) do
            exports('cam_'..v.ItemName, function(event, item, inventory, slot, data)
                if event == 'usingItem' then
                    local src = inventory.id           
                    local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                    if v.Type == 'Job' then
                        if type(v.Job) == "table" then
                            local HaveJob = false
                            for i,t in pairs(v.Job) do if hasJob(src, t) then HaveJob = true break end end          
                            if HaveJob then              
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, itemSlot.name)
                            else
                                TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                            end
                        else
                            if hasJob(src, v.Job) then
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, itemSlot.name)
                            else
                                TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                            end
                        end           
                    end
                end
            end)
        end
    elseif Config.Inventory == 'qb-inventory' then
        if Config.Framework == 'QBCore' then
            Core.Functions.CreateUseableItem(Config.RemoteTablet, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:ConnectCamBySignal', source)
            end)
            
            Core.Functions.CreateUseableItem(Config.TabletCamViewJobs, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:OpenStaticCams', source)
            end)
            
            Core.Functions.CreateUseableItem(Config.CameraSignalPaper, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:GetSignalPaper', source, item.info.signal)
            end)
            
            Core.Functions.CreateUseableItem(Config.SignalItem.NameItem, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', source, 'Signal', false, item.name)
            end)

            Core.Functions.CreateUseableItem(Config.PersonalCamera.NameItem, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', source, 'Personal', false, item.name)
            end)

            Core.Functions.CreateUseableItem(Config.PersonalCamera.TabletItem, function(source, item)
                TriggerClientEvent('sf_camerasecurity:Client:OpenPersonalCamera', source)
            end)
            
            -- Camera Job Items 
            for k,v in pairs(Config.JobItems) do
                Core.Functions.CreateUseableItem(v.ItemName, function(source, item)
                    local src = source
                    if v.Type == 'Job' then
                        if type(v.Job) == "table" then
                            local HaveJob = false 
                            for i,t in pairs(v.Job) do if hasJob(src, t) then HaveJob = true break end end          
                            if HaveJob then              
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                            else
                                TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                            end
                        else
                            if hasJob(src, v.Job) then
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                            else
                                TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                            end
                        end           
                    end     
                end)
            end
        end 
    elseif Config.Inventory == 'qs-inventory' then
        exports['qs-inventory']:CreateUsableItem(Config.RemoteTablet, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:ConnectCamBySignal', source)
        end)
        
        exports['qs-inventory']:CreateUsableItem(Config.TabletCamViewJobs, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:OpenStaticCams', source)
        end)
        
        exports['qs-inventory']:CreateUsableItem(Config.CameraSignalPaper, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:GetSignalPaper', source, item.info.signal)
        end)
        
        exports['qs-inventory']:CreateUsableItem(Config.SignalItem.NameItem, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', source, 'Signal', false, Config.SignalItem.NameItem)
        end)

        exports['qs-inventory']:CreateUsableItem(Config.PersonalCamera.NameItem, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', source, 'Personal', false, Config.PersonalCamera.NameItem)
        end)

        exports['qs-inventory']:CreateUsableItem(Config.PersonalCamera.TabletItem, function(source, item)
            TriggerClientEvent('sf_camerasecurity:Client:OpenPersonalCamera', source)
        end)
        
        -- Camera Job Items 
        for k,v in pairs(Config.JobItems) do
            exports['qs-inventory']:CreateUsableItem(v.ItemName, function(source, item)
                local src = source
                if v.Type == 'Job' then
                    if type(v.Job) == "table" then
                        local HaveJob = false 
                        for i,t in pairs(v.Job) do if hasJob(src, t) then HaveJob = true break end end          
                        if HaveJob then              
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                        else
                            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                        end
                    else
                        if hasJob(src, v.Job) then
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                        else
                            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                        end
                    end           
                end     
            end)
        end
    end
end)


-- Alert Errors
RegisterNetEvent('sf_camerasecurity:Server:ErrorSendAlert',function(msg)
    print('~r~ERROR: '..msg)
end)
