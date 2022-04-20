"use strict";
var ModItemsSpawner = {
    InputCategory: [
        ['ConditionMax'      , 'StaminaModifier' , 'FatigueOnSkillUse'],
        ['RegularDamage'     , 'ArmorDamageMult' , 'DirectDamageAdd'  ],
        ['RegularDamageMax'  , 'ShieldDamage'    , 'ChanceToHitHead'  ],
        ['AdditionalAccuracy', 'AmmoMax'        ],
        ['MeleeDefense'      , 'RangedDefense'  ],
    ],
};

var WorldItemsSpawnerScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;

    // 
    this.mStash = {
        Data               : null,
        Slot               : null,
        Label              : null,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    //
    this.mSelected = {
        Layout            : null,
        Name              : null,
        Amount            : null,
        AttributeContainer: null,
        Attribute: {
            ConditionMax      : {Input: null, ValueMin:   1, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + Asset.ICON_REPAIR_ITEM         , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            StaminaModifier   : {Input: null, ValueMin: -99, ValueMax:   0, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + Asset.ICON_FATIGUE             , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            MeleeDefense      : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + Asset.ICON_MELEE_DEFENCE       , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            RangedDefense     : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + Asset.ICON_RANGE_DEFENCE       , TooltipId: TooltipIdentifier.Assets.BusinessReputation}, 
            RegularDamage     : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + 'ui/icons/damage_dealt_min.png', TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            RegularDamageMax  : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + 'ui/icons/damage_dealt_max.png', TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            ArmorDamageMult   : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage:  true, Postfix: '%', IconPath: Path.GFX + Asset.ICON_CRUSHING_DAMAGE    , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            DirectDamageAdd   : {Input: null, ValueMin:   0, ValueMax: 100, Min: 0, Max: 3, IsPercentage:  true, Postfix: '%', IconPath: Path.GFX + 'ui/icons/direct_damage.png'  , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            ShieldDamage      : {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + 'ui/icons/shield_damage.png'   , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            ChanceToHitHead   : {Input: null, ValueMin:   0, ValueMax: 100, Min: 0, Max: 3, IsPercentage:  true, Postfix: '%', IconPath: Path.GFX + Asset.ICON_CHANCE_TO_HIT_HEAD , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            FatigueOnSkillUse : {Input: null, ValueMin: -99, ValueMax:  99, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + 'ui/icons/special.png'         , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            AdditionalAccuracy: {Input: null, ValueMin:   0, ValueMax: 999, Min: 0, Max: 3, IsPercentage:  true, Postfix: '%', IconPath: Path.GFX + 'ui/icons/hitchance.png'      , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
            AmmoMax           : {Input: null, ValueMin:   1, ValueMax: 999, Min: 0, Max: 3, IsPercentage: false, Postfix: '', IconPath: Path.GFX + Asset.ICON_ASSET_AMMO          , TooltipId: TooltipIdentifier.Assets.BusinessReputation},
        },
    };

    //
    this.mSearch = {
        Filter             : 0,
        Input              : null,
        Found              : null,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    // buttons
    this.mLeaveButton  = null;
    this.mRerollButton = null;
    this.mAddButton    = null;

    // generics
    this.mIsVisible    = false;

    // selected entry
    this.mSelectedEntry = null;
};

WorldItemsSpawnerScreen.prototype.createDIV = function(_parentDiv)
{
    var self = this;

	// create: containers (init hidden!)
     this.mContainer = $('<div class="world-items-spawner-screen display-none opacity-none"/>');
     _parentDiv.append(this.mContainer);

    // create: containers (init hidden!)
    var dialogLayout = $('<div class="l-items-spanwer-dialog-container"/>');
    this.mContainer.append(dialogLayout);
    this.mDialogContainer = dialogLayout.createDialog('Item Spawner', null, '', true, 'dialog-1024-768');

    // create tabs
    var tabButtonsContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabButtonsContainer);

    // create content
    var content = this.mDialogContainer.findDialogContentContainer();
    {
        var leftColumn = $('<div class="column with-dialog-background"/>');
        content.append(leftColumn);
        var stashHeader = $('<div class="stash-header-container with-small-dialog-background"/>');
        leftColumn.append(stashHeader);
        {
            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + 'ui/buttons/delete.png', function(_button) {
                self.notifyBackendDeleteAllStashItem();
            }, '', 6);

            var buttonLayout = $('<div class="l-flex-button-174-43"/>');
            stashHeader.append(buttonLayout);
            this.mStash.Label = buttonLayout.createTextButton('Stash', null, '', 7);
            this.mStash.Label.findButtonText().css('top', '0.3rem');
            this.mStash.Label.enableButton(false);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_SORT, function(_button) {
                self.notifyBackendSortStashItem();
            }, '', 6);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.ICON_REPAIR_ITEM, function(_button) {
                self.notifyBackendRepairAllStashItem();
            }, '', 6);

            var buttonLayout = $('<div class="l-flex-button-45-41"/>');
            stashHeader.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_DELAY_TURN, function(_button) {
                self.notifyBackendRestockAllStashItem();
            }, '', 6);
        }

        var stashContent = $('<div class="stash-content-container"/>');
        leftColumn.append(stashContent);
        var listContainerLayout = $('<div class="l-list-container"/>');
        stashContent.append(listContainerLayout);
        this.mStash.ListContainer = listContainerLayout.createList(2);
        this.mStash.ListScrollContainer = this.mStash.ListContainer.findListScrollContainer();

        var rightColumn = $('<div class="column"/>');
        content.append(rightColumn);
        {
            var upperRow = $('<div class="row-upper with-large-dialog-background"/>');
            rightColumn.append(upperRow);
            var itemContainer = $('<div class="column-is-portrait"/>');
            upperRow.append(itemContainer);
            this.mSelected.Layout = $('<div class="item-layout"/>');
            itemContainer.append(this.mSelected.Layout);
            var image = this.mSelected.Layout.createImage(Path.GFX + 'ui/items/slots/inventory_slot_bag.png', null, null, '');
            image.data('item', null);

            var nameContainer = $('<div class="column-is-name"/>');
            upperRow.append(nameContainer);
            var row = $('<div class="row"/>');
            nameContainer.append(row);
            var title = $('<div class="title title-font-big font-color-title">Item Name</div>');
            row.append(title);
            var inputLayout = $('<div class="l-input"/>');
            row.append(inputLayout);
            this.mSelected.Name = inputLayout.createInput('', 0, 50, 1, function(_input) {
            }, 'title-font-big font-bold font-color-brother-name');
            
            var column = $('<div class="column-is-option"/>');
            upperRow.append(column);
            var buttonLayout = $('<div class="l-add-button"/>');
            column.append(buttonLayout);
            this.mAddButton = buttonLayout.createTextButton('Add', function(_button) {
                var imageEntry = self.mSelected.Layout.find('img:first');
                self.notifyBackendAddItemToStash(imageEntry);
            }, '', 2);
            this.mAddButton.findButtonText().css('top', '0.2rem');
            var amountContainer = $('<div class="input-amount-container"/>');
            column.append(amountContainer);
            var title = $('<div class="amount title-font-big font-align-center font-color-title">Num</div>');
            title.css('font-size', '2.0rem');
            amountContainer.append(title);
            var amountInputLayout = $('<div class="amount-input"/>');
            amountContainer.append(amountInputLayout);
            this.createAmountInputDIV(amountInputLayout);

            this.mSelected.AttributeContainer = $('<div class="column-is-input with-scroll-tooltip-background"/>');
            upperRow.append(this.mSelected.AttributeContainer);
            for (var i = 0; i < ModItemsSpawner.InputCategory.length; i++) {
                var inputColumn = $('<div class="l-input-column"/>');
                this.mSelected.AttributeContainer.append(inputColumn);
                ModItemsSpawner.InputCategory[i].forEach(function(_key) {
                    self.createInputDIV(_key, self.mSelected.Attribute[_key], inputColumn);
                });
            }
            var buttonLayout = $('<div class="l-reroll-button"/>');
            this.mSelected.AttributeContainer.append(buttonLayout);
            this.mRerollButton = buttonLayout.createTextButton('Reroll', null, '', 2);
            this.mRerollButton.findButtonText().css('top', '0.2rem');

            var lowerRow = $('<div class="row-lower with-dialog-background"/>');
            rightColumn.append(lowerRow);
            {
                var foundContainer = $('<div class="search-found"/>');
                lowerRow.append(foundContainer);
                this.mSearch.Found = $('<div class="search-found-label text-font-medium font-color-title font-align-center"/>');
                foundContainer.append(this.mSearch.Found);

                var searchBarRow = $('<div class="search-bar-row"/>');
                lowerRow.append(searchBarRow);
                var row = $('<div class="row"/>');
                searchBarRow.append(row);
                var title = $('<div class="title title-font-big font-color-title">Search Item</div>');
                row.append(title);
                var inputLayout = $('<div class="l-input"/>');
                row.append(inputLayout);
                this.mSearch.Input = inputLayout.createInput('', 0, 50, 1, function(_input) {
                    if (_input.getInputTextLength() >= 3) {
                        self.notifyBackendSeachItemBy(_input.getInputText());
                    }
                }, 'title-font-big font-bold font-color-brother-name', function(_input) {
                    self.notifyBackendSeachItemBy(_input.getInputText());
                });
                var buttonLayout = $('<div class="search-button"/>');
                searchBarRow.append(buttonLayout);
                var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/search_icon.png', function() {
                    self.notifyBackendSeachItemBy(self.mSearch.Input.getInputText());
                }, '', 6);

                var searchResultRow = $('<div class="search-result-row"/>');
                lowerRow.append(searchResultRow);
                var searchFilterContainer = $('<div class="search-filter-container"/>');
                searchResultRow.append(searchFilterContainer);

                var filterColumn =  $('<div class="search-filter-column"/>');
                searchFilterContainer.append(filterColumn);
                for (var i = 0; i < 5; i++) {
                    var buttonLayout = $('<div class="l-flex-button-45-41"/>');
                    filterColumn.append(buttonLayout);
                    var imageButton = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function(_button) {
                        self.changeSearchItemFilter(_button);
                        if (self.mSearch.Input.getInputTextLength() >= 3) {
                            self.notifyBackendSeachItemBy(self.mSearch.Input.getInputText());
                        }
                        else {
                            self.notifyBackendShowAllItems();
                        }
                    }, '', 6);
                    this.changeSearchItemFilter(imageButton, i);
                }

                var filterColumn =  $('<div class="search-filter-column"/>');
                searchFilterContainer.append(filterColumn);
                for (var j = 5; j < 10; j++) {
                    var buttonLayout = $('<div class="l-flex-button-45-41"/>');
                    filterColumn.append(buttonLayout);
                    var imageButton = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function(_button) {
                        self.changeSearchItemFilter(_button);
                        if (self.mSearch.Input.getInputTextLength() >= 3) {
                            self.notifyBackendSeachItemBy(self.mSearch.Input.getInputText());
                        }
                        else {
                            self.notifyBackendShowAllItems();
                        }
                    }, '', 6);
                    this.changeSearchItemFilter(imageButton, j);
                }

                var searchResultContainer = $('<div class="search-result-container with-scroll-tooltip-background"/>');
                searchResultRow.append(searchResultContainer);
                var listContainerLayout = $('<div class="l-list-container"/>');
                searchResultContainer.append(listContainerLayout);
                this.mSearch.ListContainer = listContainerLayout.createList(1);
                this.mSearch.ListScrollContainer = this.mSearch.ListContainer.findListScrollContainer();
            }
        }
    }

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

    // create: buttons
    var layout = $('<div class="l-leave-button"/>');
    footerButtonBar.append(layout);
    this.mLeaveButton = layout.createTextButton("Close", function() {
        self.notifyBackendCloseButtonPressed();
    }, '', 1);

    this.mIsVisible = false;
};

