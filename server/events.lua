-- =============================================================
-- FILE: server/events.lua
-- DESCRIPTION: Network eventy, interakce s inventářem a
-- requesty klientů.
-- =============================================================
local DataLoaded = false

-- Event: Načtení dat při startu resource
AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute("SELECT * FROM aprts_clothes", {}, function(result)
            for k, v in pairs(result) do
                -- Předpoklad: safeJsonDecode je definováno v server/main.lua
                v.data = safeJsonDecode(v.data)

                -- PlayersClothes je globální proměnná z server/main.lua
                if v.data then
                    PlayersClothes[v.charID] = v.data
                end
            end
            DataLoaded = true
            print("^2[APRTS_CLOTHING]^0 Databáze načtena: " .. #result .. " záznamů.")
        end)
    end
end)

-- Event: Použití itemu z inventáře (VORP Inventory)
RegisterServerEvent("vorp_inventory:useItem")
AddEventHandler("vorp_inventory:useItem", function(data)
    local _source = source
    local itemName = data.item
    local itemId = data.id -- Unique ID itemu v DB
    exports.vorp_inventory:getItemByMainId(_source, data.id, function(data)
        local metadata = data.metadata

        -- Rychlá kontrola, zda je to item definovaný v configu pro oblečení
        local isClothingItem = false
        for _, v in pairs(Config.ClothingItems) do
            if v == itemName then
                isClothingItem = true
                break
            end
        end
        print(json.encode(data, {
            indent = true
        }))
        if isClothingItem then

            -- A) Item má metadata s oblečením -> Aplikovat
            if metadata and metadata.clothingData then
                TriggerClientEvent("aprts_clothing:Client:ApplyItemClothes", _source, metadata.clothingData, itemName,
                    itemId)
                notify(_source, "Oblečení z itemu aplikováno.")

                -- B) Item je prázdný -> Otevřít editor pro uložení
            else
                TriggerClientEvent("aprts_clothing:Client:OpenItemCreator", _source, itemName, itemId)
                notify(_source, "Item je prázdný. Otevírám editor pro uložení.")
            end
        end
    end)
end)

-- Event: Uložení oblečení DO ITEMU
RegisterServerEvent("aprts_clothing:Server:saveClothesToItem")
AddEventHandler("aprts_clothing:Server:saveClothesToItem", function(itemId, itemName, clothesData)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        return
    end

    -- Uložení metadat přes VORP Inventory export
    local description = "Obsahuje uložený outfit."

    local metadata = {
        description = description,
        clothingData = clothesData
    }

    -- VORP Inventory Export pro update metadat itemu
    exports.vorp_inventory:setItemMetadata(_source, itemId, metadata)

    notify(_source, "Oblečení uloženo do itemu.")
    -- Logování (pokud je funkce definována v main.lua)
    if LOG then
        LOG(_source, "Item Saved", "Hráč uložil oblečení do itemu: " .. itemName)
    end
end)

-- Event: Klient žádá o svá data po připojení/respawnu
RegisterServerEvent("aprts_clothing:Server:requestPlayerClothes")
AddEventHandler("aprts_clothing:Server:requestPlayerClothes", function()
    local _source = source

    -- Čekáme, až se DB načte při startu serveru
    while not DataLoaded do
        Citizen.Wait(100)
    end

    local user = Core.getUser(_source)
    if not user then
        return
    end

    local character = user.getUsedCharacter
    if not character then
        return
    end

    local charID = character.charIdentifier
    local clothesData = PlayersClothes[charID] or {}

    TriggerClientEvent("aprts_clothing:Client:receivePlayerClothes", _source, clothesData)
end)

-- Event: Uložení oblečení POSTAVY do databáze
RegisterServerEvent("aprts_clothing:Server:saveClothes")
AddEventHandler("aprts_clothing:Server:saveClothes", function(clothesData)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        return
    end

    local character = user.getUsedCharacter
    if not character then
        return
    end

    local charID = character.charIdentifier

    -- Aktualizace cache na serveru
    PlayersClothes[charID] = clothesData

    -- Uložení do DB (Funkce z server/database.lua)
    SavePlayerData(charID, clothesData)

    -- notify(_source, "Oblečení postavy uloženo.")
end)

-- Event: Uložení konkrétní kategorie (Legacy podpora, pokud je potřeba)
RegisterServerEvent("aprts_clothing:Server:saveCategory")
AddEventHandler("aprts_clothing:Server:saveCategory", function(category, categoryData)
    local _source = source
    local user = Core.getUser(_source)
    if not user then
        return
    end
    local charID = user.getUsedCharacter.charIdentifier

    if not PlayersClothes[charID] then
        PlayersClothes[charID] = {}
    end

    PlayersClothes[charID][category] = categoryData
    SavePlayerData(charID, PlayersClothes[charID])
end)

RegisterServerEvent("aprts_clothing:Server:createItemFromCurrentClothes")
AddEventHandler("aprts_clothing:Server:createItemFromCurrentClothes", function(itemType, outfitName, clothesData)
    local _source = source

    -- itemType je nyní např. "clothing_hat" nebo "clothing_all" (podle výběru hráče)
    -- outfitName je to, co hráč napsal do inputu (např. "Můj Klobouk")
    print("Creating item:", itemType, outfitName)
    print(json.encode(clothesData, {
        indent = true
    }))
    local metadata = {
        description = outfitName,
        label = outfitName, -- Pro zobrazení v inventáři
        clothingData = clothesData
    }

    -- Kontrola místa a přidání itemu
    local canCarry = exports.vorp_inventory:canCarryItem(_source, itemType, 1)

    if canCarry then
        exports.vorp_inventory:addItem(_source, itemType, 1, metadata)
        notify(_source, "Vytvořen item: " .. outfitName .. " (" .. itemType .. ")")
    else
        notify(_source, "Nemáš místo v inventáři!")
    end
end)
