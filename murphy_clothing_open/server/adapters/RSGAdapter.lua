if Config.framework == 'rsg-core' then
    local CORE = exports['rsg-core']:GetCoreObject()

    function GetCharJob(targetID)
        targetID = tonumber(targetID)
        local user = CORE.Functions.GetPlayer(targetID)
        if user then 
            job = CORE.Functions.GetPlayer(targetID).PlayerData.job.name
        else job = nil end
        return job
    end

    function GetCharJobGrade(targetID) 
        targetID = tonumber(targetID)
        local user = CORE.Functions.GetPlayer(targetID)
        if user then 
            job = CORE.Functions.GetPlayer(targetID).PlayerData.job.grade.level
        else job = nil end
        return job
    end

    function GetCharIdentifier(targetID)
        targetID = tonumber(targetID)
        return CORE.Functions.GetPlayer(targetID).PlayerData.citizenid
    end

    function GetCharFirstname(targetID)
        targetID = tonumber(targetID)
        return CORE.Functions.GetPlayer(targetID).PlayerData.charinfo.firstname
    end

    function GetCharLastname(targetID)
        targetID = tonumber(targetID)
        return CORE.Functions.GetPlayer(targetID).PlayerData.charinfo.lastname
    end

    function GetCharMoney(targetID)
        targetID = tonumber(targetID)
        return CORE.Functions.GetPlayer(targetID).PlayerData.money["cash"]
    end

    function RemoveCurrency(targetID, amount)
        targetID = tonumber(targetID)
        local Player = CORE.Functions.GetPlayer(targetID)
        Player.Functions.RemoveMoney("cash", amount)
    end

    function GetCharGroup(targetID)
        targetID = tonumber(targetID)
        local permissions = CORE.Functions.GetPermission(targetID)
        for k, v in pairs(permissions) do
            return k
        end
    end
    
    function GiveItem(src, item, amount, meta)
        local Player = CORE.Functions.GetPlayer(src)
        local _meta = meta or {}
        local result = Player.Functions.AddItem(item, amount, nil, _meta)
        return result
    end
    
    function RemoveItem(src, item, amount, meta)
        local Player = CORE.Functions.GetPlayer(src)
        local _meta = meta
        local result = Player.Functions.RemoveItem(item, amount)
        return result
    end

    function GetItemAmount(src, item)
        local Player = CORE.Functions.GetPlayer(src)
        local _meta = meta
        local result = Player.Functions.GetItemByName(item, amount)
        if result then
            amount = result.amount
        else
            amount = 0
        end

        return amount
    end

    CORE.Functions.CreateUseableItem(Config.OutfitItem, function(source, item)
        local _source = source
        local Player = CORE.Functions.GetPlayer(_source)
        if not Player.Functions.GetItemByName(item.name) then return end
        local outfit_id = item.info.outfit_id
        local datatable = {}
        MySQL.query(
            'SELECT * FROM murphy_outfits WHERE `outfit_id`=@outfit_id;', {
                outfit_id = outfit_id
            }, function(result)
                if result[1] then
                    datatable = json.decode(result[1].clothes)
                    TriggerClientEvent("murphy_clothes:clotheitem",_source, datatable, outfit_id)
                else
                    TriggerClientEvent("murphy_notify:NotifyLeft", _source, "Clothes", "Clothes are torn !", "menu_textures", "menu_icon_cross", 3000)

                end
            end)
    end)

    Citizen.CreateThread(function ()
        Wait(1000)
        for k, v in pairs(Config.SingleItemCategory) do
            CORE.Functions.CreateUseableItem(k, function(source, item)
                local _source = source
                local Player = CORE.Functions.GetPlayer(_source)
                if not Player.Functions.GetItemByName(item.name) then return end

                for _, value in pairs(item.info.meta.clothes) do
                    local cat = value.cat
                    local model = value.model
                    local texture = value.texture
                    TriggerClientEvent("murphy_clothes:itemclothes", _source, cat, model, texture)
                end
            end)
        end
    end)

    RegisterServerEvent('murphy_clothes:LoadSkin', function(male)
        local _source = source
        local player = CORE.Functions.GetPlayer(_source)
        while not player do
            player = CORE.Functions.GetPlayer(_source)
            Wait(1)
        end
        local user = CORE.Functions.GetPlayer(_source).PlayerData
            MySQL.query("SELECT * FROM playerskins WHERE `citizenid`=@citizenid;", {citizenid = user.citizenid}, function(skins)
                if skins[1] then
                    local skin = skins[1].skin
                    local decoded = json.decode(skin)
                    local body, legs = FindBody(male, decoded)
                    local data = {bodies_upper = body, bodies_lower = legs}
                    TriggerClientEvent("murphy_clothes:GetSkin", _source, data)
                end
            end)
            TriggerEvent("murphy_clothes:retrieveClothes", GetCharIdentifier(_source), function(result)
                if result then
                    local clothes = json.decode(result.clothes)
                    local hairs = json.decode(result.hairs)
                    local skin = json.decode(result.skin)
                    if hairs then
                        for k, v in pairs(hairs) do
                            clothes[k] = v
                        end
                    end
                    TriggerClientEvent("murphy_clothes:GetLoadSkin", _source, clothes, skin)
                else
                    TriggerClientEvent("murphy_clothes:GetLoadSkin", _source, {}, skin)
                end
            end)
    end)

    RegisterServerEvent('murphy_clothes:LoadSkinCharacter', function(male, ped, charid)
        local _source = source
            MySQL.query("SELECT * FROM playerskins WHERE `citizenid`=@citizenid;", {citizenid = charid}, function(skins)
                if skins[1] then
                    local skin = skins[1].skin
                    local decoded = json.decode(skin)
                    local body, legs = FindBody(male, decoded)
                    local data = {bodies_upper = body, bodies_lower = legs}
                    TriggerClientEvent("murphy_clothes:GetSkin", _source, data)
                end
            end)
            TriggerEvent("murphy_clothes:retrieveClothes", charid, function(result)
                if result then
                    local clothes = json.decode(result.clothes)
                    local hairs = json.decode(result.hairs)
                    local skin = json.decode(result.skin)
                    if hairs then
                        for k, v in pairs(hairs) do
                            clothes[k] = v
                        end
                    end
                    TriggerClientEvent("murphy_clothes:GetLoadSkinCharacter", _source, ped, clothes, skin)
                else
                    TriggerClientEvent("murphy_clothes:GetLoadSkinCharacter", _source, ped, {}, skin)
                end
            end)
    end)

    ---- TriggerServerEvent('murphy_clothes:LoadSkinCharacter', isPedMale(ped), ped, charid)

    local ComponentsFemale = {}
    local ComponentsMale = {}
    for i, v in pairs(ComponentsBody) do
        if v.category_hashname == "BODIES_LOWER" or v.category_hashname == "BODIES_UPPER" or v.category_hashname ==
            "heads" or v.category_hashname == "hair" or v.category_hashname == "teeth" or v.category_hashname == "eyes" then
            if v.ped_type == "female" and v.is_multiplayer and v.hashname ~= "" then
                if ComponentsFemale[v.category_hashname] == nil then
                    ComponentsFemale[v.category_hashname] = {}
                end
                table.insert(ComponentsFemale[v.category_hashname], v.hash)
            elseif v.ped_type == "male" and v.is_multiplayer and v.hashname ~= "" then
                if ComponentsMale[v.category_hashname] == nil then
                    ComponentsMale[v.category_hashname] = {}
                end
                table.insert(ComponentsMale[v.category_hashname], v.hash)
            end
        end
    end
    

    function FindBody(male, data)
        local output = GetSkinColorFromBodySize(tonumber(data.body_size or 1), tonumber(data.skin_tone or 1))
        local head
        local headNum = math.ceil((data.head or 1)/6)
        if male then
            head = GetHashHead(true,headNum,data.skin_tone)
            torso = ComponentsMale["BODIES_UPPER"][output]
            legs = ComponentsMale["BODIES_LOWER"][output]
        else
            head = GetHashHead(false,headNum,data.skin_tone)
            torso = ComponentsFemale["BODIES_UPPER"][output]
            legs = ComponentsFemale["BODIES_LOWER"][output]
        end
    end
    function GetHashHead(aMale,num,color)
        color = color or 1
        num = num or 1
        if color == 1 then color = 1
        elseif color == 2 then color = 4
        elseif color == 3 then color = 3
        elseif color == 4 then color = 5
        elseif color == 5 then color = 2
        elseif color == 6 then color = 6
        end
        if aMale then
            if num == 16 then num = 18
                elseif num == 17 then num = 21
                elseif num == 18 then num = 22
                elseif num == 19 then num = 25
                elseif num == 20 then num = 28
                end
            else
                if num == 17 then num = 20
                elseif num == 18 then num = 22
                elseif num == 19 then num = 27
                elseif num == 20 then num = 28
            end
        end
        local suffix = ("%03d"):format(num or 1)..'_V_'..("%03d"):format(color or 1)
        local sex = (aMale == true) and "M" or "F"
        return GetHashKey(('CLOTHING_ITEM_%s_HEAD_%s'):format(sex,suffix))
    end

    function GetSkinColorFromBodySize(body, color)
        if body == 1 then
            if color == 1 then
                return 7
            elseif color == 2 then
                return 10
            elseif color == 3 then
                return 9
            elseif color == 4 then
                return 11
            elseif color == 5 then
                return 8
            elseif color == 6 then
                return 12
            end
        elseif body == 2 then
            if color == 1 then
                return 1
            elseif color == 2 then
                return 4
            elseif color == 3 then
                return 3
            elseif color == 4 then
                return 5
            elseif color == 5 then
                return 2
            elseif color == 6 then
                return 6
            end
        elseif body == 3 then
            if color == 1 then
                return 13
            elseif color == 2 then
                return 16
            elseif color == 3 then
                return 15
            elseif color == 4 then
                return 17
            elseif color == 5 then
                return 14
            elseif color == 6 then
                return 18
            end
        elseif body == 4 then
            if color == 1 then
                return 19
            elseif color == 2 then
                return 22
            elseif color == 3 then
                return 21
            elseif color == 4 then
                return 23
            elseif color == 5 then
                return 20
            elseif color == 6 then
                return 24
            end
        elseif body == 5 then
            if color == 1 then
                return 25
            elseif color == 2 then
                return 28
            elseif color == 3 then
                return 27
            elseif color == 4 then
                return 29
            elseif color == 5 then
                return 26
            elseif color == 6 then
                return 30
            end
        elseif body == 6 then
            if color == 1 then
                return 31
            elseif color == 2 then
                return 34
            elseif color == 3 then
                return 33
            elseif color == 4 then
                return 35
            elseif color == 5 then
                return 32
            elseif color == 6 then
                return 36
            end
        end
    end
end
