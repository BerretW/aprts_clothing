-- =============================================================
-- FILE: client/nui.lua
-- DESCRIPTION: Logika NUI callbacků, detekce změn a nákup
-- =============================================================

MenuOpen = false
local limits = {
    minDist = 0.6,
    maxDist = 3.5,
    minHeight = -0.7,
    maxHeight = 0.85
}

-- =========================================================
-- POMOCNÉ FUNKCE (Ceny)
-- =========================================================

-- Získání ceny kategorie z Configu
local function GetCategoryPrice(category)
    if Config.CategoryPrices and Config.CategoryPrices[category] then
        return Config.CategoryPrices[category]
    end
    return Config.DefaultPrice or 0
end

-- Bezpečné získání tintů (řeší rozdílné formáty uložení)
local function GetSafeTints(data)
    if not data then return 0, 0, 0 end
    
    local t0 = 0
    local t1 = 0
    local t2 = 0

    -- Varianta A: vnořená tabulka (z DB/Save)
    if data.tint and type(data.tint) == "table" then
        t0 = data.tint.tint0 or data.tint[1] or 0
        t1 = data.tint.tint1 or data.tint[2] or 0
        t2 = data.tint.tint2 or data.tint[3] or 0
    -- Varianta B: přímé hodnoty (z MetaPed natives)
    else
        t0 = data.tint0 or 0
        t1 = data.tint1 or 0
        t2 = data.tint2 or 0
    end

    return tonumber(t0) or 0, tonumber(t1) or 0, tonumber(t2) or 0
end

-- =========================================================
-- CALLBACKY PRO NUI (Data a Preview)
-- =========================================================

RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    local ped = PlayerPedId()
    
    if not Assets or not Assets[gender] then 
        cb({ items = {}, currentIndex = -1, currentVar = 1 })
        return 
    end

    local items = Assets[gender][category]
    
    local currentIndex = -1
    local currentVar = 1
    local savedTints = {0, 0, 0} 
    local savedPaletteIndex = 1
    
    -- === LOGIKA PRO STAVY (WEARABLE STATES) ===
    local stateIndex = 0
    local availableStates = {}

    -- 1. Zkontrolujeme, zda tato kategorie podporuje stavy
    if WearableStates and WearableStates[gender] and WearableStates[gender][category] then
        availableStates = WearableStates[gender][category]
        
        -- Defaultně vezmeme to, co je v cache (pokud existuje)
        if PlayerClothes[category] and PlayerClothes[category].state then
            stateIndex = PlayerClothes[category].state
        end

        -- 2. POKUS O PŘEČTENÍ REÁLNÉHO STAVU Z PEDA (Overwrite)
        -- Získáme index komponenty pro danou kategorii
        local compIndex = GetComponentIndexByCategory(ped, category)
        if compIndex then
            -- Native: _GET_SHOP_ITEM_COMPONENT_AT_INDEX
            -- Získá: bool success, int componentHash, int shopItemHash, int wearableStateHash
            local retval, componentHash, shopItemHash, wearableStateHash = Citizen.InvokeNative(0x9B908423, ped, compIndex, 0, Citizen.ResultAsInteger(), Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
            print("Debug - get shop item component at index:", retval, componentHash, shopItemHash, wearableStateHash)
            if retval and wearableStateHash then
                -- Projdeme definované názvy stavů a hledáme shodu hashe
                for i, stateName in ipairs(availableStates) do
                    if GetHashKey(stateName) == wearableStateHash then
                        stateIndex = i - 1 -- Lua (od 1) -> JS (od 0)
                        
                        -- Aktualizujeme i cache, když už jsme to našli
                        if not PlayerClothes[category] then PlayerClothes[category] = {} end
                        PlayerClothes[category].state = stateIndex
                        
                        break
                    end
                end
            end
        end
    end
    -- ===========================================

    -- Načtení ostatních dat (Index, Varianta, Tints...)
    if PlayerClothes[category] then
        if PlayerClothes[category].index then
            currentIndex = PlayerClothes[category].index
            currentVar = PlayerClothes[category].varID or 1
        end

        local t0, t1, t2 = GetSafeTints(PlayerClothes[category])
        savedTints = {t0, t1, t2}

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

    -- Odeslání do UI
    cb({
        items = items,
        currentIndex = currentIndex,
        currentVar = currentVar,
        savedTints = savedTints,
        savedPalette = savedPaletteIndex,
        
        states = availableStates, 
        currentState = stateIndex
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
    
    -- Smažeme vše kromě těla
    for cat, _ in pairs(PlayerClothes) do
        if cat ~= "bodies_upper" and cat ~= "bodies_lower" and cat ~= "heads" and cat ~= "eyes" and cat ~= "teeth" then
             RemoveTagFromMetaPed(cat, ped)
        end
    end

    -- Obnovíme původní tělo
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
            
            -- 1. Co smazat (co přibylo)
            local categoriesToRemove = {}
            for category, _ in pairs(PlayerClothes) do
                if ClothesCache[category] == nil then
                    table.insert(categoriesToRemove, category)
                end
            end

            -- 2. Odstranění
            for _, category in ipairs(categoriesToRemove) do
                RemoveTagFromMetaPed(category, ped)
            end
            
            -- 3. Obnovení ze zálohy
            DressDataToPed(ped, ClothesCache)
            PlayerClothes = DeepCopy(ClothesCache)
            
            UpdatePedVariation(ped)
        end
        notify("Změny byly zrušeny.")
    end

    CurrentItemContext = nil 
    cb('ok')
end)

-- =========================================================
-- LOGIKA UKLÁDÁNÍ A NÁKUPU
-- =========================================================

RegisterNuiCallback("saveClothes", function(data, cb)
    local saveType = data.saveType 

    if saveType == 'character' then
        -- Pokud jsme v Creator módu, jen si připravíme data (ale neposíláme hned, pokud to máš jinak řešené)
        -- Ale standardně zde ukládáme:
        
        if data.CreatorMode then
             -- V creator módu často chceme rovnou uložit do DB
             TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes, PlayerOverlays)
        else
            -- V běžné hře také ukládáme vše
            TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes, PlayerOverlays)
        end
        
        -- Aktualizace cache
        ClothesCache = DeepCopy(PlayerClothes)
        notify("Vzhled postavy byl uložen.")
    end

    SetNuiFocus(false, false)
    MenuOpen = false
    EndScene()
    CurrentItemContext = nil

    cb('ok')
end)

