local menucategories = {
    male = {
        categories = { "head", "upper", "lower", "feets", "accs", "weapons", "admin" },
        head = {
            "hats", "masks", "eyewear", "headwear", "face_props",
            "hat_accessories", "masks_large"
        },

        upper = {
            "coats", "shirts_full", "lduvmjua_0x2b388a05", "vests", "suspenders",
            "unionsuits_full", "overalls_full", "shirts_full_overpants",
            "cloaks", "overalls_modular_uppers", "coats_closed", "outfits",
            "coats_heavy", "ponchos",
        },

        lower = {
            "pants", "overalls_modular_lowers",
            "dresses", "skirts", "unionsuit_legs"
        },

        feets = {
            "boots", "boot_accessories", "spats"
        },

        accs = {
            "neckerchiefs", "neckties", "gloves", "belts", "accessories",
            "badges", "satchels", "neckwear", "jewelry_necklaces",
            "jewelry_rings", "vest_accessories", "hair_accessories",
            "aprons", "coat_accessories", "chaps", "pants_accessories",
            "armor", "jewelry_bracelets", "wrist_bindings", "gauntlets",
            "ankle_bindings", "belt_buckles", "jewelry_rings_right",
            "jewelry_rings_left", "satchel_straps", "jewelry_earrings"
        },

        weapons = {
            "gunbelts", "holsters_right", "holsters_knife", "loadouts",
            "holsters_left", "holsters_crossdraw", "holsters_center",
            "gunbelt_accs", "holsters_quivers", "ammo_pistols"
        },

        admin = {
            "718708483", "1080070465", "tyyeqpea_0x5ad6c8a1",
            "hynnzeba_0x534c424e",
            "1572501618", "xvnliuia_0x625d7b14", "-822935952",
            "idntoqja_0xe85a1a4d", "-1816970959", "rheovufa_0x4a8a0b53",
            "lputhoya_0x7b78114c", "brhyqiua_0x1af71626",
            "sqwapmca_0x5b0f410e", "jjpzgvmc_0x22d33ac2",
            "ondqcrka_0xbc4255e3", "arbhwiba_0x2f725b6c",
            "dlzdyqba_0xd82c8dd3", "jmwhzgaa_0x106fe11f",
            "-801920077", "-363708904", "lvpmxtsa_0xb57244a4",
            "najrjqia_0x37b57629", "bctrhzba_0xcb350942",
            "-87047232", "916904447", "kpmcfucb_0xeb4b82d1",
            "-1373389517", "nrpnskza_0x3cadebb7", "-705203924",
            "cgvqvdaa_0xd4968e65", "wemtvpaa_0xa8fcd30e",
            "vfnqsfba_0x95ad5e2a", "464404356", "-1163401704",
            "2049190526", "118125201", "88372018",
            "upigupqa_0x5a536e23", "-1132439862", "609538240",
            "kqmlmpca_0x294e561e", "kkawrfba_0x202a8054",
            "777116858", "hyohcica_0xa1071d52", "ogdexlma_0xe8b5e43d",
            "-1783753551", "1022160959", "bloiioka_0x1e9e019b"
        }
    },
    female = {
        categories = { "head", "upper", "lower", "feets", "accs", "weapons", "admin" },
        head = {
            "hats", "headwear",
            "hair_accessories", "masks", "eyewear",
            "hat_accessories", "face_props"
        },

        upper = {
            "shirts_full", "lduvmjua_0x2b388a05", "nbtudvja_0x53b67599", "coats", "vests", "suspenders",
            "coats_closed", "overalls_full", "ponchos", "capes", "shawls", "cloaks", "corsets",
            "chemises", "outfits", "cnvfyaba_0xd7ae0d03", "gjrbmoma_0xcb39a6f4", "pnyvpusa_0x44f4c713",
            "ogoolgaa_0xecd61654",
            "gnuusvra_0x7024af8b", "oacpqvda_0x41292b6f", "ywkywwvb_0xe93b9f1b"
        },

        lower = {
            "skirts", "pants", "dresses", "spats",
            "overalls_full", "knickers", "stockings"
        },

        feets = {
            "boots", "boot_accessories"
        },

        accs = {
            "jewelry_necklaces", "gloves", "belts", "neckwear", "neckerchiefs", "neckties",
            "accessories", "jewelry_earrings", "jewelry_bracelets", "aprons",
            "gauntlets", "chaps", "satchels", "jewelry_rings_left",
            "wrist_bindings", "belt_buckles", "badges", "jewelry_rings_right",
            "ankle_bindings", "mbbwboia_0x42e8f927", "pants_accessories", "coat_accessories", "armor"
        },

        weapons = {
            "gunbelts", "loadouts", "holsters_right", "holsters_left",
            "holsters_center", "gunbelt_accs"
        },

        admin = {
            "833267460", "-808505712", "-234263672", "885415775",
            "2101323755", "-818624178", "-343684413", "2099925833",
            "-1783753551", "-272917581", "-1434819954",
            "hynnzeba_0x534c424e", "609538240", "-851097716", "-419539457",
            "-853084561", "-328758153",
            "1038525765", "758729615", "1314832239",
            "1557299516", "-94776482", "-705203924", "-2050673586",
            "-1191653202", "-347650877", "-1690877284", "-1018339117",
            "1356593691", "xvnliuia_0x625d7b14", "1382278837", "118125201",
            "-1680267930", "-1362238266", "-1301348568", "cgvqvdaa_0xd4968e65",
            "bctrhzba_0xcb350942", "najrjqia_0x37b57629", "913841068",
            "870137449", "arbhwiba_0x2f725b6c", "358502875",
            "idntoqja_0xe85a1a4d", "2044677326"
        }
    }
}

