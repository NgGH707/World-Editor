
"use strict";

var OriginCustomizerScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;

    // popup dialog
    this.mCurrentPopupDialog = null;

    // scenarios
    this.mScenario = 
    {
        Data           : null,
        Image          : null,
        Container      : null,
        ScrollContainer: null,
        Selected       : 0
    };

    // switch-to buttons
    this.mSwitchToButton = 
    {
        General   : null,
        Properties: null,
        Factions  : null,
        Contracts : null
    };

    // inputs
    this.mAssets =
    {
        BusinessReputation: {Input: null, Value: 0, ValueMin: -1000, ValueMax: 20000, Min: 0, Max: 5, IconPath: Path.GFX + Asset.ICON_ASSET_BUSINESS_REPUTATION, TooltipId: TooltipIdentifier.Assets.BusinessReputation},
        MoralReputation   : {Input: null, Value: 0, ValueMin: 0    , ValueMax: 100  , Min: 0, Max: 3, IconPath: Path.GFX + Asset.ICON_ASSET_MORAL_REPUTATION   , TooltipId: TooltipIdentifier.Assets.MoralReputation},
        Money             : {Input: null, Value: 0, ValueMin: 0    , ValueMax: null , Min: 0, Max: 9, IconPath: Path.GFX + Asset.ICON_ASSET_MONEY              , TooltipId: TooltipIdentifier.Assets.Money},
        Stash             : {Input: null, Value: 0, ValueMin: 0    , ValueMax: 500  , Min: 0, Max: 3, IconPath: Path.GFX + Asset.ICON_BAG                      , TooltipId: TooltipIdentifier.Stash.FreeSlots},
        Ammo              : {Input: null, Value: 0, ValueMin: 300  , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_AMMO               , TooltipId: TooltipIdentifier.Assets.Ammo},
        Supplies          : {Input: null, Value: 0, ValueMin: 150  , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_SUPPLIES           , TooltipId: TooltipIdentifier.Assets.Supplies},
        Medicine          : {Input: null, Value: 0, ValueMin: 100  , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_MEDICINE           , TooltipId: TooltipIdentifier.Assets.Medicine},
    };

    // avatar changer
    this.mAvatar = 
    {
        Image       : null,
        PrevButton  : null,
        NextButton  : null,
        TypeButton  : null,
        FlipButton  : null,
        SocketButton: null,
        IsFlipping  : false,
        Selected    : { Row: 0, Index: 0 },
        Avatars     : [[], [], [], [], []],
        RowNames    : [],
        Sockets     : [],
        SocketIndex : 0,
    };

    // configure options
    this.mCompanyName = null;
    this.mGenderLevel = 0;
    this.mConfig = 
    {
        //Autosave             : {Checkbox: null, Label: null, Name: 'Autosave Off'                 , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.Autosave},
        LegendBleedKiller    : {Checkbox: null, Label: null, Name: 'Bleeds Count As Kills'        , TooltipId: 'mapconfig.legendbleedkiller'},
        LegendPerkTrees      : {Checkbox: null, Label: null, Name: 'Dynamic Perks'                , TooltipId: 'mapconfig.legendperktrees'},
        LegendLocationScaling: {Checkbox: null, Label: null, Name: 'Distance Scaling'             , TooltipId: 'mapconfig.legendlocationscaling'},
        LegendRecruitScaling : {Checkbox: null, Label: null, Name: 'Recruit Scaling'              , TooltipId: 'mapconfig.legendrecruitscaling'},
        LegendWorldEconomy   : {Checkbox: null, Label: null, Name: 'World Economy'                , TooltipId: 'mapconfig.legendworldeconomy'},
        LegendAllBlueprints  : {Checkbox: null, Label: null, Name: 'All Crafting Recipes Unlocked', TooltipId: 'mapconfig.legendallblueprints'},
    };
    this.mGender =
    {
        Off : {Checkbox: null, Label: null, Name: 'Disabled', TooltipId: 'mapconfig.legendgenderequality_off' },
        Low : {Checkbox: null, Label: null, Name: 'Specific', TooltipId: 'mapconfig.legendgenderequality_low' },
        High: {Checkbox: null, Label: null, Name: 'All'     , TooltipId: 'mapconfig.legendgenderequality_high'}
    }

    // roster tier slider
    this.mRosterTier = 
    {
        Control: null, Title: null, TooltipId: 'origincustomizer.rostertier', Min: 1, Max: 10, Value: 2, Step: 1,
    };

    // buttons
    this.mSaveButton  = null;
    this.mCloseButton = null;

    // generics
    this.mIsVisible = false;
};

