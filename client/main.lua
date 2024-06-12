local LoadedProps = {}
local LoadedNoPropCams = {}
local CurrentHashCam = `prop_spycam`
local InHit = false
local Canceled = false
local InGetLock = false
local spyCam
local CurrentCam
local CurrentCamID 
local Active = false
local InCam = false
local CurrentPlayerCoordDistance
local CurrentJob 
local CurrentType
local CurrentItem
local InSwitchingCam = false
local Shown = false
local CurrentWifiResau = 'green'

-- Tablet Anim
local InAnim = false
local TabletDict = "amb@code_human_in_bus_passenger_idles@female@tablet@base"
local TabletAnim = "base"
local TabletProp = `prop_cs_tablet`
local TabletObj 
local TabletBone = 60309
local TabletOffset = vector3(0.03, 0.002, -0.0)
local TabletRot = vector3(10.0, 160.0, 0.0)


-- Handlers
AddEventHandler('onResourceStart', function(resourceName)
    if (GetCurrentResourceName() ~= resourceName) then return end
    if not isLogin() then return end
    LoadingCameraObjects()
end)

AddEventHandler('onResourceStop', function(resourceName)
	if (GetCurrentResourceName() ~= resourceName) then return end
    ClearPedSecondaryTask(PlayerPedId())
    SetEntityAsMissionEntity(TabletObj)
    DetachEntity(TabletObj, true, false)
    DeleteObject(TabletObj)
    UnloadCameraObjects()
    ExitCamera()
end)

AddEventHandler('CEventGunShot', function(witnesses, ped, coords)
    if PlayerPedId() ~= ped then return end
    local Hit, Coords, Entity = RayCastGamePlayCamera(70.0)                     
    if Hit then                                                                        
        if DoesEntityExist(Entity) then
            for k,v in pairs(LoadedProps) do
                if v.Prop == Entity then
                    local FirstPropCoords = GetEntityCoords(v.Prop)
                    local SecondPropCoords = GetEntityCoords(Entity)
                    local Dist = #(FirstPropCoords - SecondPropCoords)
                    if Dist <= 0.1 then
                        local BrokeCamera = lib.callback.await('sf_camerasecurity:Server:BrokeCamera', false, v.Id) 
                        if BrokeCamera == 'true' then
                            notify('You broke a camera', 'error', 5000)
                        end
                    end                          
                end
            end
        end
        for k,v in pairs(LoadedNoPropCams) do
            local NearDist = #(v.Coord - Coords) 
            if NearDist <= 0.3 then
                local BrokeCamera = lib.callback.await('sf_camerasecurity:Server:BrokeCamera', false, v.Id)
                if BrokeCamera == 'true' then
                    notify('You broke a camera', 'error', 5000)
                end
            end    
        end                                                                     
    end
end)

-- Events
RegisterNetEvent('sf_camerasecurity:Client:LoadPropCamera', function(Prop, Coords, Rot, TheId, ShowProp) 
    if isLogin() then
        if ShowProp then
            RequestModel(Prop)
            while not HasModelLoaded(Prop) do Wait(0) end
            local CamProp = CreateObject(Prop, Coords.x, Coords.y, Coords.z, 0, false, false)
            SetEntityCoordsNoOffset(CamProp, Coords.x, Coords.y, Coords.z, true, true, true) 
            SetEntityRotation(CamProp, Rot.x, Rot.y, Rot.z, 2, 1)
            LoadedProps[#LoadedProps +1] = {
                Id = TheId,
                Prop = CamProp
            }
        else
            LoadedNoPropCams[#LoadedNoPropCams +1] = {
                Id = TheId,
                Coord = vector3(Coords.x, Coords.y, Coords.z)
            }
        end
    end 
end)

RegisterNetEvent('sf_camerasecurity:Client:RemovePropCamera', function(TheId, RemoveProp) 
    if isLogin() then
        if RemoveProp then
            for k,v in pairs(LoadedProps) do         
                if tonumber(v.Id) == TheId then
                    DeleteObject(v.Prop)
                    LoadedProps[k] = nil
                    return
                end
            end
        else
            for k,v in pairs(LoadedNoPropCams) do         
                if tonumber(v.Id) == TheId then
                    LoadedNoPropCams[k] = nil
                    return
                end
            end
        end    
    end 
end)

RegisterNetEvent('sf_camerasecurity:Client:CreateNewCamera',function(Type, Job, Item)
    if Active then notify('You are active install camera', 'error', 3500) return end
    CurrentJob = Job
    CurrentType = Type
    CurrentItem = Item
    Active = true
    StartLineCreate(Type)   
end)

RegisterNetEvent('sf_camerasecurity:Client:ConnectCamBySignal',function()
    TabletAnimation()
    local Input = lib.inputDialog('Camera Connect',{
        {type = 'input', label = '', icon = 'wifi', required = true},
    })       
    if Input then
        local WifiZone, NotGoodConnect = InWifiZone()
        if not WifiZone and not Config.DisableWifiSystem then  
            InAnim = false return notify('No wifi in this zone', 'error', 5000) 
        elseif not hasItem(Config.VpnItem) then 
            InAnim = false return notify('Need vpn to Connect wifi', 'error', 5000) 
        end
        if NotGoodConnect and not Config.DisableWifiSystem then InAnim = false return notify('Low reseau wifi', 'error', 5000) end
        lib.callback('sf_camerasecurity:Server:GetStaticCams', false, function(Result)
            if Result then
                local FindCam = false
                local DataConnect = {}
                for k, v in pairs(Result) do
                    local Settings = json.decode(v.setting) 
                    if Settings.Type == 'Signal' or Settings.Type == 'Personal' then
                        if Settings.Signal == Input[1] then
                            FindCam = true
                            DataConnect.ID = v.id
                            DataConnect.Name = v.name
                            DataConnect.Coords = v.coords
                            DataConnect.Rot = v.rot
                            DataConnect.Settings = Settings
                            break
                        end
                    end
                end   
                if FindCam then
                    notify('Connected To Camera Successfully', 'success', 5000)
                    return WatchCam(DataConnect.Name, DataConnect.Coords, DataConnect.Rot, DataConnect.Settings, false, false, DataConnect.ID)                 
                else
                    InAnim = false
                    notify('No Camera With This Signal Or Broken', 'error', 5000)
                end
            end
        end)
    else
        InAnim = false
    end
end)

RegisterNetEvent('sf_camerasecurity:Client:GetSignalPaper',function(signalcode)
    local alert = lib.alertDialog({
        header = 'Camera Signal: '..signalcode,
        centered = true,
        cancel = false,
        labels = {confirm = 'Copy'}
    })
    
    if alert == 'confirm' then
        lib.setClipboard(signalcode)
        notify('Signal Camera Code Copied', 'success')
    end
end)

RegisterNetEvent('sf_camerasecurity:Client:CrashCamera',function(id)
    if InCam then
        if CurrentCamID ~= nil and CurrentCam ~= nil then
            if CurrentCamID == id then
                ExitCamera() 
                notify('Camera Crashed', 'error', 7000)
            end
        end
    end
end)

