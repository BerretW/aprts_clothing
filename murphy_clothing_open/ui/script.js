

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                                                                                   //
//                                       MURPHY'S CLOTHES                                            //
//                                                                                                   //
//                        2025 - Murphy / Webba Creative Technologies                                //
//                                                                                                   //
//                         This Script is working with all UI folder                                 //
//                   to show and hide datas for Clothes creation / modification                      //
//                                                                                                   //
//                                   All Right Reserved - ©                                          //
//                                                                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////


/**
 * Table of Contents
 *
 * I. JSON EXAMPLES
 *     A. Project Overview
 *     B. Objectives
 *     C. Technologies Used
 *
 * II. GLOBAL ELEMENTS
 *     A. Global Variables
 *     B. Outfit Menu (Modification / Creation)
 *     C. Outfit List Menu (All My Outfits)
 *     D. My Outfit Menu (Actual Outfit Variation / Get Naked)
 *     E. Contextual Menu (For Outfit Modification / Creation - Tint, Variations...)
 *
 * III. ALL FUNCTIONS
 *     A. Load Categories
 *     B. Load Items
 *     C. Load Contextual Datas
 *     D. Load Camera Menu
 *     E. Load Outfit List
 *     F. Load My Outfit Items
 *
 * IV. DOM
 *     A. Event Listeners for interactions
 *     B. Event Listeners for Camera Menu
 *     C. Event Listeners for Outfit Menu
 *     D. Event Listeners for Outfit List Menu
 *     E. Event Listeners for My Outfit Menu
 *     F. Event Listeners for Contextual Menu
 *     G. Event Listeners for My Outfit Items
 *
 * V. Messages
 *     A. Event Price Outfit
 *     B. Event Listener for the NUI Messages
 *     C. Escape Key
 */




///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       JSON EXAMPLES                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


// //JSON Example for categories
// const categories = [

//     {
//         "id": 1,
//         "name": "Shirts",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 2,
//         "name": "Pants",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 3,
//         "name": "Shoes",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 4,
//         "name": "Hats",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 5,
//         "name": "Accessories",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 6,
//         "name": "Accessories",
//         "image": "./img/categories/shirt.png"
//     },
//     {
//         "id": 7,
//         "name": "Accessories",
//         "image": "./img/categories/shirt.png"
//     }
// ]

// JSON Example for items

// const myItems = [
//     {
//         "id": 1,
//         "name": "Shirt Style",
//         "category": 1,
//         "totalAmount": 255,
//         "selectorType": "slider",

//         "value": 50
//     },
//     {
//         "id": 2,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "button",
//         "buttonText": "On / Off",

//         "value": 10
//     },
//     {
//         "id": 3,
//         "name": "Shirt Style",
//         "category": 1,
//         "totalAmount": 255,
//         "selectorType": "slider",

//         "value": 50
//     },
//     {
//         "id": 4,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 5,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 6,
//         "name": "Pants Style of the sky",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 7,
//         "name": "Pants Style",
//         "category": 1,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 8,
//         "name": "Pants Style",
//         "category": 2,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     },
//     {
//         "id": 9,
//         "name": "Pants Style",
//         "category": 2,
//         "totalAmount": 50,
//         "selectorType": "slider",

//         "value": 10
//     }
// ]

//JSON Example for contextualDatas
// const contextualDatasExampleVariation = [
//     {
//         "id": 1,
//         "contextual": "variation",
//         "variationAmount": 50,

//         "variationValue": 1,

//         "tints": [
//             {
//                 "tintId": 1,
//                 "value": 25
//             },
//             {
//                 "tintId": 2,
//                 "value": 50
//             },
//             {
//                 "tintId": 3,
//                 "value": 75
//             }
//         ]

//     }
// ]

// const contextualDatasExampleTint = [
//     {
//         "id": 2,
//         "contextual": "tint",
//         "tintAmount": 6,
//         "colours": [
//             {
//                 "id": 1,
//                 "image": "./img/colours/1.png"
//             },
//             {
//                 "id": 2,
//                 "image": "./img/colours/2.png"
//             },
//             {
//                 "id": 3,
//                 "image": "./img/colours/3.png"
//             },
//             {
//                 "id": 4,
//                 "image": "./img/colours/4.png"
//             },
//             {
//                 "id": 5,
//                 "image": "./img/colours/5.png"
//             },
//             {
//                 "id": 6,
//                 "image": "./img/colours/6.png"
//             }
//         ],

//         "tintValue": 1
//     }
// ]


//JSON Outfit List Menu
// const MyOutfits = [
//     {
//         "id": 1,
//         "name": "Sherif",
//         "Value": "3.00",
//     },
//     {
//         "id": 2,
//         "name": "Sexe",
//         "Value": "2.00",
//     }
// ]



///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                      GLOBAL ELEMENTS                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   TRANSLATION INITIALIZATION                                      //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Initialize translations on page load
function initializeTranslations() {
    // Update static HTML text elements with translations
    const translations = {
        // Outfit List Menu
        '#OutfitListMenu #title h1': T('outfit'),
        '#CreateNewOutfit': T('createNew'),
        // My Outfit Menu
        '#OutfitVariations #title h1': T('myOutfit'),
        // Buttons
        '#CloseMyOutfit': T('back'),
        '#ReturnToMyOutfit': T('back'),
        '#SaveActualOutfit': T('confirm')
    };

    // Apply translations
    for (const [selector, translation] of Object.entries(translations)) {
        const element = document.querySelector(selector);
        if (element) {
            element.textContent = translation;
        }
    }
}

