local DataLoaded = false
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute("SELECT * FROM aprts_clothes", {}, function(result)
            for k, v in pairs(result) do
                v.data = safeJsonDecode(v.data)

                PlayersClothes[v.charID] = v.data

            end
            DataLoaded = true
        end)
    end
end)

RegisterServerEvent("vorp_inventory:useItem")
AddEventHandler("vorp_inventory:useItem", function(data)
    local _source = source
    local itemName = data.item
    local itemId = data.id -- ID konkrétního itemu v DB (mainId)
    local metadata = data.metadata

    -- Rychlá kontrola, zda je to clothing item
    local isClothingItem = false
    for _, v in pairs(Config.ClothingItems) do
        if v == itemName then isClothingItem = true break end
    end

    if isClothingItem then
        -- Pokud item má metadata s oblečením, pošleme je klientovi k aplikaci
        if metadata and metadata.clothingData and next(metadata.clothingData) then
            TriggerClientEvent("aprts_clothing:Client:ApplyItemClothes", _source, metadata.clothingData, itemName, itemId)
            notify(_source, "Oblečení z itemu aplikováno.")
        else
            -- Item je prázdný -> Otevřeme menu pro uložení aktuálního outfitu do itemu
            TriggerClientEvent("aprts_clothing:Client:OpenItemCreator", _source, itemName, itemId)
            notify(_source, "Item je prázdný. Otevírám editor pro uložení.")
        end
    end
end)

-- NOVÝ EVENT: Uložení do itemu
RegisterServerEvent("aprts_clothing:Server:saveClothesToItem")
AddEventHandler("aprts_clothing:Server:saveClothesToItem", function(itemId, itemName, clothesData)
    local _source = source
    
    -- Získáme item z inventáře pro kontrolu (volitelné, ale bezpečnější)
    local Character = exports.vorp_core:GetCore().getUser(_source).getUsedCharacter
    
    -- Uložení metadat přes VORP Inventory export
    -- Struktura metadat: { description = "Popis...", clothingData = {...} }
    local description = "Obsahuje uložené oblečení."
    
    local metadata = {
        description = description,
        clothingData = clothesData
    }

    exports.vorp_inventory:setItemMetadata(_source, itemId, metadata)
    notify(_source, "Oblečení uloženo do itemu.")
end)

RegisterServerEvent("aprts_clothing:Server:requestPlayerClothes")
AddEventHandler("aprts_clothing:Server:requestPlayerClothes", function()

    local _source = source
    while not DataLoaded do
        Citizen.Wait(100)
    end
    local charID = Player(_source).state.Character.CharId
    if not charID then
        return
    end
    local clothesData = PlayersClothes[charID] or {}
    TriggerClientEvent("aprts_clothing:Client:receivePlayerClothes", _source, clothesData)
end)

RegisterServerEvent("aprts_clothing:Server:saveClothes")
AddEventHandler("aprts_clothing:Server:saveClothes", function(clothesData)
    local src = source
    local charID = Player(src).state.Character.CharId
    if not charID then
        return
    end
    PlayersClothes[charID] = clothesData
    SavePlayerData(charID, clothesData)
end)

RegisterServerEvent("aprts_clothing:Server:saveCategory")
AddEventHandler("aprts_clothing:Server:saveCategory", function(category, categoryData)
    local _source = source
    local charID = Player(_source).state.Character.CharId
    if not PlayersClothes[charID] then
        PlayersClothes[charID] = {}
    end
    PlayersClothes[charID][category] = categoryData
    SavePlayerData(charID, PlayersClothes[charID])
end)
