"use strict";


var OriginCustomizerScreen = function()
{
	this.mSQHandle				    = null;

	// generic containers
	this.mContainer				    = null;
    this.mDialogBackground          = null;

    // modules
    this.mMainDialogModule		    = null;
    this.mSettingsDialogModule      = null;
    this.mDifficultyDialogModule	= null;
    this.mFactionsDialogModule		= null;
	this.mContractsDialogModule	    = null;
    this.mOriginsDialogModule       = null;

	this.mActiveModule			    = null;

    this.createModules();
};

OriginCustomizerScreen.prototype.isConnected = function ()
{
    return this.mSQHandle !== null;
};

OriginCustomizerScreen.prototype.onConnection = function (_handle)
{
	this.mSQHandle = _handle;
	this.register($('.root-screen'));
};

OriginCustomizerScreen.prototype.onDisconnection = function ()
{
	this.mSQHandle = null;

    this.mMainDialogModule.onDisconnection();
    //this.mSettingsDialogModule.onDisconnection();
    //this.mDifficultyDialogModule.onDisconnection();
    //this.mFactionsDialogModule.onDisconnection();
    //this.mContractsDialogModule.onDisconnection();
    //this.mOriginsDialogModule.onDisconnection();
    
	this.unregister();
};

OriginCustomizerScreen.prototype.onModuleOnConnectionCalled = function (_module)
{
    // check if every module is connected
    if ((this.mMainDialogModule !== null && this.mMainDialogModule.isConnected()) &&
        (this.mSettingsDialogModule !== null && this.mSettingsDialogModule.isConnected()) &&
        (this.mDifficultyDialogModule !== null && this.mDifficultyDialogModule.isConnected()) &&
        (this.mFactionsDialogModule !== null && this.mFactionsDialogModule.isConnected()) &&
        (this.mContractsDialogModule !== null && this.mContractsDialogModule.isConnected()) &&
        (this.mOriginsDialogModule !== null && this.mOriginsDialogModule.isConnected()))
    {
        this.notifyBackendOnConnected();
    }
};

OriginCustomizerScreen.prototype.onModuleOnDisconnectionCalled = function (_module)
{
    // check if every module is disconnected
    if ((this.mMainDialogModule === null && !this.mMainDialogModule.isConnected()) &&
        (this.mSettingsDialogModule === null && !this.mSettingsDialogModule.isConnected()) &&
        (this.mDifficultyDialogModule === null && !this.mDifficultyDialogModule.isConnected()) &&
        (this.mFactionsDialogModule === null && !this.mFactionsDialogModule.isConnected()) &&
        (this.mContractsDialogModule === null && !this.mContractsDialogModule.isConnected()) &&
        (this.mOriginsDialogModule === null && !this.mOriginsDialogModule.isConnected()))
    {
        this.notifyBackendOnDisconnected();
    }
};

OriginCustomizerScreen.prototype.createDIV = function (_parentDiv)
{
	// create: containers (init hidden!)
    this.mContainer = $('<div class="origin-customizer-screen ui-control dialog-modal-background display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    //this.mDialogBackground = $('<div class="dialog-background-image"/>');
    //this.mContainer.append(this.mDialogBackground);
};

OriginCustomizerScreen.prototype.destroyDIV = function ()
{
    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
};

OriginCustomizerScreen.prototype.createModules = function()
{
    this.mMainDialogModule = new CustomizerScreenMainDialogModule(this);
    //this.mSettingsDialogModule = new CampScreenCommanderDialogModule(this);
    //this.mDifficultyDialogModule = new WorldTownScreenBarberDialogModule(this);
    //this.mFactionsDialogModule = new CampScreenCraftingDialogModule(this);
	//this.mContractsDialogModule = new CampScreenCraftingDialogModule(this);
	//this.mOriginsDialogModule = new CampScreenFletcherDialogModule(this);
};

OriginCustomizerScreen.prototype.registerModules = function ()
{
    this.mMainDialogModule.register(this.mContainer);
    //this.mSettingsDialogModule.register(this.mContainer);
    //this.mDifficultyDialogModule.register(this.mContainer);
    //this.mFactionsDialogModule.register(this.mContainer);
    //this.mContractsDialogModule.register(this.mContainer);
    //this.mOriginsDialogModule.register(this.mContainer);
};

OriginCustomizerScreen.prototype.unregisterModules = function ()
{
    this.mMainDialogModule.unregister();
    //this.mSettingsDialogModule.unregister();
    //this.mDifficultyDialogModule.unregister();
    //this.mFactionsDialogModule.unregister();
    //this.mContractsDialogModule.unregister();
    //this.mOriginsDialogModule.unregister();
};

OriginCustomizerScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.registerModules();
};