-- HLAVNÍ CALLBACK PRO NÁKUP / VYTVOŘENÍ ITEMŮ
RegisterNUICallback("purchaseItems", function(data, cb)
    local outfitName = data.name or "Outfit"
    -- Získáme seznam kategorií, které JS označil jako "touched" (změněné)
    local changedCategoriesList = data.changedCategories or {}
    
    print("--------------------------------------------------")
    print("[DEBUG] Zahajuji nákup: " .. outfitName)
    
    if #changedCategoriesList == 0 then
        notify("Nebyla provedena žádná změna.")
        -- I když není změna, pošleme OK, aby JS mohl případně zavřít okno (pokud to tak chceš),
        -- ale podle logiky v JS by se tento request ani neměl poslat, pokud je list prázdný.
        cb('ok')
        return
    end

    -- Převedeme seznam na mapu pro rychlejší vyhledávání
    local changedCategories = {}
    for _, cat in ipairs(changedCategoriesList) do
        changedCategories[cat] = true
        print("[DEBUG] Detekována změna (JS): " .. cat)
    end

    -- 2. MAPOVÁNÍ DO ITEMŮ
    local basket = {}
    local totalPrice = 0
    local mappedCategories = {} -- Evidence, co už máme zpracované

    -- Projdeme definované itemy v Configu (např. clothing_hat, clothing_torso...)
    for itemType, mappedCats in pairs(Config.ItemMapping) do
        local itemHasChanges = false
        local itemData = {}
        local itemPrice = 0

        -- Podíváme se na všechny kategorie, které patří do tohoto Itemu
        for _, cat in ipairs(mappedCats) do
            
            -- Pokud je tato kategorie v seznamu změn
            if changedCategories[cat] then
                itemHasChanges = true
                mappedCategories[cat] = true
            end
            
            -- Ukládáme AKTUÁLNÍ data hráče (pokud věc má na sobě)
            -- Důležité: Ukládáme VŠECHNY kategorie z mappingu, nejen ty změněné, 
            -- aby byl item kompletní (např. klobouk + doplňky), pokud to tak má být.
            -- Ale platíme jen za změnu.
            
            if PlayerClothes[cat] and not PlayerClothes[cat].hidden then
                itemData[cat] = PlayerClothes[cat]
                
                -- Cenu přičteme, pouze pokud se kategorie změnila (neplatíme za staré věci v novém itemu)
                if changedCategories[cat] then
                     itemPrice = itemPrice + GetCategoryPrice(cat)
                end
            end
        end

        -- Pokud item obsahuje alespoň jednu změnu a není prázdný
        if itemHasChanges and table.count(itemData) > 0 then
            basket[itemType] = {
                itemType = itemType,
                name = outfitName,
                data = itemData,
                price = itemPrice
            }
            totalPrice = totalPrice + itemPrice
            print("[DEBUG] Přidán item: " .. itemType .. " | Cena: " .. itemPrice)
        end
    end

    -- 3. FALLBACK PRO NEZAŘAZENÉ (Co není v Config.ItemMapping)
    local leftovers = {}
    local leftoversPrice = 0
    
    for cat, _ in pairs(changedCategories) do
        if not mappedCategories[cat] and PlayerClothes[cat] and not PlayerClothes[cat].hidden then
            leftovers[cat] = PlayerClothes[cat]
            leftoversPrice = leftoversPrice + GetCategoryPrice(cat)
            print("[DEBUG-WARN] Kategorie '"..cat.."' nemá v Configu ItemMapping! Ukládám do clothing_all.")
        end
    end

    if table.count(leftovers) > 0 then
        basket["clothing_all"] = {
            itemType = "clothing_all",
            name = outfitName .. " (Mix)",
            data = leftovers,
            price = leftoversPrice
        }
        totalPrice = totalPrice + leftoversPrice
    end

    -- 4. ODESLÁNÍ NA SERVER
    if table.count(basket) > 0 then
        TriggerServerEvent("aprts_clothing:Server:processPurchase", basket, totalPrice)
        
        -- Reset Menu a Cache - důležité pro ukončení
        SetNuiFocus(false, false)
        MenuOpen = false
        EndScene()
        CurrentItemContext = nil
        ClothesCache = DeepCopy(PlayerClothes) -- Potvrdíme změny jako nové default
    else
        notify("Košík je prázdný (věci byly sundány nebo nejsou v mappingu).")
        -- I v tomto případě zavřeme menu, pokud uživatel klikl na koupit
        SetNuiFocus(false, false)
        MenuOpen = false
        EndScene()
    end

    -- Pošleme callback zpět do JS, aby věděl, že má skrýt UI
    cb('ok')
end)

-- =========================================================
-- OVLÁDÁNÍ KAMERY
-- =========================================================

RegisterNUICallback('rotateCharacter', function(data, cb)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    SetEntityHeading(ped, heading - (data.x * 0.5))
    cb('ok')
end)

RegisterNUICallback('moveCameraHeight', function(data, cb)
    camHeight = camHeight - (data.y * 0.005)
    if camHeight < limits.minHeight then camHeight = limits.minHeight end
    if camHeight > limits.maxHeight then camHeight = limits.maxHeight end
    UpdateCameraPosition()
    cb('ok')
end)

RegisterNUICallback('zoomCamera', function(data, cb)
    local step = 0.2
    if data.dir == "in" then
        camDistance = camDistance - step
    else
        camDistance = camDistance + step
    end
    
    if camDistance < limits.minDist then camDistance = limits.minDist end
    if camDistance > limits.maxDist then camDistance = limits.maxDist end
    
    UpdateCameraPosition()
    cb('ok')
end)


