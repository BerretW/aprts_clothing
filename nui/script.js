let currentCategory = null;
let currentItems = [];
let currentItemIndex = -1; // -1 = Nic (Svlečeno), 0 = První item
let currentVarID = 1;      // Lua počítá od 1
let gender = "male";

// Konfigurace palet - musí odpovídat Config.lua
const Palettes = [
    "metaped_tint_generic_clean", "metaped_tint_hair", "metaped_tint_horse_leather", 
    "metaped_tint_animal", "metaped_tint_makeup", "metaped_tint_leather", 
    "metaped_tint_combined_leather"
];

$(document).ready(function() {
    // 1. Naplnění selectu paletami
    const paletteSelect = $('#palette-select');
    Palettes.forEach((pal, index) => {
        let name = pal.replace('metaped_tint_', '').replace(/_/g, ' ');
        paletteSelect.append(new Option(name, index + 1));
    });

    // 2. Naslouchání zprávám z Lua
    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "openClothingMenu") {
            $("#clothing-menu").fadeIn(200);
            gender = data.gender;
            
            // Voláme funkci pro zpracování strukturovaných dat
            setupStructuredCategories(data.menuData);
            
            // Reset UI
            currentCategory = null;
            $("#editor-panel").hide();
            $(".cat-btn").removeClass("active");
        }
    });

    // 3. Zavření klávesou ESC
    document.onkeyup = function(data) {
        if (data.which == 27) closeMenu();
    };
});

function closeMenu() {
    $("#clothing-menu").fadeOut(200);
    $.post(`https://${GetParentResourceName()}/closeClothingMenu`, JSON.stringify({}));
}

// Funkce pro vykreslení strukturovaného menu (Sekce -> Kategorie)
function setupStructuredCategories(menuData) {
    let list = $("#category-list");
    list.html("");

    if (!menuData || menuData.length === 0) {
        list.html('<div style="padding:15px; color:#aaa; text-align:center;">Žádné dostupné kategorie.</div>');
        return;
    }

    menuData.forEach(section => {
        // Vytvoříme Nadpis Sekce
        let headerDiv = $(`<div class="menu-header">${section.header.toUpperCase()}</div>`);
        list.append(headerDiv);

        // Vytvoříme tlačítka pro kategorie
        section.items.forEach(cat => {
            let catLabel = String(cat).replace(/_/g, ' ');
            let btn = $(`<div class="cat-btn">${catLabel}</div>`);
            
            btn.click(function() {
                $(".cat-btn").removeClass("active");
                $(this).addClass("active");
                loadCategoryData(cat);
            });
            list.append(btn);
        });
    });
}

function loadCategoryData(category) {
    currentCategory = category;
    $("#current-cat-title").text(category.replace(/_/g, ' ').toUpperCase());
    
    $("#editor-panel").show();
    $("#item-display").text("Načítám...");

    $.post(`https://${GetParentResourceName()}/getCatData`, JSON.stringify({
        gender: gender,
        category: category
    }), function(data) {
        // Převedeme data na pole, pokud přijdou jako objekt
        currentItems = Array.isArray(data) ? data : Object.values(data);
        
        // Automatický výběr:
        // Pokud jsou data, vybereme 1. item (index 0).
        // Pokud data nejsou, vybereme -1 (Nic).
        if (currentItems.length > 0) {
            selectItem(0); 
        } else {
            selectItem(-1);
        }
    });
}

// === LOGIKA PŘEPÍNÁNÍ ITEMŮ ===
function changeItem(dir) {
    if (!currentItems || currentItems.length === 0) return;

    currentItemIndex += dir;

    // Logika cyklování včetně stavu -1 (Nic)
    // Rozsah: -1 až (length - 1)
    
    if (currentItemIndex < -1) {
        currentItemIndex = currentItems.length - 1; // Skočí na konec
    } else if (currentItemIndex >= currentItems.length) {
        currentItemIndex = -1; // Skočí na "Nic"
    }

    selectItem(currentItemIndex);
}

function selectItem(index) {
    currentItemIndex = index;
    currentVarID = 1; // Reset varianty

    // STAV: SVLEČENO (-1)
    if (currentItemIndex === -1) {
        $("#item-display").text(`0 / ${currentItems.length} (Nic)`);
        $("#variant-display").text("-");
        
        // Deaktivujeme ovládací prvky
        $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', true);
        $(".stepper:eq(1) button").prop('disabled', true); // Vypne tlačítka variant

        $.post(`https://${GetParentResourceName()}/removeItem`, JSON.stringify({
            category: currentCategory
        }));
        return; 
    }

    // STAV: OBLEČENO (0 a více)
    $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', false);
    $(".stepper:eq(1) button").prop('disabled', false);

    let item = currentItems[index];
    
    // Zobrazíme index + 1 (uživatelsky přívětivé)
    $("#item-display").text(`${index + 1} / ${currentItems.length}`);
    updateVariantDisplay(item);

    // Reset hodnot
    $("#tint0, #tint1, #tint2").val(0);
    $("#palette-select").val(1);
    
    sendApplyItem(index + 1, 1);
}

// === LOGIKA PŘEPÍNÁNÍ VARIANT ===
function changeVariant(dir) {
    if (currentItemIndex === -1) return; // Neměnit varianty, když nic nemám

    let max = $("#variant-display").data("max") || 1;
    currentVarID += dir;

    if (currentVarID < 1) currentVarID = max;
    if (currentVarID > max) currentVarID = 1;

    $("#variant-display").text(`${currentVarID} / ${max}`);
    sendApplyItem(currentItemIndex + 1, currentVarID);
}

function updateVariantDisplay(item) {
    let maxVariants = 1;

    // Rozpoznání struktury itemu (Single vs MP List)
    if (item.drawable) {
        if (item.variants && Array.isArray(item.variants)) {
            maxVariants = item.variants.length;
        } else if (item.variants && typeof item.variants === 'object') {
            maxVariants = Object.keys(item.variants).length;
        }
    } else {
        if (Array.isArray(item)) {
            maxVariants = item.length;
        } else if (typeof item === 'object') {
            maxVariants = Object.keys(item).length;
        }
    }

    $("#variant-display").text(`${currentVarID} / ${maxVariants}`);
    $("#variant-display").data("max", maxVariants);
}

// === ODESLÁNÍ DAT ===
function sendApplyItem(index, varID) {
    if (!currentCategory) return;
    $.post(`https://${GetParentResourceName()}/applyItem`, JSON.stringify({
        category: currentCategory,
        index: index,
        varID: varID
    }));
}

function removeItem() {
    selectItem(-1); // Použijeme logiku pro index -1
}

function applyPalette() {
    if (!currentCategory || currentItemIndex === -1) return;
    let palIndex = $("#palette-select").val();
    $.post(`https://${GetParentResourceName()}/changePalette`, JSON.stringify({
        category: currentCategory,
        palette: parseInt(palIndex)
    }));
}

function applyTint() {
    if (!currentCategory || currentItemIndex === -1) return;
    let t0 = $("#tint0").val();
    let t1 = $("#tint1").val();
    let t2 = $("#tint2").val();

    $.post(`https://${GetParentResourceName()}/changeTint`, JSON.stringify({
        category: currentCategory,
        tint0: t0,
        tint1: t1,
        tint2: t2
    }));
}

function saveClothes() {
    $.post(`https://${GetParentResourceName()}/saveClothes`, JSON.stringify({}));
    closeMenu();
}