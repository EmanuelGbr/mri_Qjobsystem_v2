local IS_SERVER = IsDuplicityVersion()

Config = {}

Config.DefaultDataJob = {
    label = '',
    job = '',
    craftings = {},
    type = '',
    grades = {},
    typejob = ''
}

Config.Security = {
    maxCraftAmount = 50,
    creatorAce = 'group.admin'
}

Config.DefaultCraftAnimation = {
    anim = 'hack_loop',
    dict = 'mp_prison_break'
}

Config.BlacklistedStrings = {
    -- "weapon", "weed", "meth", "coke", "ammo", "gun", "pistol", "drug", "c4", "WEAPON", "AMMO", "at_", "keycard", "money", "black_money"
}

Config.jobTypeList = {
    { value = 'leo', label = 'Policiais (leo)' },
    { value = 'ems', label = 'Paramédicos (ems)' },
    { value = 'mechanic', label = 'Mecânicos (mechanic)' },
    { value = 'realestate', label = 'Imobiliária (realestate)' },
    { value = 'Nenhum', label = 'Sem tipo' }
}

Config.DirectoryToInventoryImages = 'nui://ox_inventory/web/images/'

if not IS_SERVER then
    function openBossmenu(jobtype)
        exports.qbx_management:OpenBossMenu(jobtype)
    end

    function SendDispatch(coords, jobLabel)
        local policeJobs = { 'police' }
        exports['ps-dispatch']:CustomAlert({
            coords = coords,
            job = policeJobs,
            message = 'Alarme Acionado!',
            dispatchCode = '10-??',
            firstStreet = coords,
            description = 'Alarme acionado de ' .. jobLabel,
            radius = 0,
            sprite = 161,
            color = 1,
            scale = 1.0,
            length = 3
        })
    end
end
