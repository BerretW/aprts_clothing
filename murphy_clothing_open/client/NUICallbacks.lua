baseHeading = nil
angleOffset = nil
currentH, currentZ, currentR = 0, 0, 0
RegisterNUICallback("closeoutfitmenu", function(body, resultCallback)
    if MannequinPed then
        DeletePed(MannequinPed)
        MannequinPed = nil
        ClearPedTasks(PlayerPedId())
    else
        -- Restaurer WearableCache original
        if OldWearableCache then
            WearableCache = deepcopy(OldWearableCache)
            OldWearableCache = nil
        end
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
            if datatable and id then
                TriggerEvent("murphy_clothes:clotheitem", datatable, id)
            end
        end)
        ClearPedTasks(PlayerPedId())
    end
    OpenOutfitListMenu(false)
    OpenShopMenu(false)
    OutfitPrice = 0
    if lamp or lamp2 then
        DeleteObject(lamp)
        DeleteObject(lamp2)
        lamp = nil
        lamp2 = nil
    end
end)

local playinganim = false
local currentcategory = nil

RegisterNUICallback("itemValue", function(body, resultCallback)
    local value = tonumber(body.item)
    local category = body.category
    local menu = body.menu
    if category == "bodies_upper" or category == "bodies_lower" then
        if value then
            ChangeSkin(category, value)
            if value > #WearableStates[SelectedGender][category] then
                UpdateContextualDatas(WearableCache[category].model, category)
            else
                UpdateContextualDatas(0)
            end
            -- Change(value, category, "model")
        end
    else
        if value then
            if ClothesCache[category].model > value then
                PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
            else
                PlaySound("Amount_Increase", "HUD_Donate_Sounds")
            end
            Change(value, category, "model")
            UpdateContextualDatas(value, category)
            if not playinganim then
                playinganim = true
                ChangeClothesAnim()
                playinganim = false
                IdleAnim()
            end
        else
            if ClothesCache[category].model == 0 then
                if ContextualDataOn then
                    ContextualDataOn = false
                    PlaySound("SELECT", "HUD_PLAYER_MENU")
                    SendNUIMessage(
                        {
                            type = "hidecontextualDatas",

                        }
                    )
                end
            elseif ClothesCache[category].model > 0 then
                -- if ContextualDataOn == false then
                UpdateContextualDatas(ClothesCache[category].model, category)
                -- end
            end
            if currentcategory ~= category then
                PlaySound("Amount_Increase", "HUD_Donate_Sounds")
            end
        end
        currentcategory = category
        CalculatePrice()
    end
end)

RegisterNUICallback("varValue", function(body, resultCallback)
    local value = tonumber(body.item)
    local category = body.category
    local reference
    if type(ClothesCache[category].texture) == "table" then
        reference = ClothesCache[category].texture.palette
    else
        reference = ClothesCache[category].texture or 0
    end
    if reference > value then
        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
    else
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
    end
    if category == "bodies_upper" or category == "bodies_lower" then
        if value then
            ChangeSkin(category, WearableCache[category].model, "variants", value)
        end
    else
        Change(ClothesCache[category].model, category, "variants", value)
    end
end)

RegisterNUICallback("tintValue", function(body, resultCallback)
    local value = tonumber(body.value)
    local tintId = tonumber(body.tintId)
    local category = body.category
    local reference
    if type(ClothesCache[category].texture) == "table" then
        reference = ClothesCache[category].texture["tint" .. tostring(tintId - 1)]
    else
        reference = 0
    end
    if reference > value then
        PlaySound("Amount_Decrease",
            "HUD_Donate_Sounds")
    else
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
    end
    if category == "bodies_upper" or category == "bodies_lower" then
        if value then
            ChangeSkin(category, WearableCache[category].model, tintId, value)
        end
    else
        Change(ClothesCache[category].model, category, tintId, value)
    end
end)


