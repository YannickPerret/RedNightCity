-- VARIABLE
local firstSpawn = false

-- FUNCTION CUSTOM 
function printClient(message)
    print(client_prefix .. message)
end


-- THREAD CUSTOM

Citizen.CreateThread(function()
    while firstSpawn == false do
        local spawned = Citizen.InvokeNative(0xB8DFD30D6973E135 --[[NetworkIsPlayerActive]], PlayerPedId(), Citizen.ResultAsInteger())
        if spawned then
            printClient("Joueur vient de se connecter !")
            TriggerServerEvent("playerActivated")
            firstSpawn = true
        end
    end
end)