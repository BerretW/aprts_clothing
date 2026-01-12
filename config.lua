Config = {}
Config.Debug = false

-- Nastavení času (volitelné)
Config.DST = 1
Config.GreenTimeStart = 16
Config.GreenTimeEnd = 23
Config.ActiveTimeStart = 23
Config.ActiveTimeEnd = 3

-- Server settings
Config.WebHook = ""
Config.ServerName = 'WestHaven ** Loger'
Config.DiscordColor = 16753920

-- Jobs (pokud používáš job lock)
Config.Jobs = {{job = 'police', grade = 1}, {job = 'doctor', grade = 3}}

-- Základní názvy itemů pro ukládání (Inventář)
-- Do těchto itemů se budou řadit kategorie podle Config.ItemMapping
Config.ClothingItems = {
    "clothing_hat",
    "clothing_torso",
    "clothing_bottom",
    "clothing_access",
    "clothing_all" 
}

-- Mapování kategorií do typů itemů
-- Když hráč koupí "hats", uloží se to do itemu "clothing_hat"
Config.ItemMapping = {
    ["clothing_hat"] = { 
        "hats", "hat_accessories", "masks", "masks_large", "eyewear", "headwear", "face_props", "hair_accessories" 
    }
}

-- =========================================================
-- CENÍK (PRICING)
-- Pokud cena chybí, použije se DefaultPrice
-- =========================================================
Config.DefaultPrice = 5.0 

Config.CategoryPrices = {
    -- Male Head Categories
    ["hats"] = 5.0,
    ["masks"] = 10.0,
    ["eyewear"] = 3.0,
    ["headwear"] = 4.0,
    ["face_props"] = 2.0,
    ["hat_accessories"] = 1.0,
    ["masks_large"] = 12.0,

    -- Male Upper Categories
    ["coats"] = 15.0,
    ["shirts_full"] = 8.0,
    ["lduvmjua_0x2b388a05"] = 8.0,
    ["vests"] = 6.0,
    ["suspenders"] = 3.0,
    ["unionsuits_full"] = 7.0,
    ["overalls_full"] = 10.0,
    ["shirts_full_overpants"] = 9.0,
    ["cloaks"] = 12.0,
    ["overalls_modular_uppers"] = 9.0,
    ["coats_closed"] = 15.0,
    ["outfits"] = 20.0,
    ["coats_heavy"] = 18.0,
    ["ponchos"] = 10.0,

    -- Male Lower Categories
    ["pants"] = 10.0,
    ["overalls_modular_lowers"] = 8.0,
    ["dresses"] = 12.0,
    ["skirts"] = 10.0,
    ["unionsuit_legs"] = 7.0,

    -- Male Feet Categories
    ["boots"] = 12.0,
    ["boot_accessories"] = 3.0,
    ["spats"] = 5.0,

    -- Male Accessories Categories
    ["neckerchiefs"] = 3.0,
    ["neckties"] = 4.0,
    ["gloves"] = 5.0,
    ["belts"] = 6.0,
    ["accessories"] = 4.0,
    ["badges"] = 3.0,
    ["satchels"] = 8.0,
    ["neckwear"] = 4.0,
    ["jewelry_necklaces"] = 15.0,
    ["jewelry_rings"] = 12.0,
    ["vest_accessories"] = 3.0,
    ["hair_accessories"] = 3.0,
    ["aprons"] = 5.0,
    ["coat_accessories"] = 3.0,
    ["chaps"] = 8.0,
    ["pants_accessories"] = 3.0,
    ["armor"] = 20.0,
    ["jewelry_bracelets"] = 10.0,
    ["wrist_bindings"] = 4.0,
    ["gauntlets"] = 7.0,
    ["ankle_bindings"] = 4.0,
    ["belt_buckles"] = 6.0,
    ["jewelry_rings_right"] = 12.0,
    ["jewelry_rings_left"] = 12.0,
    ["satchel_straps"] = 5.0,
    ["jewelry_earrings"] = 10.0,

    -- Male Weapons Categories
    ["gunbelts"] = 15.0,
    ["holsters_right"] = 10.0,
    ["holsters_knife"] = 8.0,
    ["loadouts"] = 25.0,
    ["holsters_left"] = 10.0,
    ["holsters_crossdraw"] = 10.0,
    ["holsters_center"] = 10.0,
    ["gunbelt_accs"] = 5.0,
    ["holsters_quivers"] = 12.0,
    ["ammo_pistols"] = 8.0,

    -- Female Specific Categories
    ["capes"] = 12.0,
    ["shawls"] = 8.0,
    ["corsets"] = 10.0,
    ["chemises"] = 7.0,
    ["knickers"] = 5.0,
    ["stockings"] = 3.0,
    ["nbtudvja_0x53b67599"] = 8.0,
    ["cnvfyaba_0xd7ae0d03"] = 10.0,
    ["gjrbmoma_0xcb39a6f4"] = 10.0,
    ["pnyvpusa_0x44f4c713"] = 10.0,
    ["ogoolgaa_0xecd61654"] = 10.0,
    ["gnuusvra_0x7024af8b"] = 10.0,
    ["oacpqvda_0x41292b6f"] = 10.0,
    ["ywkywwvb_0xe93b9f1b"] = 10.0,
    ["mbbwboia_0x42e8f927"] = 5.0,

    -- Other categories
    ["hairs"] = 8.0,
    ["hair"] = 8.0, -- Přidáno pro jistotu, někdy se liší názvy v DB vs Menu

    -- Bodies categories (Free)
    ["bodies_upper"] = 0.0,
    ["bodies_lower"] = 0.0,
    ["heads"] = 0.0,
    ["eyes"] = 0.0,
    ["teeth"] = 0.0,
    ["beard"] = 5.0, -- Vousy obvykle něco stojí (holič)
    ["beards_complete"] = 5.0,
    ["beards_chin"] = 2.0,
    ["beards_chops"] = 2.0,
    ["beards_mustache"] = 2.0
}


