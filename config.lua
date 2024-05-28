Config = Config or {}

Config.Framework = 'QBCore'     -- ESX / QBCore

Config.Inventory = 'qb-inventory'       -- ox_inventory / qb-inventory   (Note: dont use qb-inventory if your framework esx please)
Config.SignalLength = 12   -- how much characters and numbers in signal 
Config.MoveCamForwardDistance = 0.2     -- this only move camera coords to forward because some times big cam props hide the vision
Config.ImageLinkInventory = "nui://qb-inventory/html/images/"  -- location images inventory ("nui://qb-inventory/html/images/") / ("nui://ox_inventory/web/images/")
Config.RemoteTablet = 'camera_viewer'       -- for Citizens
Config.TabletCamViewJobs = 'camera_tablet'  -- for Jobs
Config.NeedItemFixCam = 'screwdriverset'    -- for job to fix cam
Config.CameraSignalPaper = 'camera_paper'   -- for citizens to receive signal when create new camera
Config.VpnItem = 'vpn'                      -- require this item in location wifi to watch camera
Config.DisableWifiSystem = false            -- if you want disable wifi system 
Config.TimerFixCamera = 10      -- sec (this only for jobs, no fix cam for normal camera)
Config.Target = 'qb-target'     -- ox_target / qb-target
Config.Notify = 'lib'           -- qb / esx / lib / custom (require to add your custom notify in [sf_camerasecurity/client/utils.lua])
Config.ProgressBar = 'lib'      -- qb / esx / lib / custom (require to add your custom progressbar in [sf_camerasecurity/client/utils.lua])
Config.EnableWifiIcon = true    -- if you are near zone wifi is show you a icon wifi up screen

-- shop information
Config.Shop = {   
    Enable = true,                                        -- to active shop
    Label = 'Camera Shop',                                -- name shop
    Icon = 'fa-solid fa-camera',                          -- icon target eye
    Ped = 's_m_y_grip_01',                                -- ped shop
    Scenario = 'WORLD_HUMAN_CLIPBOARD',                   -- scenario ped
    Coords = vector4(152.98, -1363.35, 29.33, 230.07),    -- location ped
    Distance = 2.5,                                       -- distance to require to use ped shop
    Blip = {Enable = true, Sprite = 184, Scale = 0.6, Color = 32},       -- blip setting

    -- item shop and prices 
    Store = {   
        {item = 'camera_viewer',    price = 1500},
        {item = 'vpn',              price = 1000},
        {item = 'camera_citizen',   price = 500},   
        {item = 'camera_pd',        price = 250,    job = {'police'}},
        {item = 'camera_ems',       price = 250,    job = {'ambulance'}},
        {item = 'camera_tablet',    price = 1000,   job = {'police', 'ambulance'}},
        {item = 'screwdriverset',   price = 250,    job = {'police', 'ambulance'}},
    }
}

-- props camera list only for jobs
Config.PropListJob = {     
    [1] = 'prop_cctv_cam_06a',
    [2] = 'prop_cctv_cam_04a',
    [3] = 'prop_cctv_cam_05a',
    [4] = 'prop_cctv_cam_02a',
    [5] = 'prop_cctv_cam_01a',
    [6] = 'prop_cctv_cam_07a',
    [7] = 'prop_cctv_cam_01b',
    [8] = 'prop_cctv_cam_04b',
    [9] = 'prop_cctv_cam_03a',
    [10] = 'prop_cctv_cam_04c',
    [11] = 'prop_cs_cctv',
    [12] = 'hei_prop_bank_cctv_01',
    [13] = 'hei_prop_bank_cctv_02',
    [14] = 'p_cctv_s',
    [15] = 'prop_snow_cam_03a',
    [16] = 'prop_spycam'
}

Config.DistanceCreateCam = {
    Jobs = 70.0,        -- max distance to put camera for job 
    SignalCam = 20.0    -- max distance to put camera for normal players 
}

-- wifi zones
Config.WifiZones = { 
    {
        Coords = vector3(29.66, -1345.06, 29.5),
        Distance = 10,
    }
}

-- player camera item
Config.SignalItem = {
    NameItem = 'camera_citizen',
    Type = 'Signal',
    Prop = 'prop_cctv_cam_01a'
}

-- sens to move camera (left, right..) when you watching
Config.Sens = {
    Right = 1,
    Left = 1,
    Up = 1,
    Down = 1
}

-- item and job can use this item
Config.JobItems = {
    {ItemName = 'camera_pd', Type = 'Job', Job = {'police', 'lssd'}},
    {ItemName = 'camera_ems', Type = 'Job', Job = 'ambulance'},
}

-- this for jobs if he not have tablet like (cctv) to open camera
Config.JobConnectLocations = {
    ['police'] = {
        Coords = vector3(440.71, -978.79, 29.69),
        Distance = 1
    }
}