wearablecategories = {
    "hairs", "pants", "coats", "vests", "boots", "shirts_full", "neckties", "neckwear", "ponchos", "cloaks", "gloves"
}

Citizen.CreateThread(function()
    Wait(500)
    
    -- Filter NPC assets if Config.FilterNPCAssets is enabled
    if Config.FilterNPCAssets then
        for gender, categories in pairs(MURPHY_ASSETS) do
            for category, assets in pairs(categories) do
                local filteredAssets = {}
                for i, asset in ipairs(assets) do
                    -- Keep only assets without drawable field (non-NPC assets)
                    if not asset.drawable then
                        table.insert(filteredAssets, asset)
                    end
                end
                MURPHY_ASSETS[gender][category] = filteredAssets
            end
        end
    end
    
    -- Vérifie les catégories manquantes dans le menu
    for gender, value in pairs(menucategories) do
        -- Vérifie si la catégorie existe dans MURPHY_ASSETS
        for cat, data in pairs(value) do
            for _, gamecat in pairs(data) do
                if not MURPHY_ASSETS[gender][gamecat] then
                    -- print("Unknown category in menu: " .. gamecat .. " (gender: " .. gender .. ")")
                end
            end
        end

        -- Vérifie si des catégories de MURPHY_ASSETS sont manquantes dans le menu
        for assetCat, _ in pairs(MURPHY_ASSETS[gender]) do
            local found = false
            for _, categoryData in pairs(value) do
                for _, menuCat in pairs(categoryData) do
                    if menuCat == assetCat then
                        found = true
                        break
                    end
                end
                if found then break end
            end
            if not found then
                if assetCat == "bodies_upper" or assetCat == "bodies_lower" then
                else
                    table.insert(menucategories[gender].admin, assetCat)
                end
                -- print("Category missing in menu: " .. assetCat .. " (gender: " .. gender .. ")")
            end
        end
    end

    if Config.GoreBodies then
        for gender, _ in pairs(MURPHY_ASSETS) do
            if MURPHY_ASSETS[gender]["gore_upper"] then
                if not MURPHY_ASSETS[gender]["bodies_upper"] then
                    MURPHY_ASSETS[gender]["bodies_upper"] = {}
                end

                for index, asset in pairs(MURPHY_ASSETS[gender]["gore_upper"]) do
                    table.insert(MURPHY_ASSETS[gender]["bodies_upper"], {
                        drawable = asset.drawable,
                        variants = asset.variants,
                        hash = asset.hash
                    })
                end
            end
            if MURPHY_ASSETS[gender]["gore_lower"] then
                if not MURPHY_ASSETS[gender]["bodies_lower"] then
                    MURPHY_ASSETS[gender]["bodies_lower"] = {}
                end

                for index, asset in pairs(MURPHY_ASSETS[gender]["gore_lower"]) do
                    table.insert(MURPHY_ASSETS[gender]["bodies_lower"], {
                        drawable = asset.drawable,
                        variants = asset.variants,
                        hash = asset.hash
                    })
                end
            end
        end
    end
end)


