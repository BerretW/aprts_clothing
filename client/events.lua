AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    WaitForCharacter()
    TriggerServerEvent("aprts_clothing:Server:requestPlayerClothes")
end)

AddEventHandler("onResourceStop", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then
        return
    end
    FreezeEntityPosition(PlayerPedId(), false)
    -- for k, v in pairs(Clues) do
    --     if DoesEntityExist(v.obj) then
    --         print("Ukončuji resource, mažu stopu: " .. v.id)
    --         DeleteEntity(v.obj)
    --     end
    -- end
end)

RegisterNetEvent('aprts_clothing:Client:receivePlayerClothes')
AddEventHandler('aprts_clothing:Client:receivePlayerClothes', function(clothes)
    print("Received player clothes data from server.")
    PlayerClothes = clothes or {}
    ClothesCache = clothes or {}
    DressDataToPed(PlayerPedId(), PlayerClothes)
end)

-- NOVÝ EVENT: Aplikace oblečení z itemu
RegisterNetEvent("aprts_clothing:Client:ApplyItemClothes")
AddEventHandler("aprts_clothing:Client:ApplyItemClothes", function(clothingData, itemName, itemId)
    -- Sloučíme data z itemu s aktuálním oblečením hráče
    -- Tím zajistíme, že kalhoty z itemu nepřepíšou košili, kterou už mám
    for category, data in pairs(clothingData) do
        PlayerClothes[category] = data
    end
    
    DressDataToPed(PlayerPedId(), clothingData)
    
    -- Nastavíme kontext, kdyby hráč chtěl hned otevřít menu a upravit tento item
    CurrentItemContext = { itemId = itemId, itemName = itemName }
    
    -- Volitelné: Zde můžeš zobrazit prompt "Stiskni [klávesu] pro úpravu itemu"
end)

-- NOVÝ EVENT: Otevření editoru pro prázdný item (nebo přepis)
RegisterNetEvent("aprts_clothing:Client:OpenItemCreator")
AddEventHandler("aprts_clothing:Client:OpenItemCreator", function(itemName, itemId)
    CurrentItemContext = { itemId = itemId, itemName = itemName }
    
    -- Otevřeme menu. true = CreatorMode (nemusí být nutně true, záleží jak chceš UI)
    -- Zde otevíráme normální menu, ale s kontextem itemu
    OpenMenu(Config.ClothingMenu, false) 
    
    notify("Upravuješ item: " .. itemName .. ". Uložení přepíše tento item.")
end)