RegisterNUICallback("cameraChange", function(body, resultCallback)
    local cam = body.cameraName
    local value = tonumber(body.value)
    if cam == "H" then
        -- Handle H camera change
        c_offset = scale(value, 1, 360, -0.8, 0.60)
        camera(c_zoom, c_offset)
        local focus = #(GetCamCoord(ClothingCamera) - GetEntityCoords(PlayerPedId()))
        SetCamFocusDistance(ClothingCamera, focus)
        if currentH >= value then
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Decrease",
                "HUD_Donate_Sounds")
        end
        currentH = value
    end

    if cam == "Z" then
        CamFov = scale(value, 1, 360, 10, 40)
        SetCamFov(ClothingCamera, CamFov)
        local focus = #(GetCamCoord(ClothingCamera) - GetEntityCoords(PlayerPedId()))
        SetCamFocusDistance(ClothingCamera, focus)
        if currentZ >= value then
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Decrease",
                "HUD_Donate_Sounds")
        end
        currentZ = value
    end

    if cam == "R" then
        local ped = PlayerPedId()
        if MannequinPed then ped = MannequinPed end
        local x, y, z = table.unpack(GetEntityCoords(ped))

        -- Initialiser le heading de base si pas encore fait
        if not baseHeading then
            baseHeading = GetEntityHeading(ped)
            -- Stocker l'offset initial pour que 180 corresponde à baseHeading
            angleOffset = 180 - baseHeading
        end

        -- Calculer le heading cible directement
        local targetHeading = (value - angleOffset) % 360
        local rad = math.rad(targetHeading)

        -- Calculer un point à 1 unité devant le ped selon le heading voulu
        local distance = 1.0
        local targetX = x + (math.sin(-rad) * distance)
        local targetY = y + (math.cos(-rad) * distance)

        TaskTurnPedToFaceCoord(ped, targetX, targetY, z, 0)
        local focus = #(GetCamCoord(ClothingCamera) - GetEntityCoords(PlayerPedId()))
        SetCamFocusDistance(ClothingCamera, focus)
        if currentR >= value then
            PlaySound("Amount_Increase", "HUD_Donate_Sounds")
        else
            PlaySound("Amount_Decrease",
                "HUD_Donate_Sounds")
        end
        currentR = value
    end
end)


------ OUTFIT LIST ------
RegisterNUICallback("createOutfit", function(body, resultCallback)
    local name = body.outfitName
    -- Ensure UTF-8 encoding is preserved for special characters
    if name then
        name = tostring(name)
    end
    local price = CalculatePrice()
    local ped = PlayerPedId()
    local gender = false
    if MannequinPed then ped = MannequinPed end
    if IsPedMale(ped) then gender = true end
    Callback.triggerServer('murphy_clothing:SaveOutfit', function(result, outfitid)
        if result then
            TriggerEvent("murphy_clothes:clotheitem", ClothesCache, outfitid)
            PlaySound("PURCHASE", "Ledger_Sounds")
            if WearableCache["bodies_upper"] or WearableCache["bodies_lower"] then
                Callback.triggerServer('murphy_clothing:SaveWearable', function(result)
                end, outfitid, WearableCache)
            end
            -- Mettre à jour OldWearableCache car l'outfit est maintenant sauvegardé
            OldWearableCache = deepcopy(WearableCache)
            Wait(200)
            OpenShopMenu(false)
        else
            PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        end
    end, ClothesCache, name, price, gender)
end)

RegisterNetEvent('murphy_clothing:SaveClothesCreator', function()
    local name = "Default"
    local ped = PlayerPedId()
    local gender = false
    if IsPedMale(ped) then gender = true end
    print(json.encode(ClothesCache))
    Callback.triggerServer('murphy_clothing:SaveOutfit', function(result, outfitid)
        if result then
            TriggerEvent("murphy_clothes:clotheitem", ClothesCache, outfitid)
            PlaySound("PURCHASE", "Ledger_Sounds")
            if not MannequinPed then
                if WearableCache["bodies_upper"] or WearableCache["bodies_lower"] then
                    Callback.triggerServer('murphy_clothing:SaveWearable', function(result)
                    end, outfitid, WearableCache)
                end
            end
            Wait(200)
            if CreatorMode == true then

            else
                OpenShopMenu(false)
            end
        else
            PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        end
    end, ClothesCache, name, 0, gender)
end)

RegisterNUICallback("saveOutfit", function(body, resultCallback)
    local outfitid = body.outfitid
    local changes = false
    for k, v in pairs(MURPHY_ASSETS[SelectedGender]) do
        if k ~= "bodies_upper" and k ~= "bodies_lower" then
            if OldClothesCache[k].model then
                if OldClothesCache[k].model ~= ClothesCache[k].model then
                    changes = true
                    break
                end
            else
                if ClothesCache[k].model > 0 then
                    changes = true
                    break
                end
            end
        end
    end
    if not changes then
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    else
        local price = CalculatePrice() - OutfitPrice
        Callback.triggerServer('murphy_clothing:ModifyOutfit', function(result, data)
            if result then
                -- Save wearable data (bodies_upper/bodies_lower) along with the outfit
                if WearableCache["bodies_upper"] or WearableCache["bodies_lower"] then
                    Callback.triggerServer('murphy_clothing:SaveWearable', function(wearableResult)
                    end, outfitid, WearableCache)
                end
                -- Mettre à jour OldWearableCache car l'outfit est maintenant modifié et sauvegardé
                OldWearableCache = deepcopy(WearableCache)
                OpenShopMenu(false)
                PlaySound("PURCHASE", "Ledger_Sounds")
                Wait(200)
                TriggerEvent("murphy_clothes:clotheitem", data, outfitid)
            else
                PlaySound("UNAFFORDABLE", "Ledger_Sounds")
            end
        end, ClothesCache, outfitid, price)
    end
end)



