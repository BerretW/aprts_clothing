local promptkey = 0x760A9C6F
local PromptGroup = GetRandomIntInRange(0, 0xffffff)
local str = 'Open'
local prompttext = "Tailor"

Citizen.CreateThread(function()
        Citizen.Wait(0)
        if Config.NativePrompt == true then

            clothstoreprompt = PromptRegisterBegin()
            PromptSetControlAction(clothstoreprompt, promptkey)
            str = CreateVarString(10, 'LITERAL_STRING', str)
            PromptSetText(clothstoreprompt, str)
            PromptSetEnabled(clothstoreprompt, true)
            PromptSetVisible(clothstoreprompt, true)
            PromptSetHoldMode(clothstoreprompt, true)
            PromptSetGroup(clothstoreprompt, PromptGroup)
            PromptRegisterEnd(clothstoreprompt)
        end
        for k,v in pairs(Config.Shops) do
            local shopCoords = v
            if type(v) == "table" then
                shopCoords = v.shopCoords
            end
            local blip = Citizen.InvokeNative(0x554D9D53F696D002, 1664425300, shopCoords)
            SetBlipSprite(blip, 1195729388)
            SetBlipScale(blip, 0.2)
            Citizen.InvokeNative(0x9CB1A1623062F402, blip, string.format(k))
            if Config.NativePrompt == false then
                exports.murphy_interact:AddInteraction({
                    coords = shopCoords,
                    distance = 8.0, -- optional
                    interactDst = 4.0, -- optional
                    id = k, -- needed for removing interactions
                    options = {
                        {
                            label = "Open the tailor's store",
                            action = function(entity, coords, args)
                                OpenOutfitListMenu(true, k)
                            end,
                        },
                    }
                })
            end
            
        end
end)

if Config.NativePrompt == true then
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(0)
            for k, v in pairs(Config.Shops) do
                local shopCoords = v
                if type(v) == "table" then
                    shopCoords = v.shopCoords
                end
                if #(GetEntityCoords(PlayerPedId()) - shopCoords) < 2.0 and not CreatorLight then
                    local label  = CreateVarString(10, 'LITERAL_STRING', prompttext)
                    PromptSetActiveGroupThisFrame(PromptGroup, label)
                    if IsControlJustPressed(0, promptkey) then
                        OpenOutfitListMenu(true, k)
                    end
                end
            end

        end
    end)
end

if Config.LoadClothesCommand then
    RegisterCommand(Config.LoadClothesCommand, function (source, args, raw)
        Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
            if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
            if datatable then
                local loadclothes = false
                for k, v in pairs(datatable) do
                    if v.model > 0 then
                        loadclothes = true
                        break
                    end
                end
                if loadclothes then
                    TriggerEvent("murphy_clothes:clotheitem",datatable, id)
                end
            end
        end)
    end)
   
end

RegisterNetEvent('murphy_clothing:loadclothes', function()
    Callback.triggerServer('murphy_clothing:GetCurrentClothes', function(datatable, id)
        if IsPedMale(PlayerPedId()) then SelectedGender = "male" else SelectedGender = "female" end
        if datatable then
            local loadclothes = false
            for k, v in pairs(datatable) do
                if v.model > 0 then
                    loadclothes = true
                    break
                end
            end
            if loadclothes then
                TriggerEvent("murphy_clothes:clotheitem",datatable, id)
            end
        end
    end)
end)