function ShowBusyspinnerWithText(text)
    N_0x7f78cd75cc4539e4(VarString(10, "LITERAL_STRING", text))
end

function ApplyShopItemToPed(comp, ped)
    print("Applying component:", comp)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, false, false)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped or PlayerPedId(), comp, false, true, false)
end

function UpdateShopItemWearableState(comp, wearable)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, PlayerPedId(), comp, wearable, 0, 1, 1)
end

function IsMetaPedUsingComponent(comp)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, PlayerPedId(), comp)
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped or PlayerPedId(), false, true, true, true, false)
    Citizen.InvokeNative(0xAAB86462966168CE, ped or PlayerPedId(), true)
end
function GetCategoryOfComponentAtIndex(ped, componentIndex)
    return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger())
end

function reapplySkinTexture(gender)
    local skinIndex = SkinColorTracker or 1
    if not Config.DefaultChar[gender][skinIndex] then
        return
    end

    local SkinColorData = Config.DefaultChar[gender][skinIndex]

    -- Hash textury pro konkrétní rasu
    local albedoHash = joaat(SkinColorData.HeadTexture[1])

    -- Hash materiálu a normal mapy (obecné pro pohlaví)
    local normalHash = Config.texture_types[gender].normal
    local materialHash = Config.texture_types[gender].material

    IsPedReadyToRender()
    Citizen.InvokeNative(0xC5E7204F322E49EB, PlayerPedId(), albedoHash, normalHash, materialHash)
end


function RemoveTagFromMetaPed(cat, ped)
    local hash = GetHashKey(cat)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
    PlayerClothes[cat] = nil
    UpdatePedVariation(ped or PlayerPedId())
    -- TriggerServerEvent("aprts_clothing:Server:saveCategory", cat, nil)
end

function HideTagFromMetaPed(cat, ped)
    local hash = GetHashKey(cat)
    Citizen.InvokeNative(0xD710A5007C2AC539, ped or PlayerPedId(), hash, 0)
    PlayerClothes[cat].hidden = true
    UpdatePedVariation(ped or PlayerPedId())
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped or PlayerPedId())
end

function UpdateCustomClothes(playerPed, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    while not NativeHasPedComponentLoaded(playerPed) do
        Wait(0)
    end
    local playerPed = playerPed
    local _drawable = drawable
    local _albedo = albedo
    local _normal = normal
    local _material = material
    local _palette = palette
    local _tint0 = tonumber(tint0)
    local _tint1 = tonumber(tint1)
    local _tint2 = tonumber(tint2)

    SetMetaPedTag(playerPed, _drawable, _albedo, _normal, _material, _palette, _tint0, _tint1, _tint2)
    UpdatePedVariation(playerPed)
end

function GetComponentIndexByCategory(ped, category)
    ped = ped or PlayerPedId()
    local gender = "male"
    if not IsPedMale(ped) then
        gender = "female"
    end
    local numComponents = GetNumComponentsInPed(ped)
    for i = 0, numComponents - 1, 1 do
        local componentHashSigned = GetCategoryOfComponentAtIndex(ped, i)
        local lookupKey = componentHashSigned
        if lookupKey < 0 then
            lookupKey = lookupKey + 4294967296
        end
        local foundCategoryName = CatList[gender][lookupKey]
        if foundCategoryName == category then
            print("Nalezen index pro kategorii", category .. ":", i)
            return i
        end
    end

    return nil -- Nenalezeno
end

function GetMetaPedData(category, ped)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    print("Component index for category", category, "is:", componentIndex)
    if not componentIndex then
        return nil
    end
    print("Getting MetaPed data for category:", category, "at index:", componentIndex)
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

function GetPaletteForCategory(ped, category)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then
        return nil
    end
    local Tsuccess, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)
    local name = nil
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
    if not componentIndex then
        return nil
    end
    local Tsuccess, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(playerPed, componentIndex)
    return palette, tint0, tint1, tint2
end

function ApplyDataToPed(ped, data)
    UpdateCustomClothes(ped, data.drawable, data.albedo, data.normal, data.material, data.palette, data.tint.tint0,
        data.tint.tint1, data.tint.tint2)
end

function ApplyItemToPed(ped, cat, index, varID)
    local gender = "male"
    if not IsPedMale(ped) then
        gender = "female"
    end
    local item = Assets[gender][cat][index]
    if not varID then
        varID = 1
    end
    if item.drawable then
        local variants = item.variants
        local limit = table.count(variants)
        if varID > limit then
            varID = limit
        end
        local variant = variants[varID]
        UpdateCustomClothes(ped, item.drawable, variant.albedo, variant.normal, variant.material, variant.palette,
            variant.tint[1], variant.tint[2], variant.tint[3])

        print("NPC Clothing Item:", cat, index, tostring(varID))

    else
        local limit = table.count(item)
        if varID > limit then
            varID = limit
        end
        local variant = item[varID]
        ApplyShopItemToPed(variant.hash)
        local palette, t0, t1, t2 = GetTintForCategory(ped, cat)
        print("MP Clothing Item:", cat, index, varID)
    end
    UpdatePedVariation()
    local data = GetMetaPedData(cat, ped)
    print(cat, GetHashKey(cat), json.encode(data, {
        indent = true
    }))
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
    -- TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
    -- TriggerServerEvent("aprts_clothing:Server:saveCategory",cat, PlayerClothes[cat])
end

