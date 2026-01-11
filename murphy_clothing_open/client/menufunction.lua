ContextualDataOn = false
function UpdateContextualDatas(value, category)
    if value then
        if value > 0 then 
            local variationAmount = 1
            local variationValue = 1
            local tints = {}
            local data = {}
            if category == "bodies_lower" or category == "bodies_upper" then
                variationAmount = #AlbedoData[SelectedGender][category]
                -- tints = {
                --     {tintId = 1, value = 1},
                --     {tintId = 2, value = 1},
                --     {tintId = 3, value = 1}
                -- }
            else
                
                if type(ClothesCache[category].texture) == "table" then
                    variationValue = ClothesCache[category].texture.palette or ClothesCache[category].texture.palette
                    
                else
                    variationValue = ClothesCache[category].texture
                end

                -- Ensure variationValue is valid and positive
                if not variationValue or variationValue < 1 then
                    variationValue = 1
                end

                if MURPHY_ASSETS[SelectedGender][category][value].variants then
                    variationAmount = #MURPHY_ASSETS[SelectedGender][category][value].variants
                    tint0value = ClothesCache[category].texture and ClothesCache[category].texture.tint0 or MURPHY_ASSETS[SelectedGender][category][value].variants[1].tint[1] or 1
                    tint1value = ClothesCache[category].texture and ClothesCache[category].texture.tint1 or MURPHY_ASSETS[SelectedGender][category][value].variants[1].tint[2] or 1
                    tint2value = ClothesCache[category].texture and ClothesCache[category].texture.tint2 or MURPHY_ASSETS[SelectedGender][category][value].variants[1].tint[3] or 1
                    -- Ensure tint values are valid numbers
                    tint0value = tonumber(tint0value) or 1
                    tint1value = tonumber(tint1value) or 1
                    tint2value = tonumber(tint2value) or 1
                    tints = {
                        {tintId = 1, value = tint0value},
                        {tintId = 2, value = tint1value},
                        {tintId = 3, value = tint2value}
                    }
                else
                    variationAmount = #MURPHY_ASSETS[SelectedGender][category][value]
                    if type(ClothesCache[category].texture) == "table" then 
                        tint0value = ClothesCache[category].texture.tint0 or 1
                        tint1value = ClothesCache[category].texture.tint1 or 1
                        tint2value = ClothesCache[category].texture.tint2 or 1
                    else
                        tint0value = 1
                        tint1value = 1
                        tint2value = 1
                    end
                    -- Ensure tint values are valid numbers
                    tint0value = tonumber(tint0value) or 1
                    tint1value = tonumber(tint1value) or 1
                    tint2value = tonumber(tint2value) or 1
                    tints = {
                        {tintId = 1, value = tint0value},
                        {tintId = 2, value = tint1value},
                        {tintId = 3, value = tint2value}
                    }
                end

            end
            data = {
                variationAmount = variationAmount,
                variationValue = variationValue or 1,
                tints = tints,
                contextual = "variation",
                category = category,
            }
            SendNUIMessage(
                {
                    type = "contextualDatas",
                    data = data
        
                }
            )
            if ContextualDataOn == false then
                ContextualDataOn = true
                PlaySound("SELECT", "HUD_PLAYER_MENU")
            end
        else
            PlaySound("BACK", "HUD_PLAYER_MENU")
            ContextualDataOn = false
            SendNUIMessage(
                {
                    type = "hidecontextualDatas",
        
                }
            )
        end


    end
end

OutfitPrice = 0
function CalculatePrice()
    if CreatorMode == true then
        return 0
    end
	local price = 0
    local outfitmodifier = OutfitPrice or 0
        for k,v in pairs(MURPHY_ASSETS[SelectedGender]) do
            if k ~= "bodies_upper" and k ~= "bodies_lower" then
                if OldClothesCache[k].model then 
                    if OldClothesCache[k].model ~= ClothesCache[k].model then
                        if ClothesCache[k].model > 0 then
                            if Config.Price[k] then
                                price = price + Config.Price[k]
                            else
                                price = price
                            end
                        end
                    end
                else
                    if ClothesCache[k].model > 0 then
                        if Config.Price[k] then
                            price = price + Config.Price[k]
                        else
                            price = price
                        end
                    end
                end
            end
        end
        SendNUIMessage({
            type = "setOutfitPricet",
            price = price + outfitmodifier
        })

		return price + outfitmodifier
end
