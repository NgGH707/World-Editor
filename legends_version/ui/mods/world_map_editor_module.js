
"use strict";
var ModMapEditor = {
    Category    : ['Settlement' , 'Attachment' , 'Location' , 'Unit'],
    CategoryName: ['Settlements', 'Attachments', 'Locations', 'Parties'],
    SubLocation : ['Bandit', 'Barbarian', 'Nomad', 'Goblin', 'Orc', 'Undead', 'Cultist', 'Legendary', 'Misc'],
    SubParty    : ['Caravan', 'Noble', 'Southern',  'Mercenary', 'Bandit', 'Barbarian', 'Nomad', 'Goblin', 'Orc', 'Necromancer', 'Undead', 'Misc'],
};

var WorldMapEditorModule = function()
{
	this.mSQHandle            = null;

    // event listener
    this.mEventListener       = null;

	// generic containers
	this.mContainer           = null;
    this.mListContainer       = null;
    this.mListScrollContainer = null;

    // popup dialog
    this.mCurrentPopupDialog  = null;

    // tab column
    this.mCloseButton         = null;
    this.mButton              = {
        Settlement: null,
        Attachment: null,
        Location  : null,
        Unit      : null,
    };

    this.mData                = {
        Settlement: null,
        Attachment: null,
        Location  : null,
        Unit      : null,
    };

    this.mCurrentScreen       = null;
    this.mLocationFilter      = 0;
    this.mUnitFilter          = 0;

    // content column
    this.mContentContainer    = null;
    this.mLabelButton         = null;
    this.mExpandButton        = null;

    // generics
    this.mIsVisible           = false;
    this.mIsExpanded          = true;
    this.mSelectedEntry       = null;
    this.mMinWidth            = 0;
};

WorldMapEditorModule.prototype.createDIV = function(_parentDiv)
{
    var self = this;
    var height = _parentDiv.height() - 58;
    this.mContainer = $('<div class="world-map-editor-module display-none"></div>');
    _parentDiv.append(this.mContainer);

    var tabColumn = $('<div class="l-tab-column"/>');
    this.mContainer.append(tabColumn);
    this.mMinWidth = tabColumn.width();
    {
        var buttonLayout = $('<div class="l-button-45-41"/>');
        buttonLayout.css('top', '1.0rem');
        tabColumn.append(buttonLayout);
        this.mCloseButton = buttonLayout.createImageButton(Path.GFX + Asset.ICON_CONTRACT_SCROLL, function() {
            self.hide(true);
        }, '', 6);

        var flexContainer = $('<div class="flex-container-column"/>');
        tabColumn.append(flexContainer);

        var buttonLayout = $('<div class="flex-button-39-39"/>');
        flexContainer.append(buttonLayout)
        var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/info.png', null, '', 10);
        button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.worldspawnerinfo' });

        var buttonLayouts = [];
        for (var i = 0; i < ModMapEditor.Category.length; i++) {
            var buttonLayout = $('<div class="flex-button-45-41"/>');
            //buttonLayout.css('top', (7.5 + i * 4.1) + 'rem');
            flexContainer.append(buttonLayout);
            buttonLayouts.push(buttonLayout);
        }

        // spawn stuff
        this.mButton.Settlement = buttonLayouts[0].createImageButton(Path.GFX + 'ui/buttons/icon_settlement.png', function() {
            self.openTab('Settlement');
        }, '', 6);
        this.mButton.Attachment = buttonLayouts[1].createImageButton(Path.GFX + 'ui/buttons/icon_attachment.png', function() {
            self.openTab('Attachment');
        }, '', 6);
        this.mButton.Location   = buttonLayouts[2].createImageButton(Path.GFX + 'ui/buttons/icon_location.png', function() {
            self.openTab('Location');
        }, '', 6);
        this.mButton.Unit       = buttonLayouts[3].createImageButton(Path.GFX + 'ui/buttons/icon_unit.png', function() {
            self.openTab('Unit');
        }, '', 6);
    }

    this.mContentContainer = $('<div class="l-content-column"/>');
    this.mContainer.append(this.mContentContainer);
    {
        var header = $('<div class="l-header-container"/>');
        this.mContentContainer.append(header);

        var buttonLayout = $('<div class="l-button-174-43 is-label"/>');
        header.append(buttonLayout);
        this.mLabelButton = buttonLayout.createTextButton('Selected', function(_button) {
            self.createChooseFilterPopupDialog(self.mCurrentScreen == 'Location');
        }, '', 7);
        this.mLabelButton.findButtonText().css('top', '0.3rem');

        var buttonLayout = $('<div class="l-button-45-41 is-expand"/>');
        header.append(buttonLayout);
        this.mExpandButton = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_ARROW_LEFT, function() {
            self.closeTab();
        }, '', 6);

        var content = $('<div class="l-content-container"/>');
        content.css('height', height);
        this.mContentContainer.append(content);
        var listLayout = $('<div class="l-list-container"/>');
        content.append(listLayout);
        this.mListContainer = listLayout.createList(2);
        this.mListScrollContainer = this.mListContainer.findListScrollContainer();
    }

    this.mIsVisible = false;
    this.mIsExpanded = true;
    this.expand(false);
};
WorldMapEditorModule.prototype.destroyDIV = function()
{
    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};
