-- client/utils.lua
Progressbar = exports["vorp_progressbar"]:initiate()

function debugPrint(msg)
    if Config.Debug == true then
        print("^1[SCRIPT]^0 " .. msg)
    end
end

function notify(text)
    TriggerEvent('notifications:notify', "SCRIPT", text, 3000)
end

function WaitForCharacter()
    while not LocalPlayer do Citizen.Wait(100) end
    while not LocalPlayer.state do Citizen.Wait(100) end
    while not LocalPlayer.state.Character do Citizen.Wait(100) end
end

function table.count(tbl)
    local count = 0
    for _ in pairs(tbl) do count = count + 1 end
    return count
end

function round(num)
    return math.floor(num * 100 + 0.5) / 100
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
    else
        copy = orig
    end
    return copy
end

function playAnim(entity, dict, name, flag, time)
    playingAnimation = true
    RequestAnimDict(dict)
    local waitSkip = 0
    while not HasAnimDictLoaded(dict) do
        waitSkip = waitSkip + 1
        if waitSkip > 100 then break end
        Citizen.Wait(0)
    end

    Progressbar.start("Něco dělám", time, function() end, 'blood', 'rgba(255, 255, 255, 0.8)', '20vw', 'rgba(255, 255, 255, 0.1)', 'rgba(211, 11, 21, 0.5)')

    TaskPlayAnim(entity, dict, name, 1.0, 1.0, time, flag, 0, true, 0, false, 0, false)
    Wait(time)
    playingAnimation = false
end

function DisableBodyActions(ped)
    -- Seznam native volání pro vypnutí akcí (loot, pickup atd.)
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0x27D1C284, true) -- loot
    -- ... (zbytek tvých disable funkcí)
end

function DisableActions(ped)
    -- Seznam native volání pro pohyb a boj
    Citizen.InvokeNative(0xFE99B66D079CF6BC, 0, 0xA987235F, true) -- LookLeftRight
    -- ... (zbytek tvých disable funkcí)
end

-- Export pro bezpečné volání (pokud ho používáš)
function SafeExport(resourceName, functionName, defaultReturn, ...)
    if GetResourceState(resourceName) ~= "started" then
        debugPrint("^1[ERROR]^7 Export failed: " .. resourceName .. " is not started.")
        return defaultReturn
    end
    local success, result = pcall(exports[resourceName][functionName], ...)
    if success then return result else return defaultReturn end
end