// Call translation initialization when DOM is loaded
document.addEventListener('DOMContentLoaded', initializeTranslations);

///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   MEMORY CLEANUP FUNCTIONS                                        //
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Clean up function to prevent memory leaks when menu closes
function cleanupMemory() {
    // Clear large data arrays to free memory
    if (items.length > 100) {
        items = [];
    }
    if (categories.length > 50) {
        categories = [];
    }
    if (myItems.length > 100) {
        myItems = [];
    }
    
    // Force garbage collection hint (browser will decide)
    if (window.gc) {
        window.gc();
    }
}

//Global Table values
let MyOutfits = []
let categories = [];
let items = [];
let myItems = [];

//Global Variables
let menuType = 'default';
let outfitElemId = '';
let myOutfitcategoryId = '';
let userNaked = '';
let inCreatorMode = false;

////////////////////////// OUTFIT MENU (MODIFICATION / CREATION) //////////////////////////

// Show and Hide Job Menu
function showOutfitMenu() {
    const outfitMenu = document.getElementById('OutfitMenu');
    const cameraMenu = document.getElementById('CameraSettings');
    outfitMenu.classList.remove('hidden');
    cameraMenu.classList.remove('hidden');
    loadCameraMenu();
    loadCategories();
}

// Hide Outfit Menu
function hideOutfitMenu() {
    const outfitMenu = document.getElementById('OutfitMenu');
    outfitMenu.classList.add('hidden');

    const categoriesContainer = document.getElementById('Categories');
    categoriesContainer.innerHTML = '';

    const itemsContainer = document.getElementById('StyleProperties');
    itemsContainer.innerHTML = '';

    document.getElementById('SelectOutfitGender').classList.add('hidden');

    hideContextualMenu();
    document.getElementById('CreateOutfit').innerHTML = 'Save - $0.00';
    
    // Memory cleanup when closing menu
    cleanupMemory();
}

////////////////////////// OUTFIT LIST MENU (ALL MY OUTFITS) //////////////////////////

// Show and Hide Job Menu
function showOutfitListMenu() {
    const outfitListMenu = document.getElementById('OutfitListMenu');
    const cameraMenu = document.getElementById('CameraSettings');
    cameraMenu.classList.remove('hidden');
    outfitListMenu.classList.remove('hidden');

    LoadOutfitList(MyOutfits);
    loadCameraMenu();
}

// Hide Outfit List Menu
function hideOutfitListMenu() {
    const outfitListMenu = document.getElementById('OutfitListMenu');
    const cameraMenu = document.getElementById('CameraSettings');
    const deletionConfirmation = document.getElementById('DeletionConfirmation');

    outfitListMenu.classList.add('hidden');
    cameraMenu.classList.add('hidden');

    // Hide deletion confirmation if it is open
    if (deletionConfirmation && !deletionConfirmation.classList.contains('hidden')) {
        deletionConfirmation.classList.add('hidden');
    }
    
    // Memory cleanup when closing menu
    cleanupMemory();
}

////////////////////////// MY OUTFIT MENU (ACTUAL OUTFIT VARIATION / GET NAKED) //////////////////////////

// Show My Outfit Items
function ShowMyOutfitItems() {

    document.getElementById('OutfitVariations').classList.remove('hidden');
    LoadNakedStatus();
}

// Hide My Outfit Items
function HideMyOutfitItems() {

    document.getElementById('OutfitVariations').classList.add('hidden');

    const variationMenu = document.getElementById("VariationSettings");
    const tintMenu = document.getElementById("TintSettings");
    tintMenu.classList.add('hidden');
    variationMenu.classList.add('hidden');
}



////////////////////////// CONTEXTUAL MENU (FOR OUTFIT MODIFICATION / CREATION - TINT, VARIATIONS...) //////////////////////////

// Show Contextual Menu
function showContextualMenu(contextualType) {
    const variationMenu = document.getElementById("VariationSettings");
    const tintMenu = document.getElementById("TintSettings");

    if (contextualType === "variation") {
        // Only show variation menu if it's currently hidden
        if (variationMenu.classList.contains('hidden')) {
            variationMenu.classList.remove('hidden');
            tintMenu.classList.add('hidden');
        }
    } else if (contextualType === "tint") {
        // Only show tint menu if it's currently hidden
        if (tintMenu.classList.contains('hidden')) {
            tintMenu.classList.remove('hidden');
            variationMenu.classList.add('hidden');
        }
    }
}

// Hide Contextual Menu
function hideContextualMenu() {
    const variationSettings = document.getElementById('VariationSettings');
    const tintSettings = document.getElementById('TintSettings');

    if (!variationSettings.classList.contains('hidden')) {
        variationSettings.classList.add('hidden');
    }

    if (!tintSettings.classList.contains('hidden')) {
        tintSettings.classList.add('hidden');
    }
}

//Actual Selected Values
currentSelectedCategorie = 0;
currentSelectedItem = 0;





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     LOAD CATEGORIES                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


