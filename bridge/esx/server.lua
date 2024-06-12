if Config.Framework ~= 'ESX' then return end

Core = exports['es_extended']:getSharedObject()  -- Framework call

-- get player
function getPlayer(src)
    return Core.GetPlayerFromId(src)
end

-- check if player has job
function hasJob(src, job)
    local xPlayer = Core.GetPlayerFromId(src)
    if not xPlayer then return false end

    return xPlayer.getJob().name == job
end

-- get identifier
function getIdenti(src)
    local xPlayer = Core.GetPlayerFromId(src)
    if not xPlayer then return false end

    return xPlayer.getIdentifier()
end

-- check if has money
function hasMoney(src, type, amount)
    local xPlayer = Core.GetPlayerFromId(src)
    if not xPlayer then return nil end

    if type == 'cash' then type = 'money' end   
    return xPlayer.getAccount(type).money >= amount
end

-- remove money
function removeMoney(src, type, amount)
    local xPlayer = Core.GetPlayerFromId(src)
    if not xPlayer then return nil end

    if type == 'cash' then type = 'money' end 
    xPlayer.removeAccountMoney(type, amount)
end