OriginCustomizerScreen.prototype.createDIV = function (_parentDiv)
{
    var self = this;

    // create: containers (init hidden!)
    this.mContainer = $('<div class="l-main-dialog-container display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);
    this.mDialogContainer = this.mContainer.createDialog('', '', '', true, 'dialog-1280-768');
    this.mDialogContainer.findDialogTitle().html('Origin Customizer');

    // create tabs
    var tabContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabContainer);
    {
        var buttonPanel = $('<div class="tab-button-panel"/>');
        tabContainer.append(buttonPanel);

        // button 1st
        var buttonLayout = $('<div class="l-tab-button is-general"/>');
        buttonPanel.append(buttonLayout);
        this.mSwitchToButton.General = buttonLayout.createTabTextButton("General", function()
        {
            
        }, null, 'tab-button', 7);
        this.mSwitchToButton.General.enableButton(false);

        // button 2nd
        buttonLayout = $('<div class="l-tab-button is-properties"/>');
        buttonPanel.append(buttonLayout);
        this.mSwitchToButton.Properties = buttonLayout.createTabTextButton("Properties", function()
        {
            
        }, null, 'tab-button', 7);

        // button 3rd
        buttonLayout = $('<div class="l-tab-button is-factions"/>');
        buttonPanel.append(buttonLayout);
        this.mSwitchToButton.Factions = buttonLayout.createTabTextButton("Factions", function()
        {
            
        }, null, 'tab-button', 7);

        // button 4th
        buttonLayout = $('<div class="l-tab-button is-contracts"/>');
        buttonPanel.append(buttonLayout);
        this.mSwitchToButton.Contracts = buttonLayout.createTabTextButton("Contracts", function()
        {
            
        }, null, 'tab-button', 7);


        // save changes button
        buttonLayout = $('<div class="l-tab-button is-save"/>');
        buttonPanel.append(buttonLayout);
        this.mSaveButton = buttonLayout.createImageButton(Path.GFX + 'ui/buttons/save_settings.png'/*Path.GFX + Asset.BUTTON_QUIT*/, function ()
        {
            //self.mDataSource.notifyBackendCloseButtonClicked();
        }, '', 6);
    }


    // create content
    var content = this.mDialogContainer.findDialogContentContainer();
    {
        var leftColumn = $('<div class="column-left"/>');
        content.append(leftColumn);
        {
            var subLeftColumn = $('<div class="sub-column-left"/>');
            leftColumn.append(subLeftColumn);
            {
                var originImageContainer = $('<div class="origin-image-container"/>');
                subLeftColumn.append(originImageContainer);

                this.mScenario.Image = originImageContainer.createImage(Path.GFX + 'ui/events/event_99.png', function (_image)
                {
                    _image.removeClass('opacity-none');
                }, null, 'opacity-none');

                var count = 0;
                $.each(self.mAssets, function (_key, _definition)
                {
                    self.createInputDIV(_key, _definition, subLeftColumn, count === 0 ? "Assets" : undefined);
                    count++;
                });
            }

            var subRightColumn = $('<div class="sub-column-right"/>');
            leftColumn.append(subRightColumn);
            {
                var row = $('<div class="row"/>');
                subRightColumn.append(row);
                var title = $('<div class="title title-font-big font-color-title">Company Avatar</div>');
                title.css('margin-bottom', '1.0rem');
                row.append(title);

                var avatarChangerContainer = $('<div class="avatar-changer-container"/>');
                row.append(avatarChangerContainer);
                {
                    var buttonColumn = $('<div class="sub-column1"/>');
                    avatarChangerContainer.append(buttonColumn);
                    {
                        var subRow = $('<div class="avatar-row"/>');
                        buttonColumn.append(subRow);
                        var button = $('<div class="l-avatar-button" />');
                        subRow.append(button);
                        this.mAvatar.TypeButton = button.createTextButton('Human', function () 
                        {
                            //self.onPressAvatarTypeButton();
                        }, 'display-block', 1);

                        var subRow = $('<div class="avatar-row"/>');
                        buttonColumn.append(subRow);
                        var button = $('<div class="l-avatar-button" />');
                        subRow.append(button);
                        this.mAvatar.FlipButton = button.createTextButton('Flip', function () 
                        {
                            //self.onPressAvatarTypeButton();
                        }, 'display-block', 1);

                        var subRow = $('<div class="avatar-row"/>');
                        buttonColumn.append(subRow);
                        var button = $('<div class="l-avatar-button" />');
                        subRow.append(button);
                        this.mAvatar.SocketButton = button.createTextButton('Socket', function () 
                        {
                            //self.onPressAvatarTypeButton();
                        }, 'display-block', 1);
                    }

                    var avatarColumn = $('<div class="sub-column2"/>');
                    avatarChangerContainer.append(avatarColumn);
                    {
                        var avatarContainer = $('<div class="avatar-container"/>');
                        avatarColumn.append(avatarContainer);

                        //var table = $('<table width="100%" height="21.0rem"><tr><td width="15%"><div class="l-button prev-avatar-button" /></td><td width="70%" class="avatar-image-container"></td><td width="15%"><div class="l-button next-avatar-button" /></td></tr></table>');
                        //avatarContainer.append(table);

                        var left = $('<div class="avatar-column"/>');
                        avatarContainer.append(left);
                        var prevAvatar = $('<div class="avatar-button"/>');
                        left.append(prevAvatar);
                        this.mAvatar.PrevButton = prevAvatar.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function () 
                        {
                            //self.onPreviousBannerClicked();
                        }, '', 6);

                        var mid = $('<div class="avatar-column-mid"/>');
                        avatarContainer.append(mid);
                        var avatarImage = $('<div class="avatar-image-container"/>');
                        mid.append(avatarImage);
                        this.mAvatar.Image = avatarImage.createImage(Path.GFX + 'ui/icons/legends_party.png', function (_image) 
                        {
                            _image.centerImageWithinParent(0, 0, 1.0);
                            _image.removeClass('display-none').addClass('display-block');
                        }, null, 'display-none');

                        var right = $('<div class="avatar-column"/>');
                        avatarContainer.append(right);
                        var nextAvatar = $('<div class="avatar-button"/>');
                        right.append(nextAvatar);
                        this.mAvatar.NextButton = nextAvatar.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function () 
                        {
                            //self.onNextBannerClicked();
                        }, '', 6);
                    }
                }


                var row = $('<div class="row" />');
                row.css('padding-top', '1.0rem'); // css is retarded XD
                subRightColumn.append(row);
                var title = $('<div class="title title-font-big font-color-title">Company Name</div>');
                row.append(title);
                var inputLayout = $('<div class="l-input-big"/>');
                row.append(inputLayout);
                this.mCompanyName = inputLayout.createInput('Battle Brothers', 0, 32, 1, function (_input) 
                {
                    if (_input.getInputTextLength() === 0)
                        _input.val('Battle Brothers');
                }, 'title-font-big font-bold font-color-brother-name');


                var row = $('<div class="row"/>');
                subRightColumn.append(row);
                var title = $('<div class="title title-font-big font-color-title">Configuration Options</div>');
                row.append(title);
                var configureOptionsContainer = $('<div class="configure-container"/>');
                subRightColumn.append(configureOptionsContainer);
                {
                    var column45 = $('<div class="column45"/>');
                    configureOptionsContainer.append(column45);
                    var column55 = $('<div class="column55"/>');
                    configureOptionsContainer.append(column55);

                    var count = 0;
                    $.each(self.mConfig, function(_key, _definition)
                    {
                        if (count < 5)
                            self.createCheckBoxControlDIV(_definition, column45);
                        else
                            self.createCheckBoxControlDIV(_definition, column55);

                        count++
                    });

                    var row = $('<div class="row"/>');
                    column55.append(row);
                    var title = $('<div class="title title-font-big font-color-title">Battle Sisters</div>');
                    row.append(title);

                    var count = 0;
                    $.each(self.mGender, function(_key, _definition)
                    {
                        self.createRadioControlDIV(_definition, row, count, 'gender-control', 'mGenderLevel');
                        count++;
                    });
                }
            }
        }

        var rightColumn = $('<div class="column-right"/>');
        content.append(rightColumn);
        {
            // banner
            var row = $('<div class="row"/>');
            rightColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Company Banner</div>');
            row.append(title);

            var bannerContainer = $('<div class="banner-container"/>');
            row.append(bannerContainer);
            {
                var table = $('<table width="100%" height="100%"><tr><td width="10%"><div class="l-button prev-banner-button" /></td><td width="80%" class="banner-image-container"></td><td width="10%"><div class="l-button next-banner-button" /></td></tr></table>');
                bannerContainer.append(table);

                var prevBanner = table.find('.prev-banner-button:first');
                this.mPrevBannerButton = prevBanner.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function () 
                {
                    //self.onPreviousBannerClicked();
                }, '', 6);

                var nextBanner = table.find('.next-banner-button:first');
                this.mNextBannerButton = nextBanner.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function () 
                {
                    //self.onNextBannerClicked();
                }, '', 6);

                var bannerImage = table.find('.banner-image-container:first');
                this.mBannerImage = bannerImage.createImage(Path.GFX + 'ui/banners/banner_beasts_01.png', function (_image) 
                {
                    _image.removeClass('display-none').addClass('display-block');
                }, null, 'display-none banner-image');
            }

            // rostier slider
            this.createSliderControlDIV(this.mRosterTier, 'Roster Tier', rightColumn);
        }
    }

    // create footer button bar
    var footerButtonBar = $('<div class="l-button-bar"/>');
    this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);
    {
        // create: buttons
        var layout = $('<div class="l-leave-button"/>');
        footerButtonBar.append(layout);
        this.mCloseButton = layout.createTextButton("Close", function() {
            self.notifyBackendCloseButtonPressed();
        }, '', 1);
    }

    this.mIsVisible = false;
};