// Load Categories
function loadCategories() {
    const categoriesContainer = document.getElementById('Categories');
    // Memory leak fix: Remove all event listeners before clearing
    const newContainer = categoriesContainer.cloneNode(false);
    categoriesContainer.parentNode.replaceChild(newContainer, categoriesContainer);

    categories.forEach(category => {
        const categoryElem = document.createElement('a');
        categoryElem.classList.add('categoryElem');

        categoryElem.innerHTML = `
                <img src="${category.image}" alt="${category.name}">
        `;

        loadItems();

        categoryElem.addEventListener('click', () => {
            changeCategory(category.id);
            currentSelectedCategorie = category.id;

            //Hide Contextual Datas
            document.getElementById('VariationSettings').classList.add('hidden');
            document.getElementById('TintSettings').classList.add('hidden');

            const cate = document.querySelectorAll('.categoryElem');
            cate.forEach(catego => {
                catego.classList.remove('selected');
            });

            if (currentSelectedCategorie === category.id) {
                categoryElem.classList.add('selected');
            }

        });
        newContainer.appendChild(categoryElem);
    });
}





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                       LOAD ITEMS                                                  //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function changeCategory(categoryId) {

    items.forEach(item => {

        const itemElem = document.getElementById('item_' + item.id);

        if (item.category === categoryId) {
            itemElem.classList.remove('hidden');
        }
        else {
            itemElem.classList.add('hidden');
        }

    });

};


// Load Items
function loadItems() {
    const itemsContainer = document.getElementById('StyleProperties');
    // Memory leak fix: Clone and replace to remove all orphaned event listeners
    const newItemsContainer = itemsContainer.cloneNode(false);
    itemsContainer.parentNode.replaceChild(newItemsContainer, itemsContainer);

    items.forEach(item => {

        if (item.selectorType === "slider") {

            const itemElem = document.createElement('div');
            itemElem.innerHTML = `
                    <div class="styleElem unselectable hidden" id="item_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="sliderValue_${item.id}">Style ${item.value}</p>
                            <div class="sliderElem">
                                <a id="left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="0" max="${item.totalAmount}" value="${item.value}" class="slider" id="rangeGlobal_${item.id}">
                                <a id="right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>
                `;

            newItemsContainer.appendChild(itemElem);

            updateRangeBackground('rangeGlobal_' + item.id);

            itemElem.addEventListener('click', () => {

                if (currentSelectedItem !== item.id) {
                    currentSelectedItem = item.id;
                    const items = document.querySelectorAll('.styleElem');
                    items.forEach(item => {
                        item.classList.remove('selected');

                    });

                    // if (item.contextual === "variation") {
                    //     document.getElementById("VariationSettings").classList.remove('hidden');
                    //     document.getElementById("TintSettings").classList.add('hidden');
                    // } else if (item.contextual === "tint") {
                    //     document.getElementById("TintSettings").classList.remove('hidden');
                    //     document.getElementById("VariationSettings").classList.add('hidden');
                    // }

                    const actualItem = document.getElementById('item_' + item.id);
                    actualItem.classList.add('selected');

                    // loadContextualDatas(contextualDatasExampleVariation);

                    $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                        category: item.id, menu: item.category,
                    }));

                }

            });

            document.getElementById('right_arrow_' + item.id).addEventListener('click', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                if (slider.value !== slider.max) {
                    slider.value = parseInt(slider.value) + 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                    updateRangeBackground('rangeGlobal_' + item.id);
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

            document.getElementById('left_arrow_' + item.id).addEventListener('click', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                if (slider.value !== slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                    updateRangeBackground('rangeGlobal_' + item.id);

                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

            // document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
            //     const slider = document.getElementById('rangeGlobal_' + item.id);
            //     document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

            //     $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
            //         category: item.id, menu: item.category,,
            //         item: slider.value
            //     }));
            // });

            document.getElementById('rangeGlobal_' + item.id).addEventListener('input', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;

                updateRangeBackground('rangeGlobal_' + item.id);


            });

            document.getElementById('rangeGlobal_' + item.id).addEventListener('change', () => {
                const slider = document.getElementById('rangeGlobal_' + item.id);
                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));


            });

        }
        else if (item.selectorType === "selector") {

            const itemElem = document.createElement('div');
            itemElem.innerHTML = `
                    <div class="styleElem typeTwo unselectable" id="item_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <div class="sliderElemTypeTwo">
                                <a id="left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <p class="sliderValueTypeTwo unselectable" id="sliderValue_${item.id}">Style ${item.value}</p>
                                <input type="range" min="0" max="${item.totalAmount}" value="${item.value}" class="hidden" id="rangeGlobal_${item.id}">
                                <a id="right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>

                    </div>
                `;

            itemElem.addEventListener('click', () => {

                if (currentSelectedItem !== item.id) {
                    currentSelectedItem = item.id;
                    const items = document.querySelectorAll('.styleElem');
                    items.forEach(item => {
                        item.classList.remove('selected');
                    });


                    if (item.contextual === "variation") {
                        document.getElementById("VariationSettings").classList.remove('hidden');
                        document.getElementById("TintSettings").classList.add('hidden');
                    } else if (item.contextual === "tint") {
                        document.getElementById("TintSettings").classList.remove('hidden');
                        document.getElementById("VariationSettings").classList.add('hidden');
                    }

                    const actualItem = document.getElementById('item_' + item.id);
                    actualItem.classList.add('selected');

                    $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                        item: item.id
                    }));
                }

            });
            newItemsContainer.appendChild(itemElem);

            document.getElementById(`right_arrow_${item.id}`).addEventListener('click', () => {
                const slider = document.getElementById(`rangeGlobal_${item.id}`);
                if (slider.value < slider.max) {
                    slider.value = parseInt(slider.value) + 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));

            });

            document.getElementById(`left_arrow_${item.id}`).addEventListener('click', () => {
                const slider = document.getElementById(`rangeGlobal_${item.id}`);
                if (slider.value > slider.min) {
                    slider.value = parseInt(slider.value) - 1;
                    document.getElementById('sliderValue_' + item.id).innerText = `Style ${slider.value}`;
                }

                $.post(`https://${GetParentResourceName()}/itemValue`, JSON.stringify({
                    category: item.id, menu: item.category,
                    item: slider.value
                }));
            });


        }
    });
}






