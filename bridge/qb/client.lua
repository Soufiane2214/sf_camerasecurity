if Config.Framework ~= 'QBCore' then return end

Core = exports['qb-core']:GetCoreObject()  -- Framework call
local PlayerJob = {}

-- Events
RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function() 
    PlayerJob = Core.Functions.GetPlayerData().job
    LoadingCameraObjects()
end)

RegisterNetEvent('QBCore:Client:OnPlayerUnload', function()
    UnloadCameraObjects()
    PlayerJob = {}
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function(jobInfo)
    PlayerJob = jobInfo
end)

-- Functions
function isLogin()
    return LocalPlayer.state.isLoggedIn
end

function hasJob(job)
    return PlayerJob.name == job
end