RegisterNUICallback("createNewOutfit", function(body, resultCallback)
    RemoveAllClothesExceptEssentials(PlayerPedId())
    -- PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    OpenShopMenu(true)
end)

RegisterNUICallback("showOutfit", function(body, resultCallback)
    local id = body.outfit
    local playergender
    local mannequingender
    if not ProcessingMannequin then
        PlaySound("SELECT", "HUD_PLAYER_MENU")
        if IsPedMale(PlayerPedId()) then
            playergender = "male"
            mannequingender = "female"
        else
            playergender = "female"
            mannequingender = "male"
        end
        Callback.triggerServer('murphy_clothing:GetOutfit', function(datatable, gender)
            if datatable then
                -- Charger la tenue imm\u00e9diatement pour affichage
                if playergender ~= gender then
                    if not MannequinPed then
                        ProcessingMannequin = true
                        MannequinPed = SpawnMannequin(mannequingender)
                        ProcessingMannequin = false
                    end
                    SelectedGender = mannequingender
                    TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                else
                    if MannequinPed then
                        ProcessingMannequin = true
                        DeletePed(MannequinPed)
                        MannequinPed = nil
                        TaskGoToCoordAnyMeans(PlayerPedId(), OriginalCoords, 1.0, 0, false, 786603, 0)
                        canface = false
                        repeat
                            Wait(0)
                            local playerpos = GetEntityCoords(PlayerPedId())
                            local distance = #(playerpos - OriginalCoords)
                            if distance < 0.3 then
                                canface = true
                            end
                        until canface
                        TaskGoToCoordAnyMeans(PlayerPedId(), OriginalCoords, 1.0, 0, false, 786603, 0)
                        Wait(1000)
                        TaskTurnPedToFaceCoord(PlayerPedId(), GetCamCoord(ClothingCamera), -1)
                        TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                        ProcessingMannequin = false
                    else
                        TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                    end
                end
            end
        end, id)
    else
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    end
end)

RegisterNUICallback("modifyOutfit", function(body, resultCallback)
    local id = body.outfit
    local price = body.price
    local playergender = "female"
    local mannequingender = "female"
    if not ProcessingMannequin then
        if IsPedMale(PlayerPedId()) then
            playergender = "male"
            mannequingender = "male"
        end
        Callback.triggerServer('murphy_clothing:GetOutfit', function(datatable, gender)
            if datatable then
                OutfitPrice = price
                
                -- Charger la tenue AVANT d'ouvrir le menu pour que WearableCache soit correct
                if playergender ~= gender then
                    if not MannequinPed then
                        ProcessingMannequin = true
                        MannequinPed = SpawnMannequin(mannequingender)
                        ProcessingMannequin = false
                    end
                    SelectedGender = mannequingender
                    TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                else
                    if MannequinPed then
                        ProcessingMannequin = true
                        DeletePed(MannequinPed)
                        MannequinPed = nil
                        TaskGoToCoordAnyMeans(PlayerPedId(), OriginalCoords, 1.0, 0, false, 786603, 0)
                        canface = false
                        repeat
                            Wait(0)
                            local playerpos = GetEntityCoords(PlayerPedId())
                            local distance = #(playerpos - OriginalCoords)
                            if distance < 0.3 then
                                canface = true
                            end
                        until canface
                        TaskGoToCoordAnyMeans(PlayerPedId(), OriginalCoords, 1.0, 0, false, 786603, 0)
                        Wait(1000)
                        TaskTurnPedToFaceCoord(PlayerPedId(), GetCamCoord(ClothingCamera), -1)
                        TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                        ProcessingMannequin = false
                    else
                        TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                    end
                end
                
                -- Attendre que WearableCache soit charg\u00e9 avant d'ouvrir le menu
                Wait(500)
                OpenShopMenu(true, id)
                Wait(300)
                CalculatePrice()
            end
        end, id)
    else
        PlaySound("UNAFFORDABLE", "Ledger_Sounds")
    end
end)