RegisterNetEvent('sf_camerasecurity:Client:OpenStaticCams',function()
    if InAnim then notify('Already a tablet open', 'error') return end
    lib.callback('sf_camerasecurity:Server:GetStaticCams', false, function(Result)
        if Result then
            local MenuCam = {}  
            local NumberTables = 0
            local DataCams = {}
            for k, v in pairs(Result) do
                local CanShow = false          
                local Settings = json.decode(v.setting)  
                local Icon = 'camera'   
                local Stat = 'Online 🟢' 
                if Settings.Type == 'Job' then
                    if type(Settings.Job) == "table" then          
                        for i,t in pairs(Settings.Job) do
                            
                            if hasJob(t) then
                                DataCams[#DataCams +1] = v
                                CanShow = true
                                break
                            end
                        end
                    else              
                        if hasJob(Settings.Job) then
                            CanShow = true
                        end
                    end
                end
                if Settings.Icon and Settings.Icon ~= '' then Icon = Settings.Icon end
                if tonumber(Settings.Broken) == 1 then Stat = 'Offline 🔴' end
                if CanShow then  
                    NumberTables += 1
                    local Cam_ID = #MenuCam +1
                    MenuCam[Cam_ID] = {
                        title = v.name,
                        description = 'Status: '..Stat,
                        arrow = true,
                        icon = Icon,
                        onSelect = function()
                            local SecendMenu = {}
                            
                            SecendMenu[#SecendMenu +1] = {
                                title = 'Watch',
                                icon = 'camera',
                                onSelect = function()
                                    WatchCam(v.name, v.coords, v.rot, Settings, Cam_ID, DataCams, v.id)
                                end
                            }
                            if tonumber(Settings.CanRemove) == 1 then
                                SecendMenu[#SecendMenu +1] = {
                                    title = 'Remove Camera',
                                    icon = 'trash',
                                    onSelect = function()
                                        removeCamera(v, Settings)                                                                         
                                    end
                                }
                            end
                            if tonumber(Settings.Broken) == 1 then
                                SecendMenu[#SecendMenu +1] = {
                                    title = 'Repair Camera',
                                    icon = 'screwdriver-wrench',
                                    onSelect = function()
                                        repairCamera(v.id, v.coords, Settings)                                                                           
                                    end
                                }
                            end
                            
                            
                            lib.registerContext({
                                id = 'Option_Camera_Menu', 
                                title = v.name, 
                                menu = 'Main_Camera_Menu',
                                canClose = false,
                                options = SecendMenu
                            })  
                            lib.showContext('Option_Camera_Menu')         
                        end
                    }
                end                           
            end
            if NumberTables > 0 then
                TabletAnimation()
                lib.registerContext({id = 'Main_Camera_Menu', title = 'Cameras', onExit = function() InAnim = false end, options = MenuCam})
                lib.showContext('Main_Camera_Menu')
            else
                InAnim = false
                Shown = false
                notify('No Cameras Available In This Job', 'error', 5000)
            end           
        end
    end)
end)

RegisterNetEvent('sf_camerasecurity:Client:DisableInSwitchinCamActions',function()
    while InSwitchingCam do
        DisableActions()
        Wait(0)
    end  
end)

RegisterNetEvent('sf_camerasecurity:Client:LiserFixCam',function(Prop, CamCoord, Time)
    local WaitTime = true
    local Color = {r = 255, g = 0, b = 0, a = 200}
    local Colors = {
        Orange = {r = 255, g = 165, b = 0, a = 200},
        Green = {r = 0, g = 255, b = 0, a = 200}
    } 
    SetTimeout(Time/2.3, function() Color = Colors.Orange end)
    SetTimeout(Time/1.5, function() Color = Colors.Green end)
    SetTimeout(Time, function() WaitTime = false end)   
    while WaitTime do
        local EntityCoords = GetEntityCoords(Prop)       
        DrawLine(EntityCoords.x, EntityCoords.y, EntityCoords.z, CamCoord.x, CamCoord.y, CamCoord.z, Color.r, Color.g, Color.b, Color.a)
        DrawMarker(28, CamCoord.x, CamCoord.y, CamCoord.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, Color.r, Color.g, Color.b, Color.a, false, true, 2, nil, nil, false)        
        Wait(5)
    end 
end)

RegisterNetEvent('sf_camerasecurity:Client:OpenPersonalCamera',function(result, myIdentifier)
    if InAnim then notify('Already a tablet open', 'error') return end

    if not result or not myIdentifier then
        result, myIdentifier = lib.callback.await('sf_camerasecurity:Server:GetStaticCams', false)
    end
    
    if result then
        local Menu = {} 
        for k, v in pairs(result) do
            local setting = json.decode(v.setting)
            if setting.Type == 'Personal' and setting.owned == myIdentifier then
                local stat = (tonumber(setting.Broken) == 1) and 'Offline 🔴' or 'Online 🟢'
                Menu[#Menu +1] = {
                    title = v.name,
                    description = 'Status: '..stat,
                    icon = (setting.Icon and setting.Icon ~= '') and setting.Icon or 'camera',
                    onSelect = function()
                        local menu2 = {}

                        menu2[#menu2 +1] = {
                            title = 'Watch',
                            icon = 'camera',
                            onSelect = function()
                                WatchCam(v.name, v.coords, v.rot, setting, false, false, v.id)
                            end
                        }

                        menu2[#menu2 +1] = {
                            title = 'Show Signal',
                            description = 'This to share the signal with someone',
                            icon = 'signal',
                            onSelect = function()
                                local menu3 = {}

                                menu3[#menu3 +1] = {
                                    title = 'Show Signal',
                                    icon = 'eye',
                                    onSelect = function()
                                        local alert = lib.alertDialog({
                                            header = 'Camera Signal: '..setting.Signal,
                                            centered = true,
                                            cancel = false,
                                            labels = {confirm = 'Copy'}
                                        })
                                        
                                        if alert == 'confirm' then                                                
                                            lib.setClipboard(setting.Signal)
                                            notify('Signal Camera Code Copied', 'success')
                                        end

                                        InAnim = false
                                        Shown = false
                                    end
                                }

                                menu3[#menu3 +1] = {
                                    title = 'Regenerate Signal',
                                    icon = 'repeat',
                                    onSelect = function()
                                        local sign = GenerateRandomSignal()

                                        lib.callback('sf_camerasecurity:Server:RegenerateSignal', false, function(data, ident)
                                            TriggerEvent('sf_camerasecurity:Client:OpenPersonalCamera', data, ident)
                                            InAnim = false
                                            Shown = false
                                            return
                                        end, v.id, sign)
                                    end
                                }

                                lib.registerContext({id = 'setting_personal_signal_cam', menu = 'setting_personal_cam', canClose = false, title = 'Camera Signal', options = menu3})
                                lib.showContext('setting_personal_signal_cam')                  
                            end
                        }

                        if tonumber(setting.Broken) == 1 then
                            menu2[#menu2 +1] = {
                                title = 'Repair Camera',
                                icon = 'screwdriver-wrench',
                                onSelect = function()
                                    repairCamera(v.id, v.coords, setting) 
                                end
                            }
                        end                

                        if tonumber(setting.CanRemove) == 1 then
                            menu2[#menu2 +1] = {
                                title = 'Remove Camera',
                                icon = 'trash',
                                onSelect = function()
                                    removeCamera(v, setting) 
                                end
                            }
                        end    

                        lib.registerContext({id = 'setting_personal_cam', menu = 'personal_cameras', canClose = false, title = v.name, options = menu2})
                        lib.showContext('setting_personal_cam')
                    end
                }   
            end                      
        end

        if #Menu >= 1 then
            TabletAnimation()
            lib.registerContext({id = 'personal_cameras', title = 'Personal Cameras', onExit = function() InAnim = false end, options = Menu })
            lib.showContext('personal_cameras')
        else
            InAnim = false
            Shown = false
            notify('No own camera', 'error')
        end         
    else
        InAnim = false
        Shown = false
        notify('No own camera', 'error')
    end
end)

-- Functions
function LoadingCameraObjects()
    lib.callback('sf_camerasecurity:Server:GetStaticCams', false, function(Result)
        if Result then
            for k, v in pairs(Result) do
                local Settings = json.decode(v.setting) 
                if tonumber(Settings.ShowProp) == 1 then
                    if tonumber(Settings.Broken) == 0 then
                        RequestModel(Settings.Prop)
                        while not HasModelLoaded(Settings.Prop) do Wait(0) end
                        local Coords = Settings.PropCoords.Coords
                        local Rot = Settings.PropCoords.Rotation
                        local CamProp = CreateObject(Settings.Prop, Coords.x, Coords.y, Coords.z, 0, false, false)   
                        SetEntityCoordsNoOffset(CamProp, Coords.x, Coords.y, Coords.z, true, true, true)         
                        SetEntityRotation(CamProp, Rot.x, Rot.y, Rot.z, 2, 1)
                        LoadedProps[#LoadedProps +1] = {
                            Id = v.id,
                            Prop = CamProp
                        }
                    end                   
                else
                    local Coords = Settings.PropCoords.Coords
                    LoadedNoPropCams[#LoadedNoPropCams +1] = {
                        Id = v.id,
                        Coord = vector3(Coords.x, Coords.y, Coords.z)
                    }
                end
            end
        end
    end)
end

function UnloadCameraObjects()
    for _, object in pairs(LoadedProps) do
        DeleteObject(object.Prop)
    end
end

function TabletAnimation()
    if InAnim then return end
    InAnim = true
    -- Animation
    RequestAnimDict(TabletDict)
    while not HasAnimDictLoaded(TabletDict) do Wait(100) end
    -- Model
    RequestModel(TabletProp)
    while not HasModelLoaded(TabletProp) do Wait(100) end

    local plyPed = PlayerPedId()
    TabletObj = CreateObject(TabletProp, 0.0, 0.0, 0.0, true, true, false)
    local tabletBoneIndex = GetPedBoneIndex(plyPed, TabletBone)

    AttachEntityToEntity(TabletObj, plyPed, tabletBoneIndex, TabletOffset.x, TabletOffset.y, TabletOffset.z, TabletRot.x, TabletRot.y, TabletRot.z, true, false, false, false, 2, true)
    SetModelAsNoLongerNeeded(TabletProp)

    CreateThread(function()
        while InAnim do
            Wait(0)
            if not IsEntityPlayingAnim(plyPed, TabletDict, TabletAnim, 3) then
                TaskPlayAnim(plyPed, TabletDict, TabletAnim, 3.0, 3.0, -1, 49, 0, 0, 0, 0)
            end
        end


        ClearPedSecondaryTask(plyPed)
        Wait(250)
        DetachEntity(TabletObj, true, false)
        DeleteEntity(TabletObj)
    end)
end

function GenerateRandomIPv4()
    local ip = {}
    for i = 1, 4 do
        table.insert(ip, math.random(0, 255))
    end

    local GeneratedIP = table.concat(ip, '.')

    -- Check If Generated IP Already Available
    local Result = lib.callback.await('sf_camerasecurity:Server:GetStaticCams', false)
    if Result then
        for k, v in pairs(Result) do
            local Settings = json.decode(v.setting) 
            if Settings.IP == GeneratedIP then
                TriggerServerEvent('sf_camerasecurity:Server:ErrorSendAlert', 'Generate IP Already Available, Try Creating New One')
                return GenerateRandomIPv4()
            end
        end   
    end

    return GeneratedIP
end

function GenerateRandomSignal()
    local characters = "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
    local signal = ""
    
    for i = 1, Config.SignalLength do
        local randomIndex = math.random(1, #characters)
        local randomChar = characters:sub(randomIndex, randomIndex)
        signal = signal .. randomChar
    end
    
    -- Check If Generated Signal Already Available
    local Result = lib.callback.await('sf_camerasecurity:Server:GetStaticCams', false)
    if Result then
        for k, v in pairs(Result) do
            local Settings = json.decode(v.setting) 
            if Settings.Type == 'Signal' or Settings.Type == 'Personal' then
                if Settings.Signal == signal then
                    TriggerServerEvent('sf_camerasecurity:Server:ErrorSendAlert', 'Generate Signale Already Available, Try Creating New One')
                    return GenerateRandomSignal()
                end
            end
        end   
    end
   
    return signal
end

function InWifiZone()
    for k, v in pairs(Config.WifiZones) do
        local pCoords = GetEntityCoords(PlayerPedId())
        local Dist = #(pCoords - v.Coords)
        if Dist <= v.Distance then
            local chanse = math.random(1, 100)
            if CurrentWifiResau == 'red' then
                if chanse >= 30 then
                    return true, true
                else
                    return true, false
                end 
            elseif CurrentWifiResau == 'orange' then            
                if chanse >= 70 then
                    return true, true
                else
                    return true, false
                end             
            else
                return true, false
            end
        end
    end
    return false, true
end

function MoveCoordsForward(x, y, z, heading, distance)
    -- Convert heading to radians
    local headingRad = math.rad(heading)

    -- Calculate the new coordinates
    local newX = x - distance * math.sin(headingRad)
    local newY = y + distance * math.cos(headingRad)

    return {x = newX, y = newY, z = z, w = heading}
end

function WatchCam(Name, Coords, Rotation, Action, Cam_ID, DataCams, ID)
    if not InCam then
        if Config.Inventory == 'qb-inventory' then
            LocalPlayer.state:set('inv_busy', true, false)
        elseif Config.Inventory == 'ox_inventory' then
            LocalPlayer.state:set('invBusy', true, false)
        end
        CurrentCamID = ID
        local LoadingCams = {} 
        local CuurentNumberCam 
        if Action.Type == 'Job' then
            CuurentNumberCam = Cam_ID
            for _, datacam in pairs(DataCams) do LoadingCams[_] = datacam end
        elseif Action.Type == 'Signal' then
            CuurentNumberCam = ''
        elseif Action.Type == 'Personal' then
            CuurentNumberCam = ''
        end        
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Wait(0) end
        InCam = true
        local coords = json.decode(Coords)
        local rot = json.decode(Rotation)
        CurrentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
        local ForwardCoords = MoveCoordsForward(coords.x,coords.y,coords.z, rot.z, Config.MoveCamForwardDistance) 
        SetCamCoord(CurrentCam, ForwardCoords.x,ForwardCoords.y,ForwardCoords.z)
        SetCamRot(CurrentCam, rot.x,rot.y,rot.z, 2)
        SetFocusPosAndVel(ForwardCoords.x,ForwardCoords.y,ForwardCoords.z,0,0,0)
        SetTimecycleModifier("scanline_cam_cheap")
        SetTimecycleModifierStrength(2.0)
        RenderScriptCams(true, false, 0, 1, 0)
        local s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
        local street = GetStreetNameFromHashKey(s1)
        if tonumber(Action.Broken) == 1 then Action.Broken = false else Action.Broken = true end
        SendNUIMessage({
            type = "enablecam",
            label = Name,
            id = Action.IP,
            connected = Action.Broken,
            address = street,
            time = GetCurrentTime(),
        })
        FreezeEntityPosition(PlayerPedId(), true)
        Wait(500)
        DoScreenFadeIn(500)
        local RighthingMove = 0
        local Clicked = false
        while InCam do
            local instructions = CreateInstuctionScaleform("instructional_buttons", Action.Type == 'Job')
            DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)
            DisableActions()
            if tonumber(Action.CanMove) == 1 then
                local CamRot = GetCamRot(CurrentCam, 2)

                -- ROTATE UP
                if IsControlPressed(0, 32) then
                    if CamRot.x <= 0.0 then
                        SetCamRot(CurrentCam, CamRot.x + 0.7, 0.0, CamRot.z, 2)
                    end
                end
    
                -- ROTATE DOWN
                if IsControlPressed(0, 8) then
                    if CamRot.x >= -50.0 then
                        SetCamRot(CurrentCam, CamRot.x - 0.7, 0.0, CamRot.z, 2)
                    end
                end
    
                -- ROTATE LEFT
                if IsControlPressed(0, 34) then                
                    if RighthingMove < 50.0 then
                        RighthingMove += 1
                        SetCamRot(CurrentCam, CamRot.x, 0.0, CamRot.z + 0.7, 2)
                    end         
                end
    
                -- ROTATE RIGHT
                if IsControlPressed(0, 9) then
                    if RighthingMove > -50.0 then
                        RighthingMove -= 1
                        SetCamRot(CurrentCam, CamRot.x, 0.0, CamRot.z - 0.7, 2)
                    end                       
                end      
            end 

            if Action.Type == 'Job' then
                -- NEXT CAM
                if IsControlJustPressed(0, 223) and (not IsControlPressed(0, 222)) then
                    if not Clicked then
                        Clicked = true
                        CuurentNumberCam += 1
                        if CuurentNumberCam > #LoadingCams then CuurentNumberCam = 1 end 
                    end                                   
                end

                -- BACK CAM
                if IsControlJustPressed(0, 222) and (not IsControlPressed(0, 223)) then
                    if not Clicked then
                        Clicked = true
                        CuurentNumberCam -= 1
                        if CuurentNumberCam < 1  then CuurentNumberCam = #LoadingCams end 
                    end                           
                end

                if Clicked and not InSwitchingCam then
                    InSwitchingCam = true
                    if #LoadingCams > 1 then
                        TriggerEvent('sf_camerasecurity:Client:DisableInSwitchinCamActions')
                        DoScreenFadeOut(1000)
                        while not IsScreenFadedOut() do Wait(0) end
                        SendNUIMessage({
                            type = "disablecam",
                        })
                        ClearTimecycleModifier("scanline_cam_cheap")
                        RenderScriptCams(false, false, 0, 1, 0)
                        DestroyCam(CurrentCam, false)
                        CurrentCam = CreateCam("DEFAULT_SCRIPTED_CAMERA", 1)
                        local DataCam = LoadingCams[CuurentNumberCam]
                        coords = json.decode(DataCam.coords)
                        rot = json.decode(DataCam.rot)
                        local Settings = json.decode(DataCam.setting)
                        CurrentCamID = DataCam.id
                        ForwardCoords = MoveCoordsForward(coords.x,coords.y,coords.z, rot.z, Config.MoveCamForwardDistance) 
                        SetCamCoord(CurrentCam, ForwardCoords.x,ForwardCoords.y,ForwardCoords.z)
                        SetCamRot(CurrentCam, rot.x,rot.y,rot.z, 2)
                        SetFocusPosAndVel(ForwardCoords.x,ForwardCoords.y,ForwardCoords.z,0,0,0)
                        SetTimecycleModifier("scanline_cam_cheap")
                        SetTimecycleModifierStrength(2.0)
                        RenderScriptCams(true, false, 0, 1, 0)
                        s1, s2 = GetStreetNameAtCoord(coords.x, coords.y, coords.z)
                        street = GetStreetNameFromHashKey(s1)                
                        if tonumber(Settings.Broken) == 1 then Settings.Broken = false else Settings.Broken = true end
                        Action.CanMove = Settings.CanMove
                        if Settings.Broken then
                            SendNUIMessage({
                                type = "enablecam",
                                label = DataCam.name,
                                id = Settings.IP,
                                connected = Settings.Broken,
                                address = street,
                                time = GetCurrentTime(),
                            })
                            DoScreenFadeIn(1000)
                        else
                            DoScreenFadeIn(1000)
                            SendNUIMessage({
                                type = "enablecam",
                                label = DataCam.name,
                                id = Settings.IP,
                                connected = Settings.Broken,
                                address = street,
                                time = GetCurrentTime(),
                            })
                        end   
                        while not IsScreenFadedIn() do Wait(0) end          
                        SetTimeout(500, function()
                            InSwitchingCam = false
                            Clicked = false  
                        end) 
                    else
                        notify('No Cams To Swap', 'error', 3500)
                        SetTimeout(2000, function()
                            InSwitchingCam = false
                            Clicked = false  
                        end) 
                    end           
                end  
            end                  
            Wait(0)
        end
        FreezeEntityPosition(PlayerPedId(), false)
        Shown = false
        InAnim = false
    end
end

function GetCurrentTime()
    local hours = GetClockHours()
    local minutes = GetClockMinutes()
    if hours < 10 then
        hours = tostring(0 .. GetClockHours())
    end
    if minutes < 10 then
        minutes = tostring(0 .. GetClockMinutes())
    end
    return tostring(hours .. ":" .. minutes)
end

function InstructionButton(ControlButton)
    ScaleformMovieMethodAddParamPlayerNameString(ControlButton)
end

function InstructionButtonMessage(text)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function InstructionalButton(controlButton, text)
    ScaleformMovieMethodAddParamPlayerNameString(controlButton)
    BeginTextCommandScaleformString("STRING")
    AddTextComponentScaleform(text)
    EndTextCommandScaleformString()
end

function CreateInstuctionScaleform(scaleform, switch)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ---------------------------------------------------------------------------------
    InstructionalButton(GetControlInstructionalButton(0, 194, 1), "Exit Camera")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(1)
    if switch then
        InstructionalButton(GetControlInstructionalButton(0, 25, 1), 'Back Cam') 
        PopScaleformMovieFunctionVoid()
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(2)
        InstructionalButton(GetControlInstructionalButton(0, 24, 1), 'Next Cam') 
        PopScaleformMovieFunctionVoid()
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(3)
    end  
    ---------------------------------------------------------------------------------
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()
    return scaleform
end

function CreateInstuctionScaleformCustom(scaleform, keys)
    local scaleform = RequestScaleformMovie(scaleform)
    while not HasScaleformMovieLoaded(scaleform) do
        Wait(0)
    end
    PushScaleformMovieFunction(scaleform, "CLEAR_ALL")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_CLEAR_SPACE")
    PushScaleformMovieFunctionParameterInt(200)
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
    PushScaleformMovieFunctionParameterInt(0)
    ---------------------------------------------------------------------------------
    for k, v in pairs(keys) do     
        InstructionalButton(GetControlInstructionalButton(0, v.Key, 1), v.Text)
        PopScaleformMovieFunctionVoid()
        PushScaleformMovieFunction(scaleform, "SET_DATA_SLOT")
        PushScaleformMovieFunctionParameterInt(k)       
    end
    ---------------------------------------------------------------------------------
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "DRAW_INSTRUCTIONAL_BUTTONS")
    PopScaleformMovieFunctionVoid()
    PushScaleformMovieFunction(scaleform, "SET_BACKGROUND_COLOUR")
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(0)
    PushScaleformMovieFunctionParameterInt(80)
    PopScaleformMovieFunctionVoid()
    SetScaleformMovieAsNoLongerNeeded()
    return scaleform