///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     LOAD CONTEXTUAL                                               //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

// Load Contextual Datas
function loadContextualDatas(contextualDatas) {
    // Check if contextualDatas is an array
    if (!Array.isArray(contextualDatas)) {
        console.error('contextualDatas must be an array');
        return;
    }

    contextualDatas.forEach(contextualData => {
        // Validate contextualData structure
        if (!contextualData || typeof contextualData !== 'object') {
            console.error('Invalid contextualData:', contextualData);
            return;
        }

        // Ensure required fields exist with default values
        contextualData.variationAmount = contextualData.variationAmount || 1;
        contextualData.variationValue = contextualData.variationValue || 1;
        contextualData.tints = contextualData.tints || [];
        
        // Ensure variationValue is positive
        if (contextualData.variationValue < 1) {
            contextualData.variationValue = 1;
        }

        if (contextualData.contextual === "variation") {
            // Check if there is only one variation
            if (contextualData.variationAmount === 1) {

                //Don't show the variation menu
                document.getElementById('ContextSettings').classList.add('hidden');
                document.getElementById('separator_var').classList.add('hidden');

            } else {
                document.getElementById('ContextSettings').classList.remove('hidden');
                document.getElementById('separator_var').classList.remove('hidden');
                //Show the variation menu
                document.getElementById('varSlider').innerHTML = `
                
                <p class="unselectable">Var - <span id="actualVar">${contextualData.variationValue}</span></p>

                <div class="unselectable">

                    <a id="left_arrow_variation" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                    <input type="range" name="Variation" id="rangeVariation" min="1" max="${contextualData.variationAmount}" value="${contextualData.variationValue}">
                    <a id="right_arrow_variation" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>
                `;

                document.getElementById('right_arrow_variation').addEventListener('click', () => {
                    const slider = document.getElementById('rangeVariation');
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('actualVar').innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('left_arrow_variation').addEventListener('click', () => {
                    const slider = document.getElementById('rangeVariation');
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('actualVar').innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('rangeVariation').addEventListener('input', () => {
                    const slider = document.getElementById('rangeVariation');
                    document.getElementById('actualVar').innerText = `${slider.value}`;

                    $.post(`https://${GetParentResourceName()}/varValue`, JSON.stringify({
                        item: slider.value,
                        category: contextualData.category
                    }));
                });
            }

            tintContainer = document.querySelector('.TintList');
            tintContainer.innerHTML = '';

            // Only process tints if they exist and array is not empty
            if (contextualData.tints && Array.isArray(contextualData.tints) && contextualData.tints.length > 0) {
                contextualData.tints.forEach(tint => {
                    // Validate tint object
                    if (!tint || typeof tint.tintId === 'undefined' || typeof tint.value === 'undefined') {
                        console.warn('Invalid tint data:', tint);
                        return;
                    }

                    // Ensure tint values are valid numbers
                    tint.value = parseInt(tint.value) || 1;
                    if (tint.value < 0) tint.value = 0;
                    if (tint.value > 255) tint.value = 255;


                const tintElem = document.createElement('div');
                tintElem.classList.add('ContextElem');

                tintElem.innerHTML = `

                <p class="unselectable">T${tint.tintId} - <span id="actualTint${tint.tintId}">${tint.value}</span></p>
                <div class="unselectable">

                <a id="left_arrow_tint${tint.tintId}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                <input type="range" name="Tint${tint.tintId}" class="contRange" id="rangeTint${tint.tintId}" min="0" max="255" value="${tint.value}">
                <a id="right_arrow_tint${tint.tintId}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>


                `;

                tintContainer.appendChild(tintElem);

                document.getElementById('right_arrow_tint' + tint.tintId).addEventListener('click', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('left_arrow_tint' + tint.tintId).addEventListener('click', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;
                    }

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

                document.getElementById('rangeTint' + tint.tintId).addEventListener('input', () => {
                    const slider = document.getElementById('rangeTint' + tint.tintId);
                    document.getElementById('actualTint' + tint.tintId).innerText = `${slider.value}`;

                    $.post(`https://${GetParentResourceName()}/tintValue`, JSON.stringify({
                        tintId: tint.tintId,
                        value: slider.value,
                        category: contextualData.category
                    }));
                });

                });
            }

        }
    });
}





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        LOAD CAMERA                                                //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function loadCameraMenu() {

    //NE PAS SUPPRIMER OU REMPLACER JSON LOCAL
    const cameraDatas = [
        {
            "cameraName": 'H',
            "value": 25
        },
        {
            "cameraName": 'Z',
            "value": 360
        },
        {
            "cameraName": 'R',
            "value": 180
        }
    ]


    camContainer = document.querySelector('.CameraList');
    camContainer.innerHTML = '';

    cameraDatas.forEach(cam => {


        const camElem = document.createElement('div');
        camElem.classList.add('CamElem');

        camElem.innerHTML = `

                <p class="unselectable">${cam.cameraName}</p>
                <div class="unselectable">

                    <a id="left_arrow_cam_${cam.cameraName}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                    <input type="range" value="${cam.value}" min="1" max="360" name="Variation" class="contRange" id="camRange_${cam.cameraName}">
                    <a id="right_arrow_cam_${cam.cameraName}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>

                </div>`;

        camContainer.appendChild(camElem);

        document.getElementById('right_arrow_cam_' + cam.cameraName).addEventListener('click', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);
            if (slider.value !== slider.max) {
                slider.value = parseInt(slider.value) + 1;
            }

            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

        document.getElementById('left_arrow_cam_' + cam.cameraName).addEventListener('click', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);
            if (slider.value !== slider.min) {
                slider.value = parseInt(slider.value) - 1;
            }

            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

        document.getElementById('camRange_' + cam.cameraName).addEventListener('input', () => {
            const slider = document.getElementById('camRange_' + cam.cameraName);

            $.post(`https://${GetParentResourceName()}/cameraChange`, JSON.stringify({
                cameraName: cam.cameraName,
                value: slider.value
            }));
        });

    });

}





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    LOAD OUTFITS LIST                                              //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function LoadOutfitList(outfits) {

    const outfitListContainer = document.getElementById('OutfitList');
    // Memory leak fix: Remove all orphaned event listeners
    const newOutfitContainer = outfitListContainer.cloneNode(false);
    outfitListContainer.parentNode.replaceChild(newOutfitContainer, outfitListContainer);

    outfits.forEach(outfit => {
        const outfitElem = document.createElement('div');
        outfitElem.classList.add('OutfitElement');

        outfitElem.innerHTML = `

         <div class="OutfitElemTitle">

                  <div style="display: flex; align-items: center;width: 100%;">
                      <p class="OutfitName unselectable" style="max-width: 110px;">${outfit.name}</p>
                      <p class="OutfitPrice unselectable">- ${outfit.Value}</p>
                  </div>
           </div>      

            <div class="InteractionDiv">

              <a class="buttonOutfitLeft unselectable" id="buttonViewOutfit_${outfit.id}"><img src="./img/icons/eye.png"></a>
              <a class="buttonOutfit unselectable" id="modifyOutfit_${outfit.id}"><img src="./img/icons/pen.png"></a>
              <a class="buttonOutfit unselectable" id="recoverOutfit_${outfit.id}"><img src="./img/icons/cash.png"></a>
              <a class="buttonOutfit unselectable" id="deleteOutfit_${outfit.id}"><img src="./img/icons/close.png"></a>

           </div>
        `;

        newOutfitContainer.appendChild(outfitElem);

        document.getElementById('buttonViewOutfit_' + outfit.id).addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/showOutfit`, JSON.stringify({
                outfit: outfit.id
            }));
        });

        //Mofify Outfit
        document.getElementById('modifyOutfit_' + outfit.id).addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/modifyOutfit`, JSON.stringify({
                outfit: outfit.id,
                price: outfit.Value
            }));
        });

        //Recover Outfit
        document.getElementById('recoverOutfit_' + outfit.id).addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/recoverOutfit`, JSON.stringify({
                outfit: outfit.id,
                name: outfit.name,
                price: outfit.Value
            }));
        });

        //Delete Outfit
        document.getElementById('deleteOutfit_' + outfit.id).addEventListener('click', () => {

            document.getElementById('DeletionConfirmation').classList.remove('hidden');

            document.getElementById('DeletionConfirmation').innerHTML = `

                <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>${T('warning')}</h1>
                    <p>${T('deleteConfirm')} <span style="color:#ff8585;"> ${outfit.name} </span> ${T('deleteConfirmOutfit')}</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="canceDeletationOutfit_${outfit.id}" class="button_del">${T('cancel')}</a>
                    <a id="confirmDeletationOutfit_${outfit.id}" class="button_del">${T('delete')}</a>

                </div>

                </div>

                </div>
        `;

            //Accept Deletion Outfit
            document.getElementById('confirmDeletationOutfit_' + outfit.id).addEventListener('click', () => {
                $.post(`https://${GetParentResourceName()}/deleteOutfit`, JSON.stringify({
                    outfit: outfit.id
                }));
                document.getElementById('DeletionConfirmation').classList.add('hidden');
            });

            //Cancel Deletion Outfit
            document.getElementById('canceDeletationOutfit_' + outfit.id).addEventListener('click', () => {
                $.post(`https://${GetParentResourceName()}/canceldelete`, JSON.stringify({
                }));
                document.getElementById('DeletionConfirmation').classList.add('hidden');
            });

        });


    });

    //Create New Outfit
    document.getElementById('CreateNewOutfitGlob').addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/createNewOutfit`);
        hideOutfitListMenu();

    });

    //Close Outfit Menu
    document.getElementById('CloseMyOutfit').addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/closeoutfitmenu`);
    });

}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                     LOAD NAKED STATUS                                             //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function LoadNakedStatus() {

    const NakedVariation = document.getElementById('NakedVariation');

    if (userNaked === "true") {

        NakedVariation.innerHTML = `

            <div class="styleElem typeTwo unselectable" id="item">
               <p class="elemTitle">Naked</p>
               <div class="sliderDiv">
                   <div class="sliderElemTypeTwo">
                        <a id="naked_left_arrow" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                        <p class="sliderValueTypeTwo unselectable" id="nakedValue">True</p>
                        <input type="range" min="0" max="2" value="True" class="hidden" id="rangeGlobal">
                        <a id="naked_right_arrow" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                   </div>
                </div>

           </div>
        `;

        document.getElementById('naked_right_arrow').addEventListener('click', () => {
            userNaked = "false";
            LoadNakedStatus();

            $.post(`https://${GetParentResourceName()}/isNaked`, JSON.stringify({
                naked: 'false'
            }));
        });

        document.getElementById('naked_left_arrow').addEventListener('click', () => {
            userNaked = "false";
            LoadNakedStatus();

            $.post(`https://${GetParentResourceName()}/isNaked`, JSON.stringify({
                naked: 'false'
            }));
        });

    } else {
        NakedVariation.innerHTML = `

            <div class="styleElem typeTwo unselectable" id="item">
               <p class="elemTitle">Naked</p>
               <div class="sliderDiv">
                   <div class="sliderElemTypeTwo">
                        <a id="naked_left_arrow" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                        <p class="sliderValueTypeTwo unselectable" id="nakedValue">False</p>
                        <input type="range" min="0" max="2" value="True" class="hidden" id="rangeGlobal">
                        <a id="naked_right_arrow" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                   </div>
                </div>

           </div>
        `;

        document.getElementById('naked_right_arrow').addEventListener('click', () => {
            userNaked = "true";
            LoadNakedStatus();

            $.post(`https://${GetParentResourceName()}/isNaked`, JSON.stringify({
                naked: 'true'
            }));
        });

        document.getElementById('naked_left_arrow').addEventListener('click', () => {
            userNaked = "true";
            LoadNakedStatus();

            $.post(`https://${GetParentResourceName()}/isNaked`, JSON.stringify({
                naked: 'true'
            }));
        });
    }

}


