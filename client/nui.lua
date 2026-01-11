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
-- POMOCNÉ FUNKCE (Ceny a Detekce)
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

-- Bezpečné porovnání hodnoty (ignoruje rozdíl nil/0 a string/number)
local function IsValDiff(val1, val2)
    local v1 = tonumber(val1) or 0
    local v2 = tonumber(val2) or 0
    return v1 ~= v2
end

-- Hlavní funkce pro detekci změny v kategorii
local function HasCategoryChanged(cat)
    local now = PlayerClothes[cat]
    local old = ClothesCache[cat]

    -- 1. Kontrola existence (Svlečení / Oblečení)
    if not now and not old then return false end -- Oba prázdné = beze změny
    if (now and not old) or (not now and old) then 
        return true 
    end

    -- 2. Kontrola skrytí (Toggle)
    local hiddenNow = now.hidden == true
    local hiddenOld = old.hidden == true
    if hiddenNow ~= hiddenOld then return true end

    -- 3. Porovnání hlavních MetaPed tagů
    if IsValDiff(now.drawable, old.drawable) then return true end
    if IsValDiff(now.albedo, old.albedo) then return true end
    if IsValDiff(now.normal, old.normal) then return true end
    if IsValDiff(now.material, old.material) then return true end
    if IsValDiff(now.palette, old.palette) then return true end

    -- 4. Porovnání Tintů
    local nT0, nT1, nT2 = GetSafeTints(now)
    local oT0, oT1, oT2 = GetSafeTints(old)

    if nT0 ~= oT0 or nT1 ~= oT1 or nT2 ~= oT2 then
        return true
    end

    -- 5. Fallback: Porovnání indexu/varianty (pokud se nezměnily hashe, ale ID v menu ano)
    if IsValDiff(now.index, old.index) then return true end
    if IsValDiff(now.varID, old.varID) then return true end

    return false
end

-- =========================================================
-- CALLBACKY PRO NUI (Data a Preview)
-- =========================================================

RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    
    if not Assets or not Assets[gender] then 
        cb({ items = {}, currentIndex = -1, currentVar = 1 })
        return 
    end

    local items = Assets[gender][category]
    
    local currentIndex = -1
    local currentVar = 1
    local savedTints = {0, 0, 0} 
    local savedPaletteIndex = 1

    if PlayerClothes[category] then
        -- 1. Načtení indexu a varianty
        if PlayerClothes[category].index then
            currentIndex = PlayerClothes[category].index
            currentVar = PlayerClothes[category].varID or 1
        end

        -- 2. Načtení Tintů
        local t0, t1, t2 = GetSafeTints(PlayerClothes[category])
        savedTints = {t0, t1, t2}

        -- 3. Načtení Palety (Hash -> Index)
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

    cb({
        items = items,
        currentIndex = currentIndex,
        currentVar = currentVar,
        savedTints = savedTints,
        savedPalette = savedPaletteIndex
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
    -- Toto volá jen Creator mód nebo Admin uložení postavy
    local saveType = data.saveType 

    if saveType == 'character' then
        if data.CreatorMode then
            dataReady = PlayerClothes
        else
            TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
        end
        
        ClothesCache = DeepCopy(PlayerClothes)
        notify("Postava byla uložena.")
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
    print("--------------------------------------------------")
    print("[DEBUG] Zahajuji nákup: " .. outfitName)
    
    -- 1. DETEKCE ZMĚN
    local changedCategories = {}
    
    -- Změněné v PlayerClothes
    for cat, _ in pairs(PlayerClothes) do
        if HasCategoryChanged(cat) then
            changedCategories[cat] = true
        end
    end
    -- Změněné v Cache (co jsme sundali)
    for cat, _ in pairs(ClothesCache) do
        if HasCategoryChanged(cat) then
            changedCategories[cat] = true
        end
    end

    if table.count(changedCategories) == 0 then
        notify("Nebyla provedena žádná změna.")
        cb('ok')
        return
    end

    -- Výpis změn
    for cat, _ in pairs(changedCategories) do
        print("[DEBUG] Změna v kategorii: " .. cat)
    end

    -- 2. MAPOVÁNÍ DO ITEMŮ
    local basket = {}
    local totalPrice = 0
    local mappedCategories = {} -- Evidence, co už máme zpracované

    -- Projdeme definované itemy v Configu
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
            if PlayerClothes[cat] and not PlayerClothes[cat].hidden then
                itemData[cat] = PlayerClothes[cat]
                
                -- Cenu přičteme, pokud se kategorie změnila (neplatíme za staré věci v novém itemu)
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

    -- 3. FALLBACK PRO NEZAŘAZENÉ (ZÁCHRANA)
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
        
        -- Reset Menu a Cache
        SetNuiFocus(false, false)
        MenuOpen = false
        EndScene()
        CurrentItemContext = nil
        ClothesCache = DeepCopy(PlayerClothes) -- Potvrdíme změny jako nové default
    else
        notify("Košík je prázdný (asi jsi věci jen sundal).")
    end

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