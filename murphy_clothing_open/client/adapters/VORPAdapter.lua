if Config.framework == 'vorp' then
    RegisterNetEvent('vorp:SelectedCharacter')
    AddEventHandler('vorp:SelectedCharacter', function()
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
            Wait(1000)
    if type(baseskin) ~= "table" then
        baseskin = {}
    end
    
    -- Capture base body parts with their original albedo (skin color)
    local ped = PlayerPedId()
    local equipped = GetCategoriesEquiped(ped)
    
    if not baseskin["bodies_upper"] or baseskin["bodies_upper"] == 0 then
        baseskin["bodies_upper"] = GetComponentEquiped(ped, "bodies_upper")
        -- Store original albedo to preserve skin color
        if equipped[`bodies_upper`] then
            local index = equipped[`bodies_upper`].index
            local _, albedo, _, _ = GetMetaPedAssetGuids(ped, index)
            baseskin["bodies_upper_albedo"] = albedo
        end
    end
    
    if not baseskin["bodies_lower"] or baseskin["bodies_lower"] == 0 then
        baseskin["bodies_lower"] = GetComponentEquiped(ped, "bodies_lower")
        -- Store original albedo to preserve skin color
        if equipped[`bodies_lower`] then
            local index = equipped[`bodies_lower`].index
            local _, albedo, _, _ = GetMetaPedAssetGuids(ped, index)
            baseskin["bodies_lower_albedo"] = albedo
        end
    end
    
            print(string.format("Base skin loaded: Upper Body = %s (albedo: %s), Lower Body = %s (albedo: %s)", 
                tostring(baseskin["bodies_upper"]), tostring(baseskin["bodies_upper_albedo"]),
                tostring(baseskin["bodies_lower"]), tostring(baseskin["bodies_lower_albedo"])))
            if datatable then
                local loadclothes = false
                for k, v in pairs(datatable) do
                    if v.model > 0 then
                        loadclothes = true
                        break
                    end
                end
                if loadclothes then
                    TriggerEvent("murphy_clothes:clotheitem",datatable, id)
                end
            end
        end)
    end)
    
        RegisterNetEvent('vorp_core:Client:OnPlayerRevive')
        AddEventHandler('vorp_core:Client:OnPlayerRevive', function ()
            Wait(500)
            Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
                if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
                if datatable then
                    local loadclothes = false
                    for k, v in pairs(datatable) do
                        if v.model > 0 then
                            loadclothes = true
                            break
                        end
                    end
                    if loadclothes then
                        TriggerEvent("murphy_clothes:clotheitem",datatable, id)
                    end
                end
            end)
        end)

        RegisterNetEvent('vorp_core:Client:OnPlayerRespawn')
        AddEventHandler('vorp_core:Client:OnPlayerRespawn', function ()
            Wait(500)
            Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
                if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
                if datatable then
                    local loadclothes = false
                    for k, v in pairs(datatable) do
                        if v.model > 0 then
                            loadclothes = true
                            break
                        end
                    end
                    if loadclothes then
                        TriggerEvent("murphy_clothes:clotheitem",datatable, id)
                    end
                end
            end)
        end)


        RegisterNetEvent("murphy_clothes:outfitchanged", function ()
            --- your corde
        end)
end