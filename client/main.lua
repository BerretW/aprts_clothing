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

RegisterNetEvent("aprts_clothing:Client:receivePlayerClothes")
AddEventHandler("aprts_clothing:Client:receivePlayerClothes", function(clothesData, makeupData)
    local ped = PlayerPedId()
    
    -- 1. Načtení oblečení
    PlayerClothes = clothesData or {}
    ClothesCache = DeepCopy(PlayerClothes) -- Cache pro revert
    DressDataToPed(ped, PlayerClothes)

    -- 2. Načtení Make-upu (NOVÉ)
    if makeupData then
        LoadPlayerOverlays(makeupData) -- Funkce z client/overlay.lua
    end
    
    -- Final refresh
    UpdatePedVariation(ped)
end)

-- Item Eventy
RegisterNetEvent("aprts_clothing:Client:ApplyItemClothes")
AddEventHandler("aprts_clothing:Client:ApplyItemClothes", function(clothingData, itemName, itemId)
    local ped = PlayerPedId()

    -- Pokud data neexistují, konec
    if not clothingData then return end

    -- Voláme naši novou Toggle funkci
    ToggleItemClothes(clothingData, itemName)
    
    -- Volitelné: Přehrání animace oblékání
    playAnim(ped, "mech_inventory@clothing@mask", "cor_mask_put_on_r_hand", 0, 2000)
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