WorldMapEditorModule.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};
WorldMapEditorModule.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};
WorldMapEditorModule.prototype.bindTooltips = function()
{

};
WorldMapEditorModule.prototype.unbindTooltips = function()
{
    
};
WorldMapEditorModule.prototype.isConnected = function()
{
    return this.mSQHandle !== null;
};
WorldMapEditorModule.prototype.onConnection = function(_handle)
{
    this.mSQHandle = _handle;

    // notify listener
    if (this.mEventListener !== null && ('onModuleOnConnectionCalled' in this.mEventListener)) {
        this.mEventListener.onModuleOnConnectionCalled(this);
    }
};
WorldMapEditorModule.prototype.onDisconnection = function()
{
    this.mSQHandle = null;

    // notify listener
    if (this.mEventListener !== null && ('onModuleOnDisconnectionCalled' in this.mEventListener)) {
        this.mEventListener.onModuleOnDisconnectionCalled(this);
    }
};
WorldMapEditorModule.prototype.register = function(_parentDiv)
{
    console.log('WorldMapEditorModule::REGISTER');

    if (this.mContainer !== null) {
        console.error('ERROR: Failed to register World Map Editor Module. Reason: World Map Editor Module is already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object') {
        this.create(_parentDiv);
    }
};
WorldMapEditorModule.prototype.unregister = function()
{
    console.log('WorldMapEditorModule::UNREGISTER');

    if (this.mContainer === null) {
        console.error('ERROR: Failed to unregister World Map Editor Module. Reason: World Map Editor Module is not initialized.');
        return;
    }

    this.destroy();
};
WorldMapEditorModule.prototype.isRegistered = function()
{
    if (this.mContainer !== null) {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};
WorldMapEditorModule.prototype.registerEventListener = function(_listener)
{
    this.mEventListener = _listener;
};
WorldMapEditorModule.prototype.isVisible = function ()
{
    return this.mIsVisible;
};
WorldMapEditorModule.prototype.show = function(_data)
{
    var self = this;
    var offset = -(this.mContainer.parent().width() + this.mContainer.width());
    this.loadFromData(_data);
    this.mContainer.css({ 'left': offset });
    this.mContainer.velocity("finish", true).velocity({ opacity: 1, left: '0', right: '0' }, {
        duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
        easing: 'swing',
        begin: function () {
            $(this).removeClass('display-none').addClass('display-block');
            self.notifyBackendModuleAnimating();
        },
        complete: function () {
            self.mIsVisible = true;
            self.notifyBackendModuleShown();
        }
    });
};
WorldMapEditorModule.prototype.hide = function(_withSlideAnimation)
{
    var self = this;
    var offset = -(this.mContainer.parent().width() + this.mContainer.width());
    this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset },
	{
        duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
        easing: 'swing',
        begin: function ()
        {
            $(this).removeClass('is-center');
            self.notifyBackendModuleAnimating();
        },
        complete: function ()
        {
        	self.mIsVisible = false;
            $(this).removeClass('display-block').addClass('display-none');
            self.notifyBackendModuleHidden();
        }
    });
};