///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                   LOAD MY OUTFIT ITEMS                                            //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

function LoadMyOutfitItems(myItems) {

    const myOutfitContainer = document.getElementById('MyOutfitProperties');
    myOutfitContainer.innerHTML = '';

    myItems.forEach(item => {
        if (item.category === myOutfitcategoryId) {

            if (item.selectorType === "slider") {

                const myOutFitElem = document.createElement('div');
                myOutFitElem.innerHTML = `
                    <div class="styleElem unselectable" id="myoutfit_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <p class="sliderValue unselectable" id="myoutfit_sliderValue_${item.id}">Variation ${item.value}</p>
                            <div class="sliderElem">
                                <a id="myoutfit_left_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow left"></a>
                                <input type="range" min="0" max="${item.totalAmount}" value="${item.value}" class="slider" id="myoutfitRange_${item.id}">
                                <a id="myoutfit_right_arrow_${item.id}" class="arrow"><img src="./img/arrow.png" alt="Arrow right" style="transform: rotate(180deg);"></a>
                            </div>
                        </div>
                    </div>
                `;

                myOutfitContainer.appendChild(myOutFitElem);

                updateRangeBackground('myoutfitRange_' + item.id);

                document.getElementById('myoutfit_right_arrow_' + item.id).addEventListener('click', () => {
                    const slider = document.getElementById('myoutfitRange_' + item.id);
                    if (slider.value !== slider.max) {
                        slider.value = parseInt(slider.value) + 1;
                        document.getElementById('myoutfit_sliderValue_' + item.id).innerText = `Variation ${slider.value}`;

                        updateRangeBackground('myoutfitRange_' + item.id);
                    }

                    $.post(`https://${GetParentResourceName()}/changeMyOutfitVar`, JSON.stringify({
                        category: item.id, menu: item.category,
                        item: slider.value
                    }));
                });

                document.getElementById('myoutfit_left_arrow_' + item.id).addEventListener('click', () => {
                    const slider = document.getElementById('myoutfitRange_' + item.id);
                    if (slider.value !== slider.min) {
                        slider.value = parseInt(slider.value) - 1;
                        document.getElementById('myoutfit_sliderValue_' + item.id).innerText = `Variation ${slider.value}`;

                        updateRangeBackground('myoutfitRange_' + item.id);
                    }

                    $.post(`https://${GetParentResourceName()}/changeMyOutfitVar`, JSON.stringify({
                        category: item.id, menu: item.category,
                        item: slider.value
                    }));
                });

                document.getElementById('myoutfitRange_' + item.id).addEventListener('input', () => {
                    const slider = document.getElementById('myoutfitRange_' + item.id);
                    document.getElementById('myoutfit_sliderValue_' + item.id).innerText = `Variation ${slider.value}`;

                    updateRangeBackground('myoutfitRange_' + item.id);

                    $.post(`https://${GetParentResourceName()}/changeMyOutfitVar`, JSON.stringify({
                        category: item.id, menu: item.category,
                        item: slider.value
                    }));
                });


            }
            else if (item.selectorType === "button") {

                const myOutFitElem = document.createElement('div');
                myOutFitElem.innerHTML = `
                    <div class="buttonStyleElem unselectable" id="myoutfit_${item.id}">
                        <p class="elemTitle">${item.name}</p>
                        <div class="sliderDiv">
                            <div class="sliderElem">
                                <a class="buttonStyleOutfit" id="buttonStyle_${item.id}"><p class="unselectable">${item.buttonText}</p></a>
                            </div>
                        </div>
                    </div>
                `;

                myOutfitContainer.appendChild(myOutFitElem);

                document.getElementById('buttonStyle_' + item.id).addEventListener('click', () => {

                    $.post(`https://${GetParentResourceName()}/invertActiveCategory`, JSON.stringify({
                        category: item.id,
                    }));
                });

            }
        }
    });

}






