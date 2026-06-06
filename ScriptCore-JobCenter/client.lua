local ped = nil
local currentFramework = nil

local function debugPrint(...)
    if Config.Debug then
        print('[ScriptCore-JobCenter]', ...)
    end
end

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

local function notify(title, description, type)
    lib.notify({
        title = title or 'Jobcenter',
        description = description or '',
        type = type or 'inform'
    })
end

local function loadModel(model)
    local hash = joaat(model)
    RequestModel(hash)

    local timeout = GetGameTimer() + 8000
    while not HasModelLoaded(hash) do
        Wait(25)
        if GetGameTimer() > timeout then
            return nil
        end
    end

    return hash
end

local function openJobCenter()
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = 'open',
        jobs = Config.Jobs,
        title = 'Jobcenter',
        subtitle = 'Vælg et job'
    })
end

local function closeJobCenter()
    SetNuiFocus(false, false)
    SendNUIMessage({ action = 'close' })
end

RegisterNUICallback('close', function(_, cb)
    closeJobCenter()
    cb({ ok = true })
end)

RegisterNUICallback('selectJob', function(data, cb)
    if not data or not data.job then
        cb({ ok = false })
        return
    end

    TriggerServerEvent('scriptcore_jobcenter:setJob', data.job)
    closeJobCenter()
    cb({ ok = true })
end)

RegisterNetEvent('scriptcore_jobcenter:notify', function(title, description, type)
    notify(title, description, type)
end)

CreateThread(function()
    currentFramework = detectFramework()
    debugPrint('Framework:', currentFramework)

    if Config.Blip.enabled then
        local blip = AddBlipForCoord(Config.NPC.coords.x, Config.NPC.coords.y, Config.NPC.coords.z)
        SetBlipSprite(blip, Config.Blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, Config.Blip.scale)
        SetBlipColour(blip, Config.Blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(Config.Blip.label)
        EndTextCommandSetBlipName(blip)
    end

    if not Config.NPC.enabled then return end

    local hash = loadModel(Config.NPC.model)
    if not hash then
        print('^1[ScriptCore-JobCenter] Kunne ikke loade NPC model: ' .. Config.NPC.model .. '^7')
        return
    end

    local c = Config.NPC.coords
    ped = CreatePed(4, hash, c.x, c.y, c.z - 1.0, c.w, false, true)
    SetModelAsNoLongerNeeded(hash)

    if Config.NPC.freeze then FreezeEntityPosition(ped, true) end
    if Config.NPC.invincible then SetEntityInvincible(ped, true) end
    if Config.NPC.blockEvents then SetBlockingOfNonTemporaryEvents(ped, true) end

    if Config.NPC.scenario and Config.NPC.scenario ~= '' then
        TaskStartScenarioInPlace(ped, Config.NPC.scenario, 0, true)
    end

    exports.ox_target:addLocalEntity(ped, {
        {
            name = 'scriptcore_jobcenter_open',
            icon = Config.Target.icon,
            label = Config.Target.label,
            distance = Config.Target.distance,
            onSelect = function()
                openJobCenter()
            end
        }
    })
end)

AddEventHandler('onResourceStop', function(resource)
    if resource ~= GetCurrentResourceName() then return end

    if ped and DoesEntityExist(ped) then
        exports.ox_target:removeLocalEntity(ped, 'scriptcore_jobcenter_open')
        DeleteEntity(ped)
    end
end)