SelectedGender = "female"
if Config.MenuCommand then
    RegisterCommand(Config.MenuCommand, function()
        OpenOutfitListMenu(true)
    end, false)
end

function OpenOutfitListMenu(show, shopName)
    if not show then
        SendNUIMessage(
            {
                type = "closeOutfitListMenu",

            }
        )
        PlaySound("INFO_HIDE", "HUD_SHOP_SOUNDSET")
        ClearPedTasks(PlayerPedId())
        SetNuiFocus(false, false)
        if MannequinPed then
            DeletePed(MannequinPed)
            MannequinPed = nil
        end
        CreatorLight = false
        ContextualDataOn = false
        KillCamera()
        baseHeading = nil
        angleOffset = nil
        currentH, currentZ, currentR = 0, 0, 0
        -- SwitchOffCam()
        CurrentPrice = 0
        if lamp or lamp2 then
            DeleteObject(lamp)
            DeleteObject(lamp2)
            lamp = nil
            lamp2 = nil
        end
    elseif show then
        Callback.triggerServer('murphy_clothing:GetCurrentOutfitList', function(datatable)
            if datatable then
                local outfits = {}
                for k, v in pairs(datatable) do
                    table.insert(outfits, {
                        id = v.outfit_id,
                        name = v.name,
                        Value = v.price
                    })
                end
                -- Essayer de créer une caméra fixe, sinon utiliser la caméra libre
                if shopName then
                    CurrentShopName = shopName
                    local fixedCamCreated = CreateFixedCamera(shopName)
                    if not fixedCamCreated then
                        camera(2.8, -0.15)
                    end
                else
                    camera(2.8, -0.15)
                end
                Light()
                SendNUIMessage(
                    {
                        type = "openOutfitListMenu",
                        outfits = outfits
                    }
                )
                PlaySound("INFO", "HUD_SHOP_SOUNDSET")
                SetNuiFocus(true, true)
                IdleAnim()
            end
        end)
    end
end

