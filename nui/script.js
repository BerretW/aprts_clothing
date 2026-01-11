let currentCategory = null;
let currentItems = [];
let currentItemIndex = -1; // -1 = Nic (Svlečeno), 0 = První item
let currentVarID = 1;      // Lua počítá od 1
let gender = "male";

// Stav pro levé menu (Tělo)
let bodyState = {};

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
            
            // Inicializace pravého menu (Oblečení)
            setupStructuredCategories(data.menuData);

            // Inicializace levého menu (Tělo)
            if (data.bodyCategories) {
                initBodyMenu(data.bodyCategories);
            }
            
            // Reset UI pravého menu
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
    $("#body-menu").fadeOut(200);
    $.post(`https://${GetParentResourceName()}/closeClothingMenu`, JSON.stringify({}));
}

// =========================================================
// SEKCE: PRAVÉ MENU (OBLEČENÍ)
// =========================================================

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
        section.items.forEach(catItem => {
            // catItem je nyní objekt { id: "hats", label: "Klobouky" }
            let btn = $(`<div class="cat-btn">${catItem.label}</div>`);
            
            btn.click(function() {
                $(".cat-btn").removeClass("active");
                $(this).addClass("active");
                // Pro logiku scriptu používáme technické ID (catItem.id)
                loadCategoryData(catItem.id);
            });
            list.append(btn);
        });
    });
}

function loadCategoryData(category) {
    currentCategory = category;
    
    // Zobrazíme název kategorie v hlavičce editoru (vezmeme text z aktivního tlačítka)
    let activeLabel = $(".cat-btn.active").text() || category;
    $("#current-cat-title").text(activeLabel.toUpperCase());
    
    $("#editor-panel").show();
    $("#item-display").text("Načítám...");

    $.post(`https://${GetParentResourceName()}/getCatData`, JSON.stringify({
        gender: gender,
        category: category
    }), function(data) {
        // Data nyní chodí jako objekt: { items: [], currentIndex: X, currentVar: Y }
        
        // Zpracování dat (podpora starého i nového formátu pro jistotu)
        if (Array.isArray(data)) {
            // Starý formát (jen pole) - fallback
            currentItems = data;
            selectItem(0, true); 
        } else {
            // Nový formát
            currentItems = data.items || [];
            let savedIndex = data.currentIndex; // Index, co má hráč na sobě
            let savedVar = data.currentVar;

            if (!currentItems) currentItems = [];

            // Pokud hráč má item na sobě (index není -1 a je definován)
            if (savedIndex !== undefined && savedIndex !== null && savedIndex !== -1) {
                currentVarID = savedVar || 1;
                // Silent = true (jen aktualizovat UI, neposílat na server)
                selectItem(savedIndex, true); 
            } else {
                // Hráč nic nemá -> zobrazit stav "Nic"
                selectItem(-1, true);
            }
        }
    });
}

// === LOGIKA PŘEPÍNÁNÍ ITEMŮ ===
function changeItem(dir) {
    if (!currentItems || currentItems.length === 0) return;

    currentItemIndex += dir;

    // Cyklování včetně stavu -1 (Nic)
    if (currentItemIndex < -1) {
        currentItemIndex = currentItems.length - 1;
    } else if (currentItemIndex >= currentItems.length) {
        currentItemIndex = -1;
    }

    // Změna uživatelem -> silent = false (chceme aplikovat změnu)
    selectItem(currentItemIndex, false);
}

// Hlavní funkce pro výběr itemu
// silent = true -> jen nastavit UI (používá se při načtení kategorie)
// silent = false -> poslat změnu na server (používá se při klikání na šipky)
function selectItem(index, silent = false) {
    currentItemIndex = index;

    // Pokud neměníme item v tichém režimu, resetujeme variantu na 1
    if (!silent) {
        currentVarID = 1; 
    }

    // STAV: SVLEČENO (-1)
    if (currentItemIndex === -1) {
        $("#item-display").text(`0 / ${currentItems.length} (Nic)`);
        $("#variant-display").text("-");
        
        // Deaktivujeme ovládací prvky
        $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', true);
        $(".stepper:eq(1) button").prop('disabled', true);

        // Pokud to není jen načítání UI, pošleme příkaz ke svléknutí
        if (!silent) {
            $.post(`https://${GetParentResourceName()}/removeItem`, JSON.stringify({
                category: currentCategory
            }));
        }
        return; 
    }

    // STAV: OBLEČENO (0 a více)
    $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', false);
    $(".stepper:eq(1) button").prop('disabled', false);

    let item = currentItems[index];
    
    // Zobrazíme index + 1
    $("#item-display").text(`${index + 1} / ${currentItems.length}`);
    updateVariantDisplay(item);

    if (!silent) {
        // Reset posuvníků při změně itemu
        $("#tint0, #tint1, #tint2").val(0);
        $("#palette-select").val(1);
        
        // Aplikovat na postavu
        sendApplyItem(index + 1, 1);
    }
}

