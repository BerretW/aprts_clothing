let currentCategory = null;
let currentItems = [];
let currentItemIndex = -1; 
let currentVarID = 1;      
let gender = "male";
let isCreatorMode = false;
let bodyState = {};

// === PROMĚNNÉ PRO OVLÁDÁNÍ KAMERY ===
let isLeftMouseDown = false;
let isRightMouseDown = false;
let previousMouseX = 0;
let previousMouseY = 0;
// ====================================

const Palettes = [
    "metaped_tint_generic_clean", "metaped_tint_hair", "metaped_tint_horse_leather", 
    "metaped_tint_animal", "metaped_tint_makeup", "metaped_tint_leather", 
    "metaped_tint_combined_leather"
];

$(document).ready(function() {
    // Naplnění selectu s paletami
    const paletteSelect = $('#palette-select');
    Palettes.forEach((pal, index) => {
        let name = pal.replace('metaped_tint_', '').replace(/_/g, ' ');
        paletteSelect.append(new Option(name, index + 1));
    });

    // Naslouchání zprávám z LUA
    window.addEventListener('message', function(event) {
        let data = event.data;

        if (data.action === "openClothingMenu") {
            $("#clothing-menu").fadeIn(200);
            gender = data.gender;
            isCreatorMode = data.creatorMode; 
            
            setupStructuredCategories(data.menuData);

            if (data.bodyCategories) {
                initBodyMenu(data.bodyCategories);
            }
            
            currentCategory = null;
            $("#editor-panel").hide();
            $(".cat-btn").removeClass("active");
            
            // Pokud je Creator Mode, skryjeme křížek
            if (isCreatorMode) {
                $(".close-btn").hide();
            } else {
                $(".close-btn").show();
            }

            // Reset stavu myši při otevření
            isLeftMouseDown = false;
            isRightMouseDown = false;
        }
    });

    // Zavření přes ESC
    document.onkeyup = function(data) {
        if (data.which == 27 && !isCreatorMode) closeMenu();
    };

    // ==========================================
    // OVLÁDÁNÍ KAMERY (PŘEPSÁNO DLE VUE VZORU)
    // ==========================================

    // Zamezení kontextového menu
    document.addEventListener('contextmenu', event => event.preventDefault());

    document.addEventListener('mousedown', function(event) {
        // Levé tlačítko (Rotace)
        if (event.button === 0) { 
            isLeftMouseDown = true;
            previousMouseX = event.clientX; // Uložíme aktuální pozici při kliknutí
        } 
        // Pravé tlačítko (Výška)
        else if (event.button === 2) { 
            isRightMouseDown = true;
            previousMouseY = event.clientY; // Uložíme aktuální pozici při kliknutí
        }
    });

    document.addEventListener('mouseup', function(event) {
        isLeftMouseDown = false;
        isRightMouseDown = false;
    });

    document.addEventListener('mousemove', function(event) {
        // Logika pro rotaci (Levé tlačítko)
        if (isLeftMouseDown) {
            let deltaX = event.clientX - previousMouseX;
            previousMouseX = event.clientX; // Aktualizujeme pro další frame
            
            $.post(`https://${GetParentResourceName()}/rotateCharacter`, JSON.stringify({
                x: deltaX
            }));
        }

        // Logika pro výšku kamery (Pravé tlačítko)
        if (isRightMouseDown) {
            let deltaY = event.clientY - previousMouseY;
            previousMouseY = event.clientY; // Aktualizujeme pro další frame

            $.post(`https://${GetParentResourceName()}/moveCameraHeight`, JSON.stringify({
                y: deltaY
            }));
        }
    });

    // Zoom kolečkem
    document.addEventListener('wheel', function(event) {
        let dir = event.deltaY > 0 ? "out" : "in";
        $.post(`https://${GetParentResourceName()}/zoomCamera`, JSON.stringify({
            dir: dir
        }));
    });
});

// ==========================================
// FUNKCE MENU
// ==========================================

function closeMenu() {
    $("#clothing-menu").fadeOut(200);
    $("#body-menu").fadeOut(200);
    $.post(`https://${GetParentResourceName()}/closeClothingMenu`, JSON.stringify({}));
}