OriginCustomizerScreen.prototype.createRadioControlDIV = function (_definition, _parentDiv, _index, _name, _result) 
{
    var control = $('<div class="control"></div>');
    _parentDiv.append(control);
    _definition.Checkbox = $('<input type="radio" id="' + _definition.TooltipId + '" name="' + _name + '" />');
    control.append(_definition.Checkbox);
    _definition.Label = $('<label class="text-font-normal font-color-subtitle" for="' + _definition.TooltipId + '">' + _definition.Name + '</label>');
    control.append(_definition.Label);

    _definition.Checkbox.iCheck({
        checkboxClass: 'icheckbox_flat-orange',
        radioClass: 'iradio_flat-orange',
        increaseArea: '30%'
    });
    _definition.Checkbox.on('ifChecked', null, this, function (_event) 
    {
        var self = _event.data;
        self[_result] = _index;
    });

    _definition.Checkbox.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
};

OriginCustomizerScreen.prototype.createCheckBoxControlDIV = function (_definition, _parentDiv) 
{
    var row = $('<div class="row"></div>');
    _parentDiv.append(row);
    var control = $('<div class="control"/>');
    row.append(control);
    _definition.Checkbox = $('<input type="checkbox" id="' + _definition.TooltipId + '"/>');
    control.append(_definition.Checkbox);
    _definition.Label = $('<label class="text-font-normal font-color-subtitle" for="' + _definition.TooltipId + '">' + _definition.Name + '</label>');
    control.append(_definition.Label);

    _definition.Checkbox.iCheck({
        checkboxClass: 'icheckbox_flat-orange',
        radioClass: 'iradio_flat-orange',
        increaseArea: '30%'
    });

    _definition.Checkbox.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
};

