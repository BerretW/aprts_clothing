-- client/overlay.lua

PlayerOverlays = {} 

-- Funkce pro získání dat pro NUI
function ApplyOverlayToPed(ped, layername, index, palette, t0, t1, t2, opacity, sheetGrid, blendType)
    if not index or index < 1 then
        if jo.pedTexture.disable then
            jo.pedTexture.disable(ped, layername)
        end
        PlayerOverlays[layername] = nil
        return
    end

    local variations = jo.pedTexture.variations[layername]
    if not variations or not variations[index] then return end

    local data = DeepCopy(variations[index].value)
    
    data.palette = palette or "metaped_tint_makeup"
    data.opacity = opacity or 1.0
    data.tint0 = t0 or 0
    data.tint1 = t1 or 0
    data.tint2 = t2 or 0
    -- data.sheetGrid = sheetGrid or 0
    -- data.blendType = blendType or 1

    jo.pedTexture.apply(ped, layername, data)

    PlayerOverlays[layername] = {
        index = index,
        palette = data.palette,
        opacity = data.opacity,
        -- sheetGrid = data.sheetGrid,
        -- blendType = data.blendType,
        tint0 = data.tint0,
        tint1 = data.tint1,
        tint2 = data.tint2
    }
end

function GetOverlayMenuData()
    local menuData = {}
    for _, layername in ipairs(Config.OverlayList) do
        local variations = jo.pedTexture.variations[layername]
        if variations then
            local items = {}
            table.insert(items, { label = "Žádné", index = -1 })
            for i, var in ipairs(variations) do
                table.insert(items, { label = var.label or ("Styl " .. i), index = i })
            end

            local currentData = PlayerOverlays[layername] or { 
                index = -1, 
                opacity = 1.0,
                sheetGrid = 0,
                blendType = 1,
                tint0 = 0, tint1 = 0, tint2 = 0, 
                palette = "metaped_tint_makeup" 
            }

            table.insert(menuData, {
                id = layername,
                label = Config.OverlayLabels[layername] or layername,
                items = items,
                current = currentData
            })
        end
    end
    return menuData
end

function LoadPlayerOverlays(data)
    if not data then return end
    PlayerOverlays = data
    RefreshOverlays(PlayerPedId())
end

-- Refresh všech overlayů (volat při spawnu nebo změně oblečení)
function RefreshOverlays(ped)
    ped = ped or PlayerPedId()
    if not PlayerOverlays then return end
    print("Refreshing overlays...")
    for layername, data in pairs(PlayerOverlays) do
        if data and data.index and data.index > -1 then
            ApplyOverlayToPed(ped, layername, data.index, data.palette, data.tint0, data.tint1, data.tint2, data.opacity)
        end
    end
end