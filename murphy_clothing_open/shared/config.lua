Config = {}

Config.DevMode = true    -- activate the dev category
Config.GoreBodies = false -- activate the gore bodies category, false is recommended

-- Filter NPC assets (assets with drawable) from the menu
-- ⚠️ WARNING: Changing this value requires a database wipe of murphy_clothing SQL, otherwise there will be problems
-- true = NPC assets will be filtered out
-- false = NPC assets will be available in the menu
Config.FilterNPCAssets = false

Config.framework = "vorp" --- "vorp" or "REDEMRP2k23" or "rsg-core"

Config.MenuCommand = "openmenu" --- nil if you don't want a command to open the menu
Config.NativePrompt = true     -- if you want to use the native prompt instead of the interaction menu
Config.OutfitItem = "clothes"     ---- Outfit item

Config.LoadClothesCommand = "loadclothes"
Config.ClothesManagement = {
    Command = "ClothesManagement", --- nil or Command to open the clothes management menu
    Keybind = 0x70                 --(default F1) nil or keybind must be from https://learn.microsoft.com/en-us/windows/win32/inputdev/virtual-key-codes
}

Config.SingleItemCategory = { ---- Category that will not be in the outfit but in single items `[itemname] = {category1, category2}`
    ["clothes_hat"] = { "hats", "hat_accessories" },
    ["clothes_mask"] = { "masks", "masks_large","eyewear", },
    ["clothes_gloves"] = {"gloves"},

}

Config.JobLocked = { --- categories that will shows up only to specified jobs in shops `[category] = {{"job1", grade}, {"job2", grade}}`
    ["jewelry_rings_right"] = { { "jeweler", 2 }, { "jeweler2", 2 } },
    ["jewelry_rings_left"] = { { "jeweler", 2 }, { "jeweler2", 2 } },
    ["jewelry_bracelets"] = { { "jeweler", 2 }, { "jeweler2", 2 } },
}

/**********************************************************************************************
 *                         TEMPERATURE/METABOLISM SYSTEM                                      *
 **********************************************************************************************/

-- Clothing temperature protection values
-- Configure which clothing categories provide warmth/cold protection
-- Values: "warm" (provides heat), "cold" (provides cooling), "neutral" (no effect)
Config.ClothingTemperature = {
    -- Warm clothing (protection against cold)
    ["coats"] = "warm",
    ["coats_closed"] = "warm",
    ["ponchos"] = "warm",
    ["cloaks"] = "warm",
    ["vests"] = "warm",
    ["shirts_full"] = "neutral",
    ["gloves"] = "warm",
    ["boots"] = "warm",
    ["chaps"] = "warm",
    
    -- Cold/Light clothing (protection against heat)
    ["skirts"] = "cold",
    
    -- Neutral (no temperature effect)
    ["pants"] = "neutral",
    ["hats"] = "neutral",
    ["masks"] = "neutral",
    ["eyewear"] = "neutral",
}

-- Temperature protection levels by item count
-- warm_count: number of warm items equipped
-- Returns: protection level (0 = none, 1 = light, 2 = medium, 3 = heavy)
Config.TemperatureProtection = {
    cold = { -- Protection against cold
        [0] = 0,  -- No protection
        [1] = 1,  -- Light protection (1 warm item)
        [2] = 1,  -- Light protection (2 warm items)
        [3] = 2,  -- Medium protection (3 warm items)
        [4] = 2,  -- Medium protection (4 warm items)
        [5] = 3,  -- Heavy protection (5+ warm items)
    },
    heat = { -- Protection against heat
        [0] = 0,  -- No protection
        [1] = 1,  -- Light protection (1 cold item)
        [2] = 2,  -- Medium protection (2 cold items)
        [3] = 3,  -- Heavy protection (3+ cold items)
    }
}

--[[
    Config.Shops Structure:
    
    Simple (Free Camera):
    ["Shop Name"] = vector3(x, y, z)
    
    Advanced (Fixed Camera):
    ["Shop Name"] = {
        shopCoords = vector3(x, y, z),
        camera = {
            coords = vector3(x, y, z),    -- Position de la caméra
            rotation = vector3(x, y, z),   -- Rotation de la caméra (optionnel)
            fov = 40.0,                     -- Field of view (optionnel, défaut: 40.0)
            pointAt = vector3(x, y, z)      -- Point où la caméra regarde (optionnel)
        }
    }
]]

Config.Shops = {
    ["Spawn"] = vector3(4557.712402, -3458.019775, 49.674847),

    ["Saint-Denis Tailor"] = vector3(2554.636, -1170.411, 53.68349),
    ["Valentine Tailor"] = vector3(-294.857574, 803.235779, 119.288727),
    ["Blackwater Tailor"] = vector3(-761.597961, -1293.637939, 43.835468),
    ["TW Tailor"] = vector3(-5536.572266, -2945.093506, -1.539622),
    ["Tailor"] = vector3(2586.475830, -1011.828613, 44.239956),
    ["Rhodes"] = vector3(1337.064941, -1325.610474, 77.604347)
}