OriginCustomizerScreen.prototype.createSliderControlDIV = function (_definition, _label, _parentDiv) 
{
    var row = $('<div class="row"></div>');
    _parentDiv.append(row);
    _definition.Title = $('<div class="title title-font-big font-bold font-color-title">' + _label + '</div>');
    _definition.Title.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
    row.append(_definition.Title);

    var control = $('<div class="scale-control"></div>');
    row.append(control);

    _definition.Control = $('<input class="scale-slider" type="range"/>');
    _definition.Control.attr('min', _definition.Min);
    _definition.Control.attr('max', _definition.Max);
    _definition.Control.attr('step', _definition.Step);
    _definition.Control.val(_definition.Value);
    control.append(_definition.Control);

    _definition.Label = $('<div class="scale-label text-font-normal font-color-subtitle">' + _definition.Value + '</div>');
    _definition.Label.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
    control.append(_definition.Label);

    _definition.Control.on("change", function () {
        _definition.Value = parseInt(_definition.Control.val());
        _definition.Label.text('' + _definition.Value);
    });

    return row;
};

OriginCustomizerScreen.prototype.createInputDIV = function (_key, _definition, _parentDiv, _title)
{
    var inputRow = $('<div class="input-row"/>');
    _parentDiv.append(inputRow);

    if (_title !== undefined && _title !== null && typeof _title === 'string') {
        var title = $('<div class="title title-font-big font-color-title">' + _title + '</div>');
        inputRow.css('padding-top', '0.5rem');
        inputRow.css('padding-left', '2.0rem');
        inputRow.append(title);

        inputRow = $('<div class="input-row"/>');
        _parentDiv.append(inputRow);
    }

    var inputRowLayout = $('<div class="l-input-row"/>');
    inputRow.append(inputRowLayout);

    var inputRowIconLayout = $('<div class="l-input-row-icon"/>');
    inputRowLayout.append(inputRowIconLayout);
    var inputRowIcon = $('<img class="input-row-icon-img"/>');
    inputRowIcon.attr('src', _definition.IconPath);
    inputRowIconLayout.append(inputRowIcon);
    inputRowIcon.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
    
    var inputLayout = $('<div class="l-input"/>');
    inputRowLayout.append(inputLayout);
    _definition.Input = inputLayout.createInput(_definition.Value, _definition.Min, _definition.Max, null, null, 'title-font-medium font-bold font-color-brother-name', function (_input)
    {
        //self.ConfirmAttributeChange(_input, _key);
    });
    _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    _definition.Input.css('background-size', '14.2rem 3.2rem');
    _definition.Input.css('text-align', 'center');

    _definition.Input.assignInputEventListener('mouseover', function(_event)
    {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    });

    _definition.Input.assignInputEventListener('mouseout', function(_input, _event)
    {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    });

    /*_definition.Input.assignInputEventListener('focusout', function(_input, _event)
    {
        //self.ConfirmAttributeChange(_input, _key);
    });*/

    _definition.Input.assignInputEventListener('click', function (_input, _event)
    {
        var currentText = _input.getInputText();
        var index = currentText.indexOf(' ');
        if (index > 0)
        {
            _input.setInputText(currentText.slice(0, index));
        }
    });
}