WorldMapEditorModule.prototype.createChooseFilterPopupDialog = function(_isLocation) 
{
    var self = this;
    this.notifyBackendPopupDialogIsVisible(true);
    this.mCurrentPopupDialog = $('.world-screen').createPopupDialog('Choose Filter', null, null, 'choose-filter-popup');
    var title = this.mCurrentPopupDialog.findPopupDialogTitle();
    title.removeClass('font-bottom-shadow');
    title.removeClass('font-color-title');
    title.addClass('font-color-ink');

    var result = this.createChooseFilterPopupDialogContent(this.mCurrentPopupDialog); 
    this.mCurrentPopupDialog.addPopupDialogContent(result.Content);

    // add scroll bar, due to how the ui works, it has to be created rather in the content function
    result.ListContainer.aciScrollBar({delta: 1, lineDelay: 0, lineTimer: 0, pageDelay: 0, pageTimer: 0, bindKeyboard: false, resizable: false, smoothScroll: false});
    var listScrollContainer = result.ListContainer.findListScrollContainer();
    
    // add footer buttons
    this.mCurrentPopupDialog.addPopupDialogOkButton(function (_dialog) {
        self.addDataWithFilter(_isLocation);
        self.mCurrentPopupDialog = null;
        _dialog.destroyPopupDialog();
        self.notifyBackendPopupDialogIsVisible(false);
    });
    
    // add building entries so you can pick one
    this.addFilterEntries(listScrollContainer, _isLocation);
};
WorldMapEditorModule.prototype.createChooseFilterPopupDialogContent = function(_dialog) 
{
    var content = $('<div class="l-content-container"/>');

    var container = $('<div class="l-list-container"></div>');
    content.append(container);

    var listContainer = $('<div class="ui-control list has-frame"/>');
    container.append(listContainer);
    var scrollContainer = $('<div class="scroll-container"/>');
    listContainer.append(scrollContainer);

    return {
        Content: content,
        ListContainer: listContainer
    };
};
WorldMapEditorModule.prototype.addFilterEntries = function(_listScrollContainer, _isLocation) 
{
    var data = _isLocation === true ? ModMapEditor.SubLocation : ModMapEditor.SubParty;
    for (var i = 0; i < data.length; i++) {
        this.addFilter(_listScrollContainer, data[i], _isLocation, i);
    }
    _listScrollContainer.showListScrollbar(true);
};
WorldMapEditorModule.prototype.addFilter = function(_listScrollContainer, _data, _isLocation, _index)
{
    var self = this;
    var filter = _isLocation === true ? this.mLocationFilter : this.mUnitFilter;
    var result = $('<div class="filter-entry-row"/>');
    _listScrollContainer.append(result);
    var entry = $('<div class="ui-control list-entry-for-expandable"/>');
    result.append(entry);
    var label = $('<span class="label text-font-normal font-bold font-color-ink">' + _data + '</span>');
    entry.append(label);
  
    entry.click(this, function(_event) {
        var div = $(this);
        if (div.hasClass('is-selected') === false) {
            _listScrollContainer.find('.is-selected').each(function(index, element) {
                $(element).removeClass('is-selected');
            });
            div.addClass('is-selected');
            if (_isLocation === true)
                self.mLocationFilter = _index;
            else
                self.mUnitFilter = _index;
        }
    });

    if (_index === filter) {
        entry.addClass('is-selected');
    }
};

WorldMapEditorModule.prototype.closeTab = function ()
{
    var self = this;
    $.each(this.mButton, function (_key, _definition) {
        self.mButton[_key].enableButton(true);
    });
    this.expand(false);
};