Playerjob, PlayerJobGrade = nil, nil
function OpenShopMenu(show, outfitid)
    if not show then
        if lamp or lamp2 then
            DeleteObject(lamp)
            DeleteObject(lamp2)
            lamp = nil
            lamp2 = nil
        end
        if MannequinPed then
            DeletePed(MannequinPed)
            MannequinPed = nil
            ClearPedTasks(PlayerPedId())
        else
            Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
                if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
                if datatable and id then
                    TriggerEvent("murphy_clothes:clotheitem", datatable, id)
                end
            end)
            ClearPedTasks(PlayerPedId())
        end
        SendNUIMessage(
            {
                type = "closeOutfitMenu",

            }
        )
        SetNuiFocus(false, false)
        PlaySound("INFO_HIDE", "HUD_SHOP_SOUNDSET")
        ClearPedTasks(PlayerPedId())
        CreatorLight = false
        ContextualDataOn = false
        KillCamera()
        baseHeading = nil
        angleOffset = nil
        currentH, currentZ, currentR = 0, 0, 0
        -- SwitchOffCam()
        CurrentPrice = 0
    elseif show then
        if MannequinPed then
            ped = MannequinPed
        else
            ped = PlayerPedId()
        end
        local job, grade
        Callback.triggerServer('murphy_clothing:GetCharJob', function(playerjob, playergrade)
            job, grade = playerjob, tonumber(playergrade)
        end)
        repeat
            Wait(0)
        until job and grade
        Playerjob = job
        PlayerJobGrade = grade
        print("Player job: " .. Playerjob .. ", grade: " .. PlayerJobGrade)
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable)
            if IsPedMale(ped) then SelectedGender = "male" else SelectedGender = "female" end
            if outfitid then
                if datatable then
                    ClothesCache = datatable
                    for k, v in pairs(ClothesCache) do
                        if v.texture then
                            if type(v.texture) == "table" then
                                if v.texture.model ~= nil then
                                    v.texture.palette = v.texture.model
                                    v.texture.model = nil
                                end
                            end
                        end
                    end
                    for k, v in pairs(MURPHY_ASSETS[SelectedGender]) do
                        if ClothesCache[k] == nil then
                            ClothesCache[k] = {}
                            ClothesCache[k].model = 0
                            ClothesCache[k].texture = 0
                        end
                    end
                    OldClothesCache = deepcopy(ClothesCache)
                end
                -- Sauvegarder WearableCache (bodies_upper/lower)
                OldWearableCache = deepcopy(WearableCache)
            else
                ClothesCache = {}
                for k, v in pairs(ClothesCache) do
                    if v.texture then
                        if type(v.texture) == "table" then
                            if v.texture.model ~= nil then
                                v.texture.palette = v.texture.model
                                v.texture.model = nil
                            end
                        end
                    end
                end
                for k, v in pairs(MURPHY_ASSETS[SelectedGender]) do
                    if ClothesCache[k] == nil then
                        ClothesCache[k] = {}
                        ClothesCache[k].model = 0
                        ClothesCache[k].texture = 0
                    end
                end
                OldClothesCache = deepcopy(ClothesCache)
                -- Sauvegarder WearableCache (bodies_upper/lower)
                OldWearableCache = deepcopy(WearableCache)
            end
            local categories = {}

            for _, k in ipairs(menucategories[SelectedGender].categories) do
                if k == "admin" then
                    if Config.DevMode then
                        table.insert(categories,
                            { id = k, name = k, image = "./img/categories/" .. k .. "_" .. SelectedGender .. ".png" })
                    end
                else
                    table.insert(categories,
                        { id = k, name = k, image = "./img/categories/" .. k .. "_" .. SelectedGender .. ".png" })
                end
            end
            table.insert(categories, { id = "skin", name = "skin", image = "./img/categories/skin.png" })

            local items = {}
            for key, value in pairs(menucategories[SelectedGender]) do
                for index, cat in pairs(value) do
                    if MURPHY_ASSETS[SelectedGender][cat] == nil then
                        print("Category not found: " .. cat)
                    else
                        if next(MURPHY_ASSETS[SelectedGender][cat]) ~= nil then
                            if next(Config.JobLocked) ~= nil and Config.JobLocked[cat] then
                                for _, j in pairs(Config.JobLocked[cat]) do
                                    if j[1] == Playerjob and tonumber(j[2]) <= tonumber(PlayerJobGrade) then
                                        if tostring(key) ~= "categories" then
                                            -- print (key)
                                            table.insert(items, {
                                                id = cat,
                                                name = Lang.Categories[cat] or cat,
                                                category = key,
                                                totalAmount = #MURPHY_ASSETS[SelectedGender][cat],
                                                selectorType = "slider",
                                                contextual = "variation",
                                                value = ClothesCache[cat].model or 0,
                                            })
                                        end
                                    end
                                end
                            else
                                if tostring(key) ~= "categories" then
                                    -- print (key)
                                    table.insert(items, {
                                        id = cat,
                                        name = Lang.Categories[cat] or cat,
                                        category = key,
                                        totalAmount = #MURPHY_ASSETS[SelectedGender][cat],
                                        selectorType = "slider",
                                        contextual = "variation",
                                        value = ClothesCache[cat].model or 0,
                                    })
                                end
                            end
                        end
                    end
                end
            end

            table.insert(items, {
                id = "bodies_upper",
                name = "Upper Body",
                category = "skin",
                totalAmount = #WearableStates[SelectedGender]["bodies_upper"] +
                    #MURPHY_ASSETS[SelectedGender]["bodies_upper"],
                selectorType = "slider",
                contextual = "variation",
                value = 1,
            })
            table.insert(items, {
                id = "bodies_lower",
                name = "Lower Body",
                category = "skin",
                totalAmount = #WearableStates[SelectedGender]["bodies_lower"] +
                    #MURPHY_ASSETS[SelectedGender]["bodies_lower"],
                selectorType = "slider",
                contextual = "variation",
                value = 1,
            })

            if not outfitid then
                SendNUIMessage(
                    {
                        type = "openOutfitMenu",
                        categories = categories,
                        items = items
                    }
                )
            else
                SendNUIMessage(
                    {
                        type = "openOutfitMenu",
                        menu = "modify",
                        outfitId = outfitid,
                        categories = categories,
                        items = items
                    }
                )
            end

            PlaySound("INFO", "HUD_SHOP_SOUNDSET")
            SetNuiFocus(true, true)
            IdleAnim()
        end)
    end
