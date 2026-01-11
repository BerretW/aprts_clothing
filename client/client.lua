-- local Prompt = nil
-- local promptGroup = GetRandomIntInRange(0, 0xffffff)
PlayerClothes = {}
ClothesCache = {}
dataReady = false
OriginalBody = {}
MenuOpen = false -- OPRAVA: Globální proměnná pro stav menu
Camera = nil
camHeight = 0.6
Progressbar = exports["vorp_progressbar"]:initiate()
playingAnimation = false -- OPRAVA: sjednoceno malé p

function debugPrint(msg)
    if Config.Debug == true then
        print("^1[SCRIPT]^0 " .. msg)
    end
end

function notify(text)
    TriggerEvent('notifications:notify', "SCRIPT", text, 3000)
end
function WaitForCharacter()
    while not LocalPlayer do
        Citizen.Wait(100)
    end
    while not LocalPlayer.state do
        Citizen.Wait(100)
    end
    while not LocalPlayer.state.Character do
        Citizen.Wait(100)
    end
end
function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

function round(num)
    return math.floor(num * 100 + 0.5) / 100
end

function hasJob(jobtable)
    if not jobtable or table.count(jobtable) == 0 then
        return true
    end
    local pjob = LocalPlayer.state.Character.Job
    local pGrade = LocalPlayer.state.Character.Grade
    local pLabel = LocalPlayer.state.Character.Label
    for _, v in pairs(jobtable) do
        if v.job == pjob and v.grade <= pGrade and (v.label == "" or v.label == nil or v.label == pLabel) then
            return true
        end
    end
    return false
end
function DeepCopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[DeepCopy(orig_key)] = DeepCopy(orig_value)
        end
        setmetatable(copy, DeepCopy(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end


--- Bezpečné zavolání exportu s návratovou hodnotou a defaultem
function SafeExport(resourceName, functionName, defaultReturn, ...)
    if GetResourceState(resourceName) ~= "started" then
        debugPrint("^1[ERROR]^7 Export failed: " .. resourceName .. " is not started.")
        return defaultReturn
    end
    local success, result = pcall(exports[resourceName][functionName], ...)
    if success then
        return result
    else
        debugPrint("^1[ERROR]^7 Export failed: " .. resourceName .. ":" .. functionName .. " Error: " ..
                       tostring(result))
        return defaultReturn
    end
end

function playAnim(entity, dict, name, flag, time)
    playingAnimation = true -- OPRAVA: malé p
    RequestAnimDict(dict)
    local waitSkip = 0
    while not HasAnimDictLoaded(dict) do
        waitSkip = waitSkip + 1
        if waitSkip > 100 then
            break
        end
        Citizen.Wait(0)
    end

    Progressbar.start("Něco dělám", time, function()
    end, 'blood', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 11, 21, 0.5)')

    TaskPlayAnim(entity, dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)
    Wait(time)
    playingAnimation = false -- OPRAVA: malé p
end

function equipProp(model, bone, coords)
    local ped = PlayerPedId()
    local playerPos = GetEntityCoords(ped)
    local mainProp = CreateObject(model, playerPos.x, playerPos.y, playerPos.z + 0.2, true, true, true)
    local boneIndex = GetEntityBoneIndexByName(ped, bone)
    AttachEntityToEntity(mainProp, ped, boneIndex, coords.x, coords.y, coords.z, coords.xr, coords.yr, coords.zr, true,
        true, false, true, 1, true)
    return mainProp
end

function CreateBlip(coords, sprite, name)
    if type(sprite) == "string" then
        sprite = GetHashKey(sprite)
    end
    local blip = BlipAddForCoords(1664425300, coords.x, coords.y, coords.z)
    SetBlipSprite(blip, sprite, 1)
    SetBlipScale(blip, 0.2)
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, name)
    return blip
end

function SetBlipStyle(blip, styleHash)
    if type(styleHash) == "string" then
        styleHash = GetHashKey(styleHash)
    end
    Citizen.InvokeNative(0x9CB1A1623062F402, blip, styleHash)
end

function isActive()
    local currentHour = GetClockHours()
    if currentHour >= Config.ActiveTimeStart or currentHour < Config.ActiveTimeEnd then
        return true
    end
    return false
end

function isGreenTime()
    local year, month, day, hour, minute, second = GetPosixTime()
    hour = tonumber(hour) + tonumber(Config.DST)
    if hour > 23 then
        hour = hour - 24
    end
    if hour >= Config.GreenTimeStart and hour < Config.GreenTimeEnd then
        return true
    end
    return false
end

CreateThread(function()
    while true do
        local pause = 1000
        -- OPRAVA: MenuOpen velké M, playingAnimation malé p (aby sedělo s definicemi)
        if MenuOpen == true or playingAnimation == true then
            DisableActions(PlayerPedId())
            DisableBodyActions(PlayerPedId())
            pause = 0
        end
        Citizen.Wait(pause)
    end
end)

function DisableBodyActions(ped)
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x27D1C284, true) -- loot
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x399C6619, true) -- loot
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x41AC83D1, true) -- loot
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xBE8593AF, true) -- INPUT_PICKUP_CARRIABLE2
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xEB2AC491, true) -- INPUT_PICKUP_CARRIABLE
end
function DisableActions(ped)
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xA987235F, true) -- LookLeftRight
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xD2047988, true) -- LookUpDown
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x39CCABD5, true) -- VehicleMouseControlOverride

    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x4D8FB4C1, true) -- disable left/right
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xFDA83190, true) -- disable forward/back
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xDB096B85, true) -- INPUT_DUCK
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x8FFC75D6, true) -- disable sprint

    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x9DF54706, true) -- veh turn left
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x97A8FD98, true) -- veh turn right
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x5B9FD4E2, true) -- veh forward
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x6E1F639B, true) -- veh backwards
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xFEFAB9B4, true) -- disable exit vehicle

    Citizen.InvokeNative(0x2970929FD5F9FC89, ped, true) -- Disable weapon firing
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x07CE1E61, true) -- disable attack
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xF84FA74F, true) -- disable aim
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xAC4BD4F1, true) -- disable weapon select
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x73846677, true) -- disable weapon
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x0AF99998, true) -- disable weapon
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xB2F377E8, true) -- disable melee
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xADEAF48C, true) -- disable melee
end

