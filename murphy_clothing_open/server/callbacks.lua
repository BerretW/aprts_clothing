Callback.register('murphy_clothing:GetItemAmount', function(source,item)
    local result = GetItemAmount(source, item)
    return result
end)

Callback.register('murphy_clothing:RemoveItem', function(source,item, amount, meta)
    local result = RemoveItem(source, item, amount, meta)
    return result
end)

Callback.register('murphy_clothing:GiveItem', function(source,item, amount, meta)
    local result = GiveItem(source, item, amount, meta)
    return result
end)

Callback.register('murphy_clothing:AddCurrency', function(source, amount)
    AddCurrency(source, amount)
    return
end)

Callback.register('murphy_clothing:RemoveCurrency', function(source, amount)
    RemoveCurrency(source, amount)
    return
end)

Callback.register('murphy_clothing:GetCharMoney', function(source)
    local result = GetCharMoney(source)
    return result
end)

Callback.register('murphy_clothing:GetCharJob', function(source)
    local job = GetCharJob(source)
    local grade = GetCharJobGrade(source)
    return job, grade
end)

Callback.register('murphy_clothing:GetCharIdentifier', function(source)
    local charid = GetCharIdentifier(source)
    return charid
end)

Callback.register('murphy_clothing:GetCurrentClothes', function(source)
    local _source = source
    local charid = GetCharIdentifier(_source)
    local clothestable = {}
    local outfitid = nil
    local hairtable = {}
    local datatable = nil
    MySQL.query('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    }, function(data)

        if data[1] then
            clothestable = json.decode(data[1].clothes)
            outfitid = data[1].outfit_id
        else
            clothestable = {}
            outfitid = 0
        end
        datatable = clothestable
                
    end)
    repeat
        Wait(50)
    until datatable ~= nil and outfitid ~= nil
    return datatable, outfitid
end)

Callback.register('murphy_clothing:GetCurrentClothesCharid', function(source, characterid)
    local _source = source
    local charid = characterid
    local clothestable = {}
    local outfitid = nil
    local hairtable = {}
    local datatable = nil
    MySQL.query('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    }, function(data)

        if data[1] then
            clothestable = json.decode(data[1].clothes)
            outfitid = data[1].outfit_id
        else
            clothestable = {}
            outfitid = 0
        end
        datatable = clothestable
                
    end)
    repeat
        Wait(50)
    until datatable ~= nil and outfitid ~= nil
    return datatable, outfitid
end)

Callback.register('murphy_clothing:GetCurrentOutfitList', function(source)
    local _source = source
    local charid = GetCharIdentifier(_source)
    local list = nil
    MySQL.query('SELECT * FROM murphy_outfits WHERE `charid`=@charid;', {
        charid = charid
    }, function(outfits)
        if outfits[1] then
            list = outfits
        else
            list = {}
        end
    end)
    repeat
        Wait(0)
    until list ~= nil
    return list
end)

Callback.register('murphy_clothing:GetOutfit', function(source, id)
    local _source = source
    local outfit_id = id
    local datatable = nil
    MySQL.query(
        'SELECT * FROM murphy_outfits WHERE `outfit_id`=@outfit_id;', {
            outfit_id = outfit_id
        }, function(result)
            if result[1] then
                _clothes = json.decode(result[1].clothes)
                -- _skin = json.decode(result[1].skin)
                datatable = _clothes
                gender = result[1].gender
            else
                datatable = {}
            end
        end)
    repeat
        Wait(0)
    until datatable ~= nil
    return datatable, gender
end)

Callback.register('murphy_clothing:GiveOutfit', function(source, id, name, price)
    local _source = source
    local meta = {outfit_id = id, description = name}
    local currentMoney = GetCharMoney(_source)
    local result = false
    local singleitems = nil

    -- Retrieve the singleitems from the database
    MySQL.query('SELECT singleitems FROM murphy_outfits WHERE `outfit_id`=@outfit_id;', {
        outfit_id = id
    }, function(data)
        if data[1] then
            singleitems = json.decode(data[1].singleitems)
        else
            singleitems = {}
        end
    end)

    repeat
        Wait(0)
    until singleitems ~= nil

    if next(singleitems) ~= nil then
        for item, categories in pairs(Config.SingleItemCategory) do
            local meta = {}  -- Initialize meta as an empty table
            meta.description = name
            meta.clothes = {}
            for k, category in pairs(categories) do
                if singleitems[category] then
                    if singleitems[category].model > 0 then
                        -- Ensure meta is a table and has a numeric index
                        if type(meta) ~= "table" then meta = {} meta.description = name end
                        meta.clothes[#meta.clothes + 1] = {
                            cat = category, 
                            model = singleitems[category].model, 
                            texture = singleitems[category].texture,
                        }
                        singleitems[category] = nil
                    end
                end
            end
            if #meta.clothes > 0 then  -- Only give item if meta contains data
                GiveItem(_source, item, 1, meta)
            end
        end
    end

    if currentMoney >= price then
        if GiveItem(_source, Config.OutfitItem, 1, meta) then
            RemoveCurrency(_source, price)
            result = true
        end
    end
    return result
end)