RegisterNUICallback("recoverOutfit", function(body, resultCallback)
    local id = body.outfit
    local name = body.name
    local price = body.price
    Callback.triggerServer('murphy_clothing:GiveOutfit', function(result)
        if result then
            OpenOutfitListMenu(false)
            PlaySound("PURCHASE", "Ledger_Sounds")
        else
            PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        end
    end, id, name, price)
end)

RegisterNUICallback("deleteOutfit", function(body, resultCallback)
    local id = body.outfit
    Callback.triggerServer('murphy_clothing:DeleteOutfit', function(result)
        if result then
            OpenOutfitListMenu(true)
        else
            PlaySound("UNAFFORDABLE", "Ledger_Sounds")
        end
    end, id)
end)

RegisterNUICallback("canceldelete", function(body, resultCallback)
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
end)

RegisterNUICallback("backToOutfitList", function(body, resultCallback)
    if CreatorMode == true then
        if lamp or lamp2 then
            DeleteObject(lamp)
            DeleteObject(lamp2)
            lamp = nil
            lamp2 = nil
        end
        CreatorLight = false
        SendNUIMessage(
            {
                type = "closeOutfitMenu",

            }
        )
        PlaySound("INFO_HIDE", "HUD_SHOP_SOUNDSET")
        -- ClearPedTasks(PlayerPedId())
        ContextualDataOn = false
        baseHeading = nil
        angleOffset = nil
        currentH, currentZ, currentR = 0, 0, 0
        -- KillCamera()
        CurrentPrice = 0
        Wait(1000)
        TriggerEvent("murphy_creator:BackFromClothing")
        SetNuiFocus(false, false)
    else
        OpenShopMenu(false)
    end
    -- FirstinitCreator = false
    CreatorMode = false
    PlaySound("BACK", "HUD_SHOP_SOUNDSET")
end)

RegisterNUICallback("resetOutfit", function(body, resultCallback)
    local ped = PlayerPedId()
    if MannequinPed then ped = MannequinPed end
    
    -- Restaurer WearableCache original (bodies_upper/lower)
    if OldWearableCache then
        WearableCache = deepcopy(OldWearableCache)
        -- Réappliquer les bodies originaux
        for category, value in pairs(WearableCache) do
            if (category == "bodies_upper" or category == "bodies_lower") and value.model and value.model > 0 then
                local gender = "female"
                if IsPedMale(ped) then gender = "male" end
                if value.texture and value.texture.palette then
                    ChangeSkin(category, value.model, "variants", value.texture.palette, ped)
                else
                    ChangeSkin(category, value.model, nil, nil, ped)
                end
            end
        end
    end
    
    RemoveAllClothesExceptEssentials(ped)
    local gender = "female"
    if IsPedMale(ped) then gender = "male" end
    for k, v in pairs(MURPHY_ASSETS[gender]) do
        ClothesCache[k] = {}
        ClothesCache[k].model = 0
        ClothesCache[k].texture = 0
    end
    CalculatePrice()
    PlaySound("UNAFFORDABLE", "Ledger_Sounds")
end)

