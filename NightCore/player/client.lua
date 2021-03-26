-- VARIABLE
local firstSpawn = false

local money = 0
local bank = 0
_drawHUD = true

-- FUNCTION CUSTOM 
function printClient(message)
    print(client_prefix .. message)
end


function DrawMoney(x, y, text, r, g, b, a, scaleX, scaleY)    
    SetTextScale(scaleX, scaleY)
    Citizen.InvokeNative(0x50a41ad966910f03, r, g, b, a)
    local str = Citizen.InvokeNative(0xFA925AC00EB830B9, 2, "CASH_STRING", text, Citizen.ResultAsLong())
    Citizen.InvokeNative(0xd79334a4bb99bad1, str, x, y)
end

-- REGISTER EVENT 

RegisterNetEvent("sendNotification")
RegisterNetEvent("playerLoaded")
RegisterNetEvent("SetCoordsPlayer")
RegisterNetEvent("addMoney")
RegisterNetEvent("setDrawUI")
RegisterNetEvent("removeMoney")
RegisterNetEvent("giveMoney")

-- THREAD CUSTOM

-- Timer toutes les 15 minutes pour sauvegarder la position
Citizen.CreateThread(function()
    Citizen.Wait(900000)
    while true do
        local coord = GetEntityCoords(GetPlayerPed())
        heading = GetEntityHeading(GetPlayerPed())

        coord = json.encode(coord)
       TriggerServerEvent("SaveCoordsPlayer", heading, coord)
    end
end)

-- Départ du script pour  inscrire ou connecté un joueur
Citizen.CreateThread(function()
    while firstSpawn == false do
        local spawned = Citizen.InvokeNative(0xB8DFD30D6973E135 --[[NetworkIsPlayerActive]], PlayerPedId(), Citizen.ResultAsInteger())
        if spawned then
            printClient("Joueur vient de se connecter !")
            enablePvP()
            TriggerServerEvent("playerActivated")
            firstSpawn = true
        end
    end
end)

-- Créer des interfaces
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(0)
        if _drawHUD then
            DrawMoney(0.95, 0.01, money, 255, 255, 255, 255, 0.342, 0.342)
            DrawMoney(0.95, 0.03, bank, 255, 255, 255, 255, 0.342, 0.342)
        end
    end
end)


AddEventHandler("onClientResourceStart", function() -- Reveal whole map on spawn and enable pvp
    if config.RevealMap == 1 then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end

end)

-- Player loaded

AddEventHandler("playerLoaded", function(_money)
    money = _money
end)


AddEventHandler("SetCoordsPlayer", function(_coords)
    local coords =_coords
    coord = json.decode(_coords)
    SetEntityCoords(GetPlayerPed(), coord.x, coord.y, coord.z + 0.3, 0, 0, 0, 1)
end)


-- Updating

AddEventHandler("addMoney", function(_money)
    money = _money
end)


AddEventHandler("addBank", function(_money)
    bank = _money
end)

-- Stop drawing

AddEventHandler("setDrawUI", function(status)
    _drawHUD = status
end)

-- Add et remove Money et argent en bank

AddEventHandler("giveMoney", function(moneyTogive)

    local moneyTogive = tonumber(moneyTogive)

        if (moneyTogive == nil) then
            printClient("^1ERROR ^7Merci d'inscrit un montant conforme (chiffre uniquement)")
            --return
        else
            if(moneyTogive < 0) then
                printClient("^1ERROR ^7 Impossible de donner un montant inférieur à 0")
            else
                TriggerServerEvent("updateMoney", moneyTogive, true)
            end
            print("nop")
        end
end)


AddEventHandler("removeMoney", function(moneyToRemove)

        local moneyToRemove = tonumber(moneyToRemove)
        if (moneyToRemove == nil) then
            printClient("^1ERROR ^7Merci d'inscrit un montant conforme (chiffre uniquement)")
            --return
        else
            if(moneyToRemove < 0) then
                printClient("^1ERROR ^7 Impossible de donner un montant inférieur à 0")
            else
                TriggerServerEvent("updateMoney", moneyToRemove, false)
            end
            print("nop")
        end
end)


-- COMMANDE PERSO

RegisterCommand('coords', function(source, args)

    --printClient(GetEntityCoords(GetPlayerPed()))
    local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed()))

    printClient("x : "..x.." y : "..y.." z : "..z)
    --z = GetGroundZ1(x, y)

end)

RegisterCommand('gotogps', function(source, args)

    local gps = GetWaypointCoords()

    SetEntityCoords(GetPlayerPed(), gps.x, gps.y, gps.z+3, 0, 0, 1, 1)
end)

RegisterCommand('piano', function(source, args)

    local coords = GetEntityCoords(GetPlayerPed())

    TaskStartScenarioAtPosition(GetPlayerPed(), GetHashKey('PROP_HUMAN_PIANO'), coords.x - 0.08, coords.y, coords.z + 0.03, 102.37, 0, true, true, 0, true) 
end)

RegisterCommand('save', function(source, args)

    local coord = GetEntityCoords(GetPlayerPed())
   
    coord = json.encode(coord)

    TriggerServerEvent("SaveCoordsPlayer", coord)

end)

RegisterCommand('addMoney', function(source, args, raw)

    if args[1] ~= nil then
        local moneyTogive = tonumber(args[1])
        if (moneyTogive == nil) then
            printClient("^1ERROR ^7Merci d'inscrit un montant conforme (chiffre uniquement)")
            --return
        else
            if(moneyTogive < 0) then
                printClient("^1ERROR ^7 Impossible de donner un montant inférieur à 0")
            else
                TriggerServerEvent("updateMoney", moneyTogive, true)
            end
            print("nop")
        end
    else
        printClient("^1ERROR ^7 Merci d'inscrit un montant d'argent (chiffre uniquement)")
    end

end)

RegisterCommand('removeMoney', function(source, args, raw)

    if args[1] ~= nil then
        local moneyTogive = tonumber(args[1])
        if (moneyTogive == nil) then
            printClient("^1ERROR ^7Merci d'inscrit un montant conforme (chiffre uniquement)")
            --return
        else
            if(moneyTogive < 0) then
                printClient("^1ERROR ^7 Impossible de donner un montant inférieur à 0")
            else
                TriggerServerEvent("updateMoney", moneyTogive, false)
            end
            print("nop")
        end
    else
        printClient("^1ERROR ^7 Merci d'inscrit un montant d'argent (chiffre uniquement)")
    end

end)

