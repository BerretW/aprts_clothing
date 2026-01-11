OldClothesCache = {}
ClothesCache = {}


ComponentsMale = {}
ComponentsFemale = {}
Citizen.CreateThread(function()
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
end)

function Change(id, category, change_type, value)
    id = tonumber(id)
    if MannequinPed then
        ped = MannequinPed
    else
        ped = PlayerPedId()
    end
    local gender
    if IsPedMale(ped) then gender = "male" else gender = "female" end
    if id < 1 then
        if category == "cloaks" or category == "ponchos" or category == "capes" then
            local categories = { "cloaks", "ponchos", "capes" }
            for k, v in pairs(categories) do
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, v, 0)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey(v), 0)
                local hexHash = v:match("0x[%x]+")
                local decimalHash = tonumber(hexHash)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, decimalHash, 0)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, hexHash, true)
                NativeUpdatePedVariation(ped)
            end
        elseif category == "beard" then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xF8016BCA, 0)
            NativeUpdatePedVariation(ped)
        elseif category == "hair" then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x864B03AE, 0)
            NativeUpdatePedVariation(ped)
        else
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 0)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey(category), 0)
            local hexHash = category:match("0x[%x]+")
            local decimalHash = tonumber(hexHash)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, decimalHash, 0)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, hexHash, true)
            NativeUpdatePedVariation(ped)
        end
        ClothesCache[category].model = id
    else
        if change_type == "model" then
            ClothesCache[category].model = id
            if MURPHY_ASSETS[gender][category][id].drawable then
                ClothesCache[category].texture = {}
                local drawable = MURPHY_ASSETS[gender][category][id].drawable
                local albedo = MURPHY_ASSETS[gender][category][id].variants[1].albedo
                local normal = MURPHY_ASSETS[gender][category][id].variants[1].normal
                local material = MURPHY_ASSETS[gender][category][id].variants[1].material
                local palette = MURPHY_ASSETS[gender][category][id].variants[1].palette
                local tint0 = MURPHY_ASSETS[gender][category][id].variants[1].tint[1]
                local tint1 = MURPHY_ASSETS[gender][category][id].variants[1].tint[2]
                local tint2 = MURPHY_ASSETS[gender][category][id].variants[1].tint[3]
                ClothesCache[category].texture.palette = 1
                ClothesCache[category].texture.tint0 = tint0
                ClothesCache[category].texture.tint1 = tint1
                ClothesCache[category].texture.tint2 = tint2
                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                if Config.DevMode then
                    SendNUIMessage({
                        type = 'clipboard',
                        data = "moveAsset " ..
                            gender .. " " .. category .. " " .. MURPHY_ASSETS[gender][category][id].drawable
                    })
                    print("Clipboard",
                        "moveAsset " .. gender .. " " .. category .. " " .. MURPHY_ASSETS[gender][category][id].drawable)
                end
            else
                ClothesCache[category].texture = 1
                NativeSetPedComponentEnabled(ped, MURPHY_ASSETS[gender][category][id][1].hash, false, true,
                    true)
            end
        else
            if MURPHY_ASSETS[gender][category][ClothesCache[category].model].drawable then
                drawable = MURPHY_ASSETS[gender][category][ClothesCache[category].model].drawable
                if change_type ~= "variants" then
                    albedo = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants
                        [ClothesCache[category].texture.palette].albedo
                    normal = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants
                        [ClothesCache[category].texture.palette].normal
                    material = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants
                        [ClothesCache[category].texture.palette].material
                    palette = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants
                        [ClothesCache[category].texture.palette].palette
                end
                if change_type == "variants" then
                    albedo = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].albedo
                    normal = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].normal
                    material = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].material
                    palette = MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].palette
                    tint0 = tonumber(MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].tint0)
                    tint1 = tonumber(MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].tint1)
                    tint2 = tonumber(MURPHY_ASSETS[gender][category][ClothesCache[category].model].variants[value].tint2)

                    ClothesCache[category].texture.palette = value
                    ClothesCache[category].texture.tint0 = tint0 or 0
                    ClothesCache[category].texture.tint1 = tint1 or 0
                    ClothesCache[category].texture.tint2 = tint2 or 0
                elseif change_type == 1 then
                    ClothesCache[category].texture.tint0 = value
                    tint0 = value
                    tint1 = ClothesCache[category].texture.tint1
                    tint2 = ClothesCache[category].texture.tint2
                elseif change_type == 2 then
                    ClothesCache[category].texture.tint1 = value
                    tint0 = ClothesCache[category].texture.tint0
                    tint1 = value
                    tint2 = ClothesCache[category].texture.tint2
                elseif change_type == 3 then
                    ClothesCache[category].texture.tint2 = value
                    tint0 = ClothesCache[category].texture.tint0
                    tint1 = ClothesCache[category].texture.tint1
                    tint2 = value
                end
                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
            else
                local catHash
                if type(category) ~= "number" then
                    catHash = joaat(category)
                else
                    catHash = category
                end
                if change_type == "variants" then
                    ClothesCache[category].texture = value
                    NativeSetPedComponentEnabled(ped,
                        MURPHY_ASSETS[gender][category][ClothesCache[category].model][value].hash, false, true, true)
                elseif change_type == 1 then
                    if type(ClothesCache[category].texture) == "table" then
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        ClothesCache[category].texture.tint0 = value
                        tint0 = value
                        tint1 = ClothesCache[category].texture.tint1
                        tint2 = ClothesCache[category].texture.tint2
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    else
                        local model = ClothesCache[category].texture
                        ClothesCache[category].texture = {}
                        ClothesCache[category].texture.palette = model
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        tint0 = value
                        ClothesCache[category].texture.tint0 = tint0
                        ClothesCache[category].texture.tint1 = tint1
                        ClothesCache[category].texture.tint2 = tint2
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    end
                elseif change_type == 2 then
                    if type(ClothesCache[category].texture) == "table" then
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        ClothesCache[category].texture.tint1 = value
                        tint0 = ClothesCache[category].texture.tint0
                        tint1 = value
                        tint2 = ClothesCache[category].texture.tint2
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    else
                        local model = ClothesCache[category].texture
                        ClothesCache[category].texture = {}
                        ClothesCache[category].texture.palette = model
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        tint1 = value
                        ClothesCache[category].texture.tint0 = tint0
                        ClothesCache[category].texture.tint1 = tint1
                        ClothesCache[category].texture.tint2 = tint2
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    end
                elseif change_type == 3 then
                    if type(ClothesCache[category].texture) == "table" then
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        ClothesCache[category].texture.tint2 = value
                        tint0 = ClothesCache[category].texture.tint0
                        tint1 = ClothesCache[category].texture.tint1
                        tint2 = value
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    else
                        local model = ClothesCache[category].texture
                        ClothesCache[category].texture = {}
                        ClothesCache[category].texture.palette = model
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                        tint2 = value
                        ClothesCache[category].texture.tint0 = tint0
                        ClothesCache[category].texture.tint1 = tint1
                        ClothesCache[category].texture.tint2 = tint2
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    end
                end
            end
        end
    end
end

------- ESSENTIAL ------


function GetClothesCurrentComponentHash(name)
    if ClothesCache[name] == nil then
        return 0
    end
    local texture = ClothesCache[name].texture
    local model = ClothesCache[name].model
    if model == 0 or texture == 0 then
        return 0
    end
    local hash
    if IsPedMale(PlayerPedId()) then
        if FullDB["male"][name] ~= nil then
            if FullDB["male"][name][model]['iscustom'] == true then
                hash = FullDB["male"][name][1][1].hash
            else
                hash = FullDB["male"][name][model][texture].hash
            end
        end
    else
        if FullDB["female"][name] ~= nil then
            if FullDB["female"][name][model]['iscustom'] == true then
                hash = FullDB["female"][name][1][1].hash
            else
                hash = FullDB["female"][name][model][texture].hash
            end
        end
    end
    return hash
end

function NativeSetPedComponentEnabled(ped, componentHash, immediately, isMp)
    local categoryHash = NativeGetPedComponentCategory(not IsPedMale(ped), componentHash)
    NativeFixMeshIssues(ped, categoryHash)

    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, componentHash, immediately, isMp, true)
    NativeUpdatePedVariation(ped)
end

function NativeGetPedComponentCategory(isFemale, componentHash)
    return Citizen.InvokeNative(0x5FF9A878C3D115B8, componentHash, isFemale, true)
end