end

-- Citizen.CreateThread(function ()
--     while true do
--         local job, grade
--         Callback.triggerServer('murphy_clothing:GetCharJob', function(playerjob, playergrade)
--             job, grade = playerjob, tonumber(playergrade)
--         end)
--         repeat
--             Wait(0)
--         until job and grade
--         Playerjob = job
--         PlayerJobGrade = grade
--         print ("Player job: " .. Playerjob .. ", grade: " .. PlayerJobGrade)
--         Wait(10000)
--     end
-- end)

if Config.ClothesManagement.Command then
    RegisterCommand(Config.ClothesManagement.Command, function()
        OpenWearableMenu(true)
    end, false)
end

if Config.ClothesManagement.Keybind then
    Citizen.CreateThread(function()
        while true do
            Wait(0)
            if IsRawKeyPressed(Config.ClothesManagement.Keybind) then
                OpenWearableMenu(true)
            end
        end
    end)
end



function OpenWearableMenu(show)
    if not show then
        SendNUIMessage(
            {
                type = "closeMyOutfitMenu",

            }
        )
        SetNuiFocus(false, false)
        PlaySound("INFO_HIDE", "HUD_SHOP_SOUNDSET")
        ClearPedTasks(PlayerPedId())
    elseif show then
        if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
        local outfit_id = nil
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
            if datatable then
                ClothesCache = datatable
                for k, v in pairs(ClothesCache) do
                    if v.texture then
                        if type(v.texture) == "table" then
                            if v.texture.model ~= nil then
                                v.texture.palette = v.texture.model
                                v.texture.model = nil
                            end
                        end
                    end
                end
                for k, v in pairs(MURPHY_ASSETS[SelectedGender]) do
                    if ClothesCache[k] == nil then
                        ClothesCache[k] = {}
                        ClothesCache[k].model = 0
                        ClothesCache[k].texture = 0
                    end
                end

                -- if Config.MenuBuilder[MenuType].Instance == true and not Mannequin then
                --     local room = math.random(1,1000)
                --     TriggerServerEvent("murphy_clothing:instanceplayers", room)
                -- end
                OldClothesCache = deepcopy(ClothesCache)
                -- Sauvegarder WearableCache pour le menu F1
                OldWearableCache = deepcopy(WearableCache)
            end
            outfit_id = id
        end)
        repeat Wait(0) until outfit_id
        local items = {}
        table.insert(items, {
            id = "bodies_upper",
            name = "Upper Body",
            category = 2,
            selectorType = "slider",
            totalAmount = #WearableStates[SelectedGender]["bodies_upper"] +
                #MURPHY_ASSETS[SelectedGender]["bodies_upper"],
            value = 1,
        })
        table.insert(items, {
            id = "bodies_lower",
            name = "Lower Body",
            category = 2,
            selectorType = "slider",
            totalAmount = #WearableStates[SelectedGender]["bodies_lower"] +
                #MURPHY_ASSETS[SelectedGender]["bodies_lower"],
            value = 1,
        })

        local equipped = GetCategoriesEquiped(PlayerPedId())
        for k, v in pairs(wearablecategories) do
            if equipped[joaat(v)] then
                local female = true
                if SelectedGender == "male" then female = false end
                local data = ClothesCache[v]
                if data then
                    local texture
                    if data.model > 0 then
                        if type(data.texture) == "table" then
                            texture = data.texture.palette
                        else
                            texture = data.texture
                        end
                        if MURPHY_ASSETS[SelectedGender][v][tonumber(data.model)][tonumber(texture)] then
                            if MURPHY_ASSETS[SelectedGender][v][tonumber(data.model)][tonumber(texture)].hash then
                                local count = GetShopItemNumWearableStates(
                                    MURPHY_ASSETS[SelectedGender][v][tonumber(data.model)][tonumber(texture)].hash,
                                    female,
                                    true)
                                if count > 0 then
                                    table.insert(items, {
                                        id = v,
                                        name = Lang.Categories[v],
                                        category = 1,
                                        selectorType = "slider",
                                        totalAmount = count,
                                        value = 1,
                                    })
                                end
                            end
                        end
                    end
                end
            end
        end
        table.sort(Config.Removecategories)
        for category, value in pairs(Config.Removecategories) do
            -- for _, itemName in ipairs(items) do

            -- end
            local candisplay = false
            for k, v in pairs(value) do
                if ClothesCache[v] then
                    if ClothesCache[v].model > 0 then
                        candisplay = v
                    end
                end
            end
            if candisplay then
                local value = 1
                if Equipped[candisplay] == false then value = 0 end
                table.insert(items, {
                    id = category,
                    name = Lang.Categories["Remove_" .. category],
                    category = 1,
                    selectorType = "button",
                    buttonText = "On / Off",
                })
            end
        end
        SendNUIMessage(
            {
                type = "openMyOutfitMenu",
                myItems = items,
                outfitId = outfit_id
            }
        )
        PlaySound("INFO", "HUD_SHOP_SOUNDSET")
        SetNuiFocus(true, true)
        IdleAnim()
    end
