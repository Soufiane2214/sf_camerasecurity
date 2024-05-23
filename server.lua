local QBCore = exports['qb-core']:GetCoreObject()
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
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    for k, v in pairs(StoredCams) do   
        if v.id == id then 
            local Setting = json.decode(v.setting)
            Setting.Broken = 0
            StoredCams[k].setting = json.encode(Setting)
            if tonumber(Setting.ShowProp) == 1 then
                TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, Setting.Prop, Setting.PropCoords.Coords, Setting.PropCoords.Rotation, id, true)
            else
                TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, Setting.Prop, Setting.PropCoords.Coords, Setting.PropCoords.Rotation, id, false)
            end
            QBCore.Functions.Notify(src, 'Camera Repaired Successfully', 'success', 5000)
            break
        end
    end
end)

RegisterNetEvent('sf_camerasecurity:Server:SaveNewCam',function(name, setting, coords, rot, item, signalcode)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.insert('INSERT INTO '..SQL_Table..' (name, setting, coords, rot) VALUES (?, ?, ?, ?)', {
        name, setting, coords, rot
    }, function(id)
        StoredCams[#StoredCams+1] = {name = name, setting = setting, coords = coords, rot = rot, id = id}
        if Config.Inventory == 'qb-inventory' then
            Player.Functions.RemoveItem(item, 1)
            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "remove", 1)
        elseif Config.Inventory == 'ox_inventory' then
            exports.ox_inventory:RemoveItem(src, item, 1)
        end
        local UncodedSetting = json.decode(setting)
        if tonumber(UncodedSetting.ShowProp) == 1 then
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, UncodedSetting.Prop, UncodedSetting.PropCoords.Coords, UncodedSetting.PropCoords.Rotation, id, true)
        else
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, UncodedSetting.Prop, UncodedSetting.PropCoords.Coords, UncodedSetting.PropCoords.Rotation, id, false)
        end
        if UncodedSetting.Type == 'Signal' then
            SetTimeout(2000, function()
                local info = {signal = signalcode}
                if Config.Inventory == 'qb-inventory' then
                    Player.Functions.AddItem(Config.CameraSignalPaper, 1, false, info)
                    TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.CameraSignalPaper], "add", 1)   
                elseif Config.Inventory == 'ox_inventory' then
                    exports.ox_inventory:AddItem(src, Config.CameraSignalPaper, 1, info)
                end                        
            end)   
        end     
        QBCore.Functions.Notify(src, 'Camera Added Successfully', 'success', 5000)  
    end)   
end)

RegisterNetEvent('sf_camerasecurity:Server:RemoveStaticCam',function(id)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end
    MySQL.query('DELETE FROM '..SQL_Table..' WHERE id = ?', {id})
    for k, v in pairs(StoredCams) do
        local Setting = json.decode(v.setting) 
        if v.id == id then 
            if Setting.Type == 'Job' then
                for i,s in pairs(Config.JobItems) do
                    if type(s.Job) == 'table' then
                        local loopbreak = false
                        for n,m in pairs(Setting.Job) do
                            for t,p in pairs(s.Job) do
                                if m == p then
                                    SetTimeout(2000, function()
                                        if Config.Inventory == 'qb-inventory' then
                                            Player.Functions.AddItem(s.ItemName, 1)
                                            TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[s.ItemName], "add", 1)   
                                        elseif Config.Inventory == 'ox_inventory' then
                                            exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                        end                                  
                                    end) 
                                    loopbreak = true
                                    break
                                end
                                if loopbreak then break end
                            end
                            if loopbreak then break end
                        end
                    else
                        for n,m in pairs(Setting.Job) do
                            if s.Job == m then
                                SetTimeout(2000, function()
                                    if Config.Inventory == 'qb-inventory' then
                                        Player.Functions.AddItem(s.ItemName, 1)
                                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[s.ItemName], "add", 1)
                                    elseif Config.Inventory == 'ox_inventory' then
                                        exports.ox_inventory:AddItem(src, s.ItemName, 1)
                                    end               
                                end)    
                            end
                        end            
                    end
                end
            elseif Setting.Type == 'Signal' then
                SetTimeout(2000, function()
                    if Config.Inventory == 'qb-inventory' then
                        Player.Functions.AddItem(Config.SignalItem.ItemName, 1)
                        TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[Config.SignalItem.ItemName], "add", 1)
                    elseif Config.Inventory == 'ox_inventory' then
                        exports.ox_inventory:AddItem(src, Config.SignalItem.ItemName, 1)
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
    QBCore.Functions.Notify(source, 'Camera Removed Successfully', 'success', 5000)
end)