WorldMapEditorModule.prototype.openTab = function (_name)
{
    var self = this;
    var count = 0;
    $.each(this.mButton, function (_key, _definition) {
        var isRight = _key === _name;
        if (isRight) {
            self.mLabelButton.changeButtonText(ModMapEditor.CategoryName[count]);
        }
        self.mButton[_key].enableButton(!isRight);
        ++count;
    });
    
    this.mCurrentScreen = _name;
    self['load' + _name + 'Data']();
    this.expand(true);
};

WorldMapEditorModule.prototype.expand = function (_value)
{
    if (this.mIsExpanded == _value) return;

    this.mContainer.css('width', _value === true ? '100%' : this.mMinWidth);
    this.mContentContainer.showThisDiv(_value);
    this.mIsExpanded = !this.mIsExpanded;
};

WorldMapEditorModule.prototype.selectEntry = function(_element, _type)
{
    if (_element !== null && _element.length > 0)
    {
        this.mListContainer.deselectListEntries();
        this.mSelectedEntry = _element;
        _element.addClass('is-selected');
        this.notifyBackendChangeSpawnSelection(_element, _type);
    }
    else
    {
        this.mSelectedEntry = null;
        this.notifyBackendRemoveSpawnSelection();
    }
};

WorldMapEditorModule.prototype.selectWorldEntity = function(_data) 
{
    var self = this;
    this.expand(true);
    this.mSelectedEntry = null;
    this.mListScrollContainer.empty();
    this.mLabelButton.enableButton(false);
    this.mLabelButton.changeButtonText('Selected');
    $.each(this.mButton, function (_key, _definition) {
        self.mButton[_key].enableButton(true);
    });

    var id = _data.ID;
    var entry = $('<div class="l-location-row is-selected"/>');
    this.mListScrollContainer.append(entry);
    var image = entry.createImage(Path.GFX + _data.ImagePath, function(_image) {
        _image.centerImageWithinParent(0, 0, 1.0);
    }, null, 'no-pointer-events');
    var label = $('<div class="label text-font-small font-color-white font-align-center">' + _data.Name + '</div>');
    entry.append(label);
    entry.click(this, function(_event) {
        if (KeyModiferConstants.CtrlKey in _event && _event[KeyModiferConstants.CtrlKey] === true) {
            self.notifyBackendShowWorldEntityOnMap(id);
        }
    });
    entry.bindTooltip({ contentType: 'ui-element', elementId: _data.ID, elementOwner: 'woditor.world_entity' });
}

WorldMapEditorModule.prototype.deselectWorldEntity = function(_nothing) 
{
    this.expand(false);
    this.mSelectedEntry = null;
    this.mListScrollContainer.empty();
}

WorldMapEditorModule.prototype.addDataWithFilter = function(_isLocation) 
{
    if (_isLocation === true) {
        this.loadLocationData();
        return;
    }

    this.loadUnitData();
}

WorldMapEditorModule.prototype.loadSettlementData = function()
{
    var self = this;
    this.mListScrollContainer.empty();
    this.mLabelButton.enableButton(false);

    for (var i = 0; i < this.mData.Settlement.length; i++) {
        var data = this.mData.Settlement[i];
        var entry = $('<div class="l-location-row"/>');
        this.mListScrollContainer.append(entry);
        entry.data('settlement', data);

        var image = entry.createImage(Path.GFX + data.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, 'no-pointer-events');

        var label = $('<div class="label text-font-small font-color-white font-align-center">' + data.Name + '</div>');
        entry.append(label);

        // set up event listeners
        entry.click(this, function(_event) {
            var element = $(this);
            if (element.hasClass('is-selected') === false) {
                self.selectEntry(element, 0);
            }
        });
    }
};

WorldMapEditorModule.prototype.loadAttachmentData = function()
{
    var self = this;
    this.mListScrollContainer.empty();
    this.mLabelButton.enableButton(false);

    for (var i = 0; i < this.mData.Attachment.length; i++) {
        var data = this.mData.Attachment[i];
        var entry = $('<div class="l-location-row"/>');
        this.mListScrollContainer.append(entry);
        entry.data('script', data.Script);

        var image = entry.createImage(Path.GFX + data.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, 'no-pointer-events');

        var label = $('<div class="label text-font-small font-color-white font-align-center">' + data.ID + '</div>');
        entry.append(label);

        // set up event listeners
        entry.click(this, function(_event) {
            var element = $(this);
            if (element.hasClass('is-selected') === false) {
                self.selectEntry(element, 1);
            }
        });
    }
};