function setupStructuredCategories(menuData) {
    let list = $("#category-list");
    list.html("");

    if (!menuData || menuData.length === 0) {
        list.html('<div style="padding:15px; color:#aaa; text-align:center;">Žádné dostupné kategorie.</div>');
        return;
    }

    menuData.forEach(section => {
        let headerDiv = $(`<div class="menu-header">${section.header.toUpperCase()}</div>`);
        list.append(headerDiv);

        section.items.forEach(catItem => {
            let btn = $(`<div class="cat-btn">${catItem.label}</div>`);
            
            btn.click(function() {
                $(".cat-btn").removeClass("active");
                $(this).addClass("active");
                loadCategoryData(catItem.id);
            });
            list.append(btn);
        });
    });
}

function loadCategoryData(category) {
    currentCategory = category;
    
    let activeLabel = $(".cat-btn.active").text() || category;
    $("#current-cat-title").text(activeLabel.toUpperCase());
    
    $("#editor-panel").show();
    $("#item-display").text("Načítám...");

    $.post(`https://${GetParentResourceName()}/getCatData`, JSON.stringify({
        gender: gender,
        category: category
    }), function(data) {
        if (Array.isArray(data)) {
            currentItems = data;
            selectItem(0, true); 
        } else {
            currentItems = data.items || [];
            let savedIndex = data.currentIndex;
            let savedVar = data.currentVar;

            if (!currentItems) currentItems = [];

            if (savedIndex !== undefined && savedIndex !== null && savedIndex !== -1) {
                currentVarID = savedVar || 1;
                selectItem(savedIndex, true); 
            } else {
                selectItem(-1, true);
            }
        }
    });
}

function changeItem(dir) {
    if (!currentItems || currentItems.length === 0) return;

    currentItemIndex += dir;

    if (currentItemIndex < -1) {
        currentItemIndex = currentItems.length - 1;
    } else if (currentItemIndex >= currentItems.length) {
        currentItemIndex = -1;
    }

    selectItem(currentItemIndex, false);
}

function selectItem(index, silent = false) {
    currentItemIndex = index;

    if (!silent) {
        currentVarID = 1; 
    }

    if (currentItemIndex === -1) {
        $("#item-display").text(`0 / ${currentItems.length} (Nic)`);
        $("#variant-display").text("-");
        
        $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', true);
        $(".stepper:eq(1) button").prop('disabled', true);

        if (!silent) {
            $.post(`https://${GetParentResourceName()}/removeItem`, JSON.stringify({
                category: currentCategory
            }));
        }
        return; 
    }

    $("#tint0, #tint1, #tint2, #palette-select").prop('disabled', false);
    $(".stepper:eq(1) button").prop('disabled', false);

    let item = currentItems[index];
    
    $("#item-display").text(`${index + 1} / ${currentItems.length}`);
    updateVariantDisplay(item);

    if (!silent) {
        $("#tint0, #tint1, #tint2").val(0);
        $("#palette-select").val(1);
        
        sendApplyItem(index + 1, 1);
    }
}

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
    $.post(`https://${GetParentResourceName()}/saveClothes`, JSON.stringify({
        CreatorMode: isCreatorMode
    }));
    closeMenu();
}

// ==========================================
// FUNKCE PRO MENU TĚLA (LEVÁ STRANA)
// ==========================================

function initBodyMenu(categories) {
    $("#body-menu").fadeIn(200);
    let container = $("#body-controls-list");
    container.html("");
    bodyState = {};

    categories.forEach(cat => {
        let label = cat;
        if(cat === "bodies_upper") label = "Horní část těla";
        if(cat === "bodies_lower") label = "Dolní část těla";

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

        fetchBodyData(cat);
    });
}

function fetchBodyData(category) {
    $.post(`https://${GetParentResourceName()}/getCatData`, JSON.stringify({
        gender: gender,
        category: category
    }), function(data) {
        let items = data.items || [];
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

    if (state.index < 0) state.index = state.items.length - 1;
    if (state.index >= state.items.length) state.index = 0;

    updateBodyDisplay(category);
    
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
        if (bodyState["bodies_upper"]) fetchBodyData("bodies_upper");
        if (bodyState["bodies_lower"]) fetchBodyData("bodies_lower");

        if (currentCategory) {
            loadCategoryData(currentCategory);
        }
    });
}

function refreshPed() {
    $.post(`https://${GetParentResourceName()}/refresh`, JSON.stringify({}));
}