Callback.register('murphy_clothing:DeleteOutfit', function(source, id)
    local _source = source
    local outfit_id = id
    local updated = nil
    print ("Deleting outfit with ID: " .. outfit_id)
    MySQL.update(
        'UPDATE murphy_outfits SET `charid`=@charid WHERE `outfit_id`=@outfit_id;', {
            charid = 0,
            outfit_id = outfit_id
        }, function(result)
            if result then
                updated = true
            else
                updated = false
            end
        end)
    repeat
        Wait(0)
    until updated ~= nil
    return updated
end)

local essentials = Config.EssentialsCategories


Callback.register('murphy_clothing:SaveOutfit', function(source, table, name, fee, male)
    local gender = "female"
    if male then gender = "male" end
    local _source = source
    local Clothes = table
    local numBase0 = math.random(100, 999)
    local numBase1 = math.random(0, 999)
    
    -- Ensure UTF-8 special characters are preserved
    local _Name = name
    if _Name and type(_Name) == "string" then
        -- Trim and ensure proper encoding
        _Name = _Name:gsub("^%s*(.-)%s*$", "%1")
        -- Limit name length to prevent database issues
        if #_Name > 200 then
            _Name = _Name:sub(1, 200)
        end
    end
    
    local outfit_id = string.format("%03d%04d", numBase0, numBase1)
    local charid = GetCharIdentifier(_source)
    local currentMoney = GetCharMoney(_source)
    local encode = json.encode(Clothes)
    -- local skin = json.encode(skindata)
    local price = fee or 0
    local callback = false
    if currentMoney >= price then
        callback = true
        RemoveCurrency(_source, price)
        local singleitems = {}
        for _, essential in ipairs(essentials) do
            Clothes[essential] = nil
        end
        for item, categories in pairs(Config.SingleItemCategory) do
            local meta = {}  -- Initialize meta as an empty table
            meta.description = name
            meta.clothes = {}
            for k, category in pairs(categories) do
                if Clothes[category] then
                    if Clothes[category].model > 0 then
                        -- Ensure meta is a table and has a numeric index
                        if type(meta) ~= "table" then meta = {} meta.description = name end
                        meta.clothes[#meta.clothes + 1] = {
                            cat = category, 
                            model = Clothes[category].model, 
                            texture = Clothes[category].texture,
                        }
                        singleitems[category] = Clothes[category]
                        Clothes[category] = nil
                    end
                end
            end
            if #meta.clothes > 0 then  -- Only give item if meta contains data
                GiveItem(_source, item, 1, meta)
                
            end
        end
        encodedsingleitems = json.encode(singleitems)
        encode = json.encode(Clothes)
        if _Name and next(Clothes) ~= nil then

            MySQL.update(
                'INSERT INTO murphy_outfits (`charid`, `clothes`, `name`, `outfit_id`, `price`, `gender`, `singleitems`) VALUES (@charid, @clothes , @name, @outfit_id, @price, @gender, @singleitems);',
                {
                    charid = charid,
                    clothes = encode,
                    name = _Name,
                    outfit_id = outfit_id,
                    price = price,
                    gender = gender,
                    singleitems = encodedsingleitems


                }, function(rowsChanged)
                end)
                                    -- skin = skin
            local meta = {outfit_id = outfit_id, description = name}
            if next(Clothes) ~= nil then
                GiveItem(_source, Config.OutfitItem, 1, meta)
            end
        end
    end
    return callback, outfit_id
end)