OriginCustomizerScreen.prototype.destroy = function()
{
    this.unregisterModules();
    this.destroyDIV();
};


OriginCustomizerScreen.prototype.register = function (_parentDiv)
{
    console.log('OriginCustomizerScreen::REGISTER');

    if(this.mContainer !== null)
    {
        console.error('ERROR: Failed to register Origin Customizer Screen. Reason: Origin Customizer Screen is already initialized.');
        return;
    }

    if(_parentDiv !== null && typeof(_parentDiv) == 'object')
    {
        this.create(_parentDiv);
    }
};

OriginCustomizerScreen.prototype.unregister = function ()
{
    console.log('OriginCustomizerScreen::UNREGISTER');

    if(this.mContainer === null)
    {
        console.error('ERROR: Failed to unregister Origin Customizer Screen. Reason: Origin Customizer Screen is not initialized.');
        return;
    }

    this.destroy();
};

OriginCustomizerScreen.prototype.show = function (_data)
{
    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mMainDialogModule.loadFromData(_data);
    }

	this.mActiveModule = null;

    var self = this;
    this.mContainer.velocity("finish", true).velocity({ opacity: 1 },
	{
        duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
        easing: 'swing',
        begin: function ()
        {
            $(this).css({ opacity: 0 });
            $(this).removeClass('display-none').addClass('display-block');
            self.notifyBackendOnAnimating();
            self.showMainDialog(null);
        },
        complete: function ()
        {
            self.notifyBackendOnShown();
        }
    });
};

OriginCustomizerScreen.prototype.hide = function ()
{
    var self = this;

	this.mActiveModule = null;

    this.mContainer.velocity("finish", true).velocity({ opacity: 0 },
	{
        duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
        easing: 'swing',
		begin: function()
		{
		    self.notifyBackendOnAnimating();
        },
		complete: function()
		{
		    $(this).css({ opacity: 0 });
		    $(this).removeClass('display-block').addClass('display-none');
		    self.mMainDialogModule.mDialogContainer.findDialogContentContainer().empty();
            self.notifyBackendOnHidden();
        }
    });
};

OriginCustomizerScreen.prototype.hideAllDialogs = function (_withSlideAnimation)
{
    this.mMainDialogModule.hide(false);
    
	if(this.mActiveModule != null)
	{
		this.mActiveModule.hide(_withSlideAnimation);
		this.mActiveModule = null;
	}

	this.mContainer.removeClass('display-block').addClass('display-none');
};

OriginCustomizerScreen.prototype.refresh = function (_data)
{
    if (_data !== undefined && _data !== null && typeof (_data) === 'object')
    {
        this.mMainDialogModule.loadFromData(_data);
    }

    if (this.mActiveModule != null)
    {
        this.mActiveModule.hide();
        this.mActiveModule = null;
    }

    this.mMainDialogModule.show(false);
};

OriginCustomizerScreen.prototype.getModule = function (_name)
{
	switch(_name)
	{
        case 'CustomizerScreenMainDialogModule': return this.mMainDialogModule;
        case 'CustomizerSettingsDialogModule': return this.mSettingsDialogModule;
        case 'CustomizerDifficultyDialogModule': return this.mDifficultyDialogModule;
        case 'CustomizerFactionsDialogModule': return this.mFactionsDialogModule;
        case 'CustomizerContractsDialogModule': return this.mContractsDialogModule;
        case 'CustomizerOriginsDialogModule': return this.mOriginsDialogModule;
		
        default: return null;
	}
};

