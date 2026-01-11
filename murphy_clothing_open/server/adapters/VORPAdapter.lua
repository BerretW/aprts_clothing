if Config.framework == 'vorp' then
    VorpInv = exports.vorp_inventory:vorp_inventoryApi()
    
    local VorpCore = {}
    
    TriggerEvent("getCore",function(core)
        VorpCore = core
    end)
    
    
    function GetCharJob(targetID) 
        local user = VorpCore.getUser(targetID)
        if user then 
            job = VorpCore.getUser(targetID).getUsedCharacter.job
        else job = nil end
        return job
    end

    function GetCharJobGrade(targetID) 
        local user = VorpCore.getUser(targetID)
        if user then 
            job = VorpCore.getUser(targetID).getUsedCharacter.jobGrade
        else job = nil end
        return job
    end
    
    function GetCharIdentifier(targetID)
        local user = VorpCore.getUser(targetID)
        if user then 
            charid = VorpCore.getUser(targetID).getUsedCharacter.charIdentifier
        else charid = nil end
        return charid
    end
    
    function GetCharFirstname(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.firstname
    end
    
    function GetCharLastname(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.lastname
    end
    
    function GetCharMoney(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.money
    end
    
    function RemoveCurrency(targetID, amount)
        VorpCore.getUser(targetID).getUsedCharacter.removeCurrency(0, amount)
    end
    
    function GetCharGroup(targetID)
        return VorpCore.getUser(targetID).getUsedCharacter.group
    end

    function GiveItem(src, item, amount, meta)
        local _meta = meta
        local result = VorpInv.addItem(src, item, amount, _meta)
        return result
    end

    function RemoveItem(src, item, amount, meta)
        local _meta = meta
        local result = VorpInv.subItem(src, item, amount, _meta)
        return result
    end

    function GetItemAmount(src, item)
        local ItemData = VorpInv.getItemCount(src, item)
        return ItemData
    end

    function OpenStash(src, stash, weight)
        if exports.vorp_inventory:isCustomInventoryRegistered(stash) then
            VorpInv.OpenInv(src, stash)
        else
            --- register custom inventory
            exports.vorp_inventory:registerInventory({ 
            id = stash,
            name = stash,
            limit = 0,
            acceptWeapons = true,
            shared = true,
            limitedItems = {},
            ignoreItemStackLimit = false,
            whitelistItems = false,
            PermissionTakeFrom = {},
            PermissionMoveTo = {},
            UsePermissions = false,
            UseBlackList = false,
            BlackListItems = {},
            whitelistWeapons = false,
            limitedWeapons = {} 
        })
        VorpInv.OpenInv(src, stash)
        end
    end

    VorpInv.RegisterUsableItem(Config.OutfitItem, function (_data)
        local data = _data
        local _source = data.source
        local outfit_id = data.item.metadata.outfit_id
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
            VorpInv.RegisterUsableItem(k, function (_data)
                local data = _data
                local _source = data.source
                for _, value in pairs(_data.item.metadata.clothes) do
                    local cat = value.cat
                    local model = value.model
                    local texture = value.texture
                    TriggerClientEvent("murphy_clothes:itemclothes", _source, cat, model, texture)
                end
            end)
        end
    end)

    RegisterServerEvent('murphy_clothes:LoadSkin', function()
        local _source = source
        local charid = tonumber(GetCharIdentifier(_source))
        while not charid do
            charid = tonumber(GetCharIdentifier(_source))
            Wait(200)
        end
            MySQL.query("SELECT * FROM characters WHERE `charidentifier`=@charidentifier;", {charidentifier = charid}, function(skins)
                if skins[1] then
                    local skin = skins[1].skinPlayer
                    local decoded = json.decode(skin)
                    local data = {albedo = decoded.albedo, bodies_upper = decoded.BodyType, bodies_lower = decoded.LegsType}
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
                    TriggerClientEvent("murphy_clothes:GetLoadSkin", _source, clothes, skin)
                else
                    TriggerClientEvent("murphy_clothes:GetLoadSkin", _source, {}, skin)
                end
            end)
    end)

    RegisterNetEvent("vorpcharacter:reloadedskinlistener", function()
        local timer = 1000
        local src = source
        Wait(timer)
        TriggerClientEvent("murphy_clothes:LoadBasSkin", src)
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if datatable then
                local loadclothes = false
                for k, v in pairs(datatable) do
                    if v.model > 0 then
                        loadclothes = true
                        break
                    end
                end
                if loadclothes then
                    TriggerClientEvent("murphy_clothes:clotheitem",src, datatable, id)
                end
            end
        end, src)
      end)
end
