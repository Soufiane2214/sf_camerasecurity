if Config.Framework ~= 'ESX' then return end 

Core = exports['es_extended']:getSharedObject()  -- Framework call

-- Events
RegisterNetEvent('esx:playerLoaded',function(xPlayer, isNew, skin)
    LoadingCameraObjects()
end)

RegisterNetEvent("esx:playerLogout", function(playerId)
    UnloadCameraObjects()
end)

-- Functions
function isLogin()
    return Core.IsPlayerLoaded()
end

function hasJob(job)
    return Core.GetPlayerData().job.name == job
end