end

function DisableActions()
    DisableControlAction(0, 30, true) -- disable left/right
    DisableControlAction(0, 36, true) -- Left CTRL
    DisableControlAction(0, 31, true) -- disable forward/back
    DisableControlAction(0, 36, true) -- INPUT_DUCK
    DisableControlAction(0, 21, true) -- disable sprint
    DisableControlAction(0, 75, true)  -- Disable exit vehicle
    DisableControlAction(27, 75, true) -- Disable exit vehicle 

    DisableControlAction(0, 63, true) -- veh turn left
    DisableControlAction(0, 64, true) -- veh turn right
    DisableControlAction(0, 71, true) -- veh forward
    DisableControlAction(0, 72, true) -- veh backwards
    DisableControlAction(0, 75, true) -- disable exit vehicle

    DisablePlayerFiring(PlayerId(), true) -- Disable weapon firing
    DisableControlAction(0, 24, true) -- disable attack
    DisableControlAction(0, 25, true) -- disable aim
    DisableControlAction(1, 37, true) -- disable weapon select
    DisableControlAction(0, 47, true) -- disable weapon
    DisableControlAction(0, 58, true) -- disable weapon
    DisableControlAction(0, 140, true) -- disable melee
    DisableControlAction(0, 141, true) -- disable melee
    DisableControlAction(0, 142, true) -- disable melee
    DisableControlAction(0, 143, true) -- disable melee
    DisableControlAction(0, 263, true) -- disable melee
    DisableControlAction(0, 264, true) -- disable melee
    DisableControlAction(0, 257, true) -- disable melee

    DisableControlAction(0, 199, true) -- ESC
    DisableControlAction(0, 200, true) -- P