function NativeFixMeshIssues(ped, categoryHash)
    Citizen.InvokeNative(0x59BD177A1A48600A, ped, categoryHash)
end

function NativeUpdatePedVariation(ped)
    Citizen.InvokeNative(0x704C908E9C405136, ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true) -- UNKNOWN "Fixes outfit"- always paired with _UPDATE_PED_VARIATION
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false)
    while not NativeHasPedComponentLoaded(ped) do
        Wait(1)
    end
end

function NativeHasPedComponentLoaded(ped)
    return Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped)
end

function SetMetaPedTag(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    Citizen.InvokeNative(0xBC6DF00D7A4A6819, ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
end

function UpdatePedVariation(ped)
    Citizen.InvokeNative(0xAAB86462966168CE, ped, true)                           -- UNKNOWN "Fixes outfit"- always paired with _UPDATE_PED_VARIATION
    Citizen.InvokeNative(0xCC8CA3E88256E58F, ped, false, true, true, true, false) -- _UPDATE_PED_VARIATION
end

function UpdateCustomClothes(playerPed, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    while not NativeHasPedComponentLoaded(playerPed) do
        Wait(0)
    end
    local playerPed = playerPed
    local _drawable = drawable
    local _albedo = albedo
    local _normal = normal
    local _material = material
    local _palette = palette
    local _tint0 = tonumber(tint0)
    local _tint1 = tonumber(tint1)
    local _tint2 = tonumber(tint2)

    SetMetaPedTag(playerPed, _drawable, _albedo, _normal, _material, _palette, _tint0, _tint1, _tint2)
    UpdatePedVariation(playerPed)
end

function UpdateShopItemWearableState(ped, shopItemHash, wearableStateHash, isMultiplayer)
    Citizen.InvokeNative(0x66B957AAC2EAAEAB, ped, shopItemHash, wearableStateHash, 0, isMultiplayer, 1)
end

function FixIssues(target)
    if IsPedMale(target) then
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, target, 0, 0)
        NativeUpdatePedVariation(target)

        NativeSetPedComponentEnabled(target, tonumber(ComponentsMale["BODIES_UPPER"][1]), false, true, true)
        NativeSetPedComponentEnabled(target, tonumber(ComponentsMale["BODIES_LOWER"][1]), false, true, true)
        -- NativeSetPedComponentEnabled(target, `CLOTHING_ITEM_M_HEAD_001_V_001`, false, true, true)
        -- NativeSetPedComponentEnabled(target, `CLOTHING_ITEM_M_EYES_001_TINT_001`, false, true, true)
        -- texture_types["male"].albedo = GetHashKey("mp_head_mr1_sc08_c0_000_ab")
        Citizen.InvokeNative(0xD710A5007C2AC539, target, 0x1D4C528A, 0)
    else
        Citizen.InvokeNative(0x77FF8D35EEC6BBC4, target, 7, true)
        NativeUpdatePedVariation(target)
        NativeSetPedComponentEnabled(target, tonumber(ComponentsFemale["BODIES_UPPER"][1]), false, true, true)
        NativeSetPedComponentEnabled(target, tonumber(ComponentsFemale["BODIES_LOWER"][1]), false, true, true)
        -- NativeSetPedComponentEnabled(target, `CLOTHING_ITEM_F_HEAD_001_V_001`, false, true, true)
        -- NativeSetPedComponentEnabled(target, `CLOTHING_ITEM_F_EYES_001_TINT_001`, false, true, true)
        -- NativeSetPedComponentEnabled( target, 0x1EECD215, false, true, true)
        -- texture_types["female"].albedo = GetHashKey("mp_head_fr1_sc08_c0_000_ab")
    end
    Citizen.InvokeNative(0xD710A5007C2AC539, target, 0x3F1F01E5, 0)
    Citizen.InvokeNative(0xD710A5007C2AC539, target, 0xDA0E2C55, 0)
    NativeUpdatePedVariation(target)
end

function IsPedReadyToRender(ped)
    repeat Wait(0) until Citizen.InvokeNative(0xA0BC8FAED8CFEB3C, ped or PlayerPedId())
end

function pairsByKeys(t, f)
    local a = {}
    for n in pairs(t) do
        table.insert(a, n)
    end
    table.sort(a, f)
    local i = 0             -- iterator variable
    local iter = function() -- iterator function
        i = i + 1
        if a[i] == nil then
            return nil
        else
            return a[i], t[a[i]]
        end
    end
    return iter
end

function deepcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[deepcopy(orig_key)] = deepcopy(orig_value)
        end
        setmetatable(copy, deepcopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

function GetNumComponentsInPed(ped)
    return Citizen.InvokeNative(0x90403E8107B60E81, ped, Citizen.ResultAsInteger())
end

function GetCategoryOfComponentAtIndex(ped, componentIndex)
    return Citizen.InvokeNative(0x9b90842304c938a7, ped, componentIndex, 0, Citizen.ResultAsInteger())
end

function GetComponentIndexByCategory(ped, category)
    local numComponents = GetNumComponentsInPed(ped)
    for i = 0, numComponents - 1, 1 do
        local componentCategory = GetCategoryOfComponentAtIndex(ped, i)
        if componentCategory == category then
            return i
        end
    end
end

function GetMetaPedAssetGuids(ped, index)
    return Citizen.InvokeNative(0xA9C28516A6DC9D56, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(),
        Citizen.PointerValueInt(), Citizen.PointerValueInt())
end

function GetMetaPedAssetTint(ped, index)
    return Citizen.InvokeNative(0xE7998FEC53A33BBE, ped, index, Citizen.PointerValueInt(), Citizen.PointerValueInt(),
        Citizen.PointerValueInt(), Citizen.PointerValueInt())
end

---- CAMERA ----
c_offset = -0.15
c_zoom = 2.8
CamFov = 40.0
ClothingCamera = nil
FixedCamera = false
CurrentShopName = nil

function camera(zoom, offset)
    -- Si caméra fixe, ne rien faire
    if FixedCamera then
        return
    end
    local playerPed
    if MannequinPed then
        playerPed = MannequinPed
    else
        playerPed = PlayerPedId()
    end
    local coords = GetEntityCoords(playerPed)

    if not initialHeading then
        initialHeading = GetEntityHeading(playerPed) + 90.0
    end

    local angle = initialHeading * math.pi / 180.0
    local theta = {
        x = math.cos(angle),
        y = math.sin(angle)
    }

    initialCamOffset = {
        x = zoom * theta.x,
        y = zoom * theta.y,
        z = offset
    }

    local pos = {
        x = coords.x + initialCamOffset.x,
        y = coords.y + initialCamOffset.y,
        z = coords.z + initialCamOffset.z
    }

    if not ClothingCamera then
        DestroyAllCams(true)
        ClothingCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, 300.00,
            0.00, 0.00, 40.00, false, 0)
        PointCamAtCoord(ClothingCamera, coords.x, coords.y, coords.z + offset)
        SetCamActive(ClothingCamera, true)
        SetCamFov(ClothingCamera, CamFov)
        RenderScriptCams(true, true, 1000, true, true)
        DisplayHud(false)
        DisplayRadar(false)
    else
        local ClothingCamera2 = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", pos.x, pos.y, pos.z, 300.00,
            0.00, 0.00, 40.00, false, 0)
        SetCamActive(ClothingCamera2, true)
        SetCamFov(ClothingCamera2, CamFov)
        SetCamActiveWithInterp(ClothingCamera2, ClothingCamera, 0)
        PointCamAtCoord(ClothingCamera2, coords.x, coords.y, coords.z + offset)
        Wait(10)
        SetCamActive(ClothingCamera, false)
        DestroyCam(ClothingCamera)
        ClothingCamera = ClothingCamera2
    end
end

function KillCamera()
    SetCamActive(ClothingCamera, false)
    RenderScriptCams(false, true, 500, true, true)
    DisplayHud(true)
    DisplayRadar(true)
    DestroyAllCams(true)
    ClothingCamera = nil
    initialCamOffset = nil
    initialHeading = nil
    CamFov = 40.0
    FixedCamera = false
    CurrentShopName = nil
    -- cameraprompt:setActive(false)
end

function CreateFixedCamera(shopName)
    local shopConfig = Config.Shops[shopName]
    if type(shopConfig) ~= "table" or not shopConfig.camera then
        return false
    end
    
    local camConfig = shopConfig.camera
    local ped = PlayerPedId()
    if MannequinPed then ped = MannequinPed end
    local pedCoords = GetEntityCoords(ped)
    
    DestroyAllCams(true)
    
    -- Créer la caméra fixe
    local camCoords = camConfig.coords
    local camRot = camConfig.rotation or vector3(0.0, 0.0, 0.0)
    local camFov = camConfig.fov or 40.0
    
    ClothingCamera = CreateCamWithParams("DEFAULT_SCRIPTED_CAMERA", 
        camCoords.x, camCoords.y, camCoords.z, 
        camRot.x, camRot.y, camRot.z, 
        camFov, false, 0)
    
    -- Pointer la caméra
    if camConfig.pointAt then
        PointCamAtCoord(ClothingCamera, camConfig.pointAt.x, camConfig.pointAt.y, camConfig.pointAt.z)
    else
        PointCamAtCoord(ClothingCamera, pedCoords.x, pedCoords.y, pedCoords.z + 0.5)
    end
    
    SetCamActive(ClothingCamera, true)
    SetCamFov(ClothingCamera, camFov)
    RenderScriptCams(true, true, 1000, true, true)
    DisplayHud(false)
    DisplayRadar(false)
    
    FixedCamera = true
    return true
end

function PlaySound(action, soundset)
    PlaySoundFrontend(action, soundset, true, 0)
end

local lastanim = 0
function ChangeClothesAnim()
    RequestAnimDict("script_common@tailor_shop@camp")
    while not HasAnimDictLoaded("script_common@tailor_shop@camp") do
        Citizen.Wait(0)
    end
    local anim = { "shoulder_roll_double", "adjust", "checkout_boot_left", "checkout_boot_right", "checkout_gloves_both",
        "checkout_pants_v1", "checkout_v3", "checkout_side", "shoulder_roll", "checkout_v2", "new_look",
        "checkout_right_glove", "new_look_v1", "checkout_v1", "different_fit" }
    local selectedanim = math.random(1, #anim)
    lastanim = selectedanim
    repeat selectedanim = math.random(1, #anim) until selectedanim ~= lastanim
    local timer = GetAnimDuration("script_common@tailor_shop@camp", anim[selectedanim])
    if CreatorLight == false then
        return
    end
    TaskPlayAnim(PlayerPedId(), "script_common@tailor_shop@camp", anim[selectedanim], 1.0, 1.0, -1, 0, 0, 0, 0, 0)
    Wait(timer * 1000 * 2)
    return true
end

local lastidle = 0
function IdleAnim()
    if MannequinPed then
        ped = MannequinPed
    else
        ped = PlayerPedId()
    end
    if OutfitMenuOpen == false then return end
    RequestAnimDict("script_common@tailor_shop@camp")
    while not HasAnimDictLoaded("script_common@tailor_shop@camp") do
        Citizen.Wait(0)
    end
    local idle = { "idle_v1", "idle_v2", "idle" }
    local selectedidle = math.random(1, #idle)
    lastidle = selectedidle
    repeat selectedidle = math.random(1, #idle) until selectedidle ~= lastidle
    if CreatorLight == false then
        return
    end
    TaskPlayAnim(ped, "script_common@tailor_shop@camp", idle[selectedidle], 1.0, 1.0, -1, 1, 0, 0, 0, 0)
end

lamp = nil
lamp2 = nil
CreatorLight = false
function Light()
    Citizen.CreateThread(function()
        if MannequinPed then
            ped = MannequinPed
        else
            ped = PlayerPedId()
        end
        if lamp ~= nil and lamp2 ~= nil then
            return
        end
        CreatorLight = true
        Wait(1000)
        local lightCoords = GetOffsetFromEntityInWorldCoords(ped, 1.2, 1.2, 0.5)
        RequestModel(GetHashKey("p_lamphanging06x"))
        while not HasModelLoaded(GetHashKey("p_lamphanging06x")) do
            Wait(0)
        end
        if CreatorLight == false then
            return
        end
        lamp = CreateObject(GetHashKey("p_lamphanging06x"), lightCoords.x, lightCoords.y, lightCoords.z, false, true,
            true)
        -- PlaceEntityOnGroundProperly(lamp)
        SetEntityLightsEnabled(lamp, true)
        SetLightsTypeForEntity(lamp, 20)
        SetLightsColorForEntity(lamp, 255, 200, 170)
        SetLightsIntensityForEntity(lamp, 0.0)
        AttachEntityToEntity(lamp, ped, GetEntityBoneIndexByName(ped, 'skel_pelvis'), 0.56, 1.82, 1.75, -41.0, 3.0, -9.0,
            false, false, false, false, 0, false)
        SetEntityAlpha(lamp, 0, false)

        lamp2 = CreateObject(GetHashKey("p_lamphanging06x"), lightCoords.x, lightCoords.y, lightCoords.z, false, true,
            true)
        -- PlaceEntityOnGroundProperly(lamp)
        SetEntityLightsEnabled(lamp2, true)
        SetLightsTypeForEntity(lamp2, 20)
        SetLightsColorForEntity(lamp2, 255, 200, 170)
        SetLightsIntensityForEntity(lamp2, 0.0)
        AttachEntityToEntity(lamp2, ped, GetEntityBoneIndexByName(ped, 'skel_pelvis'), 0.6, -1.7, 2.2, 39.0, 38.0, -19.0,
            false, false, false, false, 0, false)
        SetEntityAlpha(lamp2, 0, false)
        if CreatorLight == false then
            return
        end

        -- Gradually increase the light intensity over 500ms

        local duration = 500
        local steps = 50
        local stepDuration = duration / steps
        local hour = GetClockHours()
        local factor, factor2
        if hour >= 6 and hour <= 20 then
            factor = 800.0
            factor2 = 700.0
        else
            factor = 100.0
            factor2 = 60.0
        end
        for i = 1, steps do
            local intensity = (i / steps) * factor
            local intensity2 = (i / steps) * factor2
            SetLightsIntensityForEntity(lamp, intensity)
            SetLightsIntensityForEntity(lamp2, intensity2)
            Wait(stepDuration)
        end

        while CreatorLight == true do
            if MannequinPed then
                AttachEntityToEntity(lamp, MannequinPed, GetEntityBoneIndexByName(MannequinPed, 'skel_pelvis'), 0.56,
                    1.82, 1.75, -41.0, 3.0, -9.0, false, false, false, false, 0, false)
                AttachEntityToEntity(lamp2, MannequinPed, GetEntityBoneIndexByName(MannequinPed, 'skel_pelvis'), 0.6,
                    -1.7, 2.2, 39.0, 38.0, -19.0, false, false, false, false, 0, false)
            end
            local hour = GetClockHours()
            if hour >= 6 and hour <= 20 then
                SetLightsIntensityForEntity(lamp, 800.0)  -- Pleine intensité pendant la journée
                UpdateLightsOnEntity(lamp)
                SetLightsIntensityForEntity(lamp2, 700.0) -- Pleine intensité pendant la journée
                UpdateLightsOnEntity(lamp2)
            else
                SetLightsIntensityForEntity(lamp, 100.0) -- Intensité réduite la nuit
                UpdateLightsOnEntity(lamp)
                SetLightsIntensityForEntity(lamp2, 60.0) -- Pleine intensité pendant la journée
                UpdateLightsOnEntity(lamp2)
            end
            Wait(100)
        end
        DeleteObject(lamp)
        DeleteObject(lamp2)
        lamp = nil
        lamp2 = nil
    end)
end

AddEventHandler("onResourceStop", function(resource)
    if resource == GetCurrentResourceName() then
        OpenShopMenu(false)
        OpenOutfitListMenu(false)
    end
end)

Wearable = {}


function ChangeSkin(cat, value, change_type, variant_value, target)
    local category = cat
    local gender = "female"
    local ped = target or PlayerPedId()
    if MannequinPed then
        ped = MannequinPed
    end
    if IsPedMale(ped) then gender = "male" end
    -- Gestion du modèle de base et des variantes
    if value > #WearableStates[gender][category] then
        local drawable, albedo, normal, material, palette, tint0, tint1, tint2

        -- Initialisation de la texture si pas de change_type spécifié
        if not change_type then
            if not WearableCache[category] then
                WearableCache[category] = {}
            end
            WearableCache[category].model = value
            WearableCache[category].texture = nil
            value = value - #WearableStates[gender][category]
            -- ClothesCache[category].texture = {}
            -- ClothesCache[category].texture.palette = 1
            -- Vérifier que l'item existe dans MURPHY_ASSETS
            if not MURPHY_ASSETS[gender][category] or not MURPHY_ASSETS[gender][category][value] then
                return
            end
            drawable = MURPHY_ASSETS[gender][category][value].drawable
            albedo = AlbedoData[gender][category][1]
            -- albedo = MURPHY_ASSETS[gender][category][value].variants[1].albedo
            if not MURPHY_ASSETS[gender][category][value].variants or not MURPHY_ASSETS[gender][category][value].variants[1] then
                return
            end
            normal = MURPHY_ASSETS[gender][category][value].variants[1].normal
            material = MURPHY_ASSETS[gender][category][value].variants[1].material

            -- local equiped = GetCategoriesEquiped(ped)
            -- if equiped[`heads`] then
            --     print "head data"
            --     local index = equiped[`heads`].index
            --     _, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
            --     palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
            -- else
            --     -- palette = MURPHY_ASSETS[gender][category][value].variants[1].palette
            --     -- tint0 = MURPHY_ASSETS[gender][category][value].variants[1].tint[1]
            --     -- tint1 = MURPHY_ASSETS[gender][category][value].variants[1].tint[2]
            --     -- tint2 = MURPHY_ASSETS[gender][category][value].variants[1].tint[3]

            -- end
            -- ClothesCache[category].texture.tint0 = tint0
            -- ClothesCache[category].texture.tint1 = tint1
            -- ClothesCache[category].texture.tint2 = tint2
            if Config.DevMode then
                -- SendNUIMessage({
                --     type = 'clipboard',
                --     data = "moveAsset " ..
                --     gender .. " " .. category .. " " .. MURPHY_ASSETS[gender][category][value].drawable .. " gore_upper"
                -- })
                print("Clipboard",
                    "moveAsset " .. gender .. " " .. category .. " " .. MURPHY_ASSETS[gender][category][value].drawable)
            end
        else
            -- Gestion des variations de texture
            value = value - #WearableStates[gender][category]
            drawable = MURPHY_ASSETS[gender][category][value].drawable
            if WearableCache[category].texture == nil then
                WearableCache[category].texture = {}
            end
            if change_type == "variants" then
                albedo = AlbedoData[gender][category][variant_value]
                -- albedo = MURPHY_ASSETS[gender][category][value].variants[variant_value].albedo
                normal = MURPHY_ASSETS[gender][category][value].variants[1].normal
                material = MURPHY_ASSETS[gender][category][value].variants[1]
                    .material
                palette = MURPHY_ASSETS[gender][category][value].variants[1].palette
                tint0 = MURPHY_ASSETS[gender][category][value].variants[1].tint0
                tint1 = MURPHY_ASSETS[gender][category][value].variants[1].tint1
                tint2 = MURPHY_ASSETS[gender][category][value].variants[1].tint2

                WearableCache[category].texture.palette = variant_value
                WearableCache[category].texture.tint0 = tint0 or 0
                WearableCache[category].texture.tint1 = tint1 or 0
                WearableCache[category].texture.tint2 = tint2 or 0
            elseif change_type == 1 then
                -- Gestion tint0
                WearableCache[category].texture.tint0 = variant_value
                tint0 = variant_value
                tint1 = WearableCache[category].texture.tint1
                tint2 = WearableCache[category].texture.tint2
            elseif change_type == 2 then
                -- Gestion tint1
                WearableCache[category].texture.tint1 = variant_value
                tint0 = WearableCache[category].texture.tint0
                tint1 = variant_value
                tint2 = WearableCache[category].texture.tint2
            elseif change_type == 3 then
                -- Gestion tint2
                WearableCache[category].texture.tint2 = variant_value
                tint0 = WearableCache[category].texture.tint0
                tint1 = WearableCache[category].texture.tint1
                tint2 = variant_value
            end
        end
        local equiped = GetCategoriesEquiped(ped)
        if equiped[`heads`] then
            local componentIndex
            if baseskin then
                if baseskin[category] then
                    local hash = baseskin[category]
                    UpdateShopItemWearableState(ped, hash, joaat("base"), true)
                    while GetComponentIndexByCategory(ped, joaat(category)) == -1 do Wait(0) end
                    componentIndex = GetComponentIndexByCategory(ped, joaat(category))
                else
                    componentIndex = equiped[`heads`].index
                end
            else
                componentIndex = equiped[`heads`].index
            end
            -- _, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
            palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
        end
        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    else
        if WearableCache[category] == nil then
            WearableCache[category] = {}
        end
        WearableCache[category].model = value
        WearableCache[category].texture = nil
        if value == 0 then
            value = 1
        end
        if baseskin then
            local hash = baseskin[category]
            if not hash then
                return
            end
            local state = WearableStates[gender][category][value]

            UpdateShopItemWearableState(ped, hash, joaat(state), true)
            NativeUpdatePedVariation(ped)
        end
    end
end

function ChangeWearable(cat, value, target)
    local category = cat
    local gender = "female"
    local data = ClothesCache[cat]
    local ped = target or PlayerPedId()
    if MannequinPed then
        ped = MannequinPed
    end
    if IsPedMale(ped) then gender = "male" end

    local female = true
    if gender == "male" then female = false end
    -- local hash = GetComponentEquiped(ped, cat)
    if type(value) == "table" then
        value = value.model
    end

    if value == 0 then
        value = 1
    end
    local hash
    if type(data.texture) == "table" then
        hash = MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.palette)].hash
    else
        hash = MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture)].hash
    end
    NativeSetPedComponentEnabled(ped, tonumber(hash), false,
        true, true)
    NativeUpdatePedVariation(ped)
    local state = GetShopItemWearableStateByIndex(hash, value, female, true)
    UpdateShopItemWearableState(ped, hash, state, true)
    NativeUpdatePedVariation(ped)
    if type(data.texture) == "table" then
        local catHash
        if type(category) ~= "number" then
            catHash = joaat(category)
        else
            catHash = category
        end
        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
        local componentIndex = GetComponentIndexByCategory(ped, catHash)
        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
        local palette, t0, t1, t2 = GetMetaPedAssetTint(ped, componentIndex)
        local tint0 = data.texture.tint0
        local tint1 = data.texture.tint1
        local tint2 = data.texture.tint2

        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
    end
    NativeUpdatePedVariation(ped)
    if Wearable[category] == nil then
        Wearable[category] = 1
    end
end

function ApplyShopItemToPed(ped, shopItemHash, immediately, isMultiplayer)
    Citizen.InvokeNative(0xD3A7B003ED343FD9, ped, shopItemHash, immediately, isMultiplayer, false)
end

function IsMetaPedUsingComponentCategory(ped, componentCategory)
    return Citizen.InvokeNative(0xFB4891BD7578CDC1, ped, componentCategory)
end

function GetHashFromString(value)
    if type(value) == "string" then
        local number = tonumber(value)
        if number then return number end
        return joaat(value)
    end
    return value
end

function GetComponentEquiped(ped, category)
    local categoryHash = GetHashFromString(category)
    -- if not IsMetaPedUsingComponentCategory(ped, categoryHash) then
    --     print ("not using", category)
    --   return false
    -- end
    local equiped = GetCategoriesEquiped(ped)
    if equiped[categoryHash] then
        local index = equiped[categoryHash].index
        return GetShopItemComponentAtIndex(ped, index, true)
    else
        return false
    end
end

function GetCategoriesEquiped(ped)
    local equiped = {}
    local numComponent = GetNumComponentsInPed(ped) or 0
    for index = 0, numComponent - 1 do
        --Get current component
        local category = GetCategoryOfComponentAtIndex(ped, index)
        equiped[category] = {
            index = index,
        }
        if category == `neckwear` then
            equiped[`neckerchiefs`] = equiped[category]
            equiped[`neckerchiefs`].category = "neckerchiefs"
        elseif category == `neckerchiefs` then
            equiped[`neckwear`] = equiped[category]
            equiped[`neckwear`].category = "neckwear"
        end
    end
    --clear cached value
    local component = equiped
    return component
end

function GetBuggedCategories(ped)
    local returntable = {}
    local buggedcategories = {
        `hair`,
        `hair_bonnet`,
        `beard`,
        `teeth`,
        `eyes`,
        `beards_chin`,
        `beards_chops`,
        `beards_mustache`,
        `beards_complete`,
    }
    local numComponent = GetNumComponentsInPed(ped) or 0
    for index = 0, numComponent - 1 do
        --Get current component
        local category = GetCategoryOfComponentAtIndex(ped, index)
        if contains(buggedcategories, category) then
            local ret, drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
            local ret, palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
            returntable[category] = {
                index = index,
                drawable = drawable,
                albedo = albedo,
                normal = normal,
                material = material,
                palette = palette,
                tint0 = tint0,
                tint1 = tint1,
                tint2 = tint2
            }
        end
    end
    return returntable
end

function scale(value, oldMin, oldMax, newMin, newMax)
    return (((value - oldMin) * (newMax - newMin)) / (oldMax - oldMin)) + newMin
end

RegisterNetEvent("murphy:clothing:RemoveAllClothes", function(ped)
    RemoveAllClothesExceptEssentials(ped)
end)

RegisterCommand("undress", function ()
    local ped = PlayerPedId()
    TriggerEvent("murphy:clothing:RemoveAllClothes", ped)
end)

function RemoveAllClothesExceptEssentials(ped)
    IsPedReadyToRender(ped)
    local equipped = GetCategoriesEquiped(ped)
    local essentials = Config.EssentialsCategories
    if baseskin and not MannequinPed then
        local palette, tint0, tint1, tint2
        if equipped[`heads`] then
            local index = equipped[`heads`].index
            --   local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
            palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
        end
        if equipped[`bodies_upper`] then
            if baseskin["bodies_upper"] then
                local hash = baseskin["bodies_upper"]
                UpdateShopItemWearableState(ped, hash, joaat("base"), true)
            end
            local index = equipped[`bodies_upper`].index
            local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
            -- Use stored original albedo to preserve skin color (prevents white skin bug)
            if baseskin["bodies_upper_albedo"] then
                albedo = baseskin["bodies_upper_albedo"]
            end
            -- local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
            UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
        end
        if equipped[`bodies_lower`] then
            if baseskin["bodies_lower"] then
                local hash = baseskin["bodies_lower"]
                UpdateShopItemWearableState(ped, hash, joaat("base"), true)
            end
            local index = equipped[`bodies_lower`].index
            local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
            -- Use stored original albedo to preserve skin color (prevents white skin bug)
            if baseskin["bodies_lower_albedo"] then
                albedo = baseskin["bodies_lower_albedo"]
            end
            -- local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
            UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
        end
    end

    for _, tagName in pairs(catlist[SelectedGender]) do
        local isEssential = false
        local hash = joaat(tagName)
        if IsMetaPedUsingComponentCategory(ped, hash) then
            for _, essential in ipairs(essentials) do
                if hash == GetHashFromString(essential) then
                    isEssential = true
                    break
                end
            end

            if not isEssential then
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, hash, 0)
            end
        end
    end

    -- for category, data in pairs(equipped) do

    --     local isEssential = false
    --     for _, essential in ipairs(essentials) do
    --         if category == GetHashFromString(essential) then
    --             isEssential = true
    --             break
    --         end
    --     end

    --     if not isEssential then
    --         print (category)
    --         Citizen.InvokeNative(0xD710A5007C2AC539, ped, category, 0)
    --     end
    -- end


    --  NativeUpdatePedVariation(ped)
