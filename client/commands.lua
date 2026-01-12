RegisterCommand("clothItem", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local index = tonumber(args[1])
    local var = tonumber(args[2]) or 1
    local cat = "suspenders"
    ApplyItemToPed(ped, cat, index, var)
end, false)

RegisterCommand("catData", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local TagData = GetMetaPedData("bodies_upper", ped)
    print(json.encode(TagData))
end, false)

RegisterCommand("tintChange", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local cat = "suspenders"
    local tint0 = tonumber(args[1])
    local tint1 = tonumber(args[2])
    local tint2 = tonumber(args[3])
    ChangeTintForCategory(ped, cat, tint0, tint1, tint2)
end, false)

RegisterCommand("paletteChange", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local cat = "suspenders"
    local palette = tonumber(args[1])
    ChangePaletteForCategory(ped, cat, palette)
end, false)

RegisterCommand("getPalette", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local cat = "suspenders"
    local name, palette = GetPaletteForCategory(ped, cat)
    print("Current palette for category", cat, "is:", name, palette)
end, false)

RegisterCommand("ClothMenu", function(source, args, rawCommand)
    print(json.encode(GetCategoriesNamesForMenu(), {
        indent = true
    }))
end, false)

RegisterCommand("undressCat", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local cat = "suspenders"
    RemoveTagFromMetaPed(cat, ped)
end, false)

RegisterCommand("undress", function(source, args, rawCommand)
    local ped = PlayerPedId()

    -- 1. Vytvoříme mapu esenciálních kategorií pro rychlé vyhledávání (co NECHCEME sundat)
    local keepCategories = {}
    if Config.EssentialsCategories then
        for _, cat in ipairs(Config.EssentialsCategories) do
            keepCategories[cat] = true
        end
    end

    -- 2. Získáme seznam VŠECH možných kategorií
    -- Kombinujeme kategorie z Ceníku (obsahuje většinu) a aktuálního PlayerClothes
    local allCategories = {}
    
    -- A) Přidáme vše z Config.CategoryPrices (pokrývá drtivou většinu oblečení)
    if Config.CategoryPrices then
        for cat, _ in pairs(Config.CategoryPrices) do
            allCategories[cat] = true
        end
    end

    -- B) Přidáme vše, co má hráč uložené v cache (pro jistotu)
    if PlayerClothes then
        for cat, _ in pairs(PlayerClothes) do
            allCategories[cat] = true
        end
    end

    -- 3. Iterujeme přes vše a mažeme to, co není esenciální
    local count = 0
    for cat, _ in pairs(allCategories) do
        if not keepCategories[cat] then
            -- Funkce z client/clothing.lua - odstraní Native Tag a vymaže z PlayerClothes
            RemoveTagFromMetaPed(cat, ped)
            
            -- Pojistka: Pokud funkce výše nesmazala záznam z PlayerClothes (např. nebyl nasazen), smažeme ho ručně
            if PlayerClothes[cat] then
                PlayerClothes[cat] = nil
            end
            count = count + 1
        end
    end

    -- 4. Finální refresh postavy
    UpdatePedVariation(ped)
    
    -- 5. Uložení "nahého" stavu na server
    TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)

    notify("Postava byla kompletně svlečena.")
end, false)


RegisterCommand("printClothes", function(source, args, rawCommand)
    print(json.encode(PlayerClothes, {
        indent = true
    }))
end, false)

RegisterCommand("ToggleCategory", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local cat = "suspenders"
    if not PlayerClothes[cat] then
        return
    end
    if PlayerClothes[cat] and PlayerClothes[cat].hidden then
        SetCategoryVisibility(ped, cat, true)
        print("Showing category:", cat)
    else
        SetCategoryVisibility(ped, cat, false)
        print("Hiding category:", cat)
    end
end, false)

RegisterCommand("saveData", function(source, args, rawCommand)
    TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
end, false)

RegisterCommand("reloadClothes", function(source, args, rawCommand)
    DressDataToPed(PlayerPedId(), PlayerClothes)
end, false)

RegisterCommand("openClothingMenu", function(source, args, rawCommand)
    OpenMenu(Config.ClothingMenu, false)
end, false)
RegisterCommand("openHairMenu", function(source, args, rawCommand)
    OpenMenu(Config.HairMenu, false)
end, false)
RegisterCommand("fixskin", function()
    local ped = PlayerPedId()
    FixClothes(ped)
    notify("Oblečení bylo opraveno.")
end, false)

RegisterCommand("reloadskin", function()
    TriggerServerEvent("aprts_clothing:Server:requestPlayerClothes")
end, false)

RegisterCommand("states", function()
    local gender = "male"
    if not IsPedMale(PlayerPedId()) then
        gender = "female"
    end

    local states = WearableStates[gender]["bodies_upper"]
    print(json.encode(states, {
        indent = true
    }))
    local state = jo.component.getWearableState(PlayerPedId(), "bodies_upper")
    print("Current state for bodies_upper is:", state)
end, false)

