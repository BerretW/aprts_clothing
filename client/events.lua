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

-- RegisterNetEvent('aprts_farming:Client:playAnim')
-- AddEventHandler('aprts_farming:Client:playAnim', function(anim)
--     local playerPed = PlayerPedId()
--     local prop = equipProp(anim.prop.model, anim.prop.bone, anim.prop.coords)
--     playAnim(playerPed,anim.dict, anim.name, anim.flag, anim.time)
--     if DoesEntityExist(prop) then
--         DeleteEntity(prop)
--     end
-- end)