-- client/menu.lua
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
        
        -- Indikuje, zda editujeme již existující item (kliknuto v invu)
        isItemMode = (CurrentItemContext ~= nil),
        itemLabel = CurrentItemContext and CurrentItemContext.itemName or "",

        -- NOVÉ: Posíláme seznam typů itemů (clothing_hat, clothing_torso...) pro výběr při tvorbě nového itemu
        availableItemTypes = Config.ClothingItems 
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