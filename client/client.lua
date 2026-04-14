Jobs = {}
local Targets = {}
local Peds = {}
local Blips = {}
local items = BRIDGE.GetItems()

local function getPlayerJobName()
    local playerData = QBX and QBX.PlayerData
    return playerData and playerData.job and playerData.job.name or nil
end

local function getPlayerGangName()
    local playerData = QBX and QBX.PlayerData
    return playerData and playerData.gang and playerData.gang.name or nil
end

local function AddNewPed(pedData)
    table.insert(Peds, pedData)
end

local function clearPeds()
    for _, ped in pairs(Peds) do
        if DoesEntityExist(ped) then
            DeleteEntity(ped)
        end
    end
    Peds = {}
end

local function clearVisuals()
    for _, blip in pairs(Blips) do
        if DoesBlipExist(blip) then
            RemoveBlip(blip)
        end
    end
    Blips = {}
end

local function generateCrafting(craftItems, label, type)
    local options = {}
    local metadata = {}
    if craftItems and type then
        options = {}
        for _, k in pairs(craftItems) do
            metadata = {{
                label = "Itens requeridos",
                value = ""
            }}
            for _, l in pairs(k.ingedience) do
                if not items[l.itemName] then
                    print("[PLS] Error  ITEM NOT FOUND")
                else
                    local label = items[l.itemName].label
                    table.insert(metadata, {
                        label = label,
                        value = l.itemCount
                    })
                end
            end

            table.insert(options, {
                title = items[k.itemName].label .. " - " .. (k and k.count or 1) .. " x",
                icon = Config.DirectoryToInventoryImages .. k.itemName .. ".png",
                image = Config.DirectoryToInventoryImages .. k.itemName .. ".png",
                onSelect = function()
                    -- Perguntar quantos ele quer fabricar
                    local input = lib.inputDialog('Digite a quantidade', {
                        {type = 'number', label = 'Quantidade', default = 1}
                    })

                    if not input then
                        return lib.notify({
                            title = "Ação cancelada.",
                            type = "error"
                        })
                    end

                    local amount = input and input[1] or 1

                    local hasAllItems = true
                    for _, v in pairs(k.ingedience) do
                        if v.itemCount * amount > BRIDGE.GetItemCount(v.itemName) then
                            hasAllItems = false
                        end
                    end
                    if hasAllItems then
                        local animData = {
                            anim = Config.DefaultCraftAnimation.anim,
                            dict = Config.DefaultCraftAnimation.dict
                        }
                        if k.animation then
                            animData = {
                                anim = k.animation.anim,
                                dict = k.animation.dict,
                                scully = k.animation.scully
                            }
                        end
                        local label_progress = type and "Fabricando" or "Comprando"

                        local anim = {
                            anim = animData.anim,
                            dict = animData.dict
                        }

                        if animData and animData.scully then
                            ExecuteCommand(string.format("e %s", animData.scully))
                            anim = nil
                        end

                        if lib.progressCircle({
                            duration = k.duration and k.duration * 1000 * amount or 5000 * amount,
                            label = label_progress .. ' ' .. items[k.itemName].label,
                            position = 'bottom',
                            useWhileDead = false,
                            canCancel = true,
                            disable = {
                                car = true,
                                move = true
                            },
                            anim = anim
                        }) then
                            if animData.scully then
                                ExecuteCommand("e c")
                            end
                            TriggerSecureEvent("mri_Qjobsystem:server:createItem", k, amount)
                        end
                    else
                        lib.notify({
                            title = "Erro",
                            description = "Você não tem todos os itens!",
                            type = "error"
                        })
                    end
                end,
                metadata = metadata
            })
        end
        lib.registerContext({
            id = "job_system_crafting",
            title = label,
            description = "Lista de itens",
            options = options
        })
        lib.showContext("job_system_crafting")
    end
end

local function openCashRegister(job)
    local cashBalance = lib.callback.await('mri_Qjobsystem:server:getBalance', 100, job)
    if cashBalance then
        lib.registerContext({
            id = "cash_register",
            title = "Caixa registradora",
            options = {{
                name = 'balance',
                icon = 'fa-solid fa-dollar',
                title = "Saldo: R$" .. cashBalance
            }, {
                name = 'withdraw',
                icon = 'fa-solid fa-arrow-down',
                title = "Retirar",
                onSelect = function(data)
                    local input = lib.inputDialog('Crie um novo trabalho', {{
                        type = 'number',
                        label = 'Retirar',
                        description = 'Quanto você quer retirar?',
                        icon = 'hashtag',
                        min = 1
                    }})
                    if input then
                        TriggerSecureEvent("mri_Qjobsystem:server:makeRegisterAction", job, "withdraw", input[1])
                    end
                end
            }, {
                name = 'deposit',
                icon = 'fa-solid fa-arrow-up',
                title = "Depósito",
                onSelect = function(data)
                    local input = lib.inputDialog('Crie um novo trabalho', {{
                        type = 'number',
                        label = 'Depósito',
                        description = 'Quanto você deseja depósito',
                        icon = 'hashtag',
                        min = 1
                    }})
                    if input then
                        TriggerSecureEvent("mri_Qjobsystem:server:makeRegisterAction", job, "deposit", input[1])
                    end
                end
            }}
        })
        lib.showContext("cash_register")
    end
