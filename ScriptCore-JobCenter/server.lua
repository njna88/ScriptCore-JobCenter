local ESX = nil
local QBCore = nil
local framework = nil

local function detectFramework()
    if Config.Framework ~= 'auto' then
        return Config.Framework
    end

    if GetResourceState('es_extended') == 'started' then
        return 'esx'
    end

    if GetResourceState('qb-core') == 'started' then
        return 'qb'
    end

    return 'standalone'
end

CreateThread(function()
    framework = detectFramework()

    if framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        print('^2[ScriptCore-JobCenter] ESX detected^7')
    elseif framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
        print('^2[ScriptCore-JobCenter] QBCore detected^7')
    else
        print('^3[ScriptCore-JobCenter] Standalone mode - job change disabled^7')
    end
end)

local function getJobFromConfig(jobName)
    for _, job in pairs(Config.Jobs) do
        if job.job == jobName then
            return job
        end
    end

    return nil
end

RegisterNetEvent('scriptcore_jobcenter:setJob', function(jobName)
    local src = source
    local selectedJob = getJobFromConfig(jobName)

    if not selectedJob then
        TriggerClientEvent('scriptcore_jobcenter:notify', src, 'JobCenter', 'Det job findes ikke i config.lua.', 'error')
        return
    end

    local grade = tonumber(selectedJob.grade or Config.DefaultGrade) or 0

    if framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(src)
        if not xPlayer then return end

        xPlayer.setJob(selectedJob.job, grade)
        TriggerClientEvent('scriptcore_jobcenter:notify', src, 'JobCenter', 'Du er nu ansat som ' .. selectedJob.label .. '.', 'success')
        return
    end

    if framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(src)
        if not Player then return end

        Player.Functions.SetJob(selectedJob.job, grade)
        TriggerClientEvent('scriptcore_jobcenter:notify', src, 'JobCenter', 'Du er nu ansat som ' .. selectedJob.label .. '.', 'success')
        return
    end

    TriggerClientEvent('scriptcore_jobcenter:notify', src, 'JobCenter', 'Ingen framework fundet. Sæt Config.Framework til esx eller qb.', 'error')
end)