end

function ExitCamera()
    if InCam and (CurrentCam ~= nil) then
        InCam = false
        DoScreenFadeOut(500)
        while not IsScreenFadedOut() do Wait(0) end     
        ClearTimecycleModifier("scanline_cam_cheap")
        RenderScriptCams(false, false, 0, 1, 0)
        DestroyCam(CurrentCam, false)
        SetFocusEntity(PlayerPedId())
        ClearPedTasks(PlayerPedId())
        Wait(500)
        SendNUIMessage({
            type = "disablecam",
        })
        DoScreenFadeIn(500)      
        while not IsScreenFadedIn() do Wait(0) end
        CurrentCam = nil
        if Config.Inventory == 'qb-inventory' then
            LocalPlayer.state:set('inv_busy', false, false)
        elseif Config.Inventory == 'ox_inventory' then
            LocalPlayer.state:set('invBusy', false, false)
        end
    elseif Active then
        Active = false
        DeleteEntity(spyCam)
    elseif InGetLock then
        Canceled = true
    end
end

function RotationToDirection(rotation)
    local adjustedRotation = 
    { 
        x = (math.pi / 180) * rotation.x, 
        y = (math.pi / 180) * rotation.y, 
        z = (math.pi / 180) * rotation.z 
    }
    local direction = 
    {
        x = -math.sin(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        y = math.cos(adjustedRotation.z) * math.abs(math.cos(adjustedRotation.x)), 
        z = math.sin(adjustedRotation.x)
    }
    return direction
end

function RayCastGamePlayCamera(distance)
    -- Checks to see if the Gameplay Cam is Rendering or another is rendering (no clip functionality)
    local currentRenderingCam = false
    if not IsGameplayCamRendering() then
        currentRenderingCam = GetRenderingCam()
    end

    local cameraRotation = not currentRenderingCam and GetGameplayCamRot() or GetCamRot(currentRenderingCam, 2)
    local cameraCoord = not currentRenderingCam and GetGameplayCamCoord() or GetCamCoord(currentRenderingCam)
    local direction = RotationToDirection(cameraRotation)
    local destination =    {
        x = cameraCoord.x + direction.x * distance,
        y = cameraCoord.y + direction.y * distance,
        z = cameraCoord.z + direction.z * distance
    }
    local _, b, c, _, e = GetShapeTestResult(StartShapeTestRay(cameraCoord.x, cameraCoord.y, cameraCoord.z, destination.x, destination.y, destination.z, -1, PlayerPedId(), 0))
    return b, c, e
end

function StartLineCreate(thetype)
    local coords = GetEntityCoords(PlayerPedId())
    local UIShowed = false
    local ThePropHash 
    if thetype == 'Job' then
        ThePropHash = Config.PropListJob[1]
    elseif thetype == 'Signal' then
        ThePropHash = Config.SignalItem.Prop
    elseif thetype == 'Personal' then
        ThePropHash = Config.PersonalCamera.Props[1]
    end
    CurrentHashCam = ThePropHash
    RequestModel(ThePropHash)
    while not HasModelLoaded(ThePropHash) do Wait(0) end

    spyCam = CreateObject(ThePropHash,coords,0,false,false)
    SetEntityCollision(spyCam,false)
    local CurrentProp = 1
    local DistanceCamCreate = Config.DistanceCreateCam.Jobs
    if thetype == 'Signal' then
        DistanceCamCreate = Config.DistanceCreateCam.SignalCam
    elseif thetype == 'Personal' then
        DistanceCamCreate = Config.DistanceCreateCam.PersonalCam
    end
    local KeysTable = {
        {Text = 'Set Camera', Key = 38},
        {Text = 'Cancel', Key = 194},
        {Text = 'Right Camera', Key = 175},
        {Text = 'Left Camera', Key = 174},
        {Text = 'UP Camera', Key = 172},
        {Text = 'Down Camera', Key = 173},
    }
    if thetype ~= 'Signal' then
        KeysTable[#KeysTable +1] = {Text = 'Next Cam Prop', Key = 311}
        KeysTable[#KeysTable +1] = {Text = 'Back Cam Prop', Key = 182}
    end
    local InLoadingProp = false
    CreateThread(function()
        while Active do
            local hit, coords, entity = RayCastGamePlayCamera(DistanceCamCreate)
            local playerPed = PlayerPedId()
            local position = GetEntityCoords(playerPed)
            local color = {r = 255, g = 0, b = 0, a = 200} 
            if hit and #(position - vector3(coords.x, coords.y, coords.z)) <= DistanceCamCreate then
                InHit = true

                local instructions = CreateInstuctionScaleformCustom("instructional_buttons", KeysTable)
                DrawScaleformMovieFullscreen(instructions, 255, 255, 255, 255, 0)

                -- Outline Prop Camera
                SetEntityDrawOutline(spyCam, true)
                SetEntityDrawOutlineColor(color.r, color.g, color.b, color.a)

                DrawLine(position.x, position.y, position.z, coords.x, coords.y, coords.z, color.r, color.g, color.b, color.a)
                
                if not UIShowed then 
                    UIShowed = true
                    SetEntityVisible(spyCam, true, 0)                 
                end
                -- GET COORDS ENTITY
                local GetEntityRotation = GetEntityRotation(spyCam)

                -- SET OBJECT IN WALL
                SetEntityCoords(spyCam, coords.x, coords.y, coords.z, true, true, true)

                -- ROTATE UP
                if IsControlPressed(0, 172) then
                    SetEntityRotation(spyCam, GetEntityRotation.x - Config.Sens.Up, GetEntityRotation.y, GetEntityRotation.z, 2, 1)
                end

                -- ROTATE DOWN
                if IsControlPressed(0, 173) then
                    SetEntityRotation(spyCam, GetEntityRotation.x + Config.Sens.Down, GetEntityRotation.y, GetEntityRotation.z, 2, 1)
                end

                -- ROTATE LEFT
                if IsControlPressed(0, 174) then
                    SetEntityRotation(spyCam, GetEntityRotation.x, GetEntityRotation.y, GetEntityRotation.z - Config.Sens.Left, 2, 1)
                end

                -- ROTATE RIGHT
                if IsControlPressed(0, 175) then
                    SetEntityRotation(spyCam, GetEntityRotation.x, GetEntityRotation.y, GetEntityRotation.z + Config.Sens.Right, 2, 1)
                end

                -- To Add Camera
                if IsControlPressed(0, 38) then -- E
                    CurrentPlayerCoordDistance = GetEntityCoords(PlayerPedId())
                    PlaceCam()
                    return
                end
            else
                if UIShowed then 
                    UIShowed = false
                    SetEntityVisible(spyCam, false, 0)
                end
                InHit = false
            end
            if thetype ~= 'Signal' then
                local PropSwitched = false

                -- BACK PROP
                if IsControlJustPressed(0, 182) then
                    if not PropSwitched then
                        CurrentProp -= 1
                        if CurrentProp < 1 then
                            CurrentProp = #Config.PropListJob
                        end
                        PropSwitched = true
                    end
                end

                -- NEXT PROP
                if IsControlJustPressed(0, 311) then
                    if not PropSwitched then
                        CurrentProp += 1
                        if CurrentProp > #Config.PropListJob then
                            CurrentProp = 1
                        end
                        PropSwitched = true
                    end                  
                end

                if PropSwitched and not InLoadingProp then
                    InLoadingProp = true
                    CurrentHashCam = Config.PropListJob[CurrentProp]
                    DeleteEntity(spyCam)
                    RequestModel(Config.PropListJob[CurrentProp])
                    while not HasModelLoaded(Config.PropListJob[CurrentProp]) do Wait(0) end          
                    spyCam = CreateObject(Config.PropListJob[CurrentProp],coords, 0, false, false)
                    SetEntityCollision(spyCam, false)
                    PropSwitched = false
                    InLoadingProp = false 
                end
            end
            Wait(0)
        end
    end)
end

function PlaceCam(Data)
    CreateThread(function()
        if Active and InHit then
            InGetLock = true
            Active = false
            SetEntityDrawOutline(spyCam, false)
            local coords = GetEntityCoords(spyCam)
            local PropCameraCoords = {
                Coords = coords,
                Rotation = GetEntityRotation(spyCam)
            }   
            local LockCoords
            local KeysTabl = {{Text = 'Where You Want Camera Lock', Key = 47}, {Text = 'To Cancel', Key = 194}}
            while InGetLock do
                DrawScaleformMovieFullscreen(CreateInstuctionScaleformCustom("instructional_buttons", KeysTabl), 255, 255, 255, 255, 0)
    
                if Canceled then 
                    Canceled = false 
                    InGetLock = false 
                    DeleteEntity(spyCam) 
                    return 
                end
    
                local Toch, Coords, Entity = RayCastGamePlayCamera(100.0)
                local pCoords = GetEntityCoords(PlayerPedId())
                local Color = {r = 0, g = 255, b = 0, a = 200}
                if Toch then
                    DrawLine(pCoords.x, pCoords.y, pCoords.z, Coords.x, Coords.y, Coords.z, Color.r, Color.g, Color.b, Color.a)
                    DrawMarker(28, Coords.x, Coords.y, Coords.z, 0.0, 0.0, 0.0, 0.0, 180.0, 0.0, 0.1, 0.1, 0.1, Color.r, Color.g, Color.b, Color.a, false, true, 2, nil, nil, false)
                    if IsDisabledControlJustPressed(0, 47) then -- G
                        LockCoords = Coords
                        InGetLock = false
                    end
                end         
                Wait(0)
            end
            local Camera = CreateCameraWithParams("DEFAULT_SCRIPTED_CAMERA", coords, 0.0, 0.0, 0.0, 90.0, true, 2)
            PointCamAtCoord(Camera, LockCoords.x, LockCoords.y, LockCoords.z)
            Wait(200)
            local cameraRotation = GetCamRot(Camera, 2)     
            DestroyCam(Camera, false)
            local Table = {}
            
            if Data then        
                if CurrentType == 'Job' then
                    Table[#Table +1] = {type = 'input', label = 'Camera Name', required = true, min = 4, max = 30, default = Data[1]}
                    Table[#Table +1] = {type = 'input', label = 'Icon', min = 4, max = 20, default = Data[2]}
                    Table[#Table +1] = {type = 'checkbox', label = 'Can Remove', checked = Data[3]}
                    Table[#Table +1] = {type = 'checkbox', label = 'Show Camera Prop', checked = Data[4]}
                    Table[#Table +1] = {type = 'checkbox', label = 'Enable Movement', checked = Data[5]}
                elseif CurrentType == 'Signal' then
                    Table[#Table +1] = {type = 'input', label = 'Camera Name', required = true, min = 4, max = 20, default = Data[1]}
                    Table[#Table +1] = {type = 'checkbox', label = 'Enable Movement', checked = Data[5]}
                elseif CurrentType == 'Personal' then

                end
            else
                if CurrentType == 'Job' then
                    Table[#Table +1] = {type = 'input', label = 'Camera Name', required = true, min = 4, max = 30}
                    Table[#Table +1] = {type = 'input', label = 'Icon', min = 4, max = 20}
                    Table[#Table +1] = {type = 'checkbox', label = 'Can Remove'}
                    Table[#Table +1] = {type = 'checkbox', label = 'Show Camera Prop'}
                    Table[#Table +1] = {type = 'checkbox', label = 'Enable Movement'}
                elseif CurrentType == 'Signal' then
                    Table[#Table +1] = {type = 'input', label = 'Camera Name', required = true, min = 4, max = 30}
                    Table[#Table +1] = {type = 'checkbox', label = 'Enable Movement'}
                elseif CurrentType == 'Personal' then
                    Table[#Table +1] = {type = 'input', label = 'Camera Name', required = true, min = 4, max = 30}
                    Table[#Table +1] = {type = 'input', label = 'Icon', min = 4, max = 20}
                    Table[#Table +1] = {type = 'checkbox', label = 'Can Remove'}
                    Table[#Table +1] = {type = 'checkbox', label = 'Enable Movement'}
                end      
            end
    
            local Input = lib.inputDialog('Camera Setting', Table)
            
            if Input then
                local Confirm = lib.alertDialog({
                    header = 'Are You Sure About Your Information',
                    centered = true, cancel = true
                })
                if Confirm == 'confirm' then 
                    if CurrentType == 'Job' then
                        if Input[3] then Input[3] = 1 else Input[3] = 0 end
                        if Input[4] then Input[4] = 1 else Input[4] = 0 end
                        if Input[5] then Input[5] = 1 else Input[5] = 0 end
                    elseif CurrentType == 'Signal' then
                        if Input[2] then Input[2] = 1 else Input[2] = 0 end
                    elseif CurrentType == 'Personal' then
                        if Input[3] then Input[3] = 1 else Input[3] = 0 end
                        if Input[4] then Input[4] = 1 else Input[4] = 0 end
                    end     
    
                    if CurrentType == 'Job' then
                        local Setting = {
                            Prop = CurrentHashCam, 
                            Icon = Input[2] or 'camera', 
                            CanRemove = Input[3], 
                            ShowProp = Input[4], 
                            CanMove = Input[5], 
                            Type = CurrentType, 
                            Job = CurrentJob, 
                            PropCoords = PropCameraCoords, 
                            Broken = 0, 
                            IP = GenerateRandomIPv4(), 
                            DistanceRemove = #(CurrentPlayerCoordDistance - coords)
                        }
                        DeleteEntity(spyCam)
                        local RecheckItem = hasItem(CurrentItem)
                        if RecheckItem then
                            TriggerServerEvent('sf_camerasecurity:Server:SaveNewCam', Input[1], Setting, json.encode(coords), json.encode(cameraRotation), CurrentItem)
                        else
                            notify('Need item to add camera', 'error', 5000)
                        end
                        
                        CurrentType = nil
                        CurrentJob = nil
                        CurrentItem = nil
                    elseif CurrentType == 'Signal' then
                        local Setting = {
                            Prop = Config.SignalItem.Prop, 
                            Icon = '', 
                            CanRemove = 1, 
                            ShowProp = 1, 
                            CanMove = Input[2], 
                            Type = CurrentType, 
                            Job = '', 
                            PropCoords = PropCameraCoords, 
                            Signal = GenerateRandomSignal(),
                            Broken = 0, 
                            IP = GenerateRandomIPv4(), 
                            DistanceRemove = #(CurrentPlayerCoordDistance - coords)
                        }
                        DeleteEntity(spyCam)
                        local RecheckItem = hasItem(CurrentItem)
                        if RecheckItem then
                            TriggerServerEvent('sf_camerasecurity:Server:SaveNewCam', Input[1], Setting, json.encode(coords), json.encode(cameraRotation), CurrentItem, Setting.Signal)
                        else
                            notify('Need item to add camera', 'error', 5000)
                        end        
                        CurrentType = nil
                        CurrentJob = nil
                        CurrentItem = nil
                    elseif CurrentType == 'Personal' then
                        local Setting = {
                            Prop = CurrentHashCam, 
                            Icon = Input[2] or 'camera', 
                            CanRemove = Input[3], 
                            ShowProp = 1, 
                            CanMove = Input[4], 
                            Type = CurrentType, 
                            PropCoords = PropCameraCoords, 
                            Broken = 0, 
                            IP = GenerateRandomIPv4(), 
                            Signal = GenerateRandomSignal(),
                            DistanceRemove = #(CurrentPlayerCoordDistance - coords)
                        }
                        DeleteEntity(spyCam)
                        local RecheckItem = hasItem(CurrentItem)
                        if RecheckItem then
                            TriggerServerEvent('sf_camerasecurity:Server:SaveNewCam', Input[1], Setting, json.encode(coords), json.encode(cameraRotation), CurrentItem)
                        else
                            notify('Need item to add camera', 'error', 5000)
                        end
                        
                        CurrentType = nil
                        CurrentJob = nil
                        CurrentItem = nil
                    end             
                elseif Confirm == 'cancel' then
                    Active = true
                    PlaceCam(Input)
                    return 
                end 
            else
                DeleteEntity(spyCam)          
            end
        end  
    end)  
end

function hasItem(item)
    return lib.callback.await('sf_camerasecurity:Server:HasItem', false, item)
end

function CheckJob(job)
    if not job then return true end
    if type(job) == 'table' then
        for k,v in pairs(job) do        
            if hasJob(v) then
                return true
            end
        end

        return false
    else
        return hasJob(job)
    end
end

function OpenShop()
    if not Config.Shop.Enable then return end
    local menu = {}

    for k,v in ipairs(Config.Shop.Store) do
        if CheckJob(v.job) then
            local itemInfo = getItemInfo(v.item)
            local img = Config.ImageLinkInventory.. (itemInfo.image or itemInfo.name..'.png')
            menu[#menu +1] = {
                title = itemInfo.label,
                description = 'Price: '..v.price..'$',
                icon = img,
                image = img,
                onSelect = function()
                    local menu2 = {
                        {
                            title = 'Pay Cash',
                            icon = 'money-bill',
                            onSelect = function()
                                local input = lib.inputDialog('Item Amount', {
                                    {type = 'number', icon = 'hashtag', min = 1},
                                })
    
                                if input then
                                    local amount = tonumber(input[1])
                                    TriggerServerEvent('sf_camerasecurity:Server:BuyItem', 'cash', v.price, v.item, amount)
                                else
                                    lib.showContext('camera_shop_cash_bank')
                                end
                            end
                        },
                        {
                            title = 'Pay Bank',
                            icon = 'building-columns',
                            onSelect = function()
                                local input = lib.inputDialog('Item Amount', {
                                    {type = 'number', icon = 'hashtag', min = 1},
                                })
    
                                if input then
                                    local amount = tonumber(input[1])
                                    TriggerServerEvent('sf_camerasecurity:Server:BuyItem', 'bank', v.price, v.item, amount)
                                else
                                    lib.showContext('camera_shop_cash_bank')
                                end
                            end
                        },
                    }
    
                    lib.registerContext({id = 'camera_shop_cash_bank', menu = 'camera_shop_menu', canClose = false, title = 'Payment Type', options = menu2})
                    lib.showContext('camera_shop_cash_bank')
                end
            }
        end
    end

    lib.registerContext({id = 'camera_shop_menu', title = 'Camera Shop', options = menu})
    lib.showContext('camera_shop_menu')
end

function repairCamera(id, coords, setting)
    local pCoords = GetEntityCoords(PlayerPedId())
    local CamCoords = json.decode(coords)                                       
    local Dist = #(pCoords - vector3(CamCoords.x, CamCoords.y, CamCoords.z)) 
    if Dist <= setting.DistanceRemove + 1 then
        if hasItem(Config.NeedItemFixCam) then
            local timerrr = Config.TimerFixCamera*1000

            TriggerEvent('sf_camerasecurity:Client:LiserFixCam', TabletObj, CamCoords, timerrr)

            local progressON = true
            CreateThread(function() progressBar("Repairing....", timerrr) end)
            SetTimeout(timerrr, function() progressON = false end)
            while progressON do 
                DisableAllControlActions(0)
                EnableControlAction(0, 1, true)
                EnableControlAction(0, 2, true)
                Wait(5) 
            end

            InAnim = false                               
            TriggerServerEvent('sf_camerasecurity:Server:FixCameraByID', id)  
        else
            InAnim = false 
            notify('Need item ('..getItemInfo(Config.NeedItemFixCam).label..')', 'error', 5000)
        end
    else
        InAnim = false
        notify('Need to be near this camera', 'error', 5000)
    end  
end

function removeCamera(v, sett)
    local pCoords = GetEntityCoords(PlayerPedId())
    local CamCoords = json.decode(v.coords)                                       
    local Dist = #(pCoords - vector3(CamCoords.x, CamCoords.y, CamCoords.z)) 
    if Dist <= sett.DistanceRemove + 1 then
        local Confirm = lib.alertDialog({
            header = 'Are You Sure You Want Remove Camera ('..v.name..')',
            centered = true, cancel = true
        })
        if Confirm == 'confirm' then
            InAnim = false
            TriggerServerEvent('sf_camerasecurity:Server:RemoveStaticCam', v.id)      
        elseif Confirm == 'cancel' then
            lib.showContext('Option_Camera_Menu') 
        end  
    else
        InAnim = false
        notify('Need to be near this camera', 'error', 5000)
    end
end

-- Threads
CreateThread(function() -- Loop Zones
    local WaitTime = 2000
    local InRange = false
    while true do
        InRange = false
        if isLogin() then
            WaitTime = 1500
            for k, v in pairs(Config.JobConnectLocations) do       
                if hasJob(k) then               
                    local pCoords = GetEntityCoords(PlayerPedId())
                    local Dist = #(pCoords - v.Coords)
                    if Dist <= 20 and Dist >= 2 then
                        WaitTime = 500
                    end
                    if Dist <= 2 then
                        InRange = true
                        WaitTime = 5
                        if IsControlPressed(0, 38) then -- E
                            TriggerEvent('sf_camerasecurity:Client:OpenStaticCams') 
                            Wait(500)
                        end
                    end
                end
            end
        end

        if InRange and not Shown and not InCam then
            Shown = true
            lib.showTextUI('[E] Camera List', {position = "left-center"})
        elseif (not InRange and Shown) or InCam then
            Shown = false
            lib.hideTextUI()
        end
        Wait(WaitTime)
    end
end)

CreateThread(function()
    if Config.Shop.Blip.Enable then
        local blip = AddBlipForCoord(Config.Shop.Coords.x, Config.Shop.Coords.y, Config.Shop.Coords.z)
        SetBlipSprite(blip, Config.Shop.Blip.Sprite)
        SetBlipScale(blip, Config.Shop.Blip.Scale)
        SetBlipDisplay(blip, 4)
        SetBlipColour(blip, Config.Shop.Blip.Color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentSubstringPlayerName(Config.Shop.Label)
        EndTextCommandSetBlipName(blip)
    end

    if Config.Shop.Enable then
        local CurrentPed = type(Config.Shop.Ped) == "number" and Config.Shop.Ped or joaat(Config.Shop.Ped)

        RequestModel(CurrentPed)
        while not HasModelLoaded(CurrentPed) do
            Wait(0)
        end
    
        local Ped = CreatePed(0, CurrentPed, Config.Shop.Coords.x, Config.Shop.Coords.y, Config.Shop.Coords.z-1, Config.Shop.Coords.w, false, false)   
        TaskStartScenarioInPlace(Ped, Config.Shop.Scenario, 0, true)
        FreezeEntityPosition(Ped, true)
        SetEntityInvincible(Ped, true)
        SetBlockingOfNonTemporaryEvents(Ped, true)
    
        if Config.Target == 'qb-target' then
            exports['qb-target']:AddTargetEntity(Ped, {
                options = {
                    {
                        label = Config.Shop.Label,
                        icon = Config.Shop.Icon,
                        action = function()
                            OpenShop()
                        end,
                        canInteract = function() 
                            return isLogin()
                        end     
                    }
                },
                distance = 2.0
            })
        elseif Config.Target == 'ox_target' then
            exports.ox_target:addLocalEntity(Ped, {
                {
                    label = Config.Shop.Label,
                    icon = Config.Shop.Icon,
                    onSelect = function()
                        OpenShop()
                    end,
                    canInteract = function() 
                        return isLogin()
                    end     
                }
            })
        end 
    end

    if Config.Inventory == 'ox_inventory' then
        exports.ox_inventory:displayMetadata({
            signal = 'Camera Signal'
        })
    end   
end)

CreateThread(function()
    if not Config.EnableWifiIcon then return end
    local wait = 2000
    local stat, lastStat, inWifiZone, shown = 'green', 'green', false, false
    while true do
        if isLogin() then
            inWifiZone = false
            wait = 500
            local pedCoords = GetEntityCoords(PlayerPedId())
            for k,v in pairs(Config.WifiZones) do
                local lineWifi = v.Distance/3
                local dist = #(pedCoords - v.Coords)
                inWifiZone = dist <= v.Distance
                
                if dist <= lineWifi then
                    stat = 'green'
                elseif dist <= lineWifi*2 then
                    stat = 'orange'
                else
                    stat = 'red'
                end

                CurrentWifiResau = stat

                if inWifiZone then
                    wait = 200
                    break
                end
            end 
            
            if ((inWifiZone and not shown) or (inWifiZone and stat ~= lastStat)) and not InCam then
                shown = true
                lastStat = stat

                local isOpen, text = lib.isTextUIOpen()
                if isOpen and text == '' then
                    lib.hideTextUI()
                    lib.showTextUI('', {
                        position = "top-center",
                        icon = 'wifi',
                        iconAnimation = 'beatFade',
                        style = {
                            borderRadius = 5,
                            backgroundColor = 'rgba(0, 0, 0, 0.7)',
                            color = lastStat,
                            fontSize = '30px'
                        }
                    })
                else
                    if not isOpen then
                        lib.showTextUI('', {
                            position = "top-center",
                            icon = 'wifi',
                            iconAnimation = 'beatFade',
                            style = {
                                borderRadius = 5,
                                backgroundColor = 'rgba(0, 0, 0, 0.7)',
                                color = lastStat,
                                fontSize = '30px'
                            }
                        })
                    end            
                end              
            elseif (not inWifiZone and shown) or InCam then
                shown = false
                lib.hideTextUI()
            end
        else
            wait = 2000
        end
        Wait(wait)
    end
end)

-- KEY BINDS
RegisterKeyMapping("exitcamera", "Exit Camera", "keyboard", "BACK") 
RegisterCommand('exitcamera', ExitCamera, false)   
