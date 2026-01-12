const { createApp, ref, reactive, computed, onMounted } = Vue;

createApp({
    setup() {
        // --- STAV A VIDITELNOST ---
        const isVisible = ref(false);
        const isCreatorMode = ref(false); // Pokud true, zobrazí se "Uložit postavu" místo "Koupit"
        const gender = ref('male');

        // Viditelnost jednotlivých panelů
        const showBodyPanel = ref(true);
        const showClothingPanel = ref(true);
        const showOverlayPanel = ref(false); // Defaultně vypnuto

        // --- DATA ---
        const menuData = ref([]);      // Kategorie oblečení
        const bodyStates = reactive({}); // Data pro tělo
        const overlayMenuData = ref([]); // Data pro overlaye

        // Sledování změn (pro nákupní košík)
        const touchedCategories = reactive(new Set());

        // --- VÝBĚR A EDITACE (Oblečení) ---
        const currentCategory = ref(null);
        const currentItems = ref([]);
        const currentItemIndex = ref(-1);
        const currentVarID = ref(1);
        const selectedPalette = ref(1);
        const tints = reactive([0, 0, 0]);
        const newOutfitName = ref("");

        // --- VÝBĚR A EDITACE (Overlay) ---
        const currentOverlayCat = ref(null);
        const currentOverlayState = reactive({
            index: 0, // 0 = Žádné/Vypnuto (odpovídá indexu v poli items)
            palette: 'metaped_tint_makeup',
            tint0: 255,
            tint1: 0,
            tint2: 0
        });

        // --- KONSTANTY ---
        const palettes = [
            "metaped_tint_generic_clean", "metaped_tint_hair",
            "metaped_tint_horse_leather", "metaped_tint_animal",
            "metaped_tint_makeup", "metaped_tint_leather",
            "metaped_tint_combined_leather"
        ];

        // --- KAMERA ---
        const mouseState = reactive({ isLeftDown: false, isRightDown: false, lastX: 0, lastY: 0 });


        // ==========================================================================
        // COMPUTED PROPERTIES
        // ==========================================================================
        const maxItems = computed(() => {
            return currentItems.value.length > 0 ? currentItems.value.length - 1 : 0;
        });

        const maxVariants = computed(() => {
            if (currentItemIndex.value === -1 || !currentItems.value[currentItemIndex.value]) return 1;
            const item = currentItems.value[currentItemIndex.value];
            if (item.drawable) {
                if (Array.isArray(item.variants)) return item.variants.length;
                if (typeof item.variants === 'object') return Object.keys(item.variants).length;
            } else {
                if (Array.isArray(item)) return item.length;
                if (typeof item === 'object') return Object.keys(item.length).length;
            }
            return 1;
        });

        const currentCategoryLabel = computed(() => {
            if (!currentCategory.value) return "KATEGORIE";
            for (const section of menuData.value) {
                const found = section.items.find(i => i.id === currentCategory.value);
                if (found) return found.label;
            }
            return currentCategory.value;
        });

        // ==========================================================================
        // HTTP HELPER & UTILS
        // ==========================================================================
        const postData = async (endpoint, data) => {
            try {
                const response = await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify(data)
                });
                return await response.json();
            } catch (e) {
                return null;
            }
        };

        const markAsChanged = (cat) => {
            if (cat) touchedCategories.add(cat);
        };

        const formatBodyLabel = (cat) => {
            const map = { "bodies_upper": "Horní část těla", "bodies_lower": "Dolní část těla" };
            return map[cat] || cat;
        };

        const formatPaletteName = (pal) => {
            return pal.replace('metaped_tint_', '').replace(/_/g, ' ');
        };


        // ==========================================================================
        // LOGIKA TĚLA (BODY PANEL)
        // ==========================================================================
        const initBodyMenu = (categories) => {
            categories.forEach(async (cat) => {
                const data = await postData('getCatData', { gender: gender.value, category: cat });
                if (data) {
                    const items = data.items || [];
                    let currentIdx = (data.currentIndex !== undefined && data.currentIndex !== -1) ? data.currentIndex : 1;
                    currentIdx = currentIdx - 1;
                    if (currentIdx < 0) currentIdx = 0;

                    bodyStates[cat] = {
                        items: items,
                        index: currentIdx,
                        max: items.length,
                        // States (vyhrnuté rukávy atd.)
                        states: data.states || [],
                        stateIndex: data.currentState || 0
                    };
                }
            });
        };

        const changeBodyItem = (cat, dir) => {
            const state = bodyStates[cat];
            if (!state) return;
            let newIndex = state.index + dir;
            if (newIndex < 0) newIndex = state.max - 1;
            if (newIndex >= state.max) newIndex = 0;
            state.index = newIndex;
            updateBodyItem(cat);
        };

        const updateBodyItem = (cat) => {
            const state = bodyStates[cat];
            markAsChanged(cat);
            postData('applyItem', { category: cat, index: state.index + 1, varID: 1 });
        };

        const changeBodyState = (cat, dir) => {
            const state = bodyStates[cat];
            if (!state || !state.states || state.states.length === 0) return;

            let newIndex = state.stateIndex + dir;
            if (newIndex < 0) newIndex = state.states.length - 1;
            if (newIndex >= state.states.length) newIndex = 0;

            state.stateIndex = newIndex;
            postData('updateWearableState', { category: cat, stateIndex: state.stateIndex });
        };

        const saveBodyChanges = async () => {
            const response = await postData('saveClothes', {
                saveType: 'character',
                CreatorMode: isCreatorMode.value,
                saved: true
            });
            if (response === 'ok') {
                isVisible.value = false;
                touchedCategories.clear();
            }
        };


        // ==========================================================================
        // LOGIKA OBLEČENÍ (CLOTHING PANEL)
        // ==========================================================================
        const selectCategory = async (catId) => {
            currentCategory.value = catId;
            tints[0] = 0; tints[1] = 0; tints[2] = 0;
            selectedPalette.value = 1;

            const data = await postData('getCatData', { gender: gender.value, category: catId });

            if (Array.isArray(data)) {
                currentItems.value = data;
                onItemChange(false);
            } else {
                currentItems.value = data.items || [];
                const savedIndex = data.currentIndex;
                const savedVar = data.currentVar;

                if (savedIndex !== undefined && savedIndex !== -1) {
                    currentItemIndex.value = savedIndex - 1;
                    currentVarID.value = savedVar || 1;
                } else {
                    currentItemIndex.value = -1;
                }

                if (data.savedPalette) selectedPalette.value = data.savedPalette;
                if (data.savedTints && Array.isArray(data.savedTints)) {
                    tints[0] = data.savedTints[0];
                    tints[1] = data.savedTints[1];
                    tints[2] = data.savedTints[2];
                }
            }
        };

        const changeItem = (dir) => {
            if (currentItems.value.length === 0) return;
            let newIndex = currentItemIndex.value + dir;
            if (newIndex < -1) newIndex = currentItems.value.length - 1;
            else if (newIndex >= currentItems.value.length) newIndex = -1;

            currentItemIndex.value = newIndex;
            currentVarID.value = 1;
            onItemChange(true);
        };

        const onItemChange = (userAction = true) => {
            if (userAction) markAsChanged(currentCategory.value);
            if (currentItemIndex.value === -1) {
                postData('removeItem', { category: currentCategory.value });
            } else {
                sendApplyItem();
            }
        };

        const changeVariant = (dir) => {
            if (currentItemIndex.value === -1) return;
            let max = maxVariants.value;
            let newVal = currentVarID.value + dir;
            if (newVal < 1) newVal = max;
            if (newVal > max) newVal = 1;
            currentVarID.value = newVal;
            onVariantChange();
        };

        const onVariantChange = () => {
            markAsChanged(currentCategory.value);
            sendApplyItem();
        };

        const sendApplyItem = () => {
            postData('applyItem', {
                category: currentCategory.value,
                index: currentItemIndex.value + 1,
                varID: currentVarID.value
            });
        };

        const applyPalette = () => {
            markAsChanged(currentCategory.value);
            postData('changePalette', { category: currentCategory.value, palette: selectedPalette.value });
        };

        const applyTint = () => {
            markAsChanged(currentCategory.value);
            postData('changeTint', {
                category: currentCategory.value,
                tint0: tints[0], tint1: tints[1], tint2: tints[2]
            });
        };

        const removeItem = () => {
            markAsChanged(currentCategory.value);
            currentItemIndex.value = -1;
            onItemChange(false);
        };

        const purchaseItems = async () => {
            const changedList = Array.from(touchedCategories);
            const response = await postData('purchaseItems', {
                name: newOutfitName.value.trim() !== "" ? newOutfitName.value : "Oblečení",
                changedCategories: changedList
            });
            if (response === 'ok') {
                closeMenu();
            }
        };


        // ==========================================================================
        // LOGIKA OVERLAY (MAKE-UP / VZHLED)
        // ==========================================================================
        const toggleOverlayMode = async () => {
            showOverlayPanel.value = !showOverlayPanel.value;
            
            if (showOverlayPanel.value) {
                // Zapínáme Overlay mód -> skryjeme ostatní
                showBodyPanel.value = false;
                showClothingPanel.value = false;
                
                // Načteme data
                const data = await postData('getOverlayMenu', {});
                if (data) {
                    overlayMenuData.value = data;
                    // Automaticky vybrat první kategorii
                    if (data.length > 0) selectOverlayCat(data[0].id);
                }
            } else {
                // Vypínáme Overlay mód -> zobrazíme oblečení
                showBodyPanel.value = true;
                showClothingPanel.value = true;
            }
        };

        const selectOverlayCat = (catId) => {
            currentOverlayCat.value = catId;
            const catData = overlayMenuData.value.find(c => c.id === catId);
            
            if (catData && catData.current) {
                // Lua vrací items pole, kde index 1 je položka 1. 
                // Ale my tam přidali {label: "Žádné", index: -1} jako první v poli items (index 0 v JS poli).
                // Logika v Lua: Items = { {label="Žádné", index=-1}, {label="Styl 1", index=1} ... }
                
                // Náš slider pojede od 0 do items.length-1.
                // Musíme najít správnou pozici slideru podle uloženého indexu (catData.current.index).
                
                let sliderIndex = 0; // Default (Žádné)
                
                if (catData.current.index > 0) {
                    // Najdeme item v poli items, který má tento index
                    const foundIdx = catData.items.findIndex(i => i.index === catData.current.index);
                    if (foundIdx !== -1) sliderIndex = foundIdx;
                }

                currentOverlayState.index = sliderIndex;
                currentOverlayState.palette = catData.current.palette || 'metaped_tint_makeup';
                currentOverlayState.tint0 = (catData.current.tint0 !== undefined) ? catData.current.tint0 : 255;
                currentOverlayState.tint1 = (catData.current.tint1 !== undefined) ? catData.current.tint1 : 0;
                currentOverlayState.tint2 = (catData.current.tint2 !== undefined) ? catData.current.tint2 : 0;
            }
        };

        const updateOverlay = () => {
            // Získáme reálný Lua index z vybraného itemu v poli
            const catData = overlayMenuData.value.find(c => c.id === currentOverlayCat.value);
            if (!catData) return;
            
            const selectedItem = catData.items[currentOverlayState.index];
            const realLuaIndex = selectedItem ? selectedItem.index : -1;

            postData('applyOverlayChange', {
                layer: currentOverlayCat.value,
                index: realLuaIndex, // -1 pro odstranění, >0 pro aplikaci
                palette: currentOverlayState.palette,
                tint0: currentOverlayState.tint0,
                tint1: currentOverlayState.tint1,
                tint2: currentOverlayState.tint2
            });
        };

        const changeOverlayItem = (dir) => {
            const catData = overlayMenuData.value.find(c => c.id === currentOverlayCat.value);
            if (!catData) return;
            
            const max = catData.items.length - 1;
            let newVal = currentOverlayState.index + dir;
            
            if (newVal < 0) newVal = max;
            if (newVal > max) newVal = 0;
            
            currentOverlayState.index = newVal;
            updateOverlay();
        };

        const getCurrentOverlayMax = () => {
            const catData = overlayMenuData.value.find(c => c.id === currentOverlayCat.value);
            return catData ? catData.items.length - 1 : 0;
        };

        const getCurrentOverlayName = () => {
            const catData = overlayMenuData.value.find(c => c.id === currentOverlayCat.value);
            if (!catData) return "";
            const item = catData.items[currentOverlayState.index];
            return item ? item.label : "";
        };

        const getCurrentOverlayIndexDisplay = () => {
             return `${currentOverlayState.index} / ${getCurrentOverlayMax()}`;
        };

        const getOverlayLabel = (id) => {
            const found = overlayMenuData.value.find(c => c.id === id);
            return found ? found.label : id;
        };


        // ==========================================================================
        // GLOBAL MENU LOGIC
        // ==========================================================================
        const resetToNaked = () => {
            postData('resetToNaked', {}).then(() => {
                initBodyMenu(Object.keys(bodyStates));
                if (currentCategory.value) selectCategory(currentCategory.value);
                touchedCategories.clear();
            });
        };

        const refreshPed = () => postData('refresh', {});

        const saveClothes = (type) => {
            postData('saveClothes', {
                saveType: type,
                CreatorMode: isCreatorMode.value,
                saved: true
            });
            if (type === 'character') closeMenu();
        };

        const closeMenu = () => {
            isVisible.value = false;
            touchedCategories.clear();
            postData('closeClothingMenu', { saved: false });
        };


        // ==========================================================================
        // CAMERA LOGIC
        // ==========================================================================
        const handleMouseDown = (e) => {
            if (e.button === 0) { mouseState.isLeftDown = true; mouseState.lastX = e.clientX; }
            else if (e.button === 2) { mouseState.isRightDown = true; mouseState.lastY = e.clientY; }
        };

        const handleMouseUp = () => {
            mouseState.isLeftDown = false;
            mouseState.isRightDown = false;
        };

        const handleMouseMove = (e) => {
            if (!isVisible.value) return;
            if (mouseState.isLeftDown) {
                let deltaX = e.clientX - mouseState.lastX;
                mouseState.lastX = e.clientX;
                postData('rotateCharacter', { x: deltaX });
            }
            if (mouseState.isRightDown) {
                let deltaY = e.clientY - mouseState.lastY;
                mouseState.lastY = e.clientY;
                postData('moveCameraHeight', { y: deltaY });
            }
        };

        const handleWheel = (e) => {
            if (!isVisible.value) return;
            let dir = e.deltaY > 0 ? "out" : "in";
            postData('zoomCamera', { dir: dir });
        };


        // ==========================================================================
        // LIFECYCLE
        // ==========================================================================
        onMounted(() => {
            window.addEventListener('message', (event) => {
                const data = event.data;
                if (data.action === "openClothingMenu") {
                    isVisible.value = true;
                    gender.value = data.gender;
                    isCreatorMode.value = data.creatorMode;
                    menuData.value = data.menuData;

                    // Ovládání viditelnosti z Lua (volitelné)
                    showBodyPanel.value = (data.showBody !== undefined) ? data.showBody : true;
                    showClothingPanel.value = (data.showClothes !== undefined) ? data.showClothes : true;
                    showOverlayPanel.value = false; // Vždy začínáme bez overlay panelu

                    newOutfitName.value = "";
                    touchedCategories.clear();
                    currentCategory.value = null;
                    currentOverlayCat.value = null;

                    if (data.bodyCategories) {
                        initBodyMenu(data.bodyCategories);
                    }
                }
            });

            document.addEventListener('keyup', (e) => {
                if (e.which === 27 && !isCreatorMode.value && isVisible.value) closeMenu();
            });

            document.addEventListener('contextmenu', e => e.preventDefault());
            document.addEventListener('mousedown', handleMouseDown);
            document.addEventListener('mouseup', handleMouseUp);
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('wheel', handleWheel);
        });

        return {
            isVisible, isCreatorMode,
            showBodyPanel, showClothingPanel, showOverlayPanel,
            menuData, bodyStates, overlayMenuData,
            
            // Oblečení
            currentCategory, currentCategoryLabel,
            currentItems, currentItemIndex, currentVarID,
            maxItems, maxVariants,
            newOutfitName, purchaseItems,

            // Overlay
            currentOverlayCat, currentOverlayState,
            toggleOverlayMode, selectOverlayCat, updateOverlay, 
            changeOverlayItem, getCurrentOverlayMax, getCurrentOverlayName,
            getOverlayLabel, getCurrentOverlayIndexDisplay,

            // Palety & Utils
            palettes, selectedPalette, tints,
            formatBodyLabel, formatPaletteName,
            
            // Akce
            selectCategory, changeBodyItem, updateBodyItem, changeBodyState,
            changeItem, onItemChange, changeVariant, onVariantChange,
            applyPalette, applyTint, removeItem,
            resetToNaked, refreshPed, saveClothes, saveBodyChanges,
            closeMenu
        };
    }
}).mount('#app');