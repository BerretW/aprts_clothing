const { createApp, ref, reactive, computed, onMounted } = Vue;

createApp({
    setup() {
        const isVisible = ref(false);
        const isCreatorMode = ref(false);
        const gender = ref('male');

        // --- NOVÉ: Řízení viditelnosti panelů ---
        const showBodyPanel = ref(true);
        const showClothingPanel = ref(true);
        // ----------------------------------------

        // Data menu
        const menuData = ref([]);
        const currentCategory = ref(null);

        // Sledování změn (Dirty Flags)
        const touchedCategories = reactive(new Set());

        // Data pro tělo (levý panel)
        const bodyStates = reactive({});

        // Data pro vybranou kategorii (pravý panel)
        const currentItems = ref([]);
        const currentItemIndex = ref(-1);
        const currentVarID = ref(1);
        const selectedPalette = ref(1);
        const tints = reactive([0, 0, 0]);

        // Input pro název itemu/outfitu
        const newOutfitName = ref("");

        // Palety (konstanty)
        const palettes = [
            "metaped_tint_generic_clean", "metaped_tint_hair",
            "metaped_tint_horse_leather", "metaped_tint_animal",
            "metaped_tint_makeup", "metaped_tint_leather",
            "metaped_tint_combined_leather"
        ];

        // Kamera state
        const mouseState = reactive({ isLeftDown: false, isRightDown: false, lastX: 0, lastY: 0 });

        // COMPUTED
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

        // --- HTTP HELPER ---
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
            if (cat) {
                touchedCategories.add(cat);
            }
        };

        const formatBodyLabel = (cat) => {
            const map = { "bodies_upper": "Horní část těla", "bodies_lower": "Dolní část těla" };
            return map[cat] || cat;
        };

        const formatPaletteName = (pal) => {
            return pal.replace('metaped_tint_', '').replace(/_/g, ' ');
        };

        // === LOGIKA NÁKUPU ===
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

        // === BODY LOGIC ===
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
                        
                        // NOVÉ: States
                        states: data.states || [], // Seznam názvů stavů
                        stateIndex: data.currentState || 0
                    };
                }
            });
        };

         const changeBodyState = (cat, dir) => {
            const state = bodyStates[cat];
            if (!state || !state.states || state.states.length === 0) return;

            let newIndex = state.stateIndex + dir;
            if (newIndex < 0) newIndex = state.states.length - 1;
            if (newIndex >= state.states.length) newIndex = 0;

            state.stateIndex = newIndex;
            
            // Odeslat na server
            postData('updateWearableState', { 
                category: cat, 
                stateIndex: state.stateIndex 
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

        const saveBodyChanges = async () => {
            // 1. Počkáme, až Lua zpracuje uložení
            const response = await postData('saveClothes', {
                saveType: 'character',
                CreatorMode: isCreatorMode.value,
                saved: true
            });

            // 2. Pokud vše proběhlo v pořádku, skryjeme menu
            if (response === 'ok') {
                isVisible.value = false;   // Skryje HTML
                touchedCategories.clear(); // Vyčistí seznam změn
            }
        };

        // === CLOTHING LOGIC ===
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

        // === CAMERA LOGIC ===
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

        // LIFECYCLE
        onMounted(() => {
            window.addEventListener('message', (event) => {
                const data = event.data;
                if (data.action === "openClothingMenu") {
                    isVisible.value = true;
                    gender.value = data.gender;
                    isCreatorMode.value = data.creatorMode;
                    menuData.value = data.menuData;

                    // --- NOVÉ: Nastavení viditelnosti podle Lua ---
                    // Defaultně true, pokud Lua nepošle nic (zpětná kompatibilita)
                    showBodyPanel.value = (data.showBody !== undefined) ? data.showBody : true;
                    showClothingPanel.value = (data.showClothes !== undefined) ? data.showClothes : true;
                    // ----------------------------------------------

                    // Reset inputu
                    newOutfitName.value = "";
                    touchedCategories.clear();

                    // Default selection
                    currentCategory.value = null;

                    if (data.bodyCategories) {
                        initBodyMenu(data.bodyCategories);
                    }
                }
            });

            document.addEventListener('keyup', (e) => {
                // Povolíme zavření ESCapem pokud nejsme v Creator módu
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
            showBodyPanel, showClothingPanel, // <-- EXPORTOVÁNO PRO HTML
            menuData, bodyStates,
            currentCategory, currentCategoryLabel,
            currentItems, currentItemIndex, currentVarID,
            maxItems, maxVariants,
            palettes, selectedPalette, tints,

            newOutfitName, purchaseItems,

            closeMenu, selectCategory, formatBodyLabel, formatPaletteName,
            changeBodyItem, updateBodyItem,
            changeItem, onItemChange, changeVariant, onVariantChange,
            applyPalette, applyTint, removeItem,
            resetToNaked, refreshPed, saveClothes,
            saveBodyChanges, changeBodyState
        };
    }
}).mount('#app');