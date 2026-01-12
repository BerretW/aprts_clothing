const { createApp, ref, reactive, computed, onMounted } = Vue;

createApp({
    setup() {
        const isVisible = ref(false);
        const isCreatorMode = ref(false); 
        const gender = ref('male');

        const showBodyPanel = ref(false);
        const showClothingPanel = ref(false);
        const showOverlayPanel = ref(false);

        const menuData = ref([]);
        const bodyStates = reactive({});
        const overlayMenuData = ref([]);

        const touchedCategories = reactive(new Set());

        // Clothing vars
        const currentCategory = ref(null);
        const currentItems = ref([]);
        const currentItemIndex = ref(-1);
        const currentVarID = ref(1);
        const selectedPalette = ref(1);
        const tints = reactive([0, 0, 0]);
        const newOutfitName = ref("");

        // OVERLAY vars (Updated with SheetGrid, BlendType, Opacity)
        const currentOverlayCat = ref(null);
        const currentOverlayState = reactive({
            index: 0,
            palette: 'metaped_tint_makeup',
            opacity: 100, // UI range 0-100
            sheetGrid: 0, // UI integer
            blendType: 1, // UI integer
            tint0: 0,
            tint1: 0,
            tint2: 0
        });

        const palettes = [
            "metaped_tint_generic_clean", "metaped_tint_hair",
            "metaped_tint_horse_leather", "metaped_tint_animal",
            "metaped_tint_makeup", "metaped_tint_leather",
            "metaped_tint_combined_leather"
        ];

        const mouseState = reactive({ isLeftDown: false, isRightDown: false, lastX: 0, lastY: 0 });

        // --- COMPUTED ---
        const maxItems = computed(() => currentItems.value.length > 0 ? currentItems.value.length - 1 : 0);
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

        // --- HTTP ---
        const postData = async (endpoint, data) => {
            try {
                const response = await fetch(`https://${GetParentResourceName()}/${endpoint}`, {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json; charset=UTF-8' },
                    body: JSON.stringify(data)
                });
                return await response.json();
            } catch (e) { return null; }
        };
        const markAsChanged = (cat) => { if (cat) touchedCategories.add(cat); };
        const formatBodyLabel = (cat) => { const map = { "bodies_upper": "Horní část těla", "bodies_lower": "Dolní část těla" }; return map[cat] || cat; };
        const formatPaletteName = (pal) => { return pal.replace('metaped_tint_', '').replace(/_/g, ' '); };

        // --- BODY & CLOTHING LOGIC (Zkráceno - beze změny od minula) ---
        const initBodyMenu = (categories) => {
            if(!categories) return;
            categories.forEach(async (cat) => {
                const data = await postData('getCatData', { gender: gender.value, category: cat });
                if (data) {
                    const items = data.items || [];
                    let currentIdx = (data.currentIndex !== undefined && data.currentIndex !== -1) ? data.currentIndex : 1;
                    currentIdx = currentIdx - 1; if (currentIdx < 0) currentIdx = 0;
                    bodyStates[cat] = { items: items, index: currentIdx, max: items.length, states: data.states || [], stateIndex: data.currentState || 0 };
                }
            });
        };
        const changeBodyItem = (cat, dir) => { /* ... */ const state = bodyStates[cat]; if (!state) return; let newIndex = state.index + dir; if (newIndex < 0) newIndex = state.max - 1; if (newIndex >= state.max) newIndex = 0; state.index = newIndex; updateBodyItem(cat); };
        const updateBodyItem = (cat) => { const state = bodyStates[cat]; markAsChanged(cat); postData('applyItem', { category: cat, index: state.index + 1, varID: 1 }); };
        const changeBodyState = (cat, dir) => { const state = bodyStates[cat]; if (!state || !state.states || state.states.length === 0) return; let newIndex = state.stateIndex + dir; if (newIndex < 0) newIndex = state.states.length - 1; if (newIndex >= state.states.length) newIndex = 0; state.stateIndex = newIndex; postData('updateWearableState', { category: cat, stateIndex: state.stateIndex }); };

        const selectCategory = async (catId) => {
            currentCategory.value = catId; tints[0] = 0; tints[1] = 0; tints[2] = 0; selectedPalette.value = 1;
            const data = await postData('getCatData', { gender: gender.value, category: catId });
            if (Array.isArray(data)) { currentItems.value = data; onItemChange(false); } 
            else { 
                currentItems.value = data.items || []; 
                const savedIndex = data.currentIndex; const savedVar = data.currentVar;
                if (savedIndex !== undefined && savedIndex !== -1) { currentItemIndex.value = savedIndex - 1; currentVarID.value = savedVar || 1; } else { currentItemIndex.value = -1; }
                if (data.savedPalette) selectedPalette.value = data.savedPalette;
                if (data.savedTints) { tints[0] = data.savedTints[0]; tints[1] = data.savedTints[1]; tints[2] = data.savedTints[2]; }
            }
        };
        const changeItem = (dir) => { if (currentItems.value.length === 0) return; let newIndex = currentItemIndex.value + dir; if (newIndex < -1) newIndex = currentItems.value.length - 1; else if (newIndex >= currentItems.value.length) newIndex = -1; currentItemIndex.value = newIndex; currentVarID.value = 1; onItemChange(true); };
        const onItemChange = (userAction = true) => { if (userAction) markAsChanged(currentCategory.value); if (currentItemIndex.value === -1) { postData('removeItem', { category: currentCategory.value }); } else { sendApplyItem(); } };
        const changeVariant = (dir) => { if (currentItemIndex.value === -1) return; let max = maxVariants.value; let newVal = currentVarID.value + dir; if (newVal < 1) newVal = max; if (newVal > max) newVal = 1; currentVarID.value = newVal; onVariantChange(); };
        const onVariantChange = () => { markAsChanged(currentCategory.value); sendApplyItem(); };
        const sendApplyItem = () => { postData('applyItem', { category: currentCategory.value, index: currentItemIndex.value + 1, varID: currentVarID.value }); };
        const applyPalette = () => { markAsChanged(currentCategory.value); postData('changePalette', { category: currentCategory.value, palette: selectedPalette.value }); };
        const applyTint = () => { markAsChanged(currentCategory.value); postData('changeTint', { category: currentCategory.value, tint0: tints[0], tint1: tints[1], tint2: tints[2] }); };
        const removeItem = () => { markAsChanged(currentCategory.value); currentItemIndex.value = -1; onItemChange(false); };
        const purchaseItems = async () => { const changedList = Array.from(touchedCategories); const response = await postData('purchaseItems', { name: newOutfitName.value.trim() !== "" ? newOutfitName.value : "Oblečení", changedCategories: changedList }); if (response === 'ok') closeMenu(); };


        // --- OVERLAY LOGIC (Updated with Opacity, SheetGrid, BlendType) ---
        const initOverlayMenu = async () => {
            const data = await postData('getOverlayMenu', {});
            if (data) {
                overlayMenuData.value = data;
                if (data.length > 0) selectOverlayCat(data[0].id);
            }
        }

        const selectOverlayCat = (catId) => {
            currentOverlayCat.value = catId;
            const catData = overlayMenuData.value.find(c => c.id === catId);
            
            if (catData && catData.current) {
                let sliderIndex = 0;
                if (catData.current.index > 0) {
                    const foundIdx = catData.items.findIndex(i => i.index === catData.current.index);
                    if (foundIdx !== -1) sliderIndex = foundIdx;
                }

                currentOverlayState.index = sliderIndex;
                currentOverlayState.palette = catData.current.palette || 'metaped_tint_makeup';
                
                // Opacity 0.0-1.0 -> 0-100
                const op = (catData.current.opacity !== undefined) ? catData.current.opacity : 1.0;
                currentOverlayState.opacity = Math.round(op * 100);

                // Sheet Grid
                currentOverlayState.sheetGrid = (catData.current.sheetGrid !== undefined) ? catData.current.sheetGrid : 0;
                
                // Blend Type
                currentOverlayState.blendType = (catData.current.blendType !== undefined) ? catData.current.blendType : 1;

                currentOverlayState.tint0 = (catData.current.tint0 !== undefined) ? catData.current.tint0 : 0;
                currentOverlayState.tint1 = (catData.current.tint1 !== undefined) ? catData.current.tint1 : 0;
                currentOverlayState.tint2 = (catData.current.tint2 !== undefined) ? catData.current.tint2 : 0;
            }
        };

        const updateOverlay = () => {
            const catData = overlayMenuData.value.find(c => c.id === currentOverlayCat.value);
            if (!catData) return;
            const selectedItem = catData.items[currentOverlayState.index];
            const realLuaIndex = selectedItem ? selectedItem.index : -1;

            postData('applyOverlayChange', {
                layer: currentOverlayCat.value,
                index: realLuaIndex, 
                palette: currentOverlayState.palette,
                opacity: currentOverlayState.opacity / 100.0, // Send 0.0 - 1.0
                sheetGrid: currentOverlayState.sheetGrid,
                blendType: currentOverlayState.blendType,
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

        const resetOverlayLayer = () => {
    // 1. Reset UI hodnot do defaultu
    currentOverlayState.index = 0; // 0 = "Žádné"
    currentOverlayState.opacity = 100; // 100%
    currentOverlayState.sheetGrid = 0;
    currentOverlayState.blendType = 1;
    currentOverlayState.tint0 = 0;
    currentOverlayState.tint1 = 0;
    currentOverlayState.tint2 = 0;
    currentOverlayState.palette = 'metaped_tint_makeup'; // Default paleta

    // 2. Odeslání požadavku na smazání vrstvy v Lua
    postData('resetOverlayLayer', { 
        layer: currentOverlayCat.value 
    });
};

        const getCurrentOverlayMax = () => { const c = overlayMenuData.value.find(c => c.id === currentOverlayCat.value); return c ? c.items.length - 1 : 0; };
        const getCurrentOverlayName = () => { const c = overlayMenuData.value.find(c => c.id === currentOverlayCat.value); if (!c) return ""; const i = c.items[currentOverlayState.index]; return i ? i.label : ""; };
        const getCurrentOverlayIndexDisplay = () => { return `${currentOverlayState.index} / ${getCurrentOverlayMax()}`; };
        const getOverlayLabel = (id) => { const f = overlayMenuData.value.find(c => c.id === id); return f ? f.label : id; };

        // --- GLOBAL & LIFECYCLE ---
        const resetToNaked = () => { postData('resetToNaked', {}).then(() => { initBodyMenu(Object.keys(bodyStates)); if (currentCategory.value) selectCategory(currentCategory.value); touchedCategories.clear(); }); };
        const refreshPed = () => postData('refresh', {});
        const saveClothes = (type) => { postData('saveClothes', { saveType: type, CreatorMode: isCreatorMode.value, saved: true }); if (type === 'character') closeMenu(); };
        const closeMenu = () => { isVisible.value = false; touchedCategories.clear(); postData('closeClothingMenu', { saved: false }); };

        const handleMouseDown = (e) => { if (e.button === 0) { mouseState.isLeftDown = true; mouseState.lastX = e.clientX; } else if (e.button === 2) { mouseState.isRightDown = true; mouseState.lastY = e.clientY; } };
        const handleMouseUp = () => { mouseState.isLeftDown = false; mouseState.isRightDown = false; };
        const handleMouseMove = (e) => { if (!isVisible.value) return; if (mouseState.isLeftDown) { let deltaX = e.clientX - mouseState.lastX; mouseState.lastX = e.clientX; postData('rotateCharacter', { x: deltaX }); } if (mouseState.isRightDown) { let deltaY = e.clientY - mouseState.lastY; mouseState.lastY = e.clientY; postData('moveCameraHeight', { y: deltaY }); } };
        const handleWheel = (e) => { if (!isVisible.value) return; let dir = e.deltaY > 0 ? "out" : "in"; postData('zoomCamera', { dir: dir }); };

        onMounted(() => {
            window.addEventListener('message', (event) => {
                const data = event.data;
                if (data.action === "openClothingMenu") {
                    isVisible.value = true; gender.value = data.gender; isCreatorMode.value = data.creatorMode; menuData.value = data.menuData;
                    showBodyPanel.value = (data.showBody !== undefined) ? data.showBody : true;
                    showClothingPanel.value = (data.showClothes !== undefined) ? data.showClothes : true;
                    showOverlayPanel.value = false;
                    newOutfitName.value = ""; touchedCategories.clear(); currentCategory.value = null;
                    if (data.bodyCategories) initBodyMenu(data.bodyCategories);
                }
                if (data.action === "openOverlayMenu") {
                    isVisible.value = true; isCreatorMode.value = true;
                    showBodyPanel.value = false; showClothingPanel.value = false; showOverlayPanel.value = true;
                    touchedCategories.clear(); currentOverlayCat.value = null; initOverlayMenu();
                }
            });
            document.addEventListener('keyup', (e) => { if (e.which === 27 && !isCreatorMode.value && isVisible.value) closeMenu(); });
            document.addEventListener('contextmenu', e => e.preventDefault());
            document.addEventListener('mousedown', handleMouseDown);
            document.addEventListener('mouseup', handleMouseUp);
            document.addEventListener('mousemove', handleMouseMove);
            document.addEventListener('wheel', handleWheel);
        });

        return {
            isVisible, isCreatorMode, showBodyPanel, showClothingPanel, showOverlayPanel, menuData, bodyStates, overlayMenuData,
            currentCategory, currentCategoryLabel, currentItems, currentItemIndex, currentVarID, maxItems, maxVariants, newOutfitName, purchaseItems,
            currentOverlayCat, currentOverlayState, selectOverlayCat, updateOverlay, changeOverlayItem, getCurrentOverlayMax, getCurrentOverlayName, getOverlayLabel, getCurrentOverlayIndexDisplay,
            palettes, selectedPalette, tints, formatBodyLabel, formatPaletteName,
            selectCategory, changeBodyItem, updateBodyItem, changeBodyState, changeItem, onItemChange, changeVariant, onVariantChange, applyPalette, applyTint, removeItem, resetToNaked, refreshPed, saveClothes, closeMenu,
            resetOverlayLayer
        };
    }
}).mount('#app');