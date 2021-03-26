function enablePvP()
    if config.pvp == 1 then
        Citizen.InvokeNative(0xF808475FA571D823, true) --enable friendly fire
        NetworkSetFriendlyFireOption(true)
        SetRelationshipBetweenGroups(5, `PLAYER`, `PLAYER`)
    end
end


--- NOTIFICATION
local show = true
local active = false
local liczba = 1
local ProgressColor = {100, 1, 1}
local global_text
local global_timer
local global_type
------------EXAMPLE------------------------
--	  local timer = 5 
--	  local type = "success" 
--    local text = "Simple test redemrp_notification"
--    TriggerEvent("redemrp_notification:start", text, timer, type)
--------------OR-------------------------

--    TriggerEvent("redemrp_notification:start", "Simple test redemrp_notification" , 5)

-------------TEST COMMAND-------------
--[[
RegisterCommand('test_notification', function(source, args)
 local text = ''
    for i = 1,#args do
        text = text .. ' ' .. args[i]
    end
   TriggerEvent("redemrp_notification:start", text , 5, "success")
end)
]]

function GetGroundZ (x, y)
    for height = 1, 300 do

        local foundGround, zPos = GetGroundZFor_3dCoord(x, y, height)

        if foundGround then

            return zPos
        end
        height = height + 1
    end
end

function GetGroundZ1(x, y)

    -- ensure entity teleports above the ground
    local ground
    local groundFound = false
    local z
    local groundCheckHeights = {100.0, 150.0, 50.0, 0.0, 200.0, 250.0, 300.0, 350.0, 400.0,450.0, 500.0, 550.0, 600.0, 650.0, 700.0, 750.0, 800.0}

    for i,height in ipairs(groundCheckHeights) do
        Wait(10)
        ground,z = GetGroundZFor_3dCoord(x,y,height)
        if(ground) then
            groundFound = true
            return z + 3
        end
    end

    if(not groundFound)then
        return 1000
        --GiveDelayedWeaponToPed(PlayerPedId(), 0xFBAB5776, 1, 0) -- parachute
    end
end

function startUI(time, text) 
	SendNUIMessage({
		type = "ui",
		display = true,
		time = time,
		text = text
	})
end

function closeUI(...) 
	SendNUIMessage({
		type = "ui",
		display = false
	})
end





function hideUI()
    SendNUIMessage({
        type = "ui",
        display = false

    })
    show = false
    active = false
end

function ShowUI(text)
    local _text = text
    local _liczba = liczba*1.1
    if _liczba < 80 then
        _liczba = 80
    end
    SendNUIMessage({
        type = "ui",
        display = true,
        text = _text,
        liczba = _liczba
    })
    show = true
end

