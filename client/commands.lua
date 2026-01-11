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


RegisterCommand("printClothes", function(source, args, rawCommand)
    print(json.encode(PlayerClothes, {
        indent = true
    }))
end, false  )

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
end, false  )

RegisterCommand("reloadClothes", function(source, args, rawCommand)
    DressDataToPed(PlayerPedId(), PlayerClothes)
end, false  )


RegisterCommand("openClothingMenu", function(source, args, rawCommand)
OpenMenu(Config.ClothingMenu,false)
end, false)

RegisterCommand("wearable", function(source, args, rawCommand)
    -- Otevře menu, ale řekne UI, že má být v "WearableMode"
    -- K tomu musíme upravit OpenMenu funkci, viz další krok.
    OpenMenu(Config.ClothingMenu, false, true) -- Třetí parametr = isWearableOnly
end, false)