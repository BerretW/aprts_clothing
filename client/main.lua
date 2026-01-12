-- client/main.lua
PlayerClothes = {}
ClothesCache = {}
OriginalBody = {}
MenuOpen = false
playingAnimation = false
CurrentItemContext = nil
dataReady = false

-- Thread pro blokování akcí
CreateThread(function()
    while true do
        local pause = 1000
        if MenuOpen == true or playingAnimation == true then
            DisableActions(PlayerPedId())
            DisableBodyActions(PlayerPedId())
            pause = 0
        end
        Citizen.Wait(pause)
    end
end)

-- Eventy
AddEventHandler("onClientResourceStart", function(resourceName)
    if GetCurrentResourceName() ~= resourceName then return end
    WaitForCharacter()
    TriggerServerEvent("aprts_clothing:Server:requestPlayerClothes")
end)

RegisterNetEvent('aprts_clothing:Client:receivePlayerClothes')
AddEventHandler('aprts_clothing:Client:receivePlayerClothes', function(clothes)
    print("Oblečení načteno ze serveru.")
    PlayerClothes = clothes or {}
    ClothesCache = clothes or {}
    
    -- Tady použijeme novou funkci, která řadí kategorie
    DressDataToPed(PlayerPedId(), PlayerClothes)
    
    -- Pro jistotu po krátké prodlevě (fixuje načítání textur při loginu)
    Citizen.SetTimeout(1000, function()
        FixClothes(PlayerPedId())
    end)
end)

-- Item Eventy
RegisterNetEvent("aprts_clothing:Client:ApplyItemClothes")
AddEventHandler("aprts_clothing:Client:ApplyItemClothes", function(data, itemName, itemId)
    local ped = PlayerPedId()

    if not data then return end

    -- 1. SLOUČENÍ DAT (MERGE)
    -- Projdeme data z itemu a přepíšeme jimi aktuální PlayerClothes
    for category, clothesData in pairs(data) do
        PlayerClothes[category] = clothesData
        -- Ujistíme se, že kategorie není skrytá
        if PlayerClothes[category].hidden then
            PlayerClothes[category].hidden = false
        end
    end

    -- 2. APLIKACE NA PEDA
    -- Přeoblečeme peda podle aktualizované tabulky PlayerClothes
    DressDataToPed(ped, PlayerClothes)
    
    -- Fix pro případné vizuální glitche
    UpdatePedVariation(ped)

    -- 3. NASTAVENÍ KONTEXTU
    -- Uložíme si info o itemu. Pokud hráč nyní otevře /openClothingMenu, 
    -- script bude vědět, že edituje tento konkrétní item, a ne svou postavu.
    CurrentItemContext = {
        itemId = itemId,
        itemName = itemName
    }

    -- 4. ULOŽENÍ STAVU DO DB (Volitelné, ale doporučené)
    -- Pokud chceš, aby hráč měl toto oblečení i po relogu (bez nutnosti znovu klikat na item),
    -- odkomentuj následující řádek:
    -- TriggerServerEvent("aprts_clothing:Server:saveClothes", PlayerClothes)

    print("Item aplikován a PlayerClothes aktualizováno.")
end)

RegisterNetEvent("aprts_clothing:Client:OpenItemCreator")
AddEventHandler("aprts_clothing:Client:OpenItemCreator", function(itemName, itemId)
    CurrentItemContext = { itemId = itemId, itemName = itemName }
    OpenMenu(Config.ClothingMenu, false) 
    notify("Upravuješ item: " .. itemName)
end)

-- Export pro Creator
exports("creator", function()
    dataReady = false
    OpenMenu(Config.ClothingMenu, true)
    while not dataReady do Citizen.Wait(100) end
    local result = dataReady
    dataReady = false
    return result
end)