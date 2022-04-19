
"use strict";
var ModMapEditor = {
    Category:     ['Terrain', 'Scenery', 'Location', 'Settlement', 'Attachment', 'Unit'],
    CategoryName: ['Terrain', 'Scenery', 'Location', 'Settlement', 'Attachment', 'Unit'],
};

var WorldMapEditorModule = function()
{
	this.mSQHandle         = null;

    // event listener
    this.mEventListener    = null;

	// generic containers
	this.mContainer        = null;

    // tab column
    this.mCloseButton      = null;
    this.mButton           = {
        Terrain   : null,
        Scenery   : null,
        Location  : null,
        Settlement: null,
        Attachment: null,
        Unit      : null,
    };

    // content column
    this.mContentContainer = null;
    this.mLabelButton      = null;
    this.mExpandButton     = null;

    // generics
    this.mIsVisible        = false;
    this.mIsExpanded       = true;
    this.mMinWidth         = 0;
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

        var buttonLayouts = [];
        for (var i = 0; i < ModMapEditor.Category.length; i++) {
            var buttonLayout = $('<div class="l-button-45-41"/>');
            buttonLayout.css('top', (7.5 + i * 4.1) + 'rem');
            tabColumn.append(buttonLayout);
            buttonLayouts.push(buttonLayout);
        }

        // terraform
        this.mButton.Terrain    = buttonLayouts[0].createImageButton(Path.GFX + 'ui/buttons/icon_terrain.png', function() {
            self.openTab('Terrain');
        }, '', 6);
        this.mButton.Scenery    = buttonLayouts[1].createImageButton(Path.GFX + Asset.BUTTON_TOGGLE_TREES_ENABLED, function() {
            self.openTab('Scenery');
        }, '', 6);

        // spawn stuff
        this.mButton.Location   = buttonLayouts[2].createImageButton(Path.GFX + 'ui/buttons/icon_location.png', function() {
            self.openTab('Location');
        }, '', 6);
        this.mButton.Settlement = buttonLayouts[3].createImageButton(Path.GFX + 'ui/buttons/icon_settlement.png', function() {
            self.openTab('Settlement');
        }, '', 6);
        this.mButton.Attachment = buttonLayouts[4].createImageButton(Path.GFX + 'ui/buttons/icon_attachment.png', function() {
            self.openTab('Attachment');
        }, '', 6);
        this.mButton.Unit       = buttonLayouts[5].createImageButton(Path.GFX + 'ui/buttons/icon_unit.png', function() {
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
        this.mLabelButton = buttonLayout.createTextButton('Selected', null, '', 7);
        this.mLabelButton.enableButton(false);
        var label = this.mLabelButton.findButtonText().css('top', '0.1rem');

        var buttonLayout = $('<div class="l-button-45-41 is-expand"/>');
        header.append(buttonLayout);
        this.mExpandButton = buttonLayout.createImageButton(Path.GFX + Asset.BUTTON_ARROW_LEFT, function() {
            self.closeTab();
        }, '', 6);

        var content = $('<div class="l-content-container"/>');
        content.css('height', height);
        this.mContentContainer.append(content);
    }

    this.mIsVisible = false;
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
    
    this.expand(true);
};

WorldMapEditorModule.prototype.expand = function (_value)
{
    if (this.mIsExpanded == _value) return;

    this.mContainer.css('width', _value === true ? '100%' : this.mMinWidth);
    this.mContentContainer.showThisDiv(_value);
    this.mIsExpanded = !this.mIsExpanded;
};

WorldMapEditorModule.prototype.loadFromData = function(_data)
{
    
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



