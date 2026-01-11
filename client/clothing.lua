-- =============================================================
-- FILE: client/clothing.lua
-- DESCRIPTION: Logika manipulace s Pedem, aplikace oblečení,
-- MetaPed natives a pomocné funkce pro data oblečení.
-- =============================================================

-- Pomocná funkce: Kontrola, zda má Ped načtenou komponentu
function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped or PlayerPedId())
end

-- Pomocná funkce: Aktualizace variací Peda (Refresh)
function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped or PlayerPedId(), false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped or PlayerPedId(), true)
end

-- Aplikace shop itemu (Hash based)
function ApplyShopItemToPed(comp, ped)
    -- print("Applying component:", comp) -- Debug
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, false, false)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, true, false)
end

function UpdateShopItemWearableState(comp, wearable)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, PlayerPedId(), comp, wearable, 0, 1, 1)
end

-- Hlavní funkce pro nastavení MetaPed tagů (Drawable, Albedo, Normal, Material, Palette, Tints)
function UpdateCustomClothes(playerPed, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    while not NativeHasPedComponentLoaded(playerPed) do
        Wait(0)
    end
    
    local _drawable = drawable
    local _albedo = albedo
    local _normal = normal
    local _material = material
    local _palette = palette
    local _tint0 = tonumber(tint0) or 0
    local _tint1 = tonumber(tint1) or 0
    local _tint2 = tonumber(tint2) or 0

    SetMetaPedTag(playerPed, _drawable, _albedo, _normal, _material, _palette, _tint0, _tint1, _tint2)
    UpdatePedVariation(playerPed)
end

-- Odstranění oblečení (kategorie)
function RemoveTagFromMetaPed(cat, ped)
    local hash = GetHashKey(cat)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
    if PlayerClothes[cat] then
        PlayerClothes[cat] = nil
    end
    UpdatePedVariation(ped or PlayerPedId())
end

function HideTagFromMetaPed(cat, ped)
    local hash = GetHashKey(cat)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
    if PlayerClothes[cat] then
        PlayerClothes[cat].hidden = true
    end
    UpdatePedVariation(ped or PlayerPedId())
end

-- Získání kategorie komponenty podle indexu
function GetCategoryOfComponentAtIndex(ped, componentIndex)
    return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger())
end

-- Nalezení indexu komponenty podle názvu kategorie
function GetComponentIndexByCategory(ped, category)
    ped = ped or PlayerPedId()
    local gender = IsPedMale(ped) and "male" or "female"
    
    local numComponents = GetNumComponentsInPed(ped)
    for i = 0, numComponents - 1, 1 do
        local componentHashSigned = GetCategoryOfComponentAtIndex(ped, i)
        local lookupKey = componentHashSigned
        if lookupKey < 0 then
            lookupKey = lookupKey + 4294967296
        end
        
        -- CatList musí být definován v data/wearablestates.lua nebo podobně
        if CatList and CatList[gender] then
            local foundCategoryName = CatList[gender][lookupKey]
            if foundCategoryName == category then
                return i
            end
        end
    end

    return nil -- Nenalezeno
end

-- Získání aktuálních dat z Peda (Hashy textur atd.)
function GetMetaPedData(category, ped)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    
    if not componentIndex then
        return nil
    end
    
    local Gsuccess, drawable, albedo, normal, material = GetMetaPedAssetGuids(playerPed, componentIndex)
    local Tsuccess, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)

    return {
        drawable = drawable,
        albedo = albedo,
        normal = normal,
        material = material,
        palette = palette,
        tint0 = tint0,
        tint1 = tint1,
        tint2 = tint2
    }
end

-- Získání aktuální palety
function GetPaletteForCategory(ped, category)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then return nil end
    
    local Tsuccess, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)
    local name = nil
    
    -- Config musí být globálně přístupný
    for _, pal in pairs(Config.Palettes) do
        if GetHashKey(pal) == palette then
            name = pal
            break
        end
    end
    return name, palette