RegisterNUICallback("createMaleOutfit", function(body, resultCallback)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    SelectedGender = "male"
    MannequinPed = SpawnMannequin("male")
    OpenShopMenu(true)
    Wait(4000)
    RequestAnimDict("script_common@tailor_shop@camp")
    while not HasAnimDictLoaded("script_common@tailor_shop@camp") do
        Citizen.Wait(0)
    end
    local idle = { "idle_v1", "idle_v2", "idle" }
    local selectedidle = math.random(1, #idle)
    repeat selectedidle = math.random(1, #idle) until selectedidle ~= lastidle
    if MannequinPed then
        TaskPlayAnim(PlayerPedId(), "script_common@tailor_shop@camp", idle[selectedidle], 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    end
end)

RegisterNUICallback("createFemaleOutfit", function(body, resultCallback)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    SelectedGender = "female"
    MannequinPed = SpawnMannequin("female")
    OpenShopMenu(true)
    Wait(4000)
    RequestAnimDict("script_common@tailor_shop@camp")
    while not HasAnimDictLoaded("script_common@tailor_shop@camp") do
        Citizen.Wait(0)
    end
    local idle = { "idle_v1", "idle_v2", "idle" }
    local selectedidle = math.random(1, #idle)
    repeat selectedidle = math.random(1, #idle) until selectedidle ~= lastidle
    if MannequinPed then
        TaskPlayAnim(PlayerPedId(), "script_common@tailor_shop@camp", idle[selectedidle], 1.0, 1.0, -1, 1, 0, 0, 0, 0)
    end
end)



RegisterNUICallback("changeMyOutfitVar", function(body, resultCallback)
    local category = body.category
    local menu = body.menu
    local value = tonumber(body.item)
    if not WearableCache[category] then
        WearableCache[category] = { model = 0 }
    end
    if WearableCache[category].model > value then
        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
    else
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
    end
    if category == "bodies_upper" or category == "bodies_lower" then
        if value then
            ChangeSkin(category, value)
            UpdateContextualDatas(WearableCache[category].model, category)
        end
    else
        ChangeWearable(category, value)
    end
end)

RegisterNUICallback("invertActiveCategory", function(body, resultCallback)
    local category = body.category
    if Config.Removecategories[category] then
        for k, v in pairs(Config.Removecategories[category]) do
            if ClothesCache[v] then
                TriggerEvent("murphy_clothes:itemclothes", v, ClothesCache[v].model, ClothesCache[v].texture)
            end
        end
    end
end)

RegisterNUICallback("saveMyOutfit", function(body, resultCallback)
    local outfitid = body.outfitId
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    Callback.triggerServer('murphy_clothing:SaveWearable', function(result)
        if result then
            -- Mettre à jour OldWearableCache car les changements sont maintenant sauvegardés
            OldWearableCache = deepcopy(WearableCache)
        end
    end, outfitid, WearableCache)
end)

RegisterNUICallback("resetMyOutfit", function(body, resultCallback)
    PlaySound("SELECT", "HUD_SHOP_SOUNDSET")
    -- Restaurer WearableCache original
    if OldWearableCache then
        WearableCache = deepcopy(OldWearableCache)
        -- Réappliquer les bodies originaux
        local ped = PlayerPedId()
        for category, value in pairs(WearableCache) do
            if (category == "bodies_upper" or category == "bodies_lower") and value.model and value.model > 0 then
                local gender = "female"
                if IsPedMale(ped) then gender = "male" end
                if value.texture and value.texture.palette then
                    ChangeSkin(category, value.model, "variants", value.texture.palette, ped)
                else
                    ChangeSkin(category, value.model, nil, nil, ped)
                end
            end
        end
    end
    Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
        if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
        if datatable then
            TriggerEvent("murphy_clothes:clotheitem", datatable, id)
        else
        end
    end)
end)

RegisterNUICallback("isNaked", function(body, resultCallback)
    local naked = body.naked
    if naked == "true" then
        RemoveAllClothesExceptEssentials(PlayerPedId())
        PlaySound("Amount_Increase", "HUD_Donate_Sounds")
    elseif naked == "false" then
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if datatable then
                TriggerEvent("murphy_clothes:clotheitem", datatable, id)
            end
        end)
        PlaySound("Amount_Decrease", "HUD_Donate_Sounds")
    end
end)


RegisterNUICallback("closeMyOutfitMenu", function(body, resultCallback)
    -- Restaurer WearableCache original si non sauvegardé
    if OldWearableCache then
        WearableCache = deepcopy(OldWearableCache)
        OldWearableCache = nil
    end
    OpenWearableMenu(false)
    -- Recharger les vêtements du serveur pour restaurer l'apparence originale
    Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
        if datatable then
            TriggerEvent("murphy_clothes:clotheitem", datatable, id)
        end
    end)
end)

local handsup = false
RegisterNUICallback("handsup", function(body, resultCallback)
    local anim = {
        [1] = { dict = "mech_loco_f@generic@reaction@handsup@unarmed@normal", anim = "loop" },
        [2] = { dict = "mech_loco_f@generic@reaction@handsup@unarmed@tough", anim = "loop" },
        [3] = { dict = "mech_loco_m@generic@reaction@handsup@unarmed@normal", anim = "loop" },
        [4] = { dict = "mech_loco_m@generic@reaction@handsup@unarmed@tough", anim = "loop" },
        [5] = { dict = "script_common@other@unapproved", anim = "guard_handsup_loop" },
        [6] = { dict = "script_proc@robberies@shop@strgen", anim = "handsup_register" },
    }
    if not handsup then
        handsup = true
        local key = math.random(1, #anim)
        RequestAnimDict(anim[key].dict)
        while not HasAnimDictLoaded(anim[key].dict) do
            Citizen.Wait(0)
        end
        TaskPlayAnim(PlayerPedId(), anim[key].dict, anim[key].anim, 1.0, -1.0, -1, 25, 0, true, 0, false, 0, false)
    else
        handsup = false
        ClearPedTasks(PlayerPedId())
    end
end)