OriginCustomizerScreen.prototype.destroyDIV = function ()
{
	this.mCloseButton.remove();
    this.mCloseButton = null;

    this.mDialogContainer.empty();
    this.mDialogContainer.remove();
    this.mDialogContainer = null;

    this.mContainer.empty();
    this.mContainer.remove();
    this.mContainer = null;
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
    this.unregister();
};

OriginCustomizerScreen.prototype.getModule = function (_name)
{
    switch(_name)
    {
        default: return null;
    }
};

OriginCustomizerScreen.prototype.getModules = function ()
{
    return [];
};

OriginCustomizerScreen.prototype.bindTooltips = function ()
{
};

OriginCustomizerScreen.prototype.unbindTooltips = function ()
{
};

OriginCustomizerScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

OriginCustomizerScreen.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};

OriginCustomizerScreen.prototype.register = function (_parentDiv)
{
    console.log('OriginCustomizerScreen::REGISTER');

    if (this.mContainer !== null)
    {
        console.error('ERROR: Failed to register Origin Customizer Screen. Reason: Origin Customizer Screen is already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object')
    {
        this.create(_parentDiv);
    }
};

OriginCustomizerScreen.prototype.unregister = function ()
{
    console.log('OriginCustomizerScreen::UNREGISTER');

    if (this.mContainer === null)
    {
        console.error('ERROR: Failed to unregister Origin Customizer Screen. Reason: Origin Customizer Screen is not initialized.');
        return;
    }

    this.destroy();
};

OriginCustomizerScreen.prototype.isRegistered = function ()
{
    if (this.mContainer !== null)
    {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};

OriginCustomizerScreen.prototype.show = function (_data)
{
    this.loadFromData(_data);

    if(!this.mIsVisible)
    {
        var self = this;

        var withAnimation = true;
        if (withAnimation === true)
        {
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
        }
        else
        {
            this.mContainer.css({ opacity: 0 });
            this.mContainer.velocity("finish", true).velocity({ opacity: 1 }, {
                duration: Constants.SCREEN_FADE_IN_OUT_DELAY,
                easing: 'swing',
                begin: function() {
                    $(this).removeClass('display-none').addClass('display-block');
                    self.notifyBackendOnAnimating();
                },
                complete: function() {
                    self.mIsVisible = true;
                    self.notifyBackendOnShown();
                }
            });
        }
    }
};

OriginCustomizerScreen.prototype.hide = function (_withSlideAnimation)
{
    var self = this;
    var withAnimation = (_withSlideAnimation !== undefined && _withSlideAnimation !== null) ? _withSlideAnimation : true;

    if (withAnimation === true)
    {
        var offset = -(this.mContainer.parent().width() + this.mContainer.width());
        this.mContainer.velocity("finish", true).velocity({ opacity: 0, left: offset },
        {
            duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
            easing: 'swing',
            begin: function ()
            {
                $(this).removeClass('is-center');
                self.notifyBackendOnAnimating();
            },
            complete: function ()
            {
                self.mIsVisible = false;
                self.mListScrollContainer.empty();
                $(this).removeClass('display-block').addClass('display-none');
                self.notifyBackendOnHidden();
            }
        });
    }
    else
    {
        this.mContainer.velocity("finish", true).velocity({ opacity: 0 },
        {
            duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
            easing: 'swing',
            begin: function ()
            {
                $(this).removeClass('is-center');
                self.notifyBackendOnAnimating();
            },
            complete: function ()
            {
                self.mIsVisible = false;
                self.mListScrollContainer.empty();
                $(this).removeClass('display-block').addClass('display-none');
                self.notifyBackendOnHidden();
            }
        });
    }
};

OriginCustomizerScreen.prototype.isVisible = function ()
{
    return this.mIsVisible;
};

OriginCustomizerScreen.prototype.notifyBackendOnConnected = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onScreenConnected');
};

OriginCustomizerScreen.prototype.notifyBackendOnDisconnected = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onScreenDisconnected');
};

OriginCustomizerScreen.prototype.notifyBackendOnShown = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onScreenShown');
};

OriginCustomizerScreen.prototype.notifyBackendOnHidden = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onScreenHidden');
};

OriginCustomizerScreen.prototype.notifyBackendOnAnimating = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onScreenAnimating');
};

OriginCustomizerScreen.prototype.notifyBackendCloseButtonPressed = function ()
{
    if(this.mSQHandle !== null)
        SQ.call(this.mSQHandle, 'onCloseButtonPressed');
};



