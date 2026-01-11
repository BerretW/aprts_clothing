const { createApp, ref, reactive, computed, onMounted } = Vue;

createApp({
    setup() {
        const isVisible = ref(false);
        const isCreatorMode = ref(false);
        const isItemMode = ref(false);
        const isWearableMode = ref(false); // Mód pouze pro úpravy (skryje obchod)
        const gender = ref('male');
        
        // Data menu
        const menuData = ref([]);
        const currentCategory = ref(null);
        
        // Data pro tělo (levý panel)
        const bodyStates = reactive({}); 

        // Data pro vybranou kategorii (pravý panel)
        const currentItems = ref([]);
        const currentItemIndex = ref(-1); // -1 = Nic/Svlečeno
        const currentVarID = ref(1);
        
        // Nové refy pro dynamické stavy oblečení (pravý panel)
        const maxClothingStates = ref(0);
        const currentClothingState = ref(1);

        const selectedPalette = ref(1);
        const tints = reactive([0, 0, 0]);

        // Palety (konstanty)
        const palettes = [
            "metaped_tint_generic_clean", "metaped_tint_hair", 
            "metaped_tint_horse_leather", "metaped_tint_animal", 
            "metaped_tint_makeup", "metaped_tint_leather", 
            "metaped_tint_combined_leather"
        ];

        // Kamera state
        const mouseState = reactive({ isLeftDown: false, isRightDown: false, lastX: 0, lastY: 0 });

        // COMPUTED PROPERTIES
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

        // --- METODY ---

        const formatBodyLabel = (cat) => {
            const map = { "bodies_upper": "Horní část těla", "bodies_lower": "Dolní část těla" };
            return map[cat] || cat;
        };

        const formatPaletteName = (pal) => {
            return pal.replace('metaped_tint_', '').replace(/_/g, ' ');
        };

        // === BODY LOGIC (Levý Panel) ===
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
                        // Data pro stavy těla (static from wearablestates.lua)
                        maxStates: data.maxStates || 0,
                        currentState: data.currentState || 1
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
            postData('applyItem', { category: cat, index: state.index + 1, varID: 1 });
        };

        // Ovládání slideru pro Body States (Levý panel)
        const changeBodyState = (cat, dir) => {
            const state = bodyStates[cat];
            if (!state || state.maxStates <= 1) return;
            
            let newVal = state.currentState + dir;
            if (newVal < 1) newVal = state.maxStates;
            if (newVal > state.maxStates) newVal = 1;
            
            state.currentState = newVal;
            updateBodyState(cat);
        };

        const updateBodyState = (cat) => {
            const state = bodyStates[cat];
            postData('applyWearableState', { category: cat, stateIndex: state.currentState });
        };

        // === CLOTHING LOGIC (Pravý Panel) ===
        
        const selectCategory = async (catId) => {
            currentCategory.value = catId;
            
            // Reset filtrů
            tints[0] = 0; tints[1] = 0; tints[2] = 0;
            selectedPalette.value = 1;

            const data = await postData('getCatData', { gender: gender.value, category: catId });
            
            if (Array.isArray(data)) {
                // Fallback pro starý formát
                currentItems.value = data;
                onItemChange(); 
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

                if (data.savedPalette) {
                    selectedPalette.value = data.savedPalette;
                }
                
                if (data.savedTints && Array.isArray(data.savedTints)) {
                    tints[0] = data.savedTints[0];
                    tints[1] = data.savedTints[1];
                    tints[2] = data.savedTints[2];
                }

                // Načtení dat pro Clothing States (Pravý panel)
                maxClothingStates.value = data.maxClothingStates || 0;
                currentClothingState.value = data.currentClothingState || 1;
            }
        };

        const changeItem = (dir) => {
            if (currentItems.value.length === 0) return;
            let newIndex = currentItemIndex.value + dir;
            if (newIndex < -1) newIndex = currentItems.value.length - 1;
            else if (newIndex >= currentItems.value.length) newIndex = -1;

            currentItemIndex.value = newIndex;
            currentVarID.value = 1;
            onItemChange();
        };

        const onItemChange = () => {
            if (currentItemIndex.value === -1) {
                postData('removeItem', { category: currentCategory.value });
                maxClothingStates.value = 0; // Pokud sundáme item, nemáme stavy
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
            sendApplyItem();
        };

        const sendApplyItem = async () => {
            // Čekáme na odpověď od Lua, která nám řekne, kolik stavů má nový item
            const response = await postData('applyItem', {
                category: currentCategory.value,
                index: currentItemIndex.value + 1,
                varID: currentVarID.value
            });

            if (response && response.maxClothingStates !== undefined) {
                maxClothingStates.value = response.maxClothingStates;
                currentClothingState.value = 1; // Reset stavu při změně itemu
            } else {
                maxClothingStates.value = 0;
            }
        };

        // Ovládání slideru pro Clothing States (Pravý panel)
        const changeClothingState = (dir) => {
            if (maxClothingStates.value <= 0) return;
            
            let newVal = currentClothingState.value + dir;
            if (newVal < 1) newVal = maxClothingStates.value;
            if (newVal > maxClothingStates.value) newVal = 1;
            
            currentClothingState.value = newVal;
            updateClothingState();
        };

        const updateClothingState = () => {
            postData('applyClothingState', { 
                category: currentCategory.value, 
                stateIndex: currentClothingState.value 
            });
        };

        // Ostatní metody
        const applyPalette = () => {
            postData('changePalette', { category: currentCategory.value, palette: selectedPalette.value });
        };

        const applyTint = () => {
            postData('changeTint', { 
                category: currentCategory.value, 
                tint0: tints[0], tint1: tints[1], tint2: tints[2] 
            });
        };

        const removeItem = () => {
            currentItemIndex.value = -1;
            onItemChange();
        };

        // === GLOBAL ACTIONS ===
        const resetToNaked = () => {
            postData('resetToNaked', {}).then(() => {
                initBodyMenu(Object.keys(bodyStates));
                if(currentCategory.value) selectCategory(currentCategory.value);
            });
        };

        const refreshPed = () => postData('refresh', {});

        const saveClothes = (type) => {
            postData('saveClothes', { 
                saveType: type,
                CreatorMode: isCreatorMode.value,
                saved: true 
            });
            isVisible.value = false;
        };

        const closeMenu = () => {
            isVisible.value = false;
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
                    isItemMode.value = data.isItemMode || false;
                    isWearableMode.value = data.isWearableMode || false;
                    
                    currentCategory.value = null;
                    
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
            isVisible, isCreatorMode, isItemMode, isWearableMode,
            menuData, bodyStates,
            currentCategory, currentCategoryLabel,
            currentItems, currentItemIndex, currentVarID,
            maxItems, maxVariants,
            palettes, selectedPalette, tints,
            // Stavy oblečení (pravý panel)
            maxClothingStates, currentClothingState, 
            changeClothingState, updateClothingState,
            // Metody
            closeMenu, selectCategory, formatBodyLabel, formatPaletteName,
            changeBodyItem, updateBodyItem,
            changeBodyState, updateBodyState,
            changeItem, onItemChange, changeVariant, onVariantChange,
            applyPalette, applyTint, removeItem,
            resetToNaked, refreshPed, saveClothes
        };
    }
}).mount('#app');