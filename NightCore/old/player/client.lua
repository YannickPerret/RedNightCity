local firstSpawn = false
local saving = false


RegisterCommand("spawn", function(source, args, rawCommand) -- Set player model
    TriggerEvent("playerSpawned")
end)

-- Function
function printClient(message)
    print("RedNightCity_Core: " .. message)
end

function enablePvP()
    if Config.pvp == 1 then
        Citizen.InvokeNative(0xF808475FA571D823, true) --enable friendly fire
        NetworkSetFriendlyFireOption(true)
        SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
    end
end

function SavePosition()
    if not saving then
        Citizen.CreateThread(function()
            while true do
                Wait(15000)
                local coords = GetEntityCoords(PlayerPedId())
                TriggerServerEvent("registerCoords", {x = coords.x, y = coords.y, z = coords.z})
            end
        end)
        saving = true
    end
end


-- Citizen Thread

Citizen.CreateThread(function()
    ShutdownLoadingScreen()
    Wait(3000)
    TriggerServerEvent('getCharacters')
end)

Citizen.CreateThread(function()
    while firstSpawn == false do
        local spawned = Citizen.InvokeNative(0xB8DFD30D6973E135 --[[NetworkIsPlayerActive]], PlayerPedId(), Citizen.ResultAsInteger())
        if spawned then
            --TriggerEvent("redem:setDrawUI", false)
            firstSpawn = true
        end
    end    
end)

Citizen.CreateThread(function()

    while true do
        Citizen.Wait(10)
        SavePosition()


    end

end)



-- Add event

AddEventHandler("respawn", function()
    enablePvP()
end)



AddEventHandler("playerSpawned", function()
    enablePvP()
    printClient("salut aventurier !")

    TriggerServerEvent("selectCharacter")
end)

AddEventHandler("onClientResourceStart", function() -- Reveal whole map on spawn and enable pvp
    if Config.RevealMap == 1 then
        Citizen.InvokeNative(0x4B8F743A4A6D2FF8, true)
    end
end)


--SetDiscordAppId("test")