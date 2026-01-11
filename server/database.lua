MySQL = exports.oxmysql
-- server/database.lua
function SavePlayerData(charID, clothesData)
    local clothesJSON = json.encode(clothesData)
    MySQL:execute([[
        INSERT INTO aprts_clothes (charID, data)
        VALUES (@charid, @clothes)
        ON DUPLICATE KEY UPDATE data = @clothes
    ]], {
        ['@charid'] = charID,
        ['@clothes'] = clothesJSON
    })
end

function LoadPlayerData(charID)
    local clothesData = {}
    local finished = false
    
    MySQL:execute("SELECT data FROM aprts_clothes WHERE charID = @charid", {
        ['@charid'] = charID
    }, function(result)
        if result and result[1] and result[1].data then
            clothesData = safeJsonDecode(result[1].data) or {}
        end
        finished = true
    end)

    while not finished do Wait(100) end
    return clothesData
end