OriginCustomizerScreen.prototype.getModules = function ()
{
	return [
        { name: 'CustomizerScreenMainDialogModule', module: this.mMainDialogModule },
        { name: 'CustomizerSettingsDialogModule'  , module: this.mSettingsDialogModule },
        { name: 'CustomizerDifficultyDialogModule', module: this.mDifficultyDialogModule },
        { name: 'CustomizerFactionsDialogModule'  , module: this.mFactionsDialogModule },
        { name: 'CustomizerContractsDialogModule' , module: this.mContractsDialogModule },
        { name: 'CustomizerOriginsDialogModule'   , module: this.mOriginsDialogModule },
    ];
};

OriginCustomizerScreen.prototype.showMainDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = false;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if(this.mActiveModule != null)
        this.mActiveModule.hide(false);

    this.mActiveModule = null;

    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mMainDialogModule.loadFromData(_data);
    }

    this.mMainDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.showSettingsDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = true;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if(this.mActiveModule != null)
        this.mActiveModule.hide(_withSlideAnimation);
    else
        this.mMainDialogModule.hide();

    this.mActiveModule = this.mSettingsDialogModule;

    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mSettingsDialogModule.loadFromData(_data);
    }

    this.mSettingsDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.showDifficultyDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = true;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if(this.mActiveModule != null)
        this.mActiveModule.hide(_withSlideAnimation);
    else
        this.mMainDialogModule.hide();

    this.mActiveModule = this.mDifficultyDialogModule;

    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mDifficultyDialogModule.loadFromData(_data);
    }

    this.mDifficultyDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.showFactionsDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = true;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if (this.mActiveModule != null)
        this.mActiveModule.hide(_withSlideAnimation);
    else
        this.mMainDialogModule.hide();

    this.mActiveModule = this.mFactionsDialogModule;

    if (_data !== undefined && _data !== null && typeof (_data) === 'object')
    {
        this.mFactionsDialogModule.loadFromData(_data);
    }

    this.mFactionsDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.showContractsDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = true;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if(this.mActiveModule != null)
        this.mActiveModule.hide(_withSlideAnimation);
    else
        this.mMainDialogModule.hide();

    this.mActiveModule = this.mContractsDialogModule;

    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mContractsDialogModule.loadFromData(_data);
    }

    this.mContractsDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.showOriginsDialog = function (/*_withSlideAnimation,*/ _data)
{
    var _withSlideAnimation = true;

    this.mContainer.addClass('display-block').removeClass('display-none');

    if(this.mActiveModule != null)
        this.mActiveModule.hide(_withSlideAnimation);
    else
        this.mMainDialogModule.hide();

    this.mActiveModule = this.mOriginsDialogModule;

    if(_data !== undefined && _data !== null && typeof(_data) === 'object')
    {
        this.mOriginsDialogModule.loadFromData(_data);
    }

    this.mOriginsDialogModule.show(_withSlideAnimation);
};

OriginCustomizerScreen.prototype.notifyBackendOnConnected = function ()
{
	if(this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenConnected');
	}
};

OriginCustomizerScreen.prototype.notifyBackendOnDisconnected = function ()
{
	if(this.mSQHandle !== null)
	{
		SQ.call(this.mSQHandle, 'onScreenDisconnected');
	}
};

OriginCustomizerScreen.prototype.notifyBackendOnShown = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenShown');
    }
};

OriginCustomizerScreen.prototype.notifyBackendOnHidden = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenHidden');
    }
};

OriginCustomizerScreen.prototype.notifyBackendOnAnimating = function ()
{
    if(this.mSQHandle !== null)
    {
        SQ.call(this.mSQHandle, 'onScreenAnimating');
    }
};

registerScreen("OriginCustomizerScreen", new OriginCustomizerScreen());