end

function GetTintForCategory(ped, category)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then return nil end
    
    local Tsuccess, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)
    return palette, tint0, tint1, tint2
end

-- Aplikace uložených dat (objektu) na Peda
function ApplyDataToPed(ped, data)
    UpdateCustomClothes(ped, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint.tint0, data.tint.tint1, data.tint.tint2)
end

-- Hlavní funkce: Aplikace konkrétního itemu z Assets listu
function ApplyItemToPed(ped, cat, index, varID)
    local gender = IsPedMale(ped) and "male" or "female"
    
    -- Assets musí být globálně přístupné z data/assets.lua
    if not Assets[gender] or not Assets[gender][cat] then 
        print("Error: Assets not found for " .. cat)
        return 
    end

    local item = Assets[gender][cat][index]
    if not varID then varID = 1 end
    
    if item.drawable then
        -- Nový systém (MetaPed s variantami)
        local variants = item.variants
        local limit = table.count(variants)
        if varID > limit then varID = limit end
        local variant = variants[varID]
        
        UpdateCustomClothes(ped, item.drawable, variant.albedo, variant.normal, variant.material, variant.palette, variant.tint[1], variant.tint[2], variant.tint[3])
        -- print("NPC Clothing Item:", cat, index, tostring(varID))
    else
        -- Starý systém (Hash položky)
        local limit = table.count(item)
        if varID > limit then varID = limit end
        local variant = item[varID]
        
        ApplyShopItemToPed(variant.hash, ped)
        -- print("MP Clothing Item:", cat, index, varID)
    end
    
    UpdatePedVariation(ped)
    
    -- Získání dat zpět pro uložení do PlayerClothes
    local data = GetMetaPedData(cat, ped)
    
    -- Pokud se nepodařilo načíst data (např. lag), vytvoříme fallback strukturu,
    -- ale ideálně data máme z GetMetaPedData
    if data then
        PlayerClothes[cat] = {
            index = index,
            drawable = data.drawable,
            albedo = data.albedo,
            normal = data.normal,
            material = data.material,
            varID = varID,
            palette = data.palette,
            tint = {
                tint0 = data.tint0,
                tint1 = data.tint1,
                tint2 = data.tint2
            }
        }
    end
end

-- Změna tintu pro kategorii
function ChangeTintForCategory(ped, category, tint0, tint1, tint2)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then return end
    
    local TagData = GetMetaPedData(category, playerPed)
    if not TagData then return end

    SetMetaPedTag(playerPed, TagData.drawable, TagData.albedo, TagData.normal, TagData.material, TagData.palette, tint0, tint1, tint2)
    
    if PlayerClothes[category] then
        PlayerClothes[category].tint = {
            tint0 = tint0,
            tint1 = tint1,
            tint2 = tint2
        }
    end
    UpdatePedVariation(playerPed)
end

-- Změna palety pro kategorii
function ChangePaletteForCategory(ped, category, paletteIndex)
    if not Config.Palettes[paletteIndex] then
        print("Invalid palette index:", paletteIndex)
        return
    end
    
    local palette = Config.Palettes[paletteIndex]
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then return end
    
    local TagData = GetMetaPedData(category, playerPed)
    if not TagData then return end

    SetMetaPedTag(playerPed, TagData.drawable, TagData.albedo, TagData.normal, TagData.material, palette, TagData.tint0, TagData.tint1, TagData.tint2)
    
    if PlayerClothes[category] then
        PlayerClothes[category].palette = palette
    end
    UpdatePedVariation(playerPed)
end

-- Nastavení viditelnosti (toggle)
function SetCategoryVisibility(ped, category, visible)
    local playerPed = ped or PlayerPedId()
    if visible then
        if PlayerClothes[category] then
            PlayerClothes[category].hidden = false
            ApplyDataToPed(playerPed, PlayerClothes[category])
        end
    else
        if PlayerClothes[category] then
            PlayerClothes[category].hidden = true
        end
        HideTagFromMetaPed(category, playerPed)
    end