-- =========================================================
-- ESSENTIALS (Co se neukládá do itemů a nemizí)
-- =========================================================
Config.BodyCategories   = { 
    "bodies_upper",
    "bodies_lower",
}

Config.EssentialsCategories = { 
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
    "beards_complete"
}


Config.LoadOrder = {
    -- 1. Základ (Tělo a hlava)
    "bodies_upper",
    "bodies_lower",
    "heads",
    "eyes",
    "teeth",
    "hair",
    "beard",
    "beards_complete",
    "beards_chin",
    "beards_chops",
    "beards_mustache",
    "hair_bonnet",

    -- 2. Spodní prádlo a základní vrstvy
    "stockings",
    "unionsuits_full",
    "unionsuit_legs",
    "chemises",
    "knickers",

    -- 3. Hlavní oblečení (Spodek a Vršek)
    "pants",
    "skirts",
    "breeches",
    "shirts_full",
    "shirts_full_overpants",
    "dresses",
    "overalls_modular_lowers",
    "overalls_modular_uppers",
    "overalls_full",

    -- 4. Boty (Často ovlivňují kalhoty - zastrčení)
    "boots",
    "spats",
    "boot_accessories",

    -- 5. Střední vrstva
    "vests",
    "corsets",
    "suspenders",

    -- 6. Vnější vrstva (Kabáty, Ponča)
    "coats",
    "coats_closed",
    "coats_heavy",
    "ponchos",
    "cloaks",
    "capes",
    "shawls",

    -- 7. Doplňky krku a rukou
    "neckerchiefs",
    "neckties",
    "neckwear",
    "gloves",
    "gauntlets",
    "wrist_bindings",

    -- 8. Opasky a zbraně
    "belts",
    "belt_buckles",
    "gunbelts",
    "gunbelt_accs",
    "holsters_left",
    "holsters_right",
    "holsters_crossdraw",
    "holsters_center",
    "holsters_knife",
    "holsters_quivers",
    "ammo_pistols",
    
    -- 9. Doplňky a šperky
    "jewelry_rings",
    "jewelry_rings_right",
    "jewelry_rings_left",
    "jewelry_bracelets",
    "jewelry_necklaces",
    "jewelry_earrings",
    "badges",
    "satchels",
    "satchel_straps",
    "accessories",
    "vest_accessories",
    "coat_accessories",
    "pants_accessories",
    "chaps",
    "aprons",
    "ankle_bindings",
    "armor",
    "loadouts",

    -- 10. Hlava (nakonec, aby nemizely vlasy)
    "masks",
    "masks_large",
    "eyewear",
    "face_props",
    "headwear",
    "hats",
    "hat_accessories",
    "hair_accessories"
}


