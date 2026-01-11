if Config.framework == "REDEMRP2k23" then
    Inventory = {}

    TriggerEvent("redemrp_inventory:getData", function (data)
        Inventory = data
    end)

    local RedEM = exports["redem_roleplay"]:RedEM()
    
    
    function GetCharJob(targetID)
        local user = RedEM.GetPlayer(targetID)
        if user then 
            job = RedEM.GetPlayer(targetID).job
        else job = nil end
        return job
    end

    function GetCharJobGrade(targetID) 
        local user = RedEM.GetPlayer(targetID)
        if user then 
            jobgrade = RedEM.GetPlayer(targetID).jobgrade
        else jobgrade = nil end
        return jobgrade
    end
    
    function GetCharIdentifier(targetID)
        return RedEM.GetPlayer(targetID).citizenid
    end
    
    function GetCharFirstname(targetID)
        return RedEM.GetPlayer(targetID).firstname
    end
    
    function GetCharLastname(targetID)
        return RedEM.GetPlayer(targetID).lastname
    end
    
    function GetCharMoney(targetID)
        return RedEM.GetPlayer(targetID).money
    end
    
    function RemoveCurrency(targetID, amount)
        RedEM.GetPlayer(targetID).RemoveMoney(tonumber(amount))
    end

    function AddCurrency(targetID, amount)
        RedEM.GetPlayer(targetID).AddMoney(tonumber(amount))
    end
    
    function GetCharGroup(targetID)
        return RedEM.GetPlayer(targetID).group
    end
    
    function GiveItem(src, item, amount, meta)
        local _meta = meta
        local ItemData = Inventory.getItem(src, item, _meta)
        local result = ItemData.AddItem(amount)
        return result
    end
    
    function RemoveItem(src, item, amount, meta)
        local _meta = meta
        local ItemData = Inventory.getItem(src, item, _meta)
        local result = ItemData.RemoveItem(amount)
        return result
    end

    function GetItemAmount(src, item)
        local ItemData = Inventory.getItem(src, item)
        return ItemData.ItemAmount
    end

    function OpenStash(src, stash, weight)
        TriggerClientEvent("redemrp_inventory:OpenStash", src, stash, weight)
    end


    RegisterServerEvent("RegisterUsableItem:"..Config.OutfitItem)
    AddEventHandler("RegisterUsableItem:"..Config.OutfitItem, function(source, _data)
        local _source = source
        local outfit_id = tonumber(_data.meta.outfit_id)
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
            RegisterServerEvent("RegisterUsableItem:"..k)
            AddEventHandler("RegisterUsableItem:"..k, function(source, _data)
                local _source = source
                for _, value in pairs(_data.meta.clothes) do
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
        local user = RedEM.GetPlayer(_source)
        while not user do
            user = RedEM.GetPlayer(_source)
            Wait(1)
        end

    end)

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

    function GetBodyCurrentComponentHash (name)
        local hash
            local id = LoadedComponents[name]
    
            if not id then
                return
            end
            if IsPedMale(PlayerPedId()) then
                if ComponentsMale[name] ~= nil then
                    hash = ComponentsMale[name][id]
                end
            else
                if ComponentsFemale[name] ~= nil then
                    hash = ComponentsFemale[name][id]
                end
            end
            return hash
        end
    
    function FindBody(male, data)
        local output = GetSkinColorFromBodySize(tonumber(data.body_size), tonumber(data.skin_tone))
        local torso
        local legs
        if male then
            if tonumber(data.skin_tone) == 1 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc08_c0_000_ab")
            elseif tonumber(data.skin_tone) == 2 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc03_c0_000_ab")
            elseif tonumber(data.skin_tone) == 3 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc02_c0_000_ab")
            elseif tonumber(data.skin_tone) == 4 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc04_c0_000_ab")
            elseif tonumber(data.skin_tone) == 5 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("MP_head_mr1_sc01_c0_000_ab")
            elseif tonumber(data.skin_tone) == 6 then
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("MP_head_mr1_sc05_c0_000_ab")
            else
                torso = ComponentsMale["BODIES_UPPER"][output]
                legs = ComponentsMale["BODIES_LOWER"][output]
                texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc02_c0_000_ab")
            end
    
        else
            if tonumber(data.skin_tone) == 1 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab")
            elseif tonumber(data.skin_tone) == 2 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc03_c0_000_ab")
            elseif tonumber(data.skin_tone) == 3 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc02_c0_000_ab")
            elseif tonumber(data.skin_tone) == 4 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc04_c0_000_ab")
            elseif tonumber(data.skin_tone) == 5 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("MP_head_fr1_sc01_c0_000_ab")
            elseif tonumber(data.skin_tone) == 6 then
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc05_c0_000_ab")
            else
                torso = ComponentsFemale["BODIES_UPPER"][output]
                legs = ComponentsFemale["BODIES_LOWER"][output]
                texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc02_c0_000_ab")
    
            end
    
        end
        return torso, legs
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
        else
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
        end
    
    end
end