Callback.register('murphy_clothing:ModifyOutfit', function(source, table, id, fee)
    local _source = source
    local Clothes = table
    local outfit_id = id
    local charid = GetCharIdentifier(_source)
    local currentMoney = GetCharMoney(_source)
    local encode = json.encode(Clothes)
    -- local skin = json.encode(skindata)
    local price = fee or 0
    local callback = false
    local outfit_name = nil

    -- Retrieve the outfit name from the database
    MySQL.query('SELECT name FROM murphy_outfits WHERE `outfit_id`=@outfit_id;', {
        outfit_id = outfit_id
    }, function(result)
        if result[1] then
            outfit_name = result[1].name
        else
            outfit_name = "Unknown"
        end
    end)

    repeat
        Wait(0)
    until outfit_name ~= nil

    if currentMoney >= price then
        callback = true
        RemoveCurrency(_source, price)
        local singleitems = {}
        for _, essential in ipairs(essentials) do
            Clothes[essential] = nil
        end
        for item, categories in pairs(Config.SingleItemCategory) do
            local meta = {}  -- Initialize meta as an empty table
            meta.description = outfit_name
            meta.clothes = {}
            for k, category in pairs(categories) do
                if Clothes[category] then
                    if Clothes[category].model > 0 then
                        -- Ensure meta is a table and has a numeric index
                        if type(meta) ~= "table" then meta = {} meta.description = outfit_name end
                        meta.clothes[#meta.clothes + 1] = {
                            cat = category, 
                            model = Clothes[category].model, 
                            texture = Clothes[category].texture,
                        }
                        singleitems[category] = Clothes[category]
                        Clothes[category] = nil
                    end
                end
            end
            if #meta.clothes > 0 then  -- Only give item if meta contains data
                -- GiveItem(_source, item, 1, meta)

            end
        end
        encodedsingleitems = json.encode(singleitems)
        encode = json.encode(Clothes)
        if outfit_id and next(Clothes) ~= nil then
            MySQL.update("UPDATE murphy_outfits SET `clothes`=@encode, `singleitems`=@singleitems WHERE `charid`=@charid AND `outfit_id`=@outfit_id",
            {
                encode = encode,
                singleitems = encodedsingleitems,
                charid = charid,
                outfit_id = outfit_id

            }, function(done)
            end)
            local meta = {outfit_id = outfit_id, description = outfit_name}
            if next(Clothes) ~= nil then
                -- GiveItem(_source, Config.OutfitItem, 1, meta)
            end
        end
    end
    return callback, Clothes
end)

RegisterServerEvent("murphy_clothes:updateclothes", function(clothes, outfitid)
    local _source = source
    local charid = GetCharIdentifier(_source)
    local outfit_id = outfitid
    for _, essential in ipairs(essentials) do
        clothes[essential] = nil
    end
    local encodedclothes = json.encode(clothes)
    TriggerEvent("murphy_clothes:retrieveClothes", charid, function(call)
        if call then
            MySQL.update("UPDATE murphy_clothes SET clothes = @clothes, outfit_id = @outfit_id WHERE charid = @charid", {
                clothes = encodedclothes,
                outfit_id = outfit_id,
                charid = charid
            }, function(done)
            end)
        else
            MySQL.update("INSERT INTO murphy_clothes (charid, clothes, outfit_id) VALUES (@charid, @clothes, @outfit_id)", {
                charid = charid,
                clothes = encodedclothes,
                outfit_id = outfit_id
            }, function(rowsChanged)
            end)
        end
    end)
end)

AddEventHandler('murphy_clothes:retrieveClothes', function(charid, callback)
    local Callback = callback
    local id = charid
    MySQL.query('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = id
    }, function(clothes)
        if clothes[1] then
            Callback(clothes[1])
        else
            Callback(false)
        end
    end)
end)

Callback.register('murphy_clothing:SaveWearable', function(source, id, data)
    local _source = source
    local outfit_id = id
    local charid = GetCharIdentifier(_source)
    local encoded = json.encode(data)
    local result = nil
    TriggerEvent("murphy_clothes:retrieveWearable", charid, outfit_id, function(call)
        if call then
            MySQL.update("UPDATE murphy_wearable SET `skin`=@skin WHERE `charid`=@charid AND `outfit_id`=@outfit_id ", {
                skin = encoded,
                charid = charid,
                outfit_id = outfit_id
  
            }, function(done)
                result = true
            end)
        else
            MySQL.update(
                'INSERT INTO murphy_wearable (`charid`, `skin`, `outfit_id`) VALUES (@charid, @skin, @outfit_id);',
                {
                    charid = charid,
                    skin = encoded,
                    outfit_id = outfit_id
                }, function(rowsChanged)
                    result = true
                end)
        end
    end)
    repeat Wait(0) until result ~= nil
    return result
end)