-- Palety pro barvy
Config.Palettes = {
    "metaped_tint_generic_clean", "metaped_tint_hair",
    "metaped_tint_horse_leather", "metaped_tint_animal", "metaped_tint_makeup",
    "metaped_tint_leather", "metaped_tint_combined_leather"
}

Config.HairMenu = {
    ["Hair"] = {"hair_accessories", "hair"},
    ["Beard"] = {"beards_chops", "hair_bonnet", "beards_chin", "beards_mustache", "beards_complete"}
}


-- Definice kategorií v Menu (Struktura pro NUI)
Config.ClothingMenu = {
    ["Torso"] = {
        "vests", "cloaks", "shirts_full", "dresses", "satchels", "armor", "outfits", 
        "ponchos","coats_closed","coats_heavy", "corsets", "chemises", "capes", "shawls",
        "coats", "lduvmjua_0x2b388a05"
    },
    ["Legs"] = {
        "spats", "aprons", "chaps", "pants", "skirts", "stockings", 
        "knickers", "petticoats", "overalls_modular_lowers", "unionsuit_legs"
    },
    ["Feet"] = {
        "boots", "boot_accessories"
    },
    ["Hands"] = {
        "gauntlets", "wrist_bindings", "gloves"
    },
    ["Head"] = {
        "masks", "eyewear", "face_props", "masks_large", "headwear", "neckwear", "hats", "hair_accessories"
    },
    ["Accessories"] = {
       "jewelry_rings_right", "jewelry_rings_left", "ammo_pistols", "neckties", "neckerchiefs", "accessories",
        "jewelry_bracelets", "vest_accessories", "belts", "coat_accessories", "jewelry_necklaces",
        "jewelry_earrings", "satchel_straps", "badges", "ankle_bindings"
    },
    ["LOADOUTS"] = {
        "loadouts", "holsters_left", "holsters_crossdraw", "holsters_center", "belt_buckles", 
        "gunbelts", "gunbelt_accs", "holsters_right", "holsters_knife", "holsters_quivers"
    }
}

Config.OverlayList = {
    "eyeshadow",    -- Oční stíny
    "eyeliner",     -- Oční linky
    "blush",        -- Tvářenka
    "lipstick",     -- Rtěnka
    "foundation",   -- Make-up podklad
    "ageing",       -- Stárnutí
    "complex",      -- Pleť (Komplexnost)
    "freckles",     -- Pihy
    "moles",        -- Znaménka
    "acne",         -- Akné
    "spots",        -- Skvrny
    "scar",         -- Jizvy
    "grime",        -- Špína
    "eyebrow",      -- Obočí (textura)
    "beard",        -- Vousy (textura - strniště)
    "hair"          -- Vlasy (textura - doplňky)
}

-- Překlady pro Overlay kategorie
Config.OverlayLabels = {
    ["eyeshadow"] = "Oční stíny",
    ["eyeliner"] = "Oční linky",
    ["blush"] = "Tvářenka",
    ["lipstick"] = "Rtěnka",
    ["foundation"] = "Podkladová báze",
    ["ageing"] = "Vrásky a Stárnutí",
    ["complex"] = "Vzhled pleti",
    ["freckles"] = "Pihy",
    ["moles"] = "Znaménka",
    ["acne"] = "Akné",
    ["spots"] = "Skvrny na kůži",
    ["scar"] = "Jizvy",
    ["grime"] = "Špína",
    ["eyebrow"] = "Obočí (Textura)",
    ["beard"] = "Strniště / Vousy",
    ["hair"] = "Vlasy (Textura)"
}