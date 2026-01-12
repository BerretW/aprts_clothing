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

RegisterCommand("fixskin", function()
    local ped = PlayerPedId()
    jo.component.refreshPed(ped)
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
