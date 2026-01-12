-- client/menu.lua
function OpenMenu(menu, creator, showBody, showClothes)
    SetNuiFocus(true, true)
    MenuOpen = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)
    
    local gender = IsPedMale(ped) and "male" or "female"
    if showBody == nil then showBody = true end
    if showClothes == nil then showClothes = true end

    if PlayerClothes then ClothesCache = DeepCopy(PlayerClothes) else ClothesCache = {} end
    
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
        isItemMode = (CurrentItemContext ~= nil),
        itemLabel = CurrentItemContext and CurrentItemContext.itemName or "",
        availableItemTypes = Config.ClothingItems,
        showBody = showBody,
        showClothes = showClothes
    })
end

-- NOVÁ FUNKCE: Otevře pouze Overlay Menu (Make-up)
function OpenOverlayMenu()
    SetNuiFocus(true, true)
    MenuOpen = true
    local ped = PlayerPedId()
    FreezeEntityPosition(ped, true)

    initScene()
    
    -- ZMĚNA ZDE: Nastavíme kameru velmi blízko
    camDistance = 0.50  -- Původně bylo 1.2 nebo 2.5. Zkus 0.5 nebo 0.4.
    camHeight = 0.65    -- Výška očí
    
    UpdateCameraPosition()

    SendNUIMessage({
        action = "openOverlayMenu"
    })
end

function GetStructuredMenu(menuDefinition)
    local ped = PlayerPedId()
    local gender = IsPedMale(ped) and "male" or "female"
    local structuredList = {}
    
    if not menuDefinition then return {} end

    for sectionName, categories in pairs(menuDefinition) do
        local validCategories = {}
        for _, cat in ipairs(categories) do
            if Assets[gender] and Assets[gender][cat] and #Assets[gender][cat] > 0 then
                table.insert(validCategories, {
                    id = cat,
                    label = TranslateCat[cat] or cat 
                })
            end
        end
        
        if #validCategories > 0 then
            table.insert(structuredList, { header = sectionName, items = validCategories })
        end
    end
    table.sort(structuredList, function(a, b) return a.header < b.header end)
    return structuredList
end