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

AddEventHandler("vorp_inventory:useItem")
RegisterServerEvent("vorp_inventory:useItem", function(data)
    local _source = source
    local itemName = data.item
    exports.vorp_inventory:getItemByMainId(_source, data.id, function(data)
        if data == nil then
            return
        end
        local metadata = data.metadata
        if metadata then

        end
    end)
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