-- ... (předchozí kód zůstává stejný)
function OpenMenu(menu, creator)
    SetNuiFocus(true, true)
    MenuOpen = true

    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)

    local gender = "male"
    if not IsPedMale(ped) then
        gender = "female"
    end

    -- Uložíme si aktuální stav pro případné zrušení (Cancel)
    -- ClothesCache se plní při načtení postavy, ale pro jistotu ho aktualizujeme před otevřením
if PlayerClothes then
    ClothesCache = DeepCopy(PlayerClothes)
else
    ClothesCache = {}
end
    OriginalBody = {
        bodies_upper = GetIndexFromMeta("bodies_upper", ped),
        bodies_lower = GetIndexFromMeta("bodies_lower", ped)
    }

    local menuData = GetStructuredMenu(menu)
    
    initScene()

    SendNUIMessage({
        action = "openClothingMenu",
        menuData = menuData,
        gender = gender,
        bodyCategories = Config.BodyCategories,
        creatorMode = creator,
        -- NOVÉ: Posíláme info, zda upravujeme item (aby se zobrazilo tlačítko)
        isItemMode = (CurrentItemContext ~= nil),
        itemLabel = CurrentItemContext and CurrentItemContext.itemName or "" 
    })
end

function initScene()
    local ped = PlayerPedId()
    
    -- Reset hodnot
    camHeight = 0.5
    camDistance = 2.5
    camHeadingOffset = GetEntityHeading(ped) + 180.0 -- Kamera se dívá na hráče zepředu

    if not DoesCamExist(Camera) then
        Camera = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end

    SetCamActive(Camera, true)
    RenderScriptCams(true, false, 0, true, true)
    
    UpdateCameraPosition()
end

function EndScene()
    if DoesCamExist(Camera) then
        SetCamActive(Camera, false)
        RenderScriptCams(false, false, 0, true, true)
        DestroyCam(Camera, false)
        Camera = nil
    end
    FreezeEntityPosition(PlayerPedId(), false)
end

function UpdateCameraPosition()
    if not Camera or not DoesCamExist(Camera) then
        return
    end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    -- Výpočet pozice kamery
    local rad = math.rad(camHeadingOffset)
    local camX = coords.x + (math.sin(rad) * camDistance)
    local camY = coords.y + (math.cos(rad) * camDistance)
    
    -- Zde je výška samotné kamery
    local camZ = coords.z + camHeight

    SetCamCoord(Camera, camX, camY, camZ)
    
    -- OPRAVA: Kamera se nyní dívá na stejnou výšku (Z), ve které se nachází.
    -- Tím docílíme efektu "výtahu" místo rotace úhlu.
    -- (coords.z + camHeight) zajistí, že se díváme přímo před sebe.
    PointCamAtCoord(Camera, coords.x, coords.y, coords.z + camHeight) 
end

exports("creator", function()
    dataReady = false
    OpenMenu(Config.ClothingMenu, true)
    while not dataReady do
        Citizen.Wait(100)
    end
    local result = dataReady
    dataReady = false
    return result
end)