RegisterNetEvent('sf_camerasecurity:Server:BuyItem',function(typePay, price, item, amountItem)
    local src = source
    local Player = QBCore.Functions.GetPlayer(src)
    if not Player then return end

    price *= amountItem
    
    if Player.PlayerData.money[typePay] >= price then
        if Player.Functions.RemoveMoney(typePay, price) then
            if Config.Inventory == 'qb-inventory' then
                Player.Functions.AddItem(item, amountItem)
                TriggerClientEvent('inventory:client:ItemBox', src, QBCore.Shared.Items[item], "add", amountItem)
            elseif Config.Inventory == 'ox_inventory' then
                exports.ox_inventory:AddItem(src, item, amountItem)
            end       
        end       
        QBCore.Functions.Notify(source, '('..QBCore.Shared.Items[item].label..') bought successfully', 'success')
    else
        QBCore.Functions.Notify(source, 'No enough money', 'error')
    end
end)

-- CallBacks
QBCore.Functions.CreateCallback('sf_camerasecurity:Server:GetStaticCams', function(source, cb)
    cb(StoredCams)
end)

QBCore.Functions.CreateCallback('sf_camerasecurity:Server:HasItem', function(source, cb, item)
    if Config.Inventory == 'qb-inventory' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            cb(Player.Functions.GetItemByName(item))
            return
        else
            cb(nil)
            return
        end     
    elseif Config.Inventory == 'ox_inventory' then        
        cb(exports.ox_inventory:GetSlotWithItem(source, item))
        return
    end
end)

QBCore.Functions.CreateCallback('sf_camerasecurity:Server:BrokeCamera', function(source, cb, id)
    local Broken = 'false'
    for k, v in pairs(StoredCams) do
        local Setting = json.decode(v.setting) 
        if v.id == id then 
            if Setting.Type == 'Job' and tonumber(Setting.Broken) == 0 then
                Setting.Broken = 1
                StoredCams[k].setting = json.encode(Setting) 
                Broken = 'true'
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
            end        
            break
        end 
    end  
    cb(Broken)
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
                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', inventory.id, Config.SignalItem.Type, false, itemSlot.name)
            end
        end)
    
        -- Camera Job Items 
        for k,v in pairs(Config.JobItems) do
            exports('cam_'..v.ItemName, function(event, item, inventory, slot, data)
                if event == 'usingItem' then
                    local src = inventory.id           
                    local Player = QBCore.Functions.GetPlayer(src)
                    if not Player then return end
                    local itemSlot = exports.ox_inventory:GetSlot(inventory.id, slot)
                    if v.Type == 'Job' then
                        if type(v.Job) == "table" then
                            local HaveJob = false
                            for i,t in pairs(v.Job) do if Player.PlayerData.job.name == t then HaveJob = true break end end          
                            if HaveJob then              
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, itemSlot.name)
                            else
                                QBCore.Functions.Notify(src, "Not have authorization to this camera", "error", 3500)
                            end
                        else
                            if Player.PlayerData.job.name == v.Job then
                                TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, itemSlot.name)
                            else
                                QBCore.Functions.Notify(src, "Not have authorization to this camera", "error", 3500)
                            end
                        end           
                    end
                end
            end)
        end
    elseif Config.Inventory == 'qb-inventory' then
        QBCore.Functions.CreateUseableItem(Config.RemoteTablet, function(source, item)
            local src = source
            TriggerClientEvent('sf_camerasecurity:Client:ConnectCamBySignal', src)
        end)
        
        QBCore.Functions.CreateUseableItem(Config.TabletCamViewJobs, function(source, item)
            local src = source
            TriggerClientEvent('sf_camerasecurity:Client:OpenStaticCams', src)
        end)
        
        QBCore.Functions.CreateUseableItem(Config.CameraSignalPaper, function(source, item)
            local src = source
            TriggerClientEvent('sf_camerasecurity:Client:GetSignalPaper', src, item.info.signal)
        end)
        
        QBCore.Functions.CreateUseableItem(Config.SignalItem.NameItem, function(source, item)
            local src = source
            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, Config.SignalItem.Type, false, item.name)
        end)
        
        -- Camera Job Items 
        for k,v in pairs(Config.JobItems) do
            QBCore.Functions.CreateUseableItem(v.ItemName, function(source, item)
                local src = source
                local Player = QBCore.Functions.GetPlayer(src)
                if not Player then return end
                if v.Type == 'Job' then
                    if type(v.Job) == "table" then
                        local HaveJob = false
                        for i,t in pairs(v.Job) do if Player.PlayerData.job.name == t then HaveJob = true break end end          
                        if HaveJob then              
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                        else
                            QBCore.Functions.Notify(src, "Not have authorization to this camera", "error", 3500)
                        end
                    else
                        if Player.PlayerData.job.name == v.Job then
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, item.name)
                        else
                            QBCore.Functions.Notify(src, "Not have authorization to this camera", "error", 3500)
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