///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                         DOM                                                       //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////



// Event Listeners for interactions
document.addEventListener('DOMContentLoaded', function () {

    /////////////////////////// OUTFIT SAVE ///////////////////////////

    //Actual Outfit Save
    document.getElementById('SaveActualOutfit').addEventListener('click', () => {

        $.post(`https://${GetParentResourceName()}/saveMyOutfit`, JSON.stringify({
            outfitId: outfitElemId
        }));
    });

    //Actual Outfit Save
    document.getElementById('CloseActualOutfit').addEventListener('click', () => {

        $.post(`https://${GetParentResourceName()}/closeMyOutfitMenu`, JSON.stringify({
        }));
    });

    //Actual Outfit Reset
    document.getElementById('ResetActualOutfit').addEventListener('click', () => {

        $.post(`https://${GetParentResourceName()}/resetMyOutfit`, JSON.stringify({
            outfitId: outfitElemId
        }));
    });

    /////////////////////////// MY OUTFIT CATEGORIES ///////////////////////////

    //My Outfit select Clothes Categorie
    document.getElementById('ClothesCategorie').addEventListener('click', () => {
        myOutfitcategoryId = 1;
        document.getElementById('ClothesCategorie').classList.add('selected');
        document.getElementById('SkinCategorie').classList.remove('selected');
        LoadMyOutfitItems(myItems);
    });

    //My Outfit select Skin Categorie
    document.getElementById('SkinCategorie').addEventListener('click', () => {
        myOutfitcategoryId = 2;
        document.getElementById('ClothesCategorie').classList.remove('selected');
        document.getElementById('SkinCategorie').classList.add('selected');
        LoadMyOutfitItems(myItems);
    });


    /////////////////////////// CREATE OUTFIT ///////////////////////////

    //Event Create Outfit
    document.getElementById('CreateOutfit').addEventListener('click', () => {

        //Check if the outfit is already created
        if (menuType === "default") {

            document.getElementById('SelectOutfitName').classList.remove('hidden');

            document.getElementById('SelectOutfitName').innerHTML = `

                        <div id = "CreationConfirmationElem" >

                        <div id = "CreationConfirmationContent">

                        <div id="DeletionConfirmationTitle">

                            <h1>${T('outfitName')}</h1>
                            <input type="text" class="outfitInput" id="outfitName" placeholder="${T('outfitNamePlaceholder')}">

                        </div>

                        <div id="DeletionConfirmationInteraction">

                            <a id="cancelCreationOutfit" class="button_del">${T('cancel')}</a>
                            <a id="confirmCreationOutfit" class="button_del">${T('create')}</a>

                        </div>

                        </div>

                        </div>
                `;

            //Accept Creation Outfit
            document.getElementById('confirmCreationOutfit').addEventListener('click', () => {

                outfitName = document.getElementById('outfitName').value;
                
                // Trim whitespace and ensure UTF-8 encoding is preserved
                if (outfitName) {
                    outfitName = outfitName.trim();
                }

                $.post(`https://${GetParentResourceName()}/createOutfit`, JSON.stringify({
                    outfitName: outfitName
                }));
                document.getElementById('SelectOutfitName').classList.add('hidden');
            });

            //Cancel Creation Outfit
            document.getElementById('cancelCreationOutfit').addEventListener('click', () => {
                document.getElementById('SelectOutfitName').classList.add('hidden');
            });


        } else {
            $.post(`https://${GetParentResourceName()}/saveOutfit`, JSON.stringify({
                outfitid: outfitElemId
            }));
        }

    });


    document.getElementById('CancelOutfit').addEventListener('click', () => {
        $.post(`https://${GetParentResourceName()}/backToOutfitList`);
    });


    /////////////////////////// RESET OUTFIT ///////////////////////////

    //Event Reset Outfit
    document.getElementById('ResetOutfit').addEventListener('click', () => {

        document.getElementById('SelectOutfitName').classList.remove('hidden');
        document.getElementById('SelectOutfitName').innerHTML = `

            <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>Warning!</h1>
                    <p>Are you sure you want to reset the outfit you are creating?</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="cancelResetOutfit" class="button_del">Cancel</a>
                    <a id="confirmResetOutfit" class="button_del">Reset</a>

                </div>

                </div>

                </div>
    `;

        //Accept Creation Outfit
        document.getElementById('confirmResetOutfit').addEventListener('click', () => {

            $.post(`https://${GetParentResourceName()}/resetOutfit`, JSON.stringify({
            }));

            document.getElementById('SelectOutfitName').classList.add('hidden');

        });

        //Cancel Creation Outfit
        document.getElementById('cancelResetOutfit').addEventListener('click', () => {
            document.getElementById('SelectOutfitName').classList.add('hidden');
        });

    });


    //Event Create Outfit mannequin
    document.getElementById('CreateNewOutfitMannequin').addEventListener('click', () => {

        document.getElementById('SelectOutfitGender').classList.remove('hidden');
        document.getElementById('SelectOutfitGender').innerHTML = `

            <div id = "DeletionConfirmationElem" >

                <div id = "DeletionConfirmationContent" >

                <div id="DeletionConfirmationTitle">

                    <h1>New Outfit!</h1>
                    <p>Select the gender</p>

                </div>

                <div id="DeletionConfirmationInteraction">

                    <a id="maleOutfit" class="button_del">Male</a>
                    <a id="femaleOutfit" class="button_del">Female</a>

                </div>

                </div>

                </div>
    `;

        //Male Outfit
        document.getElementById('maleOutfit').addEventListener('click', () => {

            $.post(`https://${GetParentResourceName()}/createMaleOutfit`, JSON.stringify({
            }));

            document.getElementById('SelectOutfitGender').classList.add('hidden');

        });

        //Female Outfit
        document.getElementById('femaleOutfit').addEventListener('click', () => {
            $.post(`https://${GetParentResourceName()}/createFemaleOutfit`, JSON.stringify({
            }));

            document.getElementById('SelectOutfitGender').classList.add('hidden');
        });

    });


});





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                        MESSAGES                                                   //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////