end

-- Vérifie si une table contient une valeur spécifique
function contains(table, value)
    for _, v in pairs(table) do
        if v == value then
            return true
        end
    end
    return false
end

function areTablesEqual(t1, t2)
    -- Vérifie si les deux références pointent vers la même table
    if t1 == t2 then return true end

    -- Vérifie si les deux objets sont des tables
    if type(t1) ~= "table" or type(t2) ~= "table" then return false end

    -- Vérifie que toutes les clés et valeurs de t1 sont dans t2
    for key, value in pairs(t1) do
        if type(value) == "table" then
            -- Appel récursif pour les sous-tables
            if not areTablesEqual(value, t2[key]) then
                return false
            end
        else
            -- Comparaison des valeurs simples
            if value ~= t2[key] then
                return false
            end
        end
    end

    -- Vérifie que t2 n'a pas de clés supplémentaires
    for key in pairs(t2) do
        if t1[key] == nil then
            return false
        end
    end

    return true
end

function ReequipAllClothes(ped)
    local gender
    if IsPedMale(ped) then gender = "male" else gender = "female" end
    IsPedReadyToRender(ped)
    -- Définir l'ordre des catégories
    local categoryOrder = {
        "cloaks",
        "ponchos",
        "capes",
        "coats",
        "shirts_full",
        "vests",
        "boots",
        "pants",
        "gunbelts",
        "buckles",
        "gloves",


    }
    ClothesCache["bodies_upper"], ClothesCache["bodies_lower"] = nil, nil
    -- Appliquer les catégories dans l'ordre défini
    for _, category in ipairs(categoryOrder) do
        local data = ClothesCache[category]
        if data and data.model and data.model > 0 then
            -- Vérifier que l'item existe dans MURPHY_ASSETS
            if not MURPHY_ASSETS[gender][category] or not MURPHY_ASSETS[gender][category][data.model] then
                goto continue
            end
            local drawable = MURPHY_ASSETS[gender][category][data.model].drawable
            if drawable then
                -- Vérifier que data.texture existe et est une table
                if not data.texture or type(data.texture) ~= "table" or not data.texture.palette then
                    goto continue
                end
                -- Vérifier que la palette existe dans les variants
                if not MURPHY_ASSETS[gender][category][data.model].variants or not MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette] then
                    goto continue
                end
                local albedo = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].albedo
                local normal = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].normal
                local material = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].material
                local palette = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].palette
                local tint0 = data.texture.tint0
                local tint1 = data.texture.tint1
                local tint2 = data.texture.tint2

                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
            else
                if type(data.texture) == "table" then
                    NativeSetPedComponentEnabled(ped,
                        MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.palette)].hash, false,
                        true,
                        true)
                    -- local catHash
                    -- if type(category) ~= "number" then
                    --     catHash = joaat(category)
                    -- else
                    --     catHash = category
                    -- end
                    -- while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                    -- local componentIndex = GetComponentIndexByCategory(ped, catHash)
                    -- local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                    -- local palette, t0, t1, t2 = GetMetaPedAssetTint(ped, componentIndex)
                    -- RemoveShopItemFromPed(ped,
                    --     MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.palette)].hash, 0, 0,
                    --     0)
                    -- local tint0 = data.texture.tint0
                    -- local tint1 = data.texture.tint1
                    -- local tint2 = data.texture.tint2

                    -- UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                else
                    NativeSetPedComponentEnabled(ped, tonumber(
                            MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture)].hash), false,
                        true, true)
                end
            end
        end
        ::continue::
    end

    -- Appliquer les autres catégories non spécifiées dans l'ordre
    local essentials = Config.EssentialsCategories
    for category, data in pairs(ClothesCache) do
        if not contains(categoryOrder, category) and not contains(essentials, category) and data.model and data.model > 0 then
            -- Vérifier que l'item existe dans MURPHY_ASSETS
            if not MURPHY_ASSETS[gender][category] or not MURPHY_ASSETS[gender][category][data.model] then
                goto skip_category
            end
            local drawable = MURPHY_ASSETS[gender][category][data.model].drawable or nil
            if drawable then
                -- Vérifier que data.texture existe et est une table
                if not data.texture or type(data.texture) ~= "table" or not data.texture.palette then
                    goto skip_category
                end
                -- Vérifier que les variants existent
                if not MURPHY_ASSETS[gender][category][data.model].variants or not MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette] then
                    goto skip_category
                end
                local albedo = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].albedo
                local normal = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].normal
                local material = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].material
                local palette = MURPHY_ASSETS[gender][category][data.model].variants[data.texture.palette].palette
                local tint0 = data.texture.tint0
                local tint1 = data.texture.tint1
                local tint2 = data.texture.tint2

                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
            else
                if type(data.texture) == "table" then
                    NativeSetPedComponentEnabled(ped,
                        MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.palette)].hash, false,
                        true,
                        true)
                    -- local catHash
                    -- if type(category) ~= "number" then
                    --     catHash = joaat(category)
                    -- else
                    --     catHash = category
                    -- end
                    -- while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                    -- local componentIndex = GetComponentIndexByCategory(ped, catHash)
                    -- local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                    -- local palette, t0, t1, t2 = GetMetaPedAssetTint(ped, componentIndex)
                    -- RemoveShopItemFromPed(ped,
                    --     MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture.palette)].hash, 0, 0,
                    --     0)
                    -- local tint0 = data.texture.tint0
                    -- local tint1 = data.texture.tint1
                    -- local tint2 = data.texture.tint2

                    -- UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                else
                    NativeSetPedComponentEnabled(ped, tonumber(
                            MURPHY_ASSETS[gender][category][tonumber(data.model)][tonumber(data.texture)].hash), false,
                        true, true)
                end
            end
        end
        ::skip_category::
    end
    for category, data in pairs(ClothesCache) do
        if data and data.model and data.model > 0 then
            if type(data.texture) == "table" then
                local catHash
                if type(category) ~= "number" then
                    catHash = joaat(category)
                else
                    catHash = category
                end
                while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                local componentIndex = GetComponentIndexByCategory(ped, catHash)
                local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                local palette, t0, t1, t2 = GetMetaPedAssetTint(ped, componentIndex)
                local tint0 = data.texture.tint0
                local tint1 = data.texture.tint1
                local tint2 = data.texture.tint2

                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
            end
        end
    end
