local QBCore = nil
local ESX = nil

if Config.Framework == 'qbcore' then
    QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
    TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
end

RegisterNetEvent('rental:attemptRent', function(model, spawnCoords, price)
    local src = source
    local Player = nil

    if Config.Framework == 'qbcore' then
        Player = QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' then
        Player = ESX.GetPlayerFromId(src)
    end

    if not Player then return end

    local validPrice = nil
    for _, v in ipairs(Config.Vehicles) do
        if v.model == model then
            validPrice = v.price
            break
        end
    end

    if not validPrice or validPrice ~= price then
        print(("Player [%s] attempted to exploit rental price!"):format(src))
        return
    end

    local canAfford = false
    if Config.Framework == 'qbcore' then
        if Player.Functions.RemoveMoney('cash', price, 'vehicle-rental') then
            canAfford = true
        end
    elseif Config.Framework == 'esx' then
        if Player.getMoney() >= price then
            Player.removeMoney(price)
            canAfford = true
        end
    end

    if canAfford then
        TriggerClientEvent('rental:spawnVehicle', src, model, spawnCoords)
    else
        TriggerClientEvent('QBCore:Notify', src, "Insufficient funds for rental.", "error")
    end
end)

RegisterNetEvent('rental:returnVehicle', function()
    local src = source
    local Player = nil

    if Config.Framework == 'qbcore' then
        Player = QBCore.Functions.GetPlayer(src)
    elseif Config.Framework == 'esx' then
        Player = ESX.GetPlayerFromId(src)
    end

    if not Player then return end

    -- Calculate refund
    local refundAmount = 0
    -- Assuming you have a way to track the rented vehicle's price per player
    -- For simplicity, we'll use a fixed refund here
    refundAmount = 500 -- Replace with actual calculation

    if Config.Framework == 'qbcore' then
        Player.Functions.AddMoney('cash', refundAmount, 'vehicle-rental-refund')
    elseif Config.Framework == 'esx' then
        Player.addMoney(refundAmount)
    end

    TriggerClientEvent('QBCore:Notify', src, "You've received a refund of $" .. refundAmount, "success")
end)
