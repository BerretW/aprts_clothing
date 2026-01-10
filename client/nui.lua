local MenuOpen = false

RegisterNuiCallback('closeClothingMenu', function(data, cb)
    SetNuiFocus(false, false)
    MenuOpen = false
    cb('ok')
end)

RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    cb(Assets[gender][category])
end)

RegisterNuiCallback("applyItem", function(data, cb)
    local ped = PlayerPedId()
    local cat = data.category
    local index = tonumber(data.index)
    local varID = tonumber(data.varID)

    -- Voláme funkci pro aplikaci itemu podle indexu
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

-- === NOVÁ ČÁST PRO ULOŽENÍ ===
RegisterNuiCallback("saveClothes", function(data, cb)
    -- Uložíme aktuální tabulku PlayerClothes na server
    if data.CreatorMode then
        dataReady = PlayerClothes
    else
        TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)
    end
    -- Můžeme poslat notifikaci hráči (používáme tvou funkci notify z client/client.lua)
    notify("Oblečení bylo uloženo.")

    cb('ok')
end)