WorldMapEditorModule.prototype.loadLocationData = function( _type )
{
    var self = this;
    this.mListScrollContainer.empty();
    this.mLabelButton.enableButton(true);

    if (_type === null || _type === undefined) {
        _type = this.mLocationFilter;
    }

    this.mLabelButton.changeButtonText(ModMapEditor.SubLocation[_type]);
    for (var i = 0; i < this.mData.Location[ModMapEditor.SubLocation[_type]].length; i++) {
        var data = this.mData.Location[ModMapEditor.SubLocation[_type]][i];
        var entry = $('<div class="l-location-row"/>');
        this.mListScrollContainer.append(entry);
        entry.data('location', data);

        var image = entry.createImage(Path.GFX + data.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, 'no-pointer-events');

        var label = $('<div class="label text-font-small font-color-white font-align-center">' + data.Type + '</div>');
        entry.append(label);

        // set up event listeners
        entry.click(this, function(_event) {
            var element = $(this);
            if (element.hasClass('is-selected') === false) {
                self.selectEntry(element, 2);
            }
        });
    }
};

WorldMapEditorModule.prototype.loadUnitData = function( _type )
{
    var self = this;
    this.mListScrollContainer.empty();
    this.mLabelButton.enableButton(true);

    if (_type === null || _type === undefined) {
        _type = this.mUnitFilter;
    }

    this.mLabelButton.changeButtonText(ModMapEditor.SubParty[_type]);
    for (var i = 0; i < this.mData.Unit[ModMapEditor.SubParty[_type]].length; i++) {
        var data = this.mData.Unit[ModMapEditor.SubParty[_type]][i];
        var entry = $('<div class="l-location-row"/>');
        this.mListScrollContainer.append(entry);
        entry.data('unit', data);

        var image = entry.createImage(Path.GFX + data.ImagePath, function(_image) {
            _image.centerImageWithinParent(0, 0, 1.0);
        }, null, 'no-pointer-events');

        var label = $('<div class="label text-font-small font-color-white font-align-center">' + data.Key + '</div>');
        entry.append(label);

        // set up event listeners
        entry.click(this, function(_event) {
            var element = $(this);
            if (element.hasClass('is-selected') === false) {
                self.selectEntry(element, 3);
            }
        });
    }
};

WorldMapEditorModule.prototype.loadFromData = function(_data)
{
    if ('Settlements' in _data && _data.Settlements !== undefined && _data.Settlements !== null && jQuery.isArray(_data.Settlements)) {
        this.mData.Settlement = _data.Settlements;
    }

    if ('AttachedLocations' in _data && _data.AttachedLocations !== undefined && _data.AttachedLocations !== null && jQuery.isArray(_data.AttachedLocations)) {
        this.mData.Attachment = _data.AttachedLocations;
    }

    if ('Locations' in _data && _data.Locations !== undefined && _data.Locations !== null && typeof _data.Locations == 'object') {
        this.mData.Location = _data.Locations;
    } 

    if ('Units' in _data && _data.Units !== undefined && _data.Units !== null && typeof _data.Locations == 'object') {
        this.mData.Unit = _data.Units;
    }
};

WorldMapEditorModule.prototype.notifyBackendModuleShown = function()
{
    SQ.call(this.mSQHandle, 'onModuleShown');
};

WorldMapEditorModule.prototype.notifyBackendModuleHidden = function()
{
    SQ.call(this.mSQHandle, 'onModuleHidden');
};

WorldMapEditorModule.prototype.notifyBackendModuleAnimating = function()
{
    SQ.call(this.mSQHandle, 'onModuleAnimating');
};

