-- client/overlay.lua

-- Cache pro uložené overlaye hráče
PlayerOverlays = {} 

-- Funkce pro získání dat pro NUI
function GetOverlayMenuData()
    local menuData = {}
    local ped = PlayerPedId()

    for _, layername in ipairs(Config.OverlayList) do
        -- Získáme variace z knihovny jo
        local variations = jo.pedTexture.variations[layername]
        
        if variations then
            local items = {}
            
            -- Přidáme možnost "Žádné / Vypnuto"
            table.insert(items, {
                label = "Žádné",
                index = -1
            })

            -- Načteme dostupné textury
            for i, var in ipairs(variations) do
                table.insert(items, {
                    label = var.label or ("Styl " .. i),
                    index = i -- Lua index (od 1)
                })
            end

            -- Zjistíme aktuální stav (pokud je uložen)
            local currentData = PlayerOverlays[layername] or { index = -1, tint0 = 0, tint1 = 0, tint2 = 0, palette = "metaped_tint_makeup" }

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

-- Aplikace Overlaye na peda
function ApplyOverlayToPed(ped, layername, index, palette, t0, t1, t2)
    -- Pokud je index -1 nebo nil, overlay odstraníme (respektive nenačteme)
    if not index or index < 1 then
        -- V jo_libs není přímý "remove", ale můžeme aplikovat nil nebo prázdné, 
        -- záleží na implementaci jo.pedTexture. 
        -- Obvykle stačí nevolat apply při refresh.
        -- Pro okamžitý efekt zkusíme nastavit "transparent" hodnoty nebo pokud jo.libs má disable:
        if jo.pedTexture.disable then
            jo.pedTexture.disable(ped, layername)
        end
        
        PlayerOverlays[layername] = nil
        return
    end

    local variations = jo.pedTexture.variations[layername]
    if not variations or not variations[index] then return end

    -- Získáme data textury a upravíme je
    local data = variations[index].value
    
    -- Nastavení palety a tintů
    -- POZOR: jo.libs často očekává palette jako string názvu, ne hash
    data.palette = palette or "metaped_tint_makeup"
    data.tint0 = t0 or 0 -- Opacity / Albedo
    data.tint1 = t1 or 0 -- Color
    data.tint2 = t2 or 0 -- Roughness / Other

    -- Aplikace přes knihovnu
    jo.pedTexture.apply(ped, layername, data)

    -- Uložení do cache
    PlayerOverlays[layername] = {
        index = index,
        palette = palette,
        tint0 = t0,
        tint1 = t1,
        tint2 = t2
    }
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

    for layername, data in pairs(PlayerOverlays) do
        -- Aplikujeme pouze pokud máme platná data
        if data and data.index and data.index > -1 then
            -- Funkce ApplyOverlayToPed musí být definována (viz předchozí odpověď)
            ApplyOverlayToPed(ped, layername, data.index, data.palette, data.tint0, data.tint1, data.tint2)
        end
    end
end