end

RegisterNetEvent('murphy_clothing:ResetClothesMenuCreator', function()
    FirstinitCreator = false
    ClothesCache = {}
end)

FirstinitCreator = false
RegisterNetEvent('murphy_clothing:OpenClothesMenuCreator', function()
    CreatorMode = true

    Light()
    if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
    if FirstinitCreator == false then
        RemoveAllClothesExceptEssentials(PlayerPedId())
        ClothesCache = {}
        FirstinitCreator = true
        print("First init creator")
        for k, v in pairs(ClothesCache) do
            if v.texture then
                if type(v.texture) == "table" then
                    if v.texture.model ~= nil then
                        v.texture.palette = v.texture.model
                        v.texture.model = nil
                    end
                end
            end
        end
        for k, v in pairs(MURPHY_ASSETS[SelectedGender]) do
            if ClothesCache[k] == nil then
                ClothesCache[k] = {}
                ClothesCache[k].model = 0
                ClothesCache[k].texture = 0
            end
        end
    end

    OldClothesCache = deepcopy(ClothesCache)
    if type(baseskin) ~= "table" then
        baseskin = {}
    end
    
    -- Capture base body parts with their original albedo (skin color)
    local ped = PlayerPedId()
    local equipped = GetCategoriesEquiped(ped)
    
    baseskin["bodies_upper"] = GetComponentEquiped(ped, "bodies_upper")
    baseskin["bodies_lower"] = GetComponentEquiped(ped, "bodies_lower")
    
    -- Store original albedo to preserve skin color
    if equipped[`bodies_upper`] and not baseskin["bodies_upper_albedo"] then
        local index = equipped[`bodies_upper`].index
        local _, albedo, _, _ = GetMetaPedAssetGuids(ped, index)
        baseskin["bodies_upper_albedo"] = albedo
    end
    
    if equipped[`bodies_lower`] and not baseskin["bodies_lower_albedo"] then
        local index = equipped[`bodies_lower`].index
        local _, albedo, _, _ = GetMetaPedAssetGuids(ped, index)
        baseskin["bodies_lower_albedo"] = albedo
    end

    local categories = {}

    for _, k in ipairs(menucategories[SelectedGender].categories) do
        if k == "admin" then
            if Config.DevMode then
                table.insert(categories,
                    { id = k, name = k, image = "./img/categories/" .. k .. "_" .. SelectedGender .. ".png" })
            end
        else
            table.insert(categories,
                { id = k, name = k, image = "./img/categories/" .. k .. "_" .. SelectedGender .. ".png" })
        end
    end
    table.insert(categories, { id = "skin", name = "skin", image = "./img/categories/skin.png" })

    local items = {}
    for key, value in pairs(menucategories[SelectedGender]) do
        for index, cat in pairs(value) do
            if MURPHY_ASSETS[SelectedGender][cat] == nil then
                print("Category not found: " .. cat)
            else
                if next(MURPHY_ASSETS[SelectedGender][cat]) ~= nil then
                    if next(Config.JobLocked) ~= nil and Config.JobLocked[cat] then
                        for _, j in pairs(Config.JobLocked[cat]) do
                            if Playerjob ~= nil then
                                if PlayerJobGrade ~= nil then
                                    if j[1] == Playerjob and tonumber(j[2]) <= tonumber(PlayerJobGrade) then
                                        if tostring(key) ~= "categories" then
                                            -- print (key)
                                            table.insert(items, {
                                                id = cat,
                                                name = Lang.Categories[cat] or cat,
                                                category = key,
                                                totalAmount = #MURPHY_ASSETS[SelectedGender][cat],
                                                selectorType = "slider",
                                                contextual = "variation",
                                                value = ClothesCache[cat].model or 0,
                                            })
                                        end
                                    end
                                end
                            end
                        end
                    else
                        if tostring(key) ~= "categories" then
                            -- print (key)
                            table.insert(items, {
                                id = cat,
                                name = Lang.Categories[cat] or cat,
                                category = key,
                                totalAmount = #MURPHY_ASSETS[SelectedGender][cat],
                                selectorType = "slider",
                                contextual = "variation",
                                value = ClothesCache[cat].model or 0,
                            })
                        end
                    end
                end
            end
        end
    end

    table.insert(items, {
        id = "bodies_upper",
        name = "Upper Body",
        category = "skin",
        totalAmount = #WearableStates[SelectedGender]["bodies_upper"] + #MURPHY_ASSETS[SelectedGender]["bodies_upper"],
        selectorType = "slider",
        contextual = "variation",
        value = 1,
    })
    table.insert(items, {
        id = "bodies_lower",
        name = "Lower Body",
        category = "skin",
        totalAmount = #WearableStates[SelectedGender]["bodies_lower"] + #MURPHY_ASSETS[SelectedGender]["bodies_lower"],
        selectorType = "slider",
        contextual = "variation",
        value = 1,
    })

    SendNUIMessage(
        {
            type = "openOutfitMenu",
            categories = categories,
            items = items,
            menu = "creator",
        }
    )

    PlaySound("INFO", "HUD_SHOP_SOUNDSET")
    SetNuiFocus(true, true)
end)
