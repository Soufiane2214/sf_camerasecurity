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
        removeItem(src, item, 1)
        if tonumber(setting.ShowProp) == 1 then
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, setting.Prop, setting.PropCoords.Coords, setting.PropCoords.Rotation, id, true)
        else
            TriggerClientEvent('sf_camerasecurity:Client:LoadPropCamera', -1, setting.Prop, setting.PropCoords.Coords, setting.PropCoords.Rotation, id, false)
        end
        if setting.Type == 'Signal' then
            SetTimeout(2000, function()
                local info = {signal = signalcode}
                addItem(src, Config.CameraSignalPaper, 1, info)
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
                                            addItem(src, s.ItemName, 1)
                                        end) 
                                        loopbreak = true
                                        break
                                    end
                                    if loopbreak then break end
                                end
                            else
                                if m == s.Job then
                                    SetTimeout(2000, function()
                                        addItem(src, s.ItemName, 1)                                
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
                                        addItem(src, s.ItemName, 1) 
                                    end) 
                                    loopbreak = true
                                    break
                                end
                                if loopbreak then break end
                            end
                        else
                            if Setting.Job == s.Job then
                                SetTimeout(2000, function()
                                    addItem(src, s.ItemName, 1) 
                                end) 
                                break
                            end
                        end       
                    end   
                end           
            elseif Setting.Type == 'Signal' then
                SetTimeout(2000, function()
                    addItem(src, Config.SignalItem.ItemName, 1) 
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
        addItem(src, item, amountItem) 
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
    return hasItem(source, item, 1)
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
    createUsableItem(Config.RemoteTablet, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:ConnectCamBySignal', src)
        end
    })

    createUsableItem(Config.TabletCamViewJobs, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:OpenStaticCams', src)
        end
    })

    createUsableItem(Config.CameraSignalPaper, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:GetSignalPaper', src, metadata?.signal or 'Your inventory not support metadata system (contact staff)')
        end
    })

    createUsableItem(Config.SignalItem.NameItem, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, 'Signal', false, Config.SignalItem.NameItem)
        end
    })

    createUsableItem(Config.PersonalCamera.NameItem, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, 'Personal', false, Config.PersonalCamera.NameItem)
        end
    })

    createUsableItem(Config.PersonalCamera.TabletItem, {
        onUse = function(src, metadata)
            TriggerClientEvent('sf_camerasecurity:Client:OpenPersonalCamera', src)
        end
    })

    -- Camera Job Items 
    for k,v in pairs(Config.JobItems) do
        createUsableItem(v.ItemName, {
            onUse = function(src, metadata)
                if v.Type == 'Job' then
                    if type(v.Job) == "table" then
                        local HaveJob = false 
                        for i,t in pairs(v.Job) do if hasJob(src, t) then HaveJob = true break end end          
                        if HaveJob then              
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, v.ItemName)
                        else
                            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                        end
                    else
                        if hasJob(src, v.Job) then
                            TriggerClientEvent('sf_camerasecurity:Client:CreateNewCamera', src, v.Type, v.Job, v.ItemName)
                        else
                            TriggerClientEvent('sf_camerasecurity:client:notify', src, 'Not have authorization to this camera', 'error')
                        end
                    end           
                end 
            end
        })
    end
end)


-- Alert Errors
RegisterNetEvent('sf_camerasecurity:Server:ErrorSendAlert',function(msg)
    print('~r~ERROR: '..msg)
end)