RegisterCommand("setstate", function(source, args, rawCommand)
    local ped = PlayerPedId()
    local gender = "male"
    if not IsPedMale(PlayerPedId()) then
        gender = "female"
    end
    local category = "bodies_upper"
    local Stateindex = tonumber(args[1]) or 1
    local states = WearableStates[gender]["bodies_upper"]
    print("nastavuji:" .. states[Stateindex])
    local index = GetComponentIndexByCategory(ped, category)
    local componentHash, _, wearableState = GetShopItemComponentAtIndex(ped, index, true, Citizen.ResultAsInteger(),
        Citizen.ResultAsInteger())
    print('Index:', index, 'Hash:', componentHash, 'wearable state:', wearableState)
    local stateName = jo.component.getWearableStateNameFromHash(wearableState)
    print(stateName)
    local data = {
        hash = "CLOTHING_ITEM_F_BODIES_UPPER_004_V_004"
    }
    -- jo.component.setWearableState(ped, category, data, states[Stateindex])
    UpdateShopItemWearableState(ped, componentHash, -1954442920)
    local wearableState = jo.component.getWearableState(ped, category)
    print(wearableState)

end, false)

-- Příkaz pro úpravu těla (otevře JEN levý panel)
RegisterCommand("skin", function(source, args, rawCommand)
    -- Argumenty: menu, creatorMode, showBody, showClothes
    -- Skryjeme oblečení (false), zobrazíme tělo (true)
    OpenMenu(Config.ClothingMenu, false, true, false)
end, false)

-- =========================================================
-- LOGIKA PRO TOGGLE (Vypínání/Zapínání oblečení)
-- =========================================================

-- Pomocná tabulka pro mapování aliasů na kategorie
local toggleGroups = {
    ["hat"] = {"hats", "hat_accessories", "caps"},
    ["mask"] = {"masks", "masks_large"},
    ["glasses"] = {"eyewear", "eye_wear"},
    ["coat"] = {"coats", "coats_closed", "coats_heavy", "ponchos", "cloaks", "capes"},
    ["vest"] = {"vests"},
    ["shirt"] = {"shirts_full", "shirts_full_overpants", "blouses"},
    ["gloves"] = {"gloves", "gauntlets"},
    ["boots"] = {"boots", "boot_accessories"},
    ["neck"] = {"neckwear", "neckties", "neckerchiefs"},
    ["pants"] = {"pants", "skirts", "chaps"},
    ["suspenders"] = {"suspenders"}
}

-- Hlavní funkce pro přepínání
local function ToggleClothingGroup(groupName)
    local ped = PlayerPedId()
    local catsToCheck = toggleGroups[groupName]

    if not catsToCheck then
        notify("Neznámá kategorie: " .. tostring(groupName))
        return
    end

    -- 1. Zjistíme, jestli má hráč něco z této skupiny zobrazené
    local isVisible = false
    local foundCategory = nil

    for _, cat in ipairs(catsToCheck) do
        -- Kontrola: Máme záznam v PlayerClothes A není skrytý?
        if PlayerClothes[cat] and not PlayerClothes[cat].hidden then
            isVisible = true
            foundCategory = cat
            break
        end
        -- Kontrola pro jistotu i v native (pokud by PlayerClothes nebylo syncnuté)
        -- (Volitelné, ale PlayerClothes by mělo být autoritativní)
    end

    -- 2. Přepnutí stavu
    local newState = not isVisible -- Pokud je vidět, chceme skrýt (false)

    local changedAny = false
    for _, cat in ipairs(catsToCheck) do
        -- Pokud skrýváme: Skryjeme jen to, co má hráč reálně na sobě
        if not newState then
            if PlayerClothes[cat] and not PlayerClothes[cat].hidden then
                SetCategoryVisibility(ped, cat, false)
                changedAny = true
            end
        else
            -- Pokud zobrazujeme: Zobrazíme to, co má v datech (i když je to skryté)
            if PlayerClothes[cat] then
                SetCategoryVisibility(ped, cat, true)
                changedAny = true
            end
        end
    end

    if changedAny then
        -- Refresh variací, aby se opravily případné glitche (rukávy atd.)
        UpdatePedVariation(ped)

        -- Notifikace
        if newState then
            notify("Oblečení zobrazeno: " .. groupName)
        else
            notify("Oblečení sundáno/skryto: " .. groupName)
        end

        -- Volitelné: Uložit stav na server, aby to zůstalo po relogu
        -- TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
    else
        notify("V této kategorii nemáš nic oblečeno.")
    end
end

-- Generický příkaz /toggle [nazev]
RegisterCommand("switch", function(source, args, rawCommand)
    local group = args[1]
    if not group then
        notify("Použití: /toggle [hat/coat/shirt/boots/mask/glasses/gloves/neck/vest]")
        return
    end
    ToggleClothingGroup(group)
end, false)

-- Zkratky pro pohodlnější RP (volitelné)
RegisterCommand("hat", function()
    ToggleClothingGroup("hat")
end, false)
RegisterCommand("coat", function()
    ToggleClothingGroup("coat")
end, false)
RegisterCommand("kabat", function()
    ToggleClothingGroup("coat")
end, false) -- CZ alias
RegisterCommand("mask", function()
    ToggleClothingGroup("mask")
end, false)
RegisterCommand("glasses", function()
    ToggleClothingGroup("glasses")
end, false)
RegisterCommand("gloves", function()
    ToggleClothingGroup("gloves")
end, false)
RegisterCommand("boots", function()
    ToggleClothingGroup("boots")
end, false)
RegisterCommand("vest", function()
    ToggleClothingGroup("vest")
end, false)
RegisterCommand("shirt", function()
    ToggleClothingGroup("shirt")
end, false)
RegisterCommand("neck", function()
    ToggleClothingGroup("neck")
end, false)
RegisterCommand("pants", function()
    ToggleClothingGroup("pants")
end, false)
RegisterCommand("suspenders", function()
    ToggleClothingGroup("suspenders")
end, false)
