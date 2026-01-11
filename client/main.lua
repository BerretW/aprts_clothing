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
AddEventHandler("aprts_clothing:Client:ApplyItemClothes", function(clothingData, itemName, itemId)
    for category, data in pairs(clothingData) do
        PlayerClothes[category] = data
    end
    DressDataToPed(PlayerPedId(), clothingData)
    CurrentItemContext = { itemId = itemId, itemName = itemName }
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