end

local function loadModel(model)
    local modelHash = model
    if type(model) == 'string' then
        modelHash = joaat(model)
    end

    if not IsModelInCdimage(modelHash) then return nil end
    RequestModel(modelHash)

    local timeout = GetGameTimer() + 5000
    while not HasModelLoaded(modelHash) do
        if GetGameTimer() > timeout then
            return nil
        end
        Wait(0)
    end

    return modelHash
end

local function playPedAnimation(ped, pedData)
    if pedData.scenario then
        TaskStartScenarioInPlace(ped, pedData.scenario, 0, true)
        return
    end

    local anim = pedData.animation or {}
    if anim.dict and anim.anim then
        RequestAnimDict(anim.dict)
        local timeout = GetGameTimer() + 3000
        while not HasAnimDictLoaded(anim.dict) do
            if GetGameTimer() > timeout then
                return
            end
            Wait(0)
        end
        TaskPlayAnim(ped, anim.dict, anim.anim, 8.0, -8.0, -1, anim.flag or 1, 0.0, false, false, false)
    end
end

local function createConfiguredPed(pedData)
    if not pedData or not pedData.model or not pedData.coords then return end

    local modelHash = loadModel(pedData.model)
    if not modelHash then return end

    local heading = pedData.heading or pedData.coords.w or 0.0
    local ped = CreatePed(4, modelHash, pedData.coords.x, pedData.coords.y, pedData.coords.z - 1.0, heading, false, false)
    SetModelAsNoLongerNeeded(modelHash)

    if not DoesEntityExist(ped) then return end

    FreezeEntityPosition(ped, true)
    SetEntityInvincible(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    playPedAnimation(ped, pedData)
    AddNewPed(ped)
end

local function GenerateCraftings()
    clearPeds()
    clearVisuals()

    for _, job in pairs(Jobs) do
        if job.coords then
            local blip = AddBlipForCoord(job.coords.x, job.coords.y, job.coords.z)
            SetBlipSprite(blip, 280)
            SetBlipScale(blip, 0.7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName('STRING')
            AddTextComponentString(job.label or job.job)
            EndTextCommandSetBlipName(blip)
            table.insert(Blips, blip)
        end

        for _, crafting in pairs(job.craftings) do
            local craftinglabel = crafting.label
            local targetId = BRIDGE.AddSphereTarget({
                coords = vector3(crafting.coords.x, crafting.coords.y, crafting.coords.z),
                options = {{
                    name = 'sphere',
                    icon = crafting.icon or 'fa-solid fa-screwdriver-wrench',
                    label = string.format("Abrir %s", crafting.label),
                    onSelect = function(data)
                        local jobname = getPlayerJobName()
                        local gangname = getPlayerGangName()

                        if crafting.public or (jobname == job.job) or (gangname == job.job) then
                            local icon = crafting.icon or 'fa-solid fa-screwdriver-wrench'
                            local type = (icon == 'fa-solid fa-screwdriver-wrench') and true or false

                            if type then
                                generateCrafting(crafting.items, craftinglabel, type)
                            else
                                exports.ox_inventory:openInventory('shop', {
                                    type = crafting.id
                                })
                            end
                        else
                            lib.notify({
                                title = "Você não tem permissão",
                                description = "Você não pode usar isso.",
                                type = "error"
                            })
                        end
                    end
                }},
                debug = false,
                radius = 0.2
            })
            table.insert(Targets, targetId)
        end

        for _, pedData in pairs(job.peds or {}) do
            createConfiguredPed(pedData)
        end

        ------- ON DUTY
        if job.duty then
            local DutyRegister = BRIDGE.AddSphereTarget({
                coords = vector3(job.duty.x, job.duty.y, job.duty.z),
                options = {{
                    name = 'bell',
                    icon = 'fa-solid fa-briefcase',
                    label = "Bater ponto",
                    onSelect = function(data)
                        local jobname = getPlayerJobName()
                        if jobname == job.job then
                            TriggerServerEvent("QBCore:ToggleDuty")
                        else
                            lib.notify({
                                title = "Você não tem permissão",
                                description = "Você não pode usar isso.",
                                type = "error"
                            })
                        end
                    end
                }},
                debug = false,
                radius = 0.2
            })
            table.insert(Targets, DutyRegister)
        end

        ------- CASH REGISTER

        if job.register then
            local CashRegister = BRIDGE.AddSphereTarget({
                coords = vector3(job.register.x, job.register.y, job.register.z),
                options = {{
                    name = 'bell',
                    icon = 'fa-solid fa-circle',
                    label = "Caixa registradora",
                    onSelect = function(data)
                        local jobname = getPlayerJobName()
                        local gangname = getPlayerGangName()

                        if jobname == job.job or gangname == job.job then
                            openCashRegister(job.job)
                        else
                            lib.notify({
                                title = "Você não tem permissão",
                                description = "Você não pode usar isso.",
                                type = "error"
                            })
                        end
                    end
                }},
                debug = false,
                radius = 0.2
            })
            table.insert(Targets, CashRegister)
        end

        ------- ALARM
        if job.alarm then
            local AlarmTarget = BRIDGE.AddSphereTarget({
                coords = vector3(job.alarm.x, job.alarm.y, job.alarm.z),
                options = {{
                    name = 'bell',
                    icon = 'fa-solid fa-circle',
                    label = "Alarme",
                    onSelect = function(data)
                        local jobname = getPlayerJobName()
                        if jobname == job.job then
                            local alert = lib.alertDialog({
                                header = "Ligue para a polícia",
                                content = "Você realmente quer ligar para a polícia?",
                                centered = true,
                                cancel = true
                            })
                            if alert == "confirm" then
                                SendDispatch(GetEntityCoords(cache.ped), job.label)
                            end
                        else
                            lib.notify({
                                title = "Você não tem permissão",
                                description = "Você não pode usar isso.",
                                type = "error"
                            })
                        end
                    end
                }},
                debug = false,
                radius = 0.2
            })
            table.insert(Targets, AlarmTarget)
        end

        ------- STASHES
        for _, stash in pairs(job.stashes or {}) do
            if stash.coords then
                local stashTarget = BRIDGE.AddSphereTarget({
                    coords = vector3(stash.coords.x, stash.coords.y, stash.coords.z),
                    options = {{
                        name = ('stash_%s'):format(stash.id),
                        icon = 'fa-solid fa-box-open',
                        label = stash.label or 'Abrir baú',
                        onSelect = function()
                            local jobname = getPlayerJobName()
                            local gangname = getPlayerGangName()
                            local canAccess = stash.public or stash.job == false or jobname == job.job or gangname == job.job

                            if not canAccess then
                                return lib.notify({
                                    title = "Você não tem permissão",
                                    description = "Você não pode usar isso.",
                                    type = "error"
                                })
                            end

                            BRIDGE.OpenStash(stash.id)
                        end
                    }},
                    debug = false,
                    radius = 0.3
                })
                table.insert(Targets, stashTarget)
            end
        end

        if job.bossmenu then
            local BossTarget = BRIDGE.AddSphereTarget({
                coords = vector3(job.bossmenu.x, job.bossmenu.y, job.bossmenu.z),
                options = {{
                    name = 'bell',
                    icon = 'fa-solid fa-laptop',
                    label = "Boss menu",
                    onSelect = function(data)
                        local jobname = getPlayerJobName()
                        local gangname = getPlayerGangName()
                        if jobname == job.job or gangname == job.job then
                            openBossmenu(job.type)
                        else
                            lib.notify({
                                title = "Você não tem permissão",
                                description = "Você não pode usar isso.",
                                type = "error"
                            })
                        end
                    end
                }},
                debug = false,
                radius = 0.2
            })
            table.insert(Targets, BossTarget)
        end
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded', function()
    local PlayerData = QBX.PlayerData
    local jobName = PlayerData.job.name
    local jobType = PlayerData.job.type
    local jobGrade = PlayerData.job.grade

    LocalPlayer.state:set('jobName', jobName, true)
    LocalPlayer.state:set('jobType', jobType, true)
    LocalPlayer.state:set('jobGrade', jobGrade, true)
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate', function()
    local PlayerData = QBX.PlayerData
    local jobName = PlayerData.job.name
    local jobType = PlayerData.job.type
    local jobGrade = PlayerData.job.grade

    LocalPlayer.state:set('jobName', jobName, true)
    LocalPlayer.state:set('jobType', jobType, true)
    LocalPlayer.state:set('jobGrade', jobGrade, true)
end)

RegisterNetEvent("mri_Qjobsystem:client:receiveJobs", function(ServerJobs)
    local PlayerData = QBX.PlayerData
    local jobType = PlayerData.job.type

    LocalPlayer.state:set('jobType', jobType, true)
    if ServerJobs then
        for _, tid in pairs(Targets) do
            BRIDGE.RemoveSphereTarget(tid)
        end
        Wait(100)
        Jobs = ServerJobs
        GenerateCraftings()
    end
    RemoveManagementItems()
    AddManagementItens()
end)

RegisterNetEvent("mri_Qjobsystem:client:Pull")
AddEventHandler("mri_Qjobsystem:client:Pull", function(ServerJobs)
    for _, tid in pairs(Targets) do
        BRIDGE.RemoveSphereTarget(tid)
    end
    Wait(100)
    Jobs = ServerJobs
    Wait(100)
    GenerateCraftings()
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end
    clearPeds()
    clearVisuals()
end)
