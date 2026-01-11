local MenuOpen = false

RegisterNuiCallback('closeClothingMenu', function(data, cb)
    SetNuiFocus(false, false)
    MenuOpen = false
    cb('ok')
end)

RegisterNUICallback('getCatData', function(data, cb)
    local gender = data.gender
    local category = data.category
    
    -- Získáme seznam itemů
    local items = Assets[gender][category]
    
    -- Zjistíme, co má hráč aktuálně na sobě v této kategorii
    local currentIndex = -1
    local currentVar = 1
    
    if PlayerClothes[category] and PlayerClothes[category].index then
        currentIndex = PlayerClothes[category].index
        currentVar = PlayerClothes[category].varID or 1
    end

    -- Pošleme zpět objekt s daty i aktuálním stavem
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


RegisterNuiCallback("resetToNaked", function(data, cb)
    local ped = PlayerPedId()
    
    -- 1. Odstranit veškeré oblečení (kromě těla a hlavy)
    for cat, _ in pairs(PlayerClothes) do
        -- Vynecháme tělo (to budeme řešit níže) a obličejové prvky
        if cat ~= "bodies_upper" and cat ~= "bodies_lower" and cat ~= "heads" and cat ~= "eyes" and cat ~= "teeth" then
             RemoveTagFromMetaPed(cat, ped)
        end
    end

    -- 2. Obnovit původní tělo (to, se kterým hráč přišel)
    if OriginalBody.bodies_upper then
        ApplyItemToPed(ped, "bodies_upper", OriginalBody.bodies_upper, 1)
    end
    
    if OriginalBody.bodies_lower then
        ApplyItemToPed(ped, "bodies_lower", OriginalBody.bodies_lower, 1)
    end

    UpdatePedVariation(ped)
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
