Config = {}

Config.Framework = 'qbcore'


Config.TargetType = 'ox' -- Choose target system: 'ox', 'qb', or 'custom'

Config.RefundPercentage = 0.5 -- 50%

Config.Locations = {
    {
        label = "Downtown Rental",
        pedModel = 's_m_m_security_01',
        coords = vector4(-1029.82, -2734.69, 20.17, 328.72),
        spawn = vector4(-1028.28, -2731.63, 20.15, 237.75),
        blip = {sprite = 226, color = 2}
    },
    -- Add more locations as needed
}

Config.Vehicles = {
    {label = "BMX Bike", model = "bmx", price = 100},
    {label = "Cruiser Bike", model = "cruiser", price = 150},
    {label = "Faggio Scooter", model = "faggio", price = 500},
    {label = "Sanchez Dirt Bike", model = "sanchez", price = 800},
    {label = "Blista Compact", model = "blista", price = 1200}
}