WorldItemsSpawnerScreen.prototype.changeSearchItemFilter = function(_button, _i)
{   
    if (_i === undefined || _i === null) {
        this.mSearch.Filter = _button.data('filter');
        return;
    }

    var image;
    switch(_i)
    {
    case 1:
        image = 'icons/special';
        break;

    case 2:
        image = 'icons/ammo';
        break;

    case 3:
        image = 'icons/tools';
        break;

    case 4:
        image = 'icons/crafting';
        break;

    case 5:
        image = 'icons/armor_body';
        break;

    case 6:
        image = 'icons/armor_head';
        break;

    case 7:
        image = 'icons/melee_skill';
        break;

    case 8:
        image = 'icons/sturdiness';
        break;

    case 9:
        image = 'icons/accessory';
        break;

    default:
        image = 'buttons/filter_all';
    }

    _button.data('filter', _i);
    _button.changeButtonImage(Path.GFX + 'ui/' + image + '.png');
    _button.bindTooltip({ contentType: 'ui-element', elementId: _i, elementOwner: 'woditor.searchfilterbutton' });
};

WorldItemsSpawnerScreen.prototype.createAmountInputDIV = function(_layout)
{
    var self = this;
    this.mSelected.Amount = _layout.createInput('', 0, 3, null, null, 'title-font-medium font-bold font-color-brother-name font-align-center', function(_input) {
        self.confirmAmountChanges(_input);
    });
    this.mSelected.Amount.assignInputEventListener('focusout', function(_input, _event) {
        self.confirmAmountChanges(_input);
    });
    this.mSelected.Amount.assignInputEventListener('click', function(_input, _event) {
        _input.data('IsUpdated', false);
        _input.data('Default', _input.val());
    });
    this.mSelected.Amount.assignInputEventListener('mouseover', function(_input, _event) {
        _input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    this.mSelected.Amount.assignInputEventListener('mouseout', function(_input, _event) {
        _input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    this.mSelected.Amount.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    this.mSelected.Amount.css('background-size', '5.2rem 4.1rem');
}

WorldItemsSpawnerScreen.prototype.createInputDIV = function(_key, _definition, _parentDiv)
{
    var self = this;
    var isPercentage = _definition.IsPercentage;
    var inputRow = $('<div class="input-row"/>');
    _parentDiv.append(inputRow);

    var inputRowIconLayout = $('<div class="input-row-icon"/>');
    inputRow.append(inputRowIconLayout);
    var inputRowIcon = inputRowIconLayout.createImage(_definition.IconPath, null, null, '');
    inputRowIcon.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });

    var inputRowLayout = $('<div class="l-input-small"/>');
    inputRow.append(inputRowLayout);
    _definition.Input = inputRowLayout.createInput(_definition.Value, _definition.Min, _definition.Max, null, null, 'title-font-medium font-bold font-color-brother-name font-align-center', function(_input) {
        self.confirmAttributeChanges(_input, _key);
        if (isPercentage === true)
            _input.addPercentageToInput();

        _input.addDashToInput();
    });
    _definition.Input.assignInputEventListener('focusout', function(_input, _event) {
        self.confirmAttributeChanges(_input, _key);
        if (isPercentage === true)
            _input.addPercentageToInput();
    });
    _definition.Input.assignInputEventListener('click', function(_input, _event) {
        if (isPercentage === true)
            _input.removePercentageFromInput();

        _input.removeDashFromInput();
        _input.data('IsUpdated', false);
        _input.data('Default', _input.val());
    });
    _definition.Input.assignInputEventListener('mouseover', function(_input, _event) {
        _input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    _definition.Input.assignInputEventListener('mouseout', function(_input, _event) {
        _input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    });
    _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/button_03_default.png")');
    _definition.Input.css('background-size', '5.2rem 4.1rem');
}

WorldItemsSpawnerScreen.prototype.confirmAmountChanges = function(_input)
{
    if (_input.data('IsUpdated') === true)
        return;

    var self = this;
    var value = 0;
    var isValid = true;

    if (_input.getInputTextLength() <= 0) {
        isValid = false;
    }
    else {
        value = _input.isValidInputNumber(1, 99);
        if (value === null)
            isValid = false;
    }

    if (isValid === true) {
        _input.val('' + value + '');
        _input.data('IsUpdated', true);
        _input.data('Default', value);
    }
    else {
        _input.val('' + _input.data('Default') + '');
    }
};

WorldItemsSpawnerScreen.prototype.confirmAttributeChanges = function(_input, _keyName)
{
    if (_input.data('IsUpdated') === true)
        return;

    var self = this;
    var definition = this.mSelected.Attribute[_keyName];
    var value = 0;
    var isValid = true;

    if (_input.getInputTextLength() <= 0 || definition === null) {
        isValid = false;
    }
    else {
        value = _input.isValidInputNumber(definition.ValueMin, definition.ValueMax);
        if (value === null)
            isValid = false;
    }

    if (isValid === true) {
        _input.val('' + value + '');
        _input.data('IsUpdated', true);
        _input.data('Default', value);
        //this.notifyBackendUpdateAssetsPropertyValue(_keyName, value);
    }
    else {
        _input.val('' + _input.data('Default') + '');
    }
};

WorldItemsSpawnerScreen.prototype.destroyDIV = function()
{
	this.mSelectedEntry = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

WorldItemsSpawnerScreen.prototype.bindTooltips = function()
{
};

WorldItemsSpawnerScreen.prototype.unbindTooltips = function()
{
};

WorldItemsSpawnerScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

WorldItemsSpawnerScreen.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};

WorldItemsSpawnerScreen.prototype.isConnected = function()
{
    return this.mSQHandle !== null;
};

WorldItemsSpawnerScreen.prototype.onConnection = function(_handle)
{
    this.mSQHandle = _handle;
    this.register($('.root-screen'));
};

WorldItemsSpawnerScreen.prototype.onDisconnection = function()
{
    this.mSQHandle = null;
    this.unregister();
};

WorldItemsSpawnerScreen.prototype.register = function(_parentDiv)
{
    console.log('WorldItemsSpawnerScreen::REGISTER');

    if (this.mContainer !== null) {
        console.error('ERROR: Failed to register WorldItemsSpawnerScreen. Reason: Already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object') {
        this.create(_parentDiv);
    }
};

WorldItemsSpawnerScreen.prototype.unregister = function()
{
    console.log('WorldItemsSpawnerScreen::UNREGISTER');

    if (this.mContainer === null) {
        console.error('ERROR: Failed to unregister WorldItemsSpawnerScreen. Reason: Not initialized.');
        return;
    }

    this.destroy();
};

WorldItemsSpawnerScreen.prototype.isRegistered = function()
{
    if (this.mContainer !== null) {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};

WorldItemsSpawnerScreen.prototype.isVisible = function()
{
    return this.mIsVisible;
};

WorldItemsSpawnerScreen.prototype.show = function(_data)
{
    this.loadFromData(_data);
	var self = this;
	var offset = -(this.mContainer.parent().width() + this.mContainer.width());
	this.mContainer.css({ 'left': offset });
	this.mContainer.velocity("finish", true).velocity({ opacity: 1, left: '0', right: '0' }, {
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function () {
			$(this).removeClass('display-none').addClass('display-block');
			self.notifyBackendOnAnimating();
		},
		complete: function () {
			self.mIsVisible = true;
			self.notifyBackendOnShown();
		}
	});
};

WorldItemsSpawnerScreen.prototype.hide = function(_withSlideAnimation)
{
    var self = this;
    var offset = -(this.mContainer.parent().width() + this.mContainer.width());
    this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset }, {
        duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
        easing: 'swing',
        begin: function() {
            $(this).removeClass('is-center');
            self.notifyBackendOnAnimating();
        },
        complete: function() {
        	self.mIsVisible = false;
            $(this).removeClass('display-block').addClass('display-none');
            self.notifyBackendOnHidden();
        }
    });
};

WorldItemsSpawnerScreen.prototype.loadFromData = function(_data)
{
    if (_data === undefined || _data === null) {
        return;
    }

    this.revertToDefault();
    this.createItemContainer(_data.Slots);
    this.addStashData(_data.Stash);
    this.mStash.Label.changeButtonText('Stash: ' + _data.Stash.length + '/' + _data.Slots);
};

WorldItemsSpawnerScreen.prototype.createItemContainer = function(_slotNum)
{
    this.mStash.Slot = [];
    this.mStash.ListScrollContainer.empty();
    for (var i = 0; i < _slotNum; i++) {
        var itemContainer = $('<div class="item-container"/>');
        this.mStash.ListScrollContainer.append(itemContainer);
        this.mStash.Slot.push(itemContainer);
    }
};

WorldItemsSpawnerScreen.prototype.addStashData = function(_data)
{
    this.mStash.Data = _data;
    for (var i = 0; i < _data.length; i++) {
        this.createItemEntry(_data[i], this.mStash.Slot[_data[i].Index]);
    }
};

WorldItemsSpawnerScreen.prototype.createItemEntry = function(_data, _slot)
{
    var self = this;
    var itemContainer = _slot;
    itemContainer.empty();
    var imageLayout = $('<div class="item-layout"/>');
    itemContainer.append(imageLayout);
    var image = imageLayout.createImage(Path.GFX + _data.ImagePath, null, null, '');
    image.data('item', _data);

    var overlays = _data.ImageOverlayPath;
    if (overlays !== undefined && overlays !== '' && overlays.length > 0) {
        overlays.forEach(function (_imagePath) {
            if (_imagePath === '') return;

            var overlayImage = imageLayout.createImage(Path.ITEMS + _imagePath, null, null, '');
            overlayImage.css('pointer-events', 'none');
        });
    }

    if (_data.ShowAmount === true) {
        var amountLabel = $('<div class="label text-font-very-small font-shadow-outline"/>'); //font-size-13
        imageLayout.append(amountLabel);
        amountLabel.html(_data.Amount);
        amountLabel.css('color', _data.AmountColor);
    }

    // set up event listeners
    image.click(this, function(_event) {
        var element = $(this);
        self.selectItem(element);
    });
    image.bindTooltip({ contentType: 'ui-item', entityId: _data.Owner, itemId: _data.ID, itemOwner: 'woditor.itemspawner'});
};

WorldItemsSpawnerScreen.prototype.fillSearchItemResult = function(_data)
{
    var self = this;
    this.mSearch.ListScrollContainer.empty();

    if (_data.length === 0) {
        var foundNothingLabel = $('<div class="find-no-result-container text-font-normal font-bold font-color-negative-value font-align-center"/>');
        foundNothingLabel.html('No Item Matches');
        this.mSearch.ListScrollContainer.append(foundNothingLabel);
        this.mSearch.Found.html('');
        return;
    }

    this.mSearch.Found.html('Found ' + _data.length + ' item' + (_data.length > 1 ? 's' : ''));

    for (var i = 0; i < _data.length; i++) {
        var itemContainer = $('<div class="item-container"/>');
        this.mSearch.ListScrollContainer.append(itemContainer);
        
        var imageLayout = $('<div class="item-layout"/>');
        itemContainer.append(imageLayout);
        var image = imageLayout.createImage(Path.GFX + _data[i].ImagePath, null, null, '');
        image.data('item', _data[i]);

        if (_data[i].LayerImagePath.length > 0) {
            var overlayImage = imageLayout.createImage(Path.ITEMS + _data[i].LayerImagePath, null, null, '');
            overlayImage.css('pointer-events', 'none');
        }

        // set up event listeners
        image.click(this, function(_event) {
            var element = $(this);
            if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true)
                self.notifyBackendAddItemToStash(element, true);
            else
                self.selectItem(element);
        });

        image.bindTooltip({ contentType: 'ui-element', elementId: _data[i].ID, elementOwner: 'woditor.searchresult' });
    }
};

WorldItemsSpawnerScreen.prototype.selectItem = function(_element)
{
    if (_element !== null && _element.length > 0)
    {
        this.updateSelectedItemDetailPanel(_element);
    }
    else
    {
        this.updateSelectedItemDetailPanel(null);
    }
};

WorldItemsSpawnerScreen.prototype.updateSelectedItemDetailPanel = function(_element)
{
    if (_element === null || _element.length <= 0) {
        this.revertToDefault();
        return;
    }

    var self = this;
    var data = _element.data('item');
    this.updateDisplayItem(data);
    this.mAddButton.enableButton(true);

    if (data.ShowAmount === true && typeof data.Amount != 'string')
    {
        this.mSelected.Amount.val('' + data.Amount + '');
        this.mSelected.Amount.removeClass('no-pointer-events');
    }
    else if (this.mSelected.Amount.getInputText() === '-x-')
    {
        this.mSelected.Amount.val('1');
        this.mSelected.Amount.removeClass('no-pointer-events');
    }

    this.mSelected.Name.val(data.Name);
    if (data.CanChangeName === true)
        this.mSelected.Name.removeClass('no-pointer-events');
    else
        this.mSelected.Name.addClass('no-pointer-events');

    if (data.CanChangeStats === true) {
        var attribute = data.Attribute;
        this.mSelected.AttributeContainer.removeClass('is-grayscale');
        $.each(this.mSelected.Attribute, function(_key, _definition) {
            var attr = self.mSelected.Attribute[_key];
            if (_key in attribute) {
                attr.Input.val('' + attribute[_key] + attr.Postfix);
                attr.Input.removeClass('no-pointer-events');
            }
            else {
                attr.Input.val('-x-');
                attr.Input.addClass('no-pointer-events');
            }
        }); 
    }
    else {
        this.mSelected.AttributeContainer.addClass('is-grayscale');
        $.each(this.mSelected.Attribute, function(_key, _definition) {
            _definition.Input.val('-x-');
            _definition.Input.addClass('no-pointer-events');
        });
    }
};

WorldItemsSpawnerScreen.prototype.updateDisplayItem = function(_data)
{
    var self = this;
    this.mSelected.Layout.empty();
    var image = this.mSelected.Layout.createImage(Path.GFX + _data.ImagePath, null, null, '');
    image.data('item', _data);

    var overlays = _data.ImageOverlayPath;
    if (overlays !== undefined && overlays !== '' && overlays.length > 0) {
        overlays.forEach(function (_imagePath) {
            if (_imagePath === '') return;
            var overlayImage = self.mSelected.Layout.createImage(Path.ITEMS + _imagePath, null, null, '');
            overlayImage.css('pointer-events', 'none');
        });
    }
};

WorldItemsSpawnerScreen.prototype.revertToDefault = function()
{
    this.mAddButton.enableButton(false);
    this.mRerollButton.enableButton(false);
    this.mSelected.Name.val('');
    this.mSelected.Name.addClass('no-pointer-events');
    this.mSelected.Amount.val('-x-');
    this.mSelected.Amount.addClass('no-pointer-events');
    this.mSelected.AttributeContainer.addClass('is-grayscale');
    $.each(this.mSelected.Attribute, function(_key, _definition) {
        _definition.Input.val('-x-');
        _definition.Input.addClass('no-pointer-events');
    }); 
    this.mSelected.Layout.find('img').each(function(index, element) {
        var image = $(element);
        if (index === 0)
            image.attr('src', Path.GFX + 'ui/items/slots/inventory_slot_bag.png');
        else 
            image.remove();
    });
};

WorldItemsSpawnerScreen.prototype.gatherAttributes = function()
{
    var result = {};
    $.each(this.mSelected.Attribute, function(_key, _definition) {
        var v = parseInt(_definition.Input.getInputText());
        if (isNaN(v) === false) {
            result[_key] = v;
        } 
    });
    return result;
};

WorldItemsSpawnerScreen.prototype.getStashItem = function(_id)
{
    for (var i = 0; i < this.mStash.Data.length; i++) {
        if (this.mStash.Data[i].ID === _id) {
            return {
                Index = i;
                Item = this.mStash.Data[i];
            };
        }
    }
    return null;
};

WorldItemsSpawnerScreen.prototype.getSelectedItem = function()
{
    var element = this.mSelected.Layout.find('img:first');
    if (element.length > 0) {
        return element;
    }
    return null;
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnConnected = function()
{
	SQ.call(this.mSQHandle, 'onScreenConnected');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnDisconnected = function()
{
	SQ.call(this.mSQHandle, 'onScreenDisconnected');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnShown = function()
{
    SQ.call(this.mSQHandle, 'onScreenShown');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnHidden = function()
{
    SQ.call(this.mSQHandle, 'onScreenHidden');
};

WorldItemsSpawnerScreen.prototype.notifyBackendOnAnimating = function()
{
    SQ.call(this.mSQHandle, 'onScreenAnimating');
};

WorldItemsSpawnerScreen.prototype.notifyBackendCloseButtonPressed = function()
{
    SQ.call(this.mSQHandle, 'onCloseButtonPressed');
};

WorldItemsSpawnerScreen.prototype.notifyBackendSeachItemBy = function( _text )
{
    var self = this;
    var filter = this.mSearch.Filter;

    if (_text.length <= 1) {
        this.mSearch.ListScrollContainer.empty();
        this.mSearch.Found.html('');
        return;
    }

    SQ.call(this.mSQHandle, 'onSeachItemBy', [ _text, filter ], function(_data) {
        if (_data === undefined || _data === null || !jQuery.isArray(_data)) {
            console.error('ERROR: Failed to search for item. Invalid data result.');
            self.mSearch.ListScrollContainer.empty();
            var foundNothingLabel = $('<div class="find-no-result-container text-font-normal font-bold font-color-negative-value font-align-center"/>');
            foundNothingLabel.html('Error!!! Can not process input');
            self.mSearch.ListScrollContainer.append(foundNothingLabel);
            self.mSearch.Found.html('');
            return;
        }

        self.fillSearchItemResult(_data);
    });
};

WorldItemsSpawnerScreen.prototype.notifyBackendShowAllItems = function()
{
    var self = this;
    var filter = this.mSearch.Filter;
    SQ.call(this.mSQHandle, 'onShowAllItems', filter , function(_data) {
        if (_data === undefined || _data === null || !jQuery.isArray(_data)) {
            console.error('ERROR: Failed to search for item. Invalid data result.');
            self.mSearch.ListScrollContainer.empty();
            var foundNothingLabel = $('<div class="find-no-result-container text-font-normal font-bold font-color-negative-value font-align-center"/>');
            foundNothingLabel.html('Error!!! Can not process input');
            self.mSearch.ListScrollContainer.append(foundNothingLabel);
            self.mSearch.Found.html('');
            return;
        }

        self.fillSearchItemResult(_data);
    });
};

WorldItemsSpawnerScreen.prototype.notifyBackendDeleteAllStashItem = function()
{
    this.mStash.Data = [];
    this.createItemContainer(this.mStash.Slot.length);
    SQ.call(this.mSQHandle, 'onDeleteAllStashItem');
}

WorldItemsSpawnerScreen.prototype.notifyBackendSortStashItem = function()
{
    var self = this;
    SQ.call(this.mSQHandle, 'onSortStashItem', [] , function(_data) {
        if (_data === undefined || _data === null || jQuery.isArray(_data)) {
            console.error('ERROR: Failed to retrieve sorted stash data. Invalid data result.');
            return;
        }

        self.addStashData(_data);
    });
}

WorldItemsSpawnerScreen.prototype.notifyBackendRepairAllStashItem = function()
{
    var self = this;
    SQ.call(this.mSQHandle, 'onRepairAllStashItem', [] , function(_data) {
        if (_data === undefined || _data === null || jQuery.isArray(_data)) {
            console.error('ERROR: Failed to retrieve repaired stash data. Invalid data result.');
            return;
        }

        self.addStashData(_data);
    });
}

WorldItemsSpawnerScreen.prototype.notifyBackendRestockAllStashItem = function()
{
    var self = this;
    SQ.call(this.mSQHandle, 'onRestockAllStashItem', [] , function(_data) {
        if (_data === undefined || _data === null || jQuery.isArray(_data)) {
            console.error('ERROR: Failed to retrieve restocked stash data. Invalid data result.');
            return;
        }

        self.addStashData(_data);
    });
}

WorldItemsSpawnerScreen.prototype.notifyBackendAddItemToStash = function( _element, isQuickAdd )
{
    var self = this;
    var data = _element.data('item');

    if (data === null || data === undefined) {
        console.error('ERROR: Failed to add item to stash. Undefined selected data.');
        return;
    }

    var num = isQuickAdd === true ? 1 : parseInt(this.mSelected.Amount.getInputText());
    var name = isQuickAdd === true ? '' : this.mSelected.Name.getInputText();
    var attr = isQuickAdd === true ? {} : this.gatherAttributes();
    SQ.call(this.mSQHandle, 'onAddItemToStash', [ data, num, name, attr, isQuickAdd ] , function(_data) {
        if (_data === undefined || _data === null || !jQuery.isArray(_data)) {
            console.error('ERROR: Failed to add item to stash. Invalid data result.');
            return;
        }

        for (var i = 0; i < _data.length; i++) {
            self.mStash.Data.push(_data[i]);
            self.createItemEntry(_data[i], self.mStash.Slot[_data[i].Index]);
        }
    });
};

WorldItemsSpawnerScreen.prototype.notifyBackendRemoveItemFromStash = function( _element )
{
    var data = _element.data('item');
    var result = this.getStashItem(data.ID);
    var selected = this.getSelectedItem();
    this.mStash.Slot[data.Index].empty();
    if (result !== null) {
        this.mStash.Data.splice(result.Index, 1);
    }
    if (selected !== null && selected.data('item') === result.Item.ID) {
        this.revertToDefault();
    }

    SQ.call(this.mSQHandle, 'onRemoveItemFromStash', result.Item.Index);
};





registerScreen("WorldItemsSpawnerScreen", new WorldItemsSpawnerScreen());