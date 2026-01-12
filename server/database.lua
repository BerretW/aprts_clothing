MySQL = exports.oxmysql
-- server/database.lua
-- server/database.lua

function SavePlayerData(charID, clothesData, makeupData)
    local clothesJSON = json.encode(clothesData or {})
    local makeupJSON = json.encode(makeupData or {})

    MySQL:execute([[
        INSERT INTO aprts_clothes (charID, data, makeup)
        VALUES (@charid, @clothes, @makeup)
        ON DUPLICATE KEY UPDATE 
            data = @clothes,
            makeup = @makeup
    ]], {
        ['@charid'] = charID,
        ['@clothes'] = clothesJSON,
        ['@makeup'] = makeupJSON
    })
end

function LoadPlayerData(charID)
    local resultData = { clothes = {}, makeup = {} }
    local finished = false
    
    MySQL:execute("SELECT data, makeup FROM aprts_clothes WHERE charID = @charid", {
        ['@charid'] = charID
    }, function(result)
        if result and result[1] then
            if result[1].data then
                resultData.clothes = safeJsonDecode(result[1].data) or {}
            end
            if result[1].makeup then
                resultData.makeup = safeJsonDecode(result[1].makeup) or {}
            end
        end
        finished = true
    end)

    while not finished do Wait(100) end
    return resultData
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