Config.Removecategories = { ---- Modify the F1 menu to remove categories
    head = {
        "hats", "masks", "eyewear", "headwear", "face_props",
        "hat_accessories", "masks_large"
    },
    neck = {
        "neckties", "neckwear", "neckerchiefs"
    },
    torso = {
        "coats", "coats_heavy", "coats_closed", "cloaks", "ponchos",
        "vests", "suspenders", "overalls_full", "shirts_full_overpants",
        "unionsuits_full", "overalls_modular_uppers"
    },
    shirts = {
        "shirts_full", "lduvmjua_0x2b388a05"
    },
    legs = {
        "pants", "pants_accessories", "spats", "belts", "skirts"
    },
    feet = {
        "boot_accessories", "chaps", "boots", "aprons"
    },
    hands = {
        "gloves"
    },
    weapons = {
        "gunbelts", "holsters_right", "holsters_knife", "loadouts",
        "holsters_left", "holsters_crossdraw", "holsters_center",
        "gunbelt_accs", "holsters_quivers", "ammo_pistols"
    },
    accessories = {
        "jewelry_necklaces", "gloves", "belts", "neckwear",
        "neckerchiefs", "neckties", "accessories", "jewelry_earrings",
        "jewelry_bracelets", "aprons", "gauntlets", "chaps",
        "satchels", "jewelry_rings_left", "wrist_bindings",
        "belt_buckles", "badges", "jewelry_rings_right",
        "ankle_bindings", "mbbwboia_0x42e8f927", "pants_accessories",
        "coat_accessories", "armor"
    }
}

Config.Price = {
    -- Male Head Categories
    ["hats"] = 5,
    ["masks"] = 10,
    ["eyewear"] = 3,
    ["headwear"] = 4,
    ["face_props"] = 2,
    ["hat_accessories"] = 1,
    ["masks_large"] = 12,

    -- Male Upper Categories
    ["coats"] = 15,
    ["shirts_full"] = 8,
    ["lduvmjua_0x2b388a05"] = 8,
    ["vests"] = 6,
    ["suspenders"] = 3,
    ["unionsuits_full"] = 7,
    ["overalls_full"] = 10,
    ["shirts_full_overpants"] = 9,
    ["cloaks"] = 12,
    ["overalls_modular_uppers"] = 9,
    ["coats_closed"] = 15,
    ["outfits"] = 20,
    ["coats_heavy"] = 18,
    ["ponchos"] = 10,

    -- Male Lower Categories
    ["pants"] = 10,
    ["overalls_modular_lowers"] = 8,
    ["dresses"] = 12,
    ["skirts"] = 10,
    ["unionsuit_legs"] = 7,

    -- Male Feet Categories
    ["boots"] = 12,
    ["boot_accessories"] = 3,
    ["spats"] = 5,

    -- Male Accessories Categories
    ["neckerchiefs"] = 3,
    ["neckties"] = 4,
    ["gloves"] = 5,
    ["belts"] = 6,
    ["accessories"] = 4,
    ["badges"] = 3,
    ["satchels"] = 8,
    ["neckwear"] = 4,
    ["jewelry_necklaces"] = 15,
    ["jewelry_rings"] = 12,
    ["vest_accessories"] = 3,
    ["hair_accessories"] = 3,
    ["aprons"] = 5,
    ["coat_accessories"] = 3,
    ["chaps"] = 8,
    ["pants_accessories"] = 3,
    ["armor"] = 20,
    ["jewelry_bracelets"] = 10,
    ["wrist_bindings"] = 4,
    ["gauntlets"] = 7,
    ["ankle_bindings"] = 4,
    ["belt_buckles"] = 6,
    ["jewelry_rings_right"] = 12,
    ["jewelry_rings_left"] = 12,
    ["satchel_straps"] = 5,
    ["jewelry_earrings"] = 10,

    -- Male Weapons Categories
    ["gunbelts"] = 15,
    ["holsters_right"] = 10,
    ["holsters_knife"] = 8,
    ["loadouts"] = 25,
    ["holsters_left"] = 10,
    ["holsters_crossdraw"] = 10,
    ["holsters_center"] = 10,
    ["gunbelt_accs"] = 5,
    ["holsters_quivers"] = 12,
    ["ammo_pistols"] = 8,

    -- Female Specific Categories (adding only those not already included above)
    ["capes"] = 12,
    ["shawls"] = 8,
    ["corsets"] = 10,
    ["chemises"] = 7,
    ["knickers"] = 5,
    ["stockings"] = 3,
    ["nbtudvja_0x53b67599"] = 8,
    ["cnvfyaba_0xd7ae0d03"] = 10,
    ["gjrbmoma_0xcb39a6f4"] = 10,
    ["pnyvpusa_0x44f4c713"] = 10,
    ["ogoolgaa_0xecd61654"] = 10,
    ["gnuusvra_0x7024af8b"] = 10,
    ["oacpqvda_0x41292b6f"] = 10,
    ["ywkywwvb_0xe93b9f1b"] = 10,
    ["mbbwboia_0x42e8f927"] = 5,

    -- Other categories from wearablecategories
    ["hairs"] = 8,

    -- Bodies categories
    ["bodies_upper"] = 0, -- These are typically free as they're part of character creation
    ["bodies_lower"] = 0

    -- dev categories are not priced since they're dev-only
}

--- !!!! Changing the table below could result in stability issues, proceed at your own risk !!!! -----
Config.EssentialsCategories = { -- Categories that will not be removed when changing clothes, and not be saved when creating an outfit
    "bodies_upper",
    "bodies_lower",
    "heads",
    "hair",
    "hair_bonnet",
    "beard",
    "teeth",
    "eyes",
    "beards_chin",
    "beards_chops",
    "beards_mustache",
    "beards_complete",
}
