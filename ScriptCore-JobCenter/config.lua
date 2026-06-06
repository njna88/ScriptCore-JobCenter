Config = {}

Config.Framework = 'auto'
Config.Debug = false

Config.NPC = {
    enabled = true,
    model = 'a_m_m_business_01',
    coords = vector4(-232.3660, -915.6187, 32.3108, 335.9729),
    scenario = 'WORLD_HUMAN_CLIPBOARD',
    freeze = true,
    invincible = true,
    blockEvents = true
}

Config.Target = {
    icon = 'fa-solid fa-briefcase',
    label = 'Åbn JobCenter',
    distance = 2.2
}

Config.Blip = {
    enabled = true,
    sprite = 407,
    color = 0,
    scale = 0.7,
    label = 'JobCenter'
}

Config.DefaultGrade = 0

Config.Jobs = {
    { label = 'Skraldemand', job = 'garbage', grade = 0, icon = 'fa-trash' },
    { label = 'Taxi Chauffør', job = 'taxi', grade = 0, icon = 'fa-taxi' },
    { label = 'Mekaniker', job = 'mechanic', grade = 0, icon = 'fa-wrench' },
    { label = 'Miner', job = 'miner', grade = 0, icon = 'fa-hammer' },
    { label = 'Arbejdsløs', job = 'unemployed', grade = 0, icon = 'fa-user-slash' }
}