Callback.register('murphy_clothing:GetWearable', function(source, id, characterid)
    local _source = source
    local outfit_id = id
    local charid = characterid or GetCharIdentifier(_source)
    local encoded = json.encode(data)
    local data = nil
    TriggerEvent("murphy_clothes:retrieveWearable", charid, outfit_id, function(call)
        if call then
                data = json.decode(call.skin)
        else
            data = {}
        end
    end)
    repeat Wait(0) until data ~= nil
    return data
end)

AddEventHandler('murphy_clothes:retrieveWearable', function(charid, outfit_id, callback)
    local Callback = callback
    MySQL.query('SELECT * FROM murphy_wearable WHERE `charid`=@charid AND `outfit_id`=@outfit_id;', {
        charid = charid,
        outfit_id = outfit_id
    }, function(result)
        if result[1] then
            Callback(result[1])
        else
            Callback(false)
        end
    end)
end)


/**********************************************************************************************
 *                           SERVER-SIDE BANDANA DETECTION                                    *
 **********************************************************************************************/

-- Server callback to check if a player has a bandana equipped
Callback.register('murphy_clothing:IsBandanaEquipped', function(source)
    local _source = source
    local charid = GetCharIdentifier(_source)
    local hasBandana = false
    
    MySQL.query('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    }, function(result)
        if result[1] then
            local clothes = json.decode(result[1].clothes)
            -- Check masks and masks_large categories
            if clothes then
                if (clothes.masks and clothes.masks.model and clothes.masks.model > 0) or 
                   (clothes.masks_large and clothes.masks_large.model and clothes.masks_large.model > 0) then
                    hasBandana = true
                end
            end
        end
    end)
    
    return hasBandana
end)

-- Export for other resources
exports('IsBandanaEquipped', function(source)
    local charid = GetCharIdentifier(source)
    local hasBandana = false
    
    local result = MySQL.query.await('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    })
    
    if result and result[1] then
        local clothes = json.decode(result[1].clothes)
        if clothes then
            if (clothes.masks and clothes.masks.model and clothes.masks.model > 0) or 
               (clothes.masks_large and clothes.masks_large.model and clothes.masks_large.model > 0) then
                hasBandana = true
            end
        end
    end
    
    return hasBandana
end)

/**********************************************************************************************
 *                         TEMPERATURE/METABOLISM SYSTEM (SERVER)                             *
 **********************************************************************************************/

-- Server callback to get player's temperature protection
Callback.register('murphy_clothing:GetPlayerTemperatureProtection', function(source)
    local _source = source
    local charid = GetCharIdentifier(_source)
    local warmCount = 0
    local coldCount = 0
    local categories = {}
    
    local result = MySQL.query.await('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    })
    
    if result and result[1] then
        local clothes = json.decode(result[1].clothes)
        if clothes then
            for category, data in pairs(clothes) do
                if data and data.model and data.model > 0 then
                    table.insert(categories, category)
                    
                    if Config.ClothingTemperature[category] then
                        if Config.ClothingTemperature[category] == "warm" then
                            warmCount = warmCount + 1
                        elseif Config.ClothingTemperature[category] == "cold" then
                            coldCount = coldCount + 1
                        end
                    end
                end
            end
        end
    end
    
    local coldProtection = Config.TemperatureProtection.cold[warmCount] or 3
    local heatProtection = Config.TemperatureProtection.heat[coldCount] or 3
    
    return {
        warmItems = warmCount,
        coldItems = coldCount,
        coldProtection = coldProtection,
        heatProtection = heatProtection,
        categories = categories
    }
end)

-- Server export for getting player temperature protection
exports('GetPlayerTemperatureProtection', function(source)
    local charid = GetCharIdentifier(source)
    local warmCount = 0
    local coldCount = 0
    
    local result = MySQL.query.await('SELECT * FROM murphy_clothes WHERE `charid`=@charid;', {
        charid = charid
    })
    
    if result and result[1] then
        local clothes = json.decode(result[1].clothes)
        if clothes then
            for category, data in pairs(clothes) do
                if data and data.model and data.model > 0 then
                    if Config.ClothingTemperature[category] then
                        if Config.ClothingTemperature[category] == "warm" then
                            warmCount = warmCount + 1
                        elseif Config.ClothingTemperature[category] == "cold" then
                            coldCount = coldCount + 1
                        end
                    end
                end
            end
        end
    end
    
    local coldProtection = Config.TemperatureProtection.cold[warmCount] or 3
    local heatProtection = Config.TemperatureProtection.heat[coldCount] or 3
    
    return {
        warmItems = warmCount,
        coldItems = coldCount,
        coldProtection = coldProtection,
        heatProtection = heatProtection
    }
end)