function ChangeTintForCategory(ped, category, tint0, tint1, tint2)
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then
        return
    end
    local TagData = GetMetaPedData(category, playerPed)
    SetMetaPedTag(playerPed, TagData.drawable, TagData.albedo, TagData.normal, TagData.material, TagData.palette, tint0,
        tint1, tint2)
    PlayerClothes[category].tint = {
        tint0 = tint0,
        tint1 = tint1,
        tint2 = tint2
    }
    UpdatePedVariation(playerPed)
    -- TriggerServerEvent("aprts_clothing:Server:saveCategory", category, PlayerClothes[category])
end

function ChangePaletteForCategory(ped, category, paletteIndex)
    if not Config.Palettes[paletteIndex] then
        print("Invalid palette index:", paletteIndex)
        return
    end
    local palette = Config.Palettes[paletteIndex]
    local playerPed = ped or PlayerPedId()
    local componentIndex = GetComponentIndexByCategory(playerPed, category)
    if not componentIndex then
        return
    end
    local TagData = GetMetaPedData(category, playerPed)
    SetMetaPedTag(playerPed, TagData.drawable, TagData.albedo, TagData.normal, TagData.material, palette, TagData.tint0,
        TagData.tint1, TagData.tint2)
    PlayerClothes[category].palette = palette
    UpdatePedVariation(playerPed)
    -- TriggerServerEvent("aprts_clothing:Server:saveCategory", category, PlayerClothes[category])
end

function SetCategoryVisibility(ped, category, visible)
    local playerPed = ped or PlayerPedId()
    if visible then
        PlayerClothes[category].hidden = false
        local data = PlayerClothes[category]
        ApplyDataToPed(playerPed, data)
    else
        PlayerClothes[category].hidden = true
        HideTagFromMetaPed(category, playerPed)
    end
end

function RefreshShopItems(ped)
    local playerPed = ped or PlayerPedId()
    Citizen.InvokeNative(0x59BD177A1A48600A, playerPed, 1)
    -- UpdatePedVariation(playerPed)
end

function DressDataToPed(ped, data)
    for cat, catData in pairs(data) do
        ApplyDataToPed(ped, catData)
    end
end

function GetCategoriesNamesForMenu()
    local gender = "male"
    if not IsPedMale(PlayerPedId()) then
        gender = "female"
    end
    
    local list = {}
    if Assets[gender] then
        for cat, data in pairs(Assets[gender]) do
            -- Zkontrolujeme, zda kategorie obsahuje data a není prázdná
            if data and type(data) == "table" and #data > 0 then
                table.insert(list, cat)
            end
        end
    end
    
    -- Seřadíme abecedně
    table.sort(list)
    
    return list
end

-- Funkce pro získání strukturovaného menu podle Configu
function GetStructuredMenu(menuDefinition)
    local ped = PlayerPedId()
    local gender = "male"
    if not IsPedMale(ped) then
        gender = "female"
    end
    
    local structuredList = {}
    
    -- Pokud nemáme definici, vrátíme prázdné
    if not menuDefinition then return {} end

    -- Projdeme definici menu (Sekce -> Seznam kategorií)
    for sectionName, categories in pairs(menuDefinition) do
        local validCategories = {}
        
        for _, cat in ipairs(categories) do
            -- Zkontrolujeme, zda kategorie existuje v Assets pro dané pohlaví a zda má položky
            if Assets[gender] and Assets[gender][cat] and #Assets[gender][cat] > 0 then
                -- ZDE JE ZMĚNA: Hledáme překlad v TranslateCat, pokud není, použijeme surový název
                local labelName = TranslateCat[cat] or cat 
                
                -- Vkládáme objekt místo pouhého stringu
                table.insert(validCategories, {
                    id = cat,
                    label = labelName
                })
            end
        end
        
        -- Pokud má sekce alespoň jednu platnou kategorii, přidáme ji do seznamu
        if #validCategories > 0 then
            table.insert(structuredList, {
                header = sectionName,
                items = validCategories
            })
        end
    end

    -- Seřadíme sekce abecedně
    table.sort(structuredList, function(a, b) return a.header < b.header end)

    return structuredList
end

function GetIndexFromMeta(category, ped)
    local playerPed = ped or PlayerPedId()
    local gender = "male"
    if not IsPedMale(playerPed) then
        gender = "female"
    end

    -- 1. Získáme aktuální data z peda (Hash, textury...)
    local currentData = GetMetaPedData(category, playerPed)
    
    -- Pokud data nemáme, vrátíme 1 (default)
    if not currentData or not Assets[gender] or not Assets[gender][category] then
        return 1
    end

    -- 2. Projdeme seznam v Assets a hledáme shodu
    local assetsList = Assets[gender][category]
    
    for index, item in ipairs(assetsList) do
        -- Porovnáváme hash modelu (drawable)
        -- Některé itemy mají strukturu {drawable=...}, jiné přímo hash.
        
        if item.drawable and item.drawable == currentData.drawable then
            return index
        elseif item.hash and item.hash == currentData.drawable then
            return index
        end
        
        -- Fallback pro přímé porovnání (někdy v Assets jsou jen čísla/hashe)
        if item == currentData.drawable then
            return index
        end
    end

    return 1 -- Pokud nenajdeme shodu, vrátíme 1
end


-- NOVÁ FUNKCE: Filtruje oblečení podle povolených kategorií pro daný item
function FilterClothesForMapping(fullClothes, itemName)
    -- Pokud item nemá definované mapování v Configu, bereme to jako "Master Item" (ukládá vše)
    local allowedCategories = Config.ItemMapping[itemName]
    
    if not allowedCategories then
        return fullClothes -- Vracíme všechno
    end

    local filteredData = {}
    
    -- Převedeme seznam na mapu pro rychlejší hledání
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