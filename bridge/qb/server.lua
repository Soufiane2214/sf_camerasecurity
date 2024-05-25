if Config.Framework ~= 'QBCore' then return end

Core = exports['qb-core']:GetCoreObject()  -- Framework call

-- get player
function getPlayer(src)
    return Core.Functions.GetPlayer(src)
end

-- check if player has job
function hasJob(src, job)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return nil end

    return Player.PlayerData.job.name == job
end

-- check if has money
function hasMoney(src, type, amount)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return nil end

    return Player.PlayerData.money[type] >= amount 
end

-- remove money
function removeMoney(src, type, amount)
    local Player = Core.Functions.GetPlayer(src)
    if not Player then return nil end

    return Player.Functions.RemoveMoney(type, amount)
end