keys = {
    ['G'] = 0x760A9C6F,
    ['S'] = 0xD27782E3,
    ['W'] = 0x8FD015D8,
	['H'] = 0x24978A28,
	['G'] = 0x5415BE48,
	['E'] = 0xDFF812F9
}

local noclip = false
local noclip_speed = 5.0

RegisterCommand("noclip", function(source, args, rawCommand)
    admin_no_clip()

end, false)


function admin_no_clip()
    noclip = not noclip
      local playerPed = PlayerPedId()
      if noclip then -- active
        SetEntityInvincible(playerPed, true)
        SetEntityVisible(playerPed, false, false)
        
      else -- desactive
        SetEntityInvincible(playerPed, false)
        SetEntityVisible(playerPed, true, false)
        
      end
    end


    function getPosition()
        local x,y,z = table.unpack(GetEntityCoords(PlayerPedId(),true))
        return x,y,z
      end
      
      function getCamDirection()
        local heading = GetGameplayCamRelativeHeading()+GetEntityHeading(PlayerPedId())
        local pitch = GetGameplayCamRelativePitch()
      
        local x = -math.sin(heading*math.pi/180.0)
        local y = math.cos(heading*math.pi/180.0)
        local z = math.sin(pitch*math.pi/180.0)
      
        local len = math.sqrt(x*x+y*y+z*z)
        if len ~= 0 then
          x = x/len
          y = y/len
          z = z/len
        end
      
        return x,y,z
      end
      
    
Citizen.CreateThread(function()
    while true do
      Wait(0)
      if noclip then
        local playerPed = PlayerPedId()
        local x,y,z = getPosition()
        local dx,dy,dz = getCamDirection()
        local speed = noclip_speed
  
        -- reset du velocity
        SetEntityVelocity(playerPed, 0.0001, 0.0001, 0.0001)
  
        -- aller vers le haut
        if IsControlPressed(0, keys['W']) then -- MOVE UP
          x = x+speed*dx
          y = y+speed*dy
          z = z+speed*dz
        end
  
        -- aller vers le bas
        if IsControlPressed(0, keys['S']) then -- MOVE DOWN
          x = x-speed*dx
          y = y-speed*dy
          z = z-speed*dz
        end
        SetEntityCoordsNoOffset(playerPed,x,y,z,true,true,true)
      end
    end
  end)
  
  RegisterNetEvent('noclip:activate')
  AddEventHandler('noclip:activate', function()
      admin_no_clip()
  end)