//Event Price Outfit
window.addEventListener('message', (event) => {
    if (event.data.type === 'setOutfitPricet') {
        document.getElementById('CreateOutfit').innerHTML = T('savePrice') + event.data.price;
    }
});

// Event Listener for the NUI Messages
window.addEventListener('message', function (event) {

    // Open Outfit Menu
    if (event.data.type === "openOutfitMenu") {
        console.log("Activer le menu outfit")
        if (event.data.categories) {
            categories = event.data.categories;
        }

        if (event.data.menu == "wearable") {
            this.document.getElementById('CreateOutfit').classList.add('cache');
        }
        else {
            this.document.getElementById('CreateOutfit').classList.remove('cache');
        }

        if (event.data.menu == "creator") {
            inCreatorMode = true;
            this.document.getElementById('CreateOutfit').classList.add('cache');
        }
        else {
            inCreatorMode = false;
            this.document.getElementById('CreateOutfit').classList.remove('cache');
        }

        outfitElemId = event.data.outfitId;

        if (event.data.menu == "modify") {
            menuType = "modify";
        }
        else {
            menuType = "default";
        }

        if (event.data.items) {
            items = event.data.items;
        }
        showOutfitMenu();

    }

    // Open Actual Outfit Settings Menu
    if (event.data.type === "openMyOutfitMenu") {
        console.log("Activer le menu de mes outfit")
        if (event.data.myItems) {
            myItems = event.data.myItems;
            outfitElemId = event.data.outfitId;
            myOutfitcategoryId = 1;
            document.getElementById('ClothesCategorie').classList.add('selected');
            document.getElementById('SkinCategorie').classList.remove('selected');
            LoadMyOutfitItems(myItems);

        }
        ShowMyOutfitItems();
    }

    // Open Actual Outfit Settings Menu
    if (event.data.type === "closeMyOutfitMenu") {
        console.log("Fermer le menu de mes outfit")
        HideMyOutfitItems();
    }


    // Open Outfit List Menu
    if (event.data.type === "openOutfitListMenu") {
        console.log("Activer le menu de list de mes outfit")
        if (event.data.outfits) {
            MyOutfits = event.data.outfits;
        }
        showOutfitListMenu();
    }

    // Close Outfit Menu
    if (event.data.type === "closeOutfitMenu") {
        console.log("Fermer le menu outfit")
        hideOutfitMenu();
        hideOutfitListMenu();
    }

    // Open Outfit List Menu
    if (event.data.type === "closeOutfitListMenu") {
        console.log("Activer le menu de list de mes outfit")
        hideOutfitListMenu();
    }


    // Load contextualDatas
    if (event.data.type === "contextualDatas") {

        // Convert to array if it's an object
        const contextualData = Array.isArray(event.data.data) ? event.data.data : [event.data.data];
        const contextualType = contextualData[0]?.contextual
        showContextualMenu(contextualType);
        loadContextualDatas(contextualData);
        console.log("Charger les données de l'item", contextualData);
    }

    // Hide contextualDatas
    if (event.data.type === "hidecontextualDatas") {
        console.log("Cacher le contextuel");
        hideContextualMenu();
    }

});