end

-- Refresh (často řeší bugnuté oblečení)
function RefreshShopItems(ped)
    local playerPed = ped or PlayerPedId()
    Citizen.InvokeNative(0x59BD177A1A48600A, playerPed, 1)
    UpdatePedVariation(playerPed)
end

-- Hromadná aplikace celého outfitu (z tabulky)
-- =========================================================
-- FIX FUNKCE A LOAD ORDER
-- =========================================================

-- Funkce, která oblékne peda ve správném pořadí podle Config.LoadOrder
function DressDataToPed(ped, data)
    if not data then return end
    ped = ped or PlayerPedId()

    -- 1. Projdeme definovaný LoadOrder z Configu
    for _, category in ipairs(Config.LoadOrder) do
        local catData = data[category]
        
        -- Pokud máme data pro tuto kategorii a není skrytá
        if catData and not catData.hidden then
            ApplyDataToPed(ped, catData)
        end
    end

    -- 2. Projdeme zbytek, co NENÍ v LoadOrder (pojistka pro custom kategorie)
    for category, catData in pairs(data) do
        -- Jednoduchá kontrola, zda už jsme to aplikovali
        local isOrdered = false
        for _, orderedCat in ipairs(Config.LoadOrder) do
            if orderedCat == category then isOrdered = true break end
        end

        if not isOrdered and not catData.hidden then
            ApplyDataToPed(ped, catData)
        end
    end

    -- 3. Finální refresh variací
    UpdatePedVariation(ped)
end


-- Hromadný FIX oblečení (volat po načtení postavy nebo při chybách)
function FixClothes(ped)
    ped = ped or PlayerPedId()
    
    if not PlayerClothes or next(PlayerClothes) == nil then
        return
    end

    print("Provádím FIX oblečení...")

    -- Volitelné: Občas pomůže na chvíli "shodit" problematické vrstvy, 
    -- ale v RedM je lepší prostě znovu aplikovat tagy v pořadí.
    
    DressDataToPed(ped, PlayerClothes)
    
    -- Vynutíme update shop itemů, pokud se používají
    Citizen.InvokeNative(0x59BD177A1A48600A, ped, 1) -- _UPDATE_SHOP_ITEM_WEARABLE_STATE
    UpdatePedVariation(ped)
    
    print("FIX dokončen.")
end

-- Získání indexu itemu v Assets listu podle toho, co má hráč na sobě
function GetIndexFromMeta(category, ped)
    local playerPed = ped or PlayerPedId()
    local gender = IsPedMale(playerPed) and "male" or "female"

    -- 1. Získáme aktuální data z peda
    local currentData = GetMetaPedData(category, playerPed)
    
    if not currentData or not Assets[gender] or not Assets[gender][category] then
        return 1
    end

    -- 2. Projdeme seznam v Assets a hledáme shodu
    local assetsList = Assets[gender][category]
    
    for index, item in ipairs(assetsList) do
        if item.drawable and item.drawable == currentData.drawable then
            return index
        elseif item.hash and item.hash == currentData.drawable then
            return index
        end
        
        -- Fallback porovnání
        if item == currentData.drawable then
            return index
        end
    end

    return 1 -- Default
end

-- Filtrování oblečení pro uložení do itemu (podle Config.ItemMapping)
function FilterClothesForMapping(fullClothes, itemName)
    local allowedCategories = Config.ItemMapping[itemName]
    
    -- Pokud item není v mappingu, bere se jako "Master", co ukládá vše
    if not allowedCategories then
        return fullClothes 
    end

    local filteredData = {}
    local allowedMap = {}
    
    for _, cat in pairs(allowedCategories) do
        allowedMap[cat] = true
    end

    for category, data in pairs(fullClothes) do
        if allowedMap[category] then
            filteredData[category] = data
        end
    end

    return filteredData
end