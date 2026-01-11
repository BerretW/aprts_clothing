-- OPRAVA: Odstraněno 'local', aby byla proměnná globální a viditelná v client.lua
MenuOpen = false
local limits = {
    minDist = 0.6,
    maxDist = 3.5,
    minHeight = -0.7,
    maxHeight = 0.85
}


RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    local ped = PlayerPedId()
    
    -- Ochrana proti chybějícím datům
    if not Assets or not Assets[gender] then 
        cb({ items = {}, currentIndex = -1, currentVar = 1, maxStates = 0, currentState = 1, maxClothingStates = 0, currentClothingState = 1 })
        return 
    end

    local items = Assets[gender][category]
    
    local currentIndex = -1
    local currentVar = 1
    local savedTints = {0, 0, 0} 
    local savedPaletteIndex = 1

    -- === 1. NAČTENÍ ULOŽENÝCH DAT OBLEČENÍ ===
    if PlayerClothes[category] then
        if PlayerClothes[category].index then
            currentIndex = PlayerClothes[category].index
            currentVar = PlayerClothes[category].varID or 1
        end

        if PlayerClothes[category].tint then
            savedTints = {
                PlayerClothes[category].tint.tint0 or 0,
                PlayerClothes[category].tint.tint1 or 0,
                PlayerClothes[category].tint.tint2 or 0
            }
        end

        if PlayerClothes[category].palette then
            local currentHash = PlayerClothes[category].palette
            for i, palName in ipairs(Config.Palettes) do
                if GetHashKey(palName) == currentHash or palName == currentHash then
                    savedPaletteIndex = i
                    break
                end
            end
        end
    end

    -- === 2. DATA PRO BODY STATES (LEVÝ PANEL) ===
    -- Statické stavy definované v wearablestates.lua (pro tělo/kůži)
    local maxStates = 0
    local currentState = 1
    if WearableStates and WearableStates[gender] and WearableStates[gender][category] then
        maxStates = #WearableStates[gender][category]
        if PlayerClothes[category] and PlayerClothes[category].state then
            currentState = PlayerClothes[category].state
        end
    end

    -- === 3. DATA PRO CLOTHING STATES (PRAVÝ PANEL) ===
    -- Dynamické stavy zjištěné z itemu přes Native (pro konkrétní oblečení)
    local maxClothingStates = 0
    local currentClothingState = 1
    
    -- Funkce GetWearableCountForCategory musí být definovaná v functions.lua (viz předchozí kroky)
    local count, _ = GetWearableCountForCategory(ped, category)
    if count > 0 then
        maxClothingStates = count
        if PlayerClothes[category] and PlayerClothes[category].state then
            currentClothingState = PlayerClothes[category].state
        end
    end

    cb({
        items = items,
        currentIndex = currentIndex,
        currentVar = currentVar,
        savedTints = savedTints,
        savedPalette = savedPaletteIndex,
        
        -- Levý panel (Body)
        maxStates = maxStates,
        currentState = currentState,

        -- Pravý panel (Clothing)
        maxClothingStates = maxClothingStates,
        currentClothingState = currentClothingState
    })
end)

RegisterNuiCallback("applyItem", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local index = tonumber(data.index)
    local varID = tonumber(data.varID)

    ApplyItemToPed(ped, cat, index, varID)
    
    -- Po aplikaci itemu zjistíme, kolik má variant nošení
    local count, _ = GetWearableCountForCategory(ped, cat)
    
    -- Vrátíme objekt s počtem stavů
    cb({ status = 'ok', maxClothingStates = count })
end)

RegisterNuiCallback("applyClothingState", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local stateIndex = tonumber(data.stateIndex)

    ApplyClothingWearableState(ped, cat, stateIndex)
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

RegisterNuiCallback('closeClothingMenu', function(data, cb)
    SetNuiFocus(false, false)
    MenuOpen = false
    EndScene()
    
    -- Pokud jsme neuložili (data.saved ~= true), vrátíme původní oblečení
    if not data.saved then
        if ClothesCache then
            local ped = PlayerPedId()
            
            -- 1. SEZNAM K ODSTRANĚNÍ
            -- Nejdřív zjistíme, co máme na sobě navíc oproti Cache
            -- Nemůžeme to mazat rovnou v cyklu, protože by to rozbilo iteraci
            local categoriesToRemove = {}

            for category, _ in pairs(PlayerClothes) do
                -- Pokud kategorie v Cache vůbec není (je nil), znamená to, že jsme ji přidali v editoru
                if ClothesCache[category] == nil then
                    table.insert(categoriesToRemove, category)
                end
            end

            -- 2. ODSTRANĚNÍ
            -- Teď bezpečně smažeme vše, co jsme našli
            for _, category in ipairs(categoriesToRemove) do
                -- Toto zavolá nativku na odstranění a nastaví PlayerClothes[category] = nil
                RemoveTagFromMetaPed(category, ped)
            end
            
            -- 3. OBNOVENÍ PŮVODNÍCH VĚCÍ
            -- Aplikujeme zpět to, co bylo v Cache (přepíše změněné, oblékne svlečené)
            DressDataToPed(ped, ClothesCache)
            
            -- 4. VRÁCENÍ PROMĚNNÉ ZPĚT
            -- Obnovíme globální proměnnou ze zálohy
            PlayerClothes = DeepCopy(ClothesCache)
            
            -- Finální aktualizace vzhledu
            UpdatePedVariation(ped)
        end
        notify("Změny byly zrušeny.")
    end

    CurrentItemContext = nil 
    
    cb('ok')
end)

-- 2. Callback pro ULOŽENÍ (Item nebo Postava)
RegisterNuiCallback("saveClothes", function(data, cb)
    local saveType = data.saveType -- 'item' nebo 'character'

    if saveType == 'item' and CurrentItemContext then
        -- A) Uložení do ITEMU
        local itemName = CurrentItemContext.itemName
        local itemId = CurrentItemContext.itemId

        -- Vyfiltrujeme jen kategorie povolené pro tento item (z Configu)
        local filteredData = FilterClothesForMapping(PlayerClothes, itemName)
        
        TriggerServerEvent("aprts_clothing:Server:saveClothesToItem", itemId, itemName, filteredData)
        notify("Oblečení uloženo do itemu: " .. itemName)

    elseif saveType == 'character' then
        -- B) Uložení na POSTAVU (Databáze)
        if data.CreatorMode then
            dataReady = PlayerClothes
        else
            TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
        end
        
        -- Aktualizujeme Cache, protože toto je nyní náš "nový standard"
        ClothesCache = PlayerClothes
        notify("Postava byla uložena.")
    end

    -- Zavřeme menu s příznakem, že JSME uložili (aby se nevrátily staré hadry)
    SetNuiFocus(false, false)
    MenuOpen = false
    EndScene()
    CurrentItemContext = nil -- Vyčistit kontext

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

RegisterNUICallback("applyWearableState", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local stateIndex = tonumber(data.stateIndex)

    -- Volá funkci definovanou v client/functions.lua (viz předchozí krok)
    ApplyWearableState(ped, cat, stateIndex)
    cb('ok')
end)