end

RegisterNetEvent('murphy_clothes:clotheitem')
AddEventHandler('murphy_clothes:clotheitem', function(ClothesComponents, outfitid, target, charid)
    Citizen.CreateThread(function()
        local _Target = PlayerPedId()
        if MannequinPed then
            _Target = MannequinPed
        end
        if target then
            _Target = target
        else
            TriggerEvent("murphy_clothes:outfitchanged")
        end
        local buggedCategories = GetBuggedCategories(_Target)
        local gender
        if IsPedMale(_Target) then gender = "male" else gender = "female" end
        ClothesCache = ClothesComponents
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
        for k, v in pairs(MURPHY_ASSETS[gender]) do
            if ClothesCache[k] == nil then
                ClothesCache[k] = {}
                ClothesCache[k].model = 0
                ClothesCache[k].texture = 0
            end
        end
        if not target then
            TriggerServerEvent("murphy_clothes:updateclothes", ClothesCache, outfitid)
            OldClothesCache = deepcopy(ClothesCache)
        end
        RemoveAllClothesExceptEssentials(_Target)
        ReequipAllClothes(_Target)
        Wait(100)
        Callback.triggerServer('murphy_clothing:GetWearable', function(datatable)
            if datatable then
                TriggerEvent("murphy_clothes:applyWearable", datatable, _Target)
                WearableCache = datatable
            end
        end, outfitid, charid)
        Wait(2000)
        for k, v in pairs(buggedCategories) do
            local drawable = v.drawable
            local albedo = v.albedo
            local normal = v.normal
            local material = v.material
            local palette = v.palette
            local tint0 = v.tint0
            local tint1 = v.tint1
            local tint2 = v.tint2
            UpdateCustomClothes(_Target, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
        end
    end)
end)

Equipped = {}
RegisterNetEvent("murphy_clothes:itemclothes", function(cat, model, texture)
    local ped = PlayerPedId()
    local gender
    if IsPedMale(ped) then gender = "male" else gender = "female" end
    if Equipped[cat] == nil then Equipped[cat] = true end
    if Equipped[cat] then
        if cat == "cloaks" or cat == "ponchos" or cat == "capes" then
            local categories = { "cloaks", "ponchos", "capes" }
            for k, v in pairs(categories) do
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, v, 0)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey(v), 0)
                local hexHash = v:match("0x[%x]+")
                local decimalHash = tonumber(hexHash)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, decimalHash, 0)
                Citizen.InvokeNative(0xD710A5007C2AC539, ped, hexHash, true)
                NativeUpdatePedVariation(ped)
            end
        elseif cat == "beard" then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0xF8016BCA, 0)
            NativeUpdatePedVariation(ped)
        elseif cat == "hair" then
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, 0x864B03AE, 0)
            NativeUpdatePedVariation(ped)
        else
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, cat, 0)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, GetHashKey(cat), 0)
            local hexHash = cat:match("0x[%x]+")
            local decimalHash = tonumber(hexHash)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, decimalHash, 0)
            Citizen.InvokeNative(0xD710A5007C2AC539, ped, hexHash, true)
            NativeUpdatePedVariation(ped)
        end
        Equipped[cat] = false
        if baseskin and not MannequinPed then
            local equipped = GetCategoriesEquiped(ped)
            local palette, tint0, tint1, tint2
            if equipped[`heads`] then
                local index = equipped[`heads`].index
                --   local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
                palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
            end

            if cat == "shirts_full" then
                if equipped[`bodies_upper`] then
                    if baseskin["bodies_upper"] then
                        local hash = baseskin["bodies_upper"]
                        UpdateShopItemWearableState(ped, hash, joaat("base"), true)
                    end
                    local index = equipped[`bodies_upper`].index
                    local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
                    -- Use stored original albedo to preserve skin color (prevents white skin bug)
                    if baseskin["bodies_upper_albedo"] then
                        albedo = baseskin["bodies_upper_albedo"]
                    end
                    -- local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
                    UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                end
            end
            if cat == "pants" then
                if equipped[`bodies_lower`] then
                    if baseskin["bodies_lower"] then
                        local hash = baseskin["bodies_lower"]
                        UpdateShopItemWearableState(ped, hash, joaat("base"), true)
                    end
                    local index = equipped[`bodies_lower`].index
                    local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, index)
                    -- Use stored original albedo to preserve skin color (prevents white skin bug)
                    if baseskin["bodies_lower_albedo"] then
                        albedo = baseskin["bodies_lower_albedo"]
                    end
                    -- local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, index)
                    UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                end
            end
        end
    else
        if model > 0 then
            -- Vérifier que l'item existe
            if not MURPHY_ASSETS[gender] or not MURPHY_ASSETS[gender][cat] or not MURPHY_ASSETS[gender][cat][model] then
                Equipped[cat] = true
                return
            end
            if MURPHY_ASSETS[gender][cat][model].drawable then
                -- if cat ~= "cloaks" then
                --     NativeSetPedComponentEnabled(ped, MURPHY_ASSETS[gender][cat][1][1].hash, false, true,
                --  true)
                --  NativeUpdatePedVariation(PlayerPedId())
                -- end
                local drawable = MURPHY_ASSETS[gender][cat][model].drawable
                -- Vérifier que texture est une table et a une palette valide
                if type(texture) ~= "table" or not texture.palette then
                    Equipped[cat] = true
                    return
                end
                -- Vérifier que les variants existent
                if not MURPHY_ASSETS[gender][cat][model].variants or not MURPHY_ASSETS[gender][cat][model].variants[texture.palette] then
                    Equipped[cat] = true
                    return
                end
                local albedo = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].albedo
                local normal = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].normal
                local material = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].material
                local palette = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].palette
                if type(texture) == "table" then
                    tint0 = texture.tint0
                    tint1 = texture.tint1
                    tint2 = texture.tint2
                else
                    tint0 = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].tint0
                    tint1 = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].tint1
                    tint2 = MURPHY_ASSETS[gender][cat][model].variants[texture.palette].tint2
                end
                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                NativeUpdatePedVariation(PlayerPedId())
            else
                if type(texture) == "table" then
                    NativeSetPedComponentEnabled(ped, MURPHY_ASSETS[gender][cat][model][texture.palette].hash, false,
                        true,
                        true)
                    NativeUpdatePedVariation(PlayerPedId())
                    local catHash = MURPHY_ASSETS[gender][cat][model][1]['category_hash_dec_signed']
                    while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                    local componentIndex = GetComponentIndexByCategory(ped, catHash)
                    local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                    local palette, tint0, tint1, tint2 = GetMetaPedAssetTint(ped, componentIndex)
                    local tint0 = texture.tint0
                    local tint1 = texture.tint1
                    local tint2 = texture.tint2
                    UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                else
                    NativeSetPedComponentEnabled(ped, MURPHY_ASSETS[gender][cat][model][texture].hash, false, true,
                        true)
                end
            end
        else
        end
        if cat == "pants" then
            local gender = "female"
            if IsPedMale(PlayerPedId()) then gender = "male" end
            local category = "bodies_lower"
            if WearableCache[category] then
                local model = WearableCache[category].model + #WearableStates[gender][category]
                if WearableCache[category].texture then
                    ChangeSkin(category, model)
                    ChangeSkin(category, model, "variants", WearableCache[category].texture.palette)
                else
                    ChangeSkin(category, model)
                end
            end
        end

        if cat == "shirts_full" then
            local gender = "female"
            if IsPedMale(PlayerPedId()) then gender = "male" end
            local category = "bodies_upper"
            if WearableCache[category] then
                local model = WearableCache[category].model + #WearableStates[gender][category]
                if WearableCache[category].texture then
                    ChangeSkin(category, model)
                    ChangeSkin(category, model, "variants", WearableCache[category].texture.palette)
                else
                    ChangeSkin(category, model)
                end
            end
        end
        NativeFixMeshIssues(PlayerPedId(), GetHashKey(cat))
        Equipped[cat] = true
    end
    
    -- Trigger bandana status event if mask category was toggled
    if cat == "masks" or cat == "masks_large" then
        local hasBandana = IsBandanaEquipped()
        TriggerEvent('murphy_clothes:ToggleBandana', hasBandana)
    end
    
    -- Trigger clothing changed event for temperature/metabolism scripts
    TriggerEvent('murphy_clothes:OnClothingChanged', cat, Equipped[cat])
