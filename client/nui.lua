-- OPRAVA: Odstraněno 'local', aby byla proměnná globální a viditelná v client.lua
MenuOpen = false
local limits = {
    minDist = 0.6,
    maxDist = 3.5,
    minHeight = -0.7,
    maxHeight = 0.85
}
RegisterNuiCallback('closeClothingMenu', function(data, cb)
    SetNuiFocus(false, false)
    MenuOpen = false
    EndScene() -- DŮLEŽITÉ: Zničit kameru a odmrazit hráče
    cb('ok')
end)

RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    
    -- BEZPEČNOST: Kontrola jestli Assets existují
    if not Assets or not Assets[gender] then 
        cb({ items = {}, currentIndex = -1, currentVar = 1 })
        return 
    end

    local items = Assets[gender][category]
    
    local currentIndex = -1
    local currentVar = 1
    
    if PlayerClothes[category] and PlayerClothes[category].index then
        currentIndex = PlayerClothes[category].index
        currentVar = PlayerClothes[category].varID or 1
    end

    cb({
        items = items,
        currentIndex = currentIndex,
        currentVar = currentVar
    })
end)

RegisterNuiCallback("applyItem", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local index = tonumber(data.index)
    local varID = tonumber(data.varID)

    ApplyItemToPed(ped, cat, index, varID)
    cb('ok')
end)

RegisterNuiCallback("removeItem", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    RemoveTagFromMetaPed(cat, ped)
    cb('ok')
end)

RegisterNuiCallback("changeTint", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local tint0 = tonumber(data.tint0)
    local tint1 = tonumber(data.tint1)
    local tint2 = tonumber(data.tint2)
    ChangeTintForCategory(ped, cat, tint0, tint1, tint2)
    cb('ok')
end)

RegisterNuiCallback("changePalette", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local palette = tonumber(data.palette)
    ChangePaletteForCategory(ped, cat, palette)
    cb('ok')
end)

RegisterNuiCallback("refresh", function(data, cb)
    RefreshShopItems(PlayerPedId())
    cb('ok')
end)

RegisterNuiCallback("resetToNaked", function(data, cb)
    local ped = PlayerPedId()
    
    for cat, _ in pairs(PlayerClothes) do
        if cat ~= "bodies_upper" and cat ~= "bodies_lower" and cat ~= "heads" and cat ~= "eyes" and cat ~= "teeth" then
             RemoveTagFromMetaPed(cat, ped)
        end
    end

    if OriginalBody.bodies_upper then
        ApplyItemToPed(ped, "bodies_upper", OriginalBody.bodies_upper, 1)
    end
    
    if OriginalBody.bodies_lower then
        ApplyItemToPed(ped, "bodies_lower", OriginalBody.bodies_lower, 1)
    end

    UpdatePedVariation(ped)
    cb('ok')
end)

RegisterNuiCallback("saveClothes", function(data, cb)
    if data.CreatorMode then
        -- Tady naplníme dataReady, což ukončí while smyčku v client.lua (exportu)
        dataReady = PlayerClothes
    else
        TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
    end
    notify("Oblečení bylo uloženo.")

    cb('ok')
end)
-- Rotace postavy (Levé tlačítko)
RegisterNUICallback('rotateCharacter', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    
    -- data.x je rozdíl v pohybu myši. Pokud hýbeme doleva, přičítáme, doprava odečítáme.
    local newHeading = heading - (data.x * 0.5) 
    
    SetEntityHeading(ped, newHeading)
    
    -- Aktualizujeme i offset kamery, aby se kamera neotáčela s hráčem, ale zůstala "fixní" vůči světu,
    -- nebo můžeme nechat kameru tak a jen točit pedem.
    -- V tomto případě jen točíme pedem, kamera stojí.
    
    cb('ok')
end)

-- Výška kamery (Pravé tlačítko)
RegisterNUICallback('moveCameraHeight', function(data, cb)
    camHeight = camHeight - (data.y * 0.005)
    if camHeight < limits.minHeight then
        camHeight = limits.minHeight
    end
    if camHeight > limits.maxHeight then
        camHeight = limits.maxHeight
    end
    UpdateCameraPosition()
    cb('ok')
end)

-- Zoom kamery (Kolečko)
RegisterNUICallback('zoomCamera', function(data, cb)
    local step = 0.2
    
    if data.dir == "in" then
        camDistance = camDistance - step
    else
        camDistance = camDistance + step
    end
    
    if camDistance < limits.minDist then
        camDistance = limits.minDist
    end
    if camDistance > limits.maxDist then
        camDistance = limits.maxDist
    end
    
    UpdateCameraPosition()
    cb('ok')
end)