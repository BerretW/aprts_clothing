-- client/camera.lua
Camera = nil
camHeight = 0.6
camDistance = 2.5
camHeadingOffset = 0.0

-- ZMĚNA ZDE: minDist sníženo na 0.3 (původně 0.6)
local limits = { minDist = 0.3, maxDist = 3.5, minHeight = -0.7, maxHeight = 0.85 }

function initScene()
    local ped = PlayerPedId()
    
    camHeight = 0.5
    camDistance = 2.5
    camHeadingOffset = GetEntityHeading(ped) + 180.0

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
    if not Camera or not DoesCamExist(Camera) then return end
    
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    local rad = math.rad(camHeadingOffset)
    local camX = coords.x + (math.sin(rad) * camDistance)
    local camY = coords.y + (math.cos(rad) * camDistance)
    local camZ = coords.z + camHeight

    SetCamCoord(Camera, camX, camY, camZ)
    PointCamAtCoord(Camera, coords.x, coords.y, coords.z + camHeight) 
end

-- Funkce volané z NUI
function RotateCharacter(deltaX)
    local ped = PlayerPedId()
    local heading = GetEntityHeading(ped)
    SetEntityHeading(ped, heading - (deltaX * 0.5))
end

function MoveCameraHeight(deltaY)
    camHeight = camHeight - (deltaY * 0.005)
    if camHeight < limits.minHeight then camHeight = limits.minHeight end
    if camHeight > limits.maxHeight then camHeight = limits.maxHeight end
    UpdateCameraPosition()
end

function ZoomCamera(direction)
    local step = 0.2
    if direction == "in" then
        camDistance = camDistance - step
    else
        camDistance = camDistance + step
    end
    
    if camDistance < limits.minDist then camDistance = limits.minDist end
    if camDistance > limits.maxDist then camDistance = limits.maxDist end
    UpdateCameraPosition()
end