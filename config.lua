Config = {}
Config.Debug = false
Config.DST = 1
Config.GreenTimeStart = 16
Config.GreenTimeEnd = 23
Config.ActiveTimeStart = 23
Config.ActiveTimeEnd = 3

Config.WebHook = ""
Config.ServerName = 'WestHaven ** Loger'
Config.DiscordColor = 16753920
Config.Jobs = {{job = 'police', grade = 1}, {job = 'doctor', grade = 3}}

Config.Palettes = {
    "metaped_tint_generic_clean", "metaped_tint_hair",
    "metaped_tint_horse_leather", "metaped_tint_animal", "metaped_tint_makeup",
    "metaped_tint_leather", "metaped_tint_combined_leather"
}

Config.EssentialsCategories =
    { -- Categories that will not be removed when changing clothes, and not be saved when creating an outfit
        "bodies_upper", "bodies_lower", "heads", "hair", "hair_bonnet", "beard",
        "teeth", "eyes", "beards_chin", "beards_chops", "beards_mustache",
        "beards_complete"
    }

Config.ClothingMenu = {
    ["Torso"] = {
        "vests", "cloaks", "shirts_full", "dresses", "satchels", "armor", "outfits", "ponchos","coats_closed","coats_heavy"
    },
    ["Legs"] = {
        "spats", "aprons", "chaps", "pants", "chaps", "chaps", "chaps", "chaps",
        "chaps"
    },
    ["Feet"] = {
        "boots", "spats", "spats", "spats", "spats", "spats", "spats", "spats"
    },
    ["Hands"] = {
        "gauntlets", "wrist_bindings", "gloves", "gloves", "gloves", "gloves", "gloves",
        "gloves"
    },
    ["Head"] = {"masks", "eyewear", "face_props", "masks_large", "headwear", "neckwear", "hats"},
    ["Accessories"] = {
       "jewelry_rings_right", "ammo_pistols", "neckties", "neckerchiefs", "accessories",
        "jewelry_bracelets", "vest_accessories", "belts"
    }
    ,["LOADOUTS"] = {
        "loadouts", "holsters_left", "holsters_crossdraw", "holsters_center", "belt_buckles", "gunbelts", "gunbelt_accs",
    }
}