RegisterNuiCallback("updateWearableState", function(data, cb)
    local ped = PlayerPedId()
    local category = data.category
    local stateIndex = data.stateIndex -- Index v poli WearableStates (0-based z JS, takže +1 pro Lua)
    
    local gender = IsPedMale(ped) and "male" or "female"
    
    -- Ověření, zda máme definice
    if not WearableStates[gender] or not WearableStates[gender][category] then
        return cb('error')
    end

    local stateName = WearableStates[gender][category][stateIndex + 1] -- +1 protože Lua indexuje od 1
    if not stateName then return cb('error') end

    local stateHash = GetHashKey(stateName)

    -- 1. Musíme zjistit hash aktuální komponenty na těle
    -- Použijeme tvou pomocnou funkci nebo native
    local componentIndex = GetComponentIndexByCategory(ped, category)
    if componentIndex then
        -- Získáme hash komponenty (to, co má hráč na sobě)
        local componentHash = Citizen.InvokeNative(0x884968C0, ped, componentIndex) -- _GET_COMPONENT_HASH_AT_INDEX (přibližný native, nebo použij GetShopItemComponentAtIndex)
        
        -- Lepší metoda pro získání hashe pro WearableState:
        local numComponents = GetNumComponentsInPed(ped)
        local foundHash = nil
        
        -- Najdeme hash itemu pro danou kategorii (trochu složitější, ale nutné)
        -- Zjednodušení: Pokud používáme MetaPedTags, wearable state se aplikuje na peda globálně nebo na konkrétní hash.
        -- Zkusíme aplikovat state přímo:
        
        -- Toto je native z tvého commandu /setstate
        -- UpdateShopItemWearableState(ped, componentHash, stateHash)
        -- Ale musíme mít SPRÁVNÝ componentHash.
        
        -- Pokusíme se ho vytáhnout přes shop native, pokud existuje:
        local valid, hash, unk, type = Citizen.InvokeNative(0x9B908423, ped, componentIndex, 0, Citizen.ResultAsInteger(), Citizen.ResultAsInteger(), Citizen.ResultAsInteger()) 
        -- 0x9B908423 = _GET_SHOP_ITEM_COMPONENT_AT_INDEX (přibližně)
        -- V tvém commandu jsi použil GetShopItemComponentAtIndex, což je wrapper.
        
        local compHash, _, _ = GetShopItemComponentAtIndex(ped, componentIndex, true, Citizen.ResultAsInteger(), Citizen.ResultAsInteger())
        
        if compHash and compHash ~= 0 then
            UpdateShopItemWearableState(compHash, stateHash) -- Tvoje funkce z clothing.lua
            
            -- Uložíme si stav do PlayerClothes
            if not PlayerClothes[category] then PlayerClothes[category] = {} end
            PlayerClothes[category].state = stateIndex
            
            -- Refresh
            UpdatePedVariation(ped)
            cb('ok')
        else
            print("Nenalezen hash komponenty pro state update.")
            cb('error')
        end
    else
        cb('error')
    end
end)


-- Přidat do client/nui.lua

RegisterNUICallback('getOverlayMenu', function(data, cb)
    local menuData = GetOverlayMenuData()
    cb(menuData)
end)

RegisterNUICallback('applyOverlayChange', function(data, cb)
    local ped = PlayerPedId()
    
    -- Přemapování dat z JS
    local layer = data.layer
    local index = tonumber(data.index) -- Index textury
    local palette = data.palette -- String název
    local t0 = tonumber(data.tint0)
    local t1 = tonumber(data.tint1)
    local t2 = tonumber(data.tint2)

    ApplyOverlayToPed(ped, layer, index, palette, t0, t1, t2)
    cb('ok')
end)

-- Uprav existující saveClothes callback, aby ukládal i Overlaye
-- (Musíš sloučit PlayerClothes a PlayerOverlays do jednoho objektu pro DB,
--  nebo mít v DB dva sloupce. Doporučuji sloučit.)