// === LOGIKA PŘEPÍNÁNÍ VARIANT ===
function changeVariant(dir) {
    if (currentItemIndex === -1) return; 

    let max = $("#variant-display").data("max") || 1;
    currentVarID += dir;

    if (currentVarID < 1) currentVarID = max;
    if (currentVarID > max) currentVarID = 1;

    $("#variant-display").text(`${currentVarID} / ${max}`);
    sendApplyItem(currentItemIndex + 1, currentVarID);
}

function updateVariantDisplay(item) {
    let maxVariants = 1;
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
    selectItem(-1, false);
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


// =========================================================
// SEKCE: LEVÉ MENU (TĚLO - BODY MENU)
// =========================================================

function initBodyMenu(categories) {
    $("#body-menu").fadeIn(200);
    let container = $("#body-controls-list");
    container.html("");
    bodyState = {};

    categories.forEach(cat => {
        // Jednoduchý překlad názvů pro body parts
        let label = cat;
        if(cat === "bodies_upper") label = "Horní část těla";
        if(cat === "bodies_lower") label = "Dolní část těla";

        // HTML struktura řádku
        let row = `
            <div class="body-row" id="body-row-${cat}">
                <label>${label}</label>
                <div class="stepper">
                    <button onclick="changeBodyPart('${cat}', -1)">◄</button>
                    <span id="body-display-${cat}">Načítám...</span>
                    <button onclick="changeBodyPart('${cat}', 1)">►</button>
                </div>
            </div>
        `;
        container.append(row);

        // Načtení dat pro tuto kategorii těla
        fetchBodyData(cat);
    });
}

function fetchBodyData(category) {
    $.post(`https://${GetParentResourceName()}/getCatData`, JSON.stringify({
        gender: gender,
        category: category
    }), function(data) {
        // Uložíme data do bodyState
        let items = data.items || [];
        // Zjistíme aktuální index (pokud Lua vrátila -1 nebo nic, použijeme 0 jako default pro tělo)
        let currentIdx = (data.currentIndex !== undefined && data.currentIndex !== -1) ? data.currentIndex : 0;
        
        bodyState[category] = {
            items: items,
            index: currentIdx
        };

        updateBodyDisplay(category);
    });
}

function changeBodyPart(category, dir) {
    if (!bodyState[category]) return;

    let state = bodyState[category];
    state.index += dir;

    // Cyklování indexu
    if (state.index < 0) state.index = state.items.length - 1;
    if (state.index >= state.items.length) state.index = 0;

    updateBodyDisplay(category);
    
    // Aplikace změny na postavu (vždy index + 1 pro Lua, varID 1 pro těla)
    // Používáme speciální funkci, abychom neovlivnili hlavní menu
    $.post(`https://${GetParentResourceName()}/applyItem`, JSON.stringify({
        category: category,
        index: state.index + 1,
        varID: 1
    }));
}

function updateBodyDisplay(category) {
    let state = bodyState[category];
    if (state && state.items) {
        $(`#body-display-${category}`).text(`${state.index + 1} / ${state.items.length}`);
    }
}

function resetToNaked() {
    $.post(`https://${GetParentResourceName()}/resetToNaked`, JSON.stringify({}), function() {
        // Callback po úspěšném resetu:
        
        // 1. Aktualizujeme levé menu (Tělo), aby ukazovalo správná čísla
        // (Protože Lua teď změnila tělo zpět na OriginalBody)
        if (bodyState["bodies_upper"]) fetchBodyData("bodies_upper");
        if (bodyState["bodies_lower"]) fetchBodyData("bodies_lower");

        // 2. Aktualizujeme pravé menu, pokud je otevřené
        if (currentCategory) {
            loadCategoryData(currentCategory);
        }
    });
}

function refreshPed() {
    $.post(`https://${GetParentResourceName()}/refresh`, JSON.stringify({}));
}