end)


OrignalHeading = nil
OriginalCoords = nil
function SpawnMannequin(gender)
    local model = RequestModel(GetHashKey("mp_" .. gender))
    while not HasModelLoaded(GetHashKey("mp_" .. gender)) do
        Wait(100)
    end

    -- Get player position and heading
    local playerPed = PlayerPedId()
    local playerCoords = GetEntityCoords(playerPed)
    OriginalCoords = playerCoords
    local playerHeading = GetEntityHeading(playerPed)
    OrignalHeading = playerHeading
    -- Calculate position behind mannequin using radians
    local rad = math.rad(playerHeading + 160.0) -- Convert heading to radians and add 180° to go behind
    local distance = 2.0                        -- Distance behind mannequin

    -- Calculate target coordinates behind mannequin
    local targetCoords = {
        x = playerCoords.x + (math.sin(-rad) * distance),
        y = playerCoords.y + (math.cos(-rad) * distance),
        z = playerCoords.z
    }

    -- Make player walk to position behind mannequin
    TaskGoToCoordAnyMeans(playerPed, targetCoords.x, targetCoords.y, targetCoords.z, 1.0, 0, false, 786603, 0)
    Wait(1500)
    -- Spawn mannequin at player position
    local ped = CreatePed(GetHashKey("mp_" .. gender), playerCoords.x, playerCoords.y, playerCoords.z - 1.0,
        playerHeading, true, true, true, true)
    Citizen.InvokeNative(0x283978A15512B2FE, ped, true)

    -- Setup mannequin properties
    if gender == "male" then
        SetPedOutfitPreset(ped, 8)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_M_HEAD_001_V_001`, false, true, true)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_M_EYES_001_TINT_001`, false, true, true)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_M_HAIR_001_Blonde`, false, true, true)
    else
        SetPedOutfitPreset(ped, 8)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_F_HEAD_001_V_001`, false, true, true)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_F_EYES_001_TINT_001`, false, true, true)
        NativeSetPedComponentEnabled(ped, `CLOTHING_ITEM_F_HAIR_001_Blonde`, false, true, true)
    end

    PlaceEntityOnGroundProperly(ped, true)
    SetEntityCanBeDamaged(ped, false)
    SetEntityInvincible(ped, true)
    -- FreezeEntityPosition(ped, true)
    SetBlockingOfNonTemporaryEvents(ped, true)
    -- Citizen.InvokeNative(0xD710A5007C2AC539, ped, `shirts_full`, 0)
    -- Citizen.InvokeNative(0xD710A5007C2AC539, ped, `gunbelts`, 0)
    -- Citizen.InvokeNative(0xD710A5007C2AC539, ped, `boots`, 0)
    -- Citizen.InvokeNative(0xD710A5007C2AC539, ped, `ammo_pistols`, 0)
    -- Citizen.InvokeNative(0xD710A5007C2AC539, ped, `pants`, 0)
    -- FixIssues(ped)
    TaskTurnPedToFaceCoord(playerPed, GetEntityCoords(ped), -1)
    SetModelAsNoLongerNeeded(model)
    return ped
end

WearableCache = {}
OldWearableCache = nil
RegisterNetEvent("murphy_clothes:applyWearable", function(data, target)
    local ped = target or PlayerPedId()
    WearableCache = {}
    for category, value in pairs(data) do
        WearableCache[category] = value
        ClothesCache[category] = WearableCache[category]
        if category == "bodies_upper" or category == "bodies_lower" then
            if WearableCache[category].model > 0 then
                local gender = "female"
                if IsPedMale(ped) then gender = "male" end
                local model = WearableCache[category].model
                if WearableCache[category].texture then
                    ChangeSkin(category, model, "variants", WearableCache[category].texture.palette, ped)
                else
                    ChangeSkin(category, model, nil, nil, ped)
                end
            end
        else
            if type(value) == "table" then
                if value.model > 0 then
                    ChangeWearable(category, value, ped)
                end
            else
                if value > 0 then
                    ChangeWearable(category, value, ped)
                end
            end
        end
    end
end)

----- DEV EVENTS ----

RegisterNetEvent("murphy_clothes:ApplyClothesToCharid", function(charid, ped)
    Callback.triggerServer('murphy_clothing:GetCurrentClothesCharid', function(datatable, id)
        if IsPedMale(ped) then SelectedGender = "male" else SelectedGender = "female" end
        if datatable then
            local loadclothes = false
            for k, v in pairs(datatable) do
                if v.model > 0 then
                    loadclothes = true
                    break
                end
            end
            if loadclothes then
                TriggerEvent("murphy_clothes:clotheitem", datatable, id, ped, charid)
            end
        end
    end, charid)
end)


RegisterNetEvent("murphy_clothes:Equip-UnequipCategory", function(category)
    TriggerEvent("murphy_clothes:itemclothes", category, ClothesCache[category].model, ClothesCache[category].texture)
end)

---Returns a table of currently equipped clothing categories
---@return table categories Table containing equipped clothing categories and their data
function GetEquippedCategories()
    local equippedCategories = {}

    for category, data in pairs(ClothesCache) do
        if data.model and data.model > 0 then
            equippedCategories[category] = {
                model = data.model,
                texture = data.texture
            }
        end
    end

    return equippedCategories
end

exports('GetEquippedCategories', GetEquippedCategories)

RegisterNetEvent("murphy_clothes:OpenClothingMenu", function()
    OpenOutfitListMenu(true)
end)


local HairCache = {} -- Cache pour stocker les informations des cheveux

function ToggleHair(remove)
    local ped = PlayerPedId()

    if remove then
        -- Sauvegarde des informations actuelles des cheveux dans le cache
        local hairData = {
            guid = GetPedDrawableVariation(ped, 2),   -- GUID des cheveux
            palette = GetPedPaletteVariation(ped, 2), -- Palette des cheveux
            tint = GetPedHairTint(ped)                -- Teinte des cheveux
        }

        HairCache = hairData

        -- Enlève les cheveux en appliquant un modèle vide
        SetPedComponentVariation(ped, 2, 0, 0, 0)
        print("Cheveux enlevés et sauvegardés dans le cache.")
    else
        -- Vérifie si des données sont disponibles dans le cache
        if HairCache.guid then
            -- Réapplique les cheveux avec les données sauvegardées
            SetPedComponentVariation(ped, 2, HairCache.guid, 0, HairCache.palette)
            SetPedHairTint(ped, HairCache.tint)
            print("Cheveux réappliqués depuis le cache.")
        else
            print("Aucune donnée de cheveux trouvée dans le cache.")
        end
    end
end

RegisterNetEvent("murphy_clothes:LoadBasSkin", function()
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
end)

RegisterNetEvent("murphy_clothes:Loadlowerbody", function(comp)
    if type(baseskin) ~= "table" then
        baseskin = {}
    end
    baseskin["bodies_lower"] = comp
end)

RegisterNetEvent("murphy_clothes:Loadupperbody", function(comp)
    if type(baseskin) ~= "table" then
        baseskin = {}
    end
    baseskin["bodies_upper"] = comp
end)


Citizen.CreateThread(function()
    while true do
        Wait(2000)
        if CreatorLight == false then
            if lamp or lamp2 then
                DeleteObject(lamp)
                DeleteObject(lamp2)
                lamp = nil
                lamp2 = nil
            end
        end
    end
end)

---Equips multiple clothing items at once with support for model, texture (palette), and tint values
---@param clothesData table Table containing clothing categories with model, texture, and optional tint values
---Example: { ["hats"] = {model = 1, texture = 0, tint0 = 0, tint1 = 0, tint2 = 0}, ["shirts_full"] = {model = 5, texture = 2} }
---@param ped number Optional ped entity to apply clothes to (defaults to PlayerPedId())
function EquipMultipleClothes(clothesData, ped)
    if not clothesData or type(clothesData) ~= "table" then
        print("Error: clothesData must be a table")
        return false
    end
    
    ped = ped or PlayerPedId()
    local gender
    if IsPedMale(ped) then gender = "male" else gender = "female" end
    
    for category, data in pairs(clothesData) do
        if type(data) == "table" and data.model then
            -- Validate that the category exists in MURPHY_ASSETS
            if not MURPHY_ASSETS or not MURPHY_ASSETS[gender] or not MURPHY_ASSETS[gender][category] then
                print(string.format("Warning: Category '%s' not found for gender '%s'", category, gender))
                goto continue
            end
            
            -- Validate that the model exists
            if not MURPHY_ASSETS[gender][category][data.model] then
                print(string.format("Warning: Model %d not found for category '%s'", data.model, category))
                goto continue
            end
            
            local model = data.model
            local texture = data.texture or 0
            
            -- Update ClothesCache
            ClothesCache[category] = ClothesCache[category] or {}
            ClothesCache[category].model = model
            
            -- Check if this is a drawable-based clothing item
            if MURPHY_ASSETS[gender][category][model].drawable then
                -- Set up texture data with palette
                ClothesCache[category].texture = {}
                ClothesCache[category].texture.palette = texture
                
                -- Get the default values from MURPHY_ASSETS if not provided
                local variantData = MURPHY_ASSETS[gender][category][model].variants[texture] or 
                                  MURPHY_ASSETS[gender][category][model].variants[1]
                
                if not variantData then
                    print(string.format("Warning: Texture %d not found for model %d in category '%s'", texture, model, category))
                    goto continue
                end
                
                local drawable = MURPHY_ASSETS[gender][category][model].drawable
                local albedo = variantData.albedo
                local normal = variantData.normal
                local material = variantData.material
                local palette = variantData.palette
                
                -- Use provided tint values or defaults from the variant
                local tint0 = tonumber(data.tint0) or tonumber(variantData.tint0) or 0
                local tint1 = tonumber(data.tint1) or tonumber(variantData.tint1) or 0
                local tint2 = tonumber(data.tint2) or tonumber(variantData.tint2) or 0
                
                -- Store tint values in cache
                ClothesCache[category].texture.tint0 = tint0
                ClothesCache[category].texture.tint1 = tint1
                ClothesCache[category].texture.tint2 = tint2
                
                -- Apply the clothing
                UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                
            else
                -- Non-drawable clothing item
                ClothesCache[category].texture = texture
                
                -- Get the hash for this texture variant
                local clothingHash
                if type(texture) == "table" then
                    clothingHash = MURPHY_ASSETS[gender][category][model][texture.palette].hash
                else
                    clothingHash = MURPHY_ASSETS[gender][category][model][texture].hash
                end
                
                if clothingHash then
                    NativeSetPedComponentEnabled(ped, clothingHash, false, true, true)
                    
                    -- If tint values are provided, apply them after the component is equipped
                    if data.tint0 or data.tint1 or data.tint2 then
                        local catHash = MURPHY_ASSETS[gender][category][model][1]['category_hash_dec_signed']
                        while GetComponentIndexByCategory(ped, catHash) == -1 do Wait(0) end
                        local componentIndex = GetComponentIndexByCategory(ped, catHash)
                        local drawable, albedo, normal, material = GetMetaPedAssetGuids(ped, componentIndex)
                        local palette, oldTint0, oldTint1, oldTint2 = GetMetaPedAssetTint(ped, componentIndex)
                        
                        local tint0 = tonumber(data.tint0) or oldTint0
                        local tint1 = tonumber(data.tint1) or oldTint1
                        local tint2 = tonumber(data.tint2) or oldTint2
                        
                        UpdateCustomClothes(ped, drawable, albedo, normal, material, palette, tint0, tint1, tint2)
                    end
                end
            end
            
            -- Mark as equipped
            if Equipped[category] ~= nil then
                Equipped[category] = true
            end
            
            ::continue::
        end
    end
    
    -- Update ped variation to apply all changes
    NativeUpdatePedVariation(ped)
    return true
end

-- Export the function
exports('EquipMultipleClothes', EquipMultipleClothes)

-- Register event for equipping multiple clothes
RegisterNetEvent("murphy_clothes:EquipMultipleClothes", function(clothesData, ped)
    EquipMultipleClothes(clothesData, ped)
end)

/**********************************************************************************************
 *                              BANDANA/MASK DETECTION SYSTEM                                 *
 **********************************************************************************************/

-- Function to check if player has a bandana/mask equipped
function IsBandanaEquipped()
    local maskCategories = {"masks", "masks_large"}
    
    for _, category in ipairs(maskCategories) do
        if ClothesCache[category] and ClothesCache[category].model and ClothesCache[category].model > 0 then
            return true
        end
    end
    
    return false
end

-- Export for other scripts
exports('IsBandanaEquipped', IsBandanaEquipped)

-- Event to check bandana status - returns boolean
RegisterNetEvent('murphy_clothes:CheckBandana', function()
    local hasBandana = IsBandanaEquipped()
    TriggerEvent('murphy_clothes:BandanaStatus', hasBandana)
end)

-- Event compatible with syn_robbery format for doctorjob script
RegisterNetEvent('murphy_clothes:ToggleBandana', function(state)
    -- This event is triggered when bandana state changes
    -- state: true = bandana up/equipped, false = bandana down/removed
    TriggerEvent('syn_robbery:bandana', state)
end)

-- Server callback for other resources to check bandana status
if lib and lib.callback then
    lib.callback.register('murphy_clothes:IsBandanaEquipped', function()
        return IsBandanaEquipped()
    end)
end


/**********************************************************************************************
 *                         TEMPERATURE/METABOLISM SYSTEM                                      *
 **********************************************************************************************/

-- Get all equipped clothing categories
function GetEquippedClothing()
    local equipped = {}
    
    for category, data in pairs(ClothesCache) do
        if data and data.model and data.model > 0 then
            equipped[category] = {
                model = data.model,
                texture = data.texture,
                category = category
            }
        end
    end
    
    return equipped
end

-- Get temperature protection data
function GetTemperatureProtection()
    local warmCount = 0
    local coldCount = 0
    local equippedCategories = {}
    
    for category, data in pairs(ClothesCache) do
        if data and data.model and data.model > 0 then
            table.insert(equippedCategories, category)
            
            -- Check temperature value from config
            if Config.ClothingTemperature[category] then
                if Config.ClothingTemperature[category] == "warm" then
                    warmCount = warmCount + 1
                elseif Config.ClothingTemperature[category] == "cold" then
                    coldCount = coldCount + 1
                end
            end
        end
    end
    
    -- Calculate protection levels
    local coldProtection = Config.TemperatureProtection.cold[warmCount] or 3
    local heatProtection = Config.TemperatureProtection.heat[coldCount] or 3
    
    return {
        warmItems = warmCount,
        coldItems = coldCount,
        coldProtection = coldProtection,  -- 0-3 (0=none, 3=heavy)
        heatProtection = heatProtection,  -- 0-3 (0=none, 3=heavy)
        categories = equippedCategories
    }
end

-- Check if specific clothing category is equipped
function IsClothingCategoryEquipped(category)
    if ClothesCache[category] and ClothesCache[category].model and ClothesCache[category].model > 0 then
        return true
    end
    return false
end

-- Get detailed clothing info for a specific category
function GetClothingInfo(category)
    if ClothesCache[category] and ClothesCache[category].model and ClothesCache[category].model > 0 then
        return {
            category = category,
            model = ClothesCache[category].model,
            texture = ClothesCache[category].texture,
            temperature = Config.ClothingTemperature[category] or "neutral"
        }
    end
    return nil
end

-- Exports for metabolism scripts
exports('GetEquippedClothing', GetEquippedClothing)
exports('GetTemperatureProtection', GetTemperatureProtection)
exports('IsClothingCategoryEquipped', IsClothingCategoryEquipped)
exports('GetClothingInfo', GetClothingInfo)

-- Events for metabolism scripts
RegisterNetEvent('murphy_clothes:GetTemperatureProtection', function()
    local protection = GetTemperatureProtection()
    TriggerEvent('murphy_clothes:TemperatureProtectionData', protection)
end)

-- Trigger event when clothing changes (for real-time updates)
AddEventHandler('murphy_clothes:OnClothingChanged', function(category, equipped)
    local protection = GetTemperatureProtection()
    -- Notify metabolism scripts about the change
    TriggerEvent('murphy_clothes:TemperatureUpdate', protection)
end)