// Escape Key
document.addEventListener('keyup', function (e) {
    if (e.key === "Escape") {
        if (inCreatorMode === false) {
            $.post(`https://${GetParentResourceName()}/closeoutfitmenu`);
            $.post(`https://${GetParentResourceName()}/closeMyOutfitMenu`);
            this.document.getElementById('CreateOutfit').classList.remove('cache');
        }
    }
});

// X Key
document.addEventListener('keyup', function (e) {
    if (e.key === "x") {
        $.post(`https://${GetParentResourceName()}/handsup`);
    }
});

const copyToClipboard = str => {
    const el = document.createElement('textarea');
    el.value = str;
    document.body.appendChild(el);
    el.select();
    document.execCommand('copy');
    document.body.removeChild(el);
};

window.addEventListener('message', (event) => {
    if (event.data.type === 'clipboard') {
        copyToClipboard(event.data.data);
    }
});





///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////
//                                    LOAD RED INPUT                                                 //
///////////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////////


function updateRangeBackground(rangeInput) {
    // Use a unique style element per slider and clean previous one
    const styleId = 'style_' + rangeInput;
    const oldStyle = document.getElementById(styleId);
    if (oldStyle) {
        oldStyle.parentNode.removeChild(oldStyle);
    }

    const rangeInputElem = document.getElementById(rangeInput);
    if (!rangeInputElem) return;

    const value = rangeInputElem.value;
    const min = rangeInputElem.min || 0;
    const max = rangeInputElem.max || 100;
    const percentage = ((value - min) / (max - min)) * 100;

    const backgroundStyle = `
         #${rangeInput} {
            background: linear-gradient(to right, 
                red 0%, 
                red ${percentage}%, 
                #ddd ${percentage}%, 
                #ddd 100%
            ) !important;
        }
        /* Styles supplémentaires pour assurer la compatibilité avec différents navigateurs */
        #${rangeInput}::-webkit-slider-runnable-track {
            background: transparent;
        }
        #${rangeInput}::-moz-range-track {
            background: transparent;
        }
        #${rangeInput}::-ms-track {
            background: transparent;
        }
    `;

    const style = document.createElement('style');
    style.id = styleId;
    style.textContent = backgroundStyle;
    document.head.appendChild(style);
};

