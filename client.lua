local rentedVehicle = nil

local QBCore = nil
local ESX = nil

CreateThread(function()
    if Config.Framework == 'qbcore' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end)

CreateThread(function()
    for i, loc in ipairs(Config.Locations) do
        RequestModel(loc.pedModel)
        while not HasModelLoaded(loc.pedModel) do
            Wait(0)
        end

        local ped = CreatePed(0, loc.pedModel, loc.coords.x, loc.coords.y, loc.coords.z - 1, loc.coords.w, false, true)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)

        local function addRentalTargets(ped, i, loc)
            local options = {
                {
                    icon = 'fa-car',
                    label = 'Rent a Vehicle',
                    onSelect = function()
                        local opts = {}
                        for _, vehicle in ipairs(Config.Vehicles) do
                            table.insert(opts, {
                                title = vehicle.label .. " ($" .. vehicle.price .. ")",
                                onSelect = function()
                                    TriggerServerEvent('rental:attemptRent', vehicle.model, loc.spawn, vehicle.price)
                                end
                            })
                        end
                        lib.registerContext({
                            id = 'rental_menu_' .. i,
                            title = loc.label,
                            options = opts
                        })
                        lib.showContext('rental_menu_' .. i)
                    end
                },
                {
                    icon = 'fa-undo',
                    label = 'Return Vehicle',
                    onSelect = function()
                        if rentedVehicle and DoesEntityExist(rentedVehicle) then
                            DeleteVehicle(rentedVehicle)
                            rentedVehicle = nil
                            TriggerServerEvent('rental:returnVehicle')
                        else
                            notify("No rented vehicle to return.", "error")
                        end
                    end
                }
            }

            if Config.TargetType == 'ox' then
                exports.ox_target:addLocalEntity(ped, options)
            elseif Config.TargetType == 'qb' then
                exports['qb-target']:AddTargetEntity(ped, {
                    options = options,
                    distance = 2.5
                })
            elseif Config.TargetType == 'custom' then
                -- Your own targeting logic can go here
            end
        end

        local blip = AddBlipForCoord(loc.coords.x, loc.coords.y, loc.coords.z)
        SetBlipSprite(blip, loc.blip.sprite)
        SetBlipDisplay(blip, 4)
        SetBlipScale(blip, 0.65)
        SetBlipColour(blip, loc.blip.color)
        SetBlipAsShortRange(blip, true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(loc.label)
        EndTextCommandSetBlipName(blip)
    end
end)

RegisterNetEvent('rental:spawnVehicle', function(model, spawnCoords)
    local playerPed = PlayerPedId()
    QBCore.Functions.SpawnVehicle(model, function(veh)
        SetEntityCoords(veh, spawnCoords.x, spawnCoords.y, spawnCoords.z)
        SetEntityHeading(veh, spawnCoords.w)
        SetVehicleNumberPlateText(veh, "RENTAL")
        TaskWarpPedIntoVehicle(playerPed, veh, -1)
        rentedVehicle = veh
    end, spawnCoords, true)
end)

function notify(msg, type)
    if Config.Framework == 'qbcore' then
        QBCore.Functions.Notify(msg, type)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(msg)
    else
        print(msg)
    end
end
