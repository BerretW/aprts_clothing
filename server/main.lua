-- server/main.lua
Core = exports.vorp_core:GetCore()
PlayersClothes = {}

function notify(playerId, message)
    TriggerClientEvent('notifications:notify', playerId, "SCRIPT", message, 4000)
end

function safeJsonDecode(jsonString)
    if not jsonString or jsonString == '' or jsonString == 'null' then return nil end
    local success, data = pcall(json.decode, jsonString)
    return success and data or nil
end

AddEventHandler("onResourceStart", function(resource)
    if resource == GetCurrentResourceName() then
        MySQL:execute("SELECT * FROM aprts_clothes", {}, function(result)
            for k, v in pairs(result) do
                v.data = safeJsonDecode(v.data)
                PlayersClothes[v.charID] = v.data
            end
            print("Database loaded: " .. #result .. " records.")
        end)
    end
end)