WorldMapEditorModule.prototype.notifyBackendPopupDialogIsVisible = function(_visible)
{
    SQ.call(this.mSQHandle, 'onPopupDialogIsVisible', [_visible]);
};

WorldMapEditorModule.prototype.notifyBackendRemoveSpawnSelection = function()
{
    SQ.call(this.mSQHandle, 'onRemoveSpawnSelection');
};

WorldMapEditorModule.prototype.notifyBackendShowWorldEntityOnMap = function(_id)
{
    SQ.call(this.mSQHandle, 'onShowWorldEntityOnMap', _id);
};

WorldMapEditorModule.prototype.notifyBackendChangeSpawnSelection = function(_element, _type)
{
    var data = {
        Script: null
    };

    switch(_type)
    {
    case 3:
        data = _element.data('unit');
        break;

    case 2:
        data = _element.data('location');
        break;

    case 1:
        data['Script'] = _element.data('script');
        break;

    case 0:
        data = _element.data('settlement');
        break;
    }

    SQ.call(this.mSQHandle, 'onChangeSpawnSelection', [ data, _type ]);
};








// HOOK TIME
var w_unregisterModulesWorldScreen = WorldScreen.prototype.unregisterModules;
WorldScreen.prototype.unregisterModules = function()
{
    this.mMapEditorModule.onDisconnection();
    this.mMapEditorModule.unregister();
    w_unregisterModulesWorldScreen.call(this);
};

var w_onModuleOnConnectionCalledWorldScreen = WorldScreen.prototype.onModuleOnConnectionCalled;
WorldScreen.prototype.onModuleOnConnectionCalled = function(_module)
{
    if (this.mMapEditorModule !== null && this.mMapEditorModule.isConnected())
    {
        w_onModuleOnConnectionCalledWorldScreen.call(this);
    }
};

var w_onModuleOnDisconnectionCalledWorldScreen = WorldScreen.prototype.onModuleOnDisconnectionCalled;
WorldScreen.prototype.onModuleOnDisconnectionCalled = function(_module)
{
    if (this.mMapEditorModule !== null && !this.mMapEditorModule.isConnected())
    {
        w_onModuleOnDisconnectionCalledWorldScreen.call(this);
    }
};

WorldScreen.prototype.createMapEditorModuleWorldScreen = function()
{
    var self = this;

    if (!('mMapEditorModule' in self))
    {
        self.mMapEditorModule = null;
        self.mMapEditorModule = new WorldMapEditorModule();
        self.mMapEditorModule.registerEventListener(this);
    }
};
WorldScreen.prototype.createMapEditorModuleWorldScreen.call(WorldScreen); // force the already created WorldScreen to create new module


var w_registerModulesWorldScreen = WorldScreen.prototype.registerModules;
WorldScreen.prototype.registerModules = function() 
{
    w_registerModulesWorldScreen.call(this);
    
    var self = this;

    if (!('mMapEditorModule' in self)) {
        self.mMapEditorModule = null;
        self.mMapEditorModule = new WorldMapEditorModule();
        self.mMapEditorModule.registerEventListener(this);
    }

    if (!('mMapEditorContainer' in self)) {
        self.mMapEditorContainer = null;
    }

    var height = this.mContainer.height() - this.mTopBarContainer.height() - 5;
    this.mMapEditorContainer = $('<div class="world-map-editor-container"/>');
    this.mMapEditorContainer.css('height', height);
    this.mContainer.append(this.mMapEditorContainer);
    this.mMapEditorModule.register(this.mMapEditorContainer);
}

var w_getModuleWorldScreen = WorldScreen.prototype.getModule;
WorldScreen.prototype.getModule = function(_name)
{
    if (_name === 'WorldMapEditorModule') {
        return this.mMapEditorModule;
    }

    var result = w_getModuleWorldScreen.call(this, _name);
    return result;
};

var w_getModulesWorldScreen = WorldScreen.prototype.getModules;
WorldScreen.prototype.getModules = function()
{
    var result = w_getModulesWorldScreen.call(this);
    result.push({name: 'WorldMapEditorModule', module: this.mMapEditorModule});
    return result;
};



