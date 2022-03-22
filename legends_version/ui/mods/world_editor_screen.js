"use strict";

var WorldEditor =
{
    Screens: ['General'   , 'Properties'   , 'Factions'   , 'Settlements'   , 'Locations'   , 'Contracts'   ],
    Classes: ['is-general', 'is-properties', 'is-factions', 'is-settlements', 'is-locations', 'is-contracts'],
    Locations: ['Locations', 'Legendary', 'Misc'],
};

var WorldEditorScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;

    // switch-to buttons
    this.mSwitchToButton = 
    {
        General    : null,
        Properties : null,
        Factions   : null,
        Settlements: null,
        Locations  : null,
        Contracts  : null,
    };

    // screens
    this.mScreens = 
    {
        General    : null,
        Properties : null,
        Factions   : null,
        Settlements: null,
        Locations  : null,
        Contracts  : null,
    };

    // factions
    this.mFaction =
    {
        Data               : null,
        Name               : null,
        Banner             : null,
        Selected           : null,
        Contracts          : null,
        NextButton         : null,
        PrevButton         : null,
        Settlement         : null,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    // settlements
    this.mSettlement =
    {
        Data               : null,
        Name               : null,
        Image              : null,
        Selected           : null,
        Wealth             : null,
        Resources          : null,
        Buildings          : null,
        Situations         : null,
        Attachments        : null,
        OwnerBanner        : null,
        FactionBanner      : null,
        ListContainer      : null,
        ListScrollContainer: null,
        IsViewingAttachment: true,
    }

    // locations
    this.mLocation =
    {
        Data               : null,
        Name               : null,
        Image              : null,
        Loots              : null,
        Troops             : null,
        Selected           : null,
        Strength           : null,
        Resources          : null,
        FilterButton       : null,
        ListContainer      : null,
        ListScrollContainer: null,
        FilterType         : 0,
    };

    // inputs
    this.mCoordinate = 
    {
        X: {Input: null, Value: 0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, TooltipId: TooltipIdentifier.Assets.BusinessReputation},
        Y: {Input: null, Value: 0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, TooltipId: TooltipIdentifier.Assets.MoralReputation},
    }
    this.mAssets =
    {
        BusinessReputation: {Input: null, Value: 0, ValueMin:-1000, ValueMax: 20000, Min: 0, Max: 5, IconPath: Path.GFX + Asset.ICON_ASSET_BUSINESS_REPUTATION, TooltipId: TooltipIdentifier.Assets.BusinessReputation},
        MoralReputation   : {Input: null, Value: 0, ValueMin: 0   , ValueMax: 100  , Min: 0, Max: 3, IconPath: Path.GFX + Asset.ICON_ASSET_MORAL_REPUTATION   , TooltipId: TooltipIdentifier.Assets.MoralReputation},
        Money             : {Input: null, Value: 0, ValueMin: 0   , ValueMax: null , Min: 0, Max: 9, IconPath: Path.GFX + Asset.ICON_ASSET_MONEY              , TooltipId: TooltipIdentifier.Assets.Money},
        Stash             : {Input: null, Value: 0, ValueMin: 0   , ValueMax: 500  , Min: 0, Max: 3, IconPath: Path.GFX + Asset.ICON_BAG                      , TooltipId: TooltipIdentifier.Stash.FreeSlots},
        Ammo              : {Input: null, Value: 0, ValueMin: 300 , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_AMMO               , TooltipId: TooltipIdentifier.Assets.Ammo},
        Supplies          : {Input: null, Value: 0, ValueMin: 150 , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_SUPPLIES           , TooltipId: TooltipIdentifier.Assets.Supplies},
        Medicine          : {Input: null, Value: 0, ValueMin: 100 , ValueMax: null , Min: 0, Max: 4, IconPath: Path.GFX + Asset.ICON_ASSET_MEDICINE           , TooltipId: TooltipIdentifier.Assets.Medicine},
    };
    this.mAssetProperties =
    {
        // general properties
        General:
        {
            BusinessReputationRate  : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/asset_business_reputation.png', TooltipId: 'woditor.renown'},
            XPMult                  : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/xp_received.png', TooltipId: 'woditor.xp'},
            HitpointsPerHourMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/days_wounded.png', TooltipId: 'woditor.hp'},
            RepairSpeedMult         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/repair_item.png', TooltipId: 'woditor.repair'},
            VisionRadiusMult        : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/vision.png', TooltipId: 'woditor.vision'},
            FootprintVision         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/tracking_disabled.png', TooltipId: 'woditor.footprint'},
            MovementSpeedMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/boot.png', TooltipId: 'woditor.speed'},
            FoodAdditionalDays      : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/asset_daily_food.png', TooltipId: 'woditor.fooddays'},
        },

        // relation properties
        Relation:
        {
            RelationDecayGoodMult   : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/relation_good.png', TooltipId: 'woditor.goodrelation'},
            RelationDecayBadMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/relation_bad.png', TooltipId: 'woditor.badrelation'},
        },

        // contract properties
        Contract:
        {
            NegotiationAnnoyanceMult: {Input: null, Value: 100, ValueMin: 1, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/contract_annoyance.png', TooltipId: 'woditor.negotiation'},
            ContractPaymentMult     : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/contract_payment.png', TooltipId: 'woditor.contractpayment'},
            AdvancePaymentCap       : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scroll_01.png', TooltipId: 'woditor.advancepaymentcap'},
        },

        // scaling properties
        Scaling:
        {
            BrothersScaleMax        : {Input: null, Value:   0, ValueMin: 1, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scaling_max.png', TooltipId: 'woditor.brotherscalemax'},
            BrothersScaleMin        : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scaling_min.png', TooltipId: 'woditor.brotherscalemin'},
        },

        // recruit properties
        Recruit:
        {
            RosterSizeAdditionalMax : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/recruit_max.png', TooltipId: 'woditor.recruitmax'},
            RosterSizeAdditionalMin : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/recruit_min.png', TooltipId: 'woditor.recruitmin'},
            HiringCostMult          : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/hiring_cost.png', TooltipId: 'woditor.hiring'},
            TryoutPriceMult         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/tryout_cost.png', TooltipId: 'woditor.tryout'},
            DailyWageMult           : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/asset_daily_money.png', TooltipId: 'woditor.wage'},
            TrainingPriceMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/training_cost.png', TooltipId: 'woditor.trainingprice'},
        },

        // economy properties
        Economy:
        {
            TaxidermistPriceMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/crafting_cost.png', TooltipId: 'woditor.craft'},
            BuyPriceMult            : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/buying.png', TooltipId: 'woditor.buying'},
            SellPriceMult           : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/selling.png', TooltipId: 'woditor.selling'},
            BuyPriceTradeMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/buying_player.png', TooltipId: 'woditor.buying_trade'},
            SellPriceTradeMult      : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/selling_player.png', TooltipId: 'woditor.selling_trade'},
        },

        // combat properties
        Combat:
        {
            ChampionChanceAdditional: {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/miniboss.png', TooltipId: 'woditor.champion'},
            ExtraLootChance         : {Input: null, Value:   0, ValueMin: 0, ValueMax:  100, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/bag.png', TooltipId: 'woditor.loot'},
            EquipmentLootChance     : {Input: null, Value:   0, ValueMin: 0, ValueMax:  100, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/grab.png', TooltipId: 'woditor.equipmentloot'},
        }
    }

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
    this.mDifficultyLevel = 0;
    this.mEconomicDifficultyLevel = 0;
    this.mConfig = 
    {
        Ironman              : {Checkbox: null, Label: null, Name: 'Ironman'                      , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.Ironman},
        LegendBleedKiller    : {Checkbox: null, Label: null, Name: 'Bleeds Count As Kills'        , TooltipId: 'mapconfig.legendbleedkiller'},
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
    };
    this.mDifficulty =
    {
        Easy     : {Checkbox: null, Label: null, Name: 'Beginner' , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyEasy},
        Normal   : {Checkbox: null, Label: null, Name: 'Veteran'  , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyNormal},
        Hard     : {Checkbox: null, Label: null, Name: 'Expert'   , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyHard},
        Legendary: {Checkbox: null, Label: null, Name: 'Legendary', TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyLegendary}
    };
    this.mEconomicDifficulty =
    {
        Easy     : {Checkbox: null, Label: null, Name: 'Beginner' , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyEasy},
        Normal   : {Checkbox: null, Label: null, Name: 'Veteran'  , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyNormal},
        Hard     : {Checkbox: null, Label: null, Name: 'Expert'   , TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyHard},
        Legendary: {Checkbox: null, Label: null, Name: 'Legendary', TooltipId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyLegendary}
    };
    this.mFactionFixedRelation = {Checkbox: null, Label: null, Name: 'Stop Relation Deterioration', TooltipId: 'woditor.fixedrelation'};

    // sliders
    this.mRosterTier           = {Control: null, Title: null, Min: 1, Max:  10, Value:   2, Step: 1, TooltipId: 'woditor.rostertier', Postfix: ''};
    this.mDifficultyMult       = {Control: null, Title: null, Min: 5, Max: 300, Value: 100, Step: 5, TooltipId: 'woditor.difficultymult', Postfix: '%'};
    this.mFactionRelation      = {Control: null, Title: null, Min: 0, Max: 100, Value:  50, Step: 5, TooltipId: TooltipIdentifier.RelationsScreen.Relations, Postfix: ''};

    // troop selection dialog
    this.mTroop =
    {
        Selected: [],
        Filter: 0,
    };

    // buttons
    this.mSaveButton  = null;
    this.mCloseButton = null;

    // popup dialog
    this.mCurrentPopupDialog = null;

    // popup scenarios picker
    this.mScenario = 
    {
        Data               : null,
        Image              : null,
        Selected           : null,
        Description        : null,
        ListContainer      : null,
        ListScrollContainer: null,
    };

    // generics
    this.mLastScreen           = null;
    this.mIsVisible            = false;
    this.mIsChoosingCoordinate = false;
};

WorldEditorScreen.prototype.createDIV = function(_parentDiv)
{
    var self = this;

    // create: containers (init hidden!)
    this.mContainer = $('<div class="world-editor-screen ui-control dialog-modal-background display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    // create: dialog layout (init hidden!)
    var dialogLayout = $('<div class="l-world-editor-dialog-container"/>');
    this.mContainer.append(dialogLayout);

    // create: dialog
    this.mDialogContainer = dialogLayout.createDialog('World Editor', '', '', true, 'dialog-1280-768');

    // create tabs
    var tabContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabContainer);
    {
        var buttonPanel = $('<div class="tab-button-panel"/>');
        tabContainer.append(buttonPanel);

        // create the buttons to switch to other screens
        var index = 0;
        $.each(this.mSwitchToButton, function(_key, _definition) {
            var buttonLayout = $('<div class="l-tab-button ' + WorldEditor.Classes[index] + '"/>');
            buttonPanel.append(buttonLayout);
            self.mSwitchToButton[_key] = buttonLayout.createTabTextButton(_key, function() {
                self.switchScreen(_key);
            }, null, 'tab-button', 7);
            index++;
        });


        // save changes button
        var buttonLayout = $('<div class="l-tab-button is-save"/>');
        buttonPanel.append(buttonLayout);
        this.mSaveButton = buttonLayout.createImageButton(Path.GFX + 'ui/buttons/save_settings.png', function () {
            //self.mDataSource.notifyBackendCloseButtonClicked();
        }, '', 6);
        this.mSaveButton.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.save_button' });
    }


    // create content
    var content = this.mDialogContainer.findDialogContentContainer();
    {
        // create content screens
        $.each(this.mScreens, function(_key, _definition) {
            self.mScreens[_key] = $('<div class="display-none"/>');
            content.append(self.mScreens[_key]);
            self['create' + _key + 'ScreenDIV'](self.mScreens[_key]);
        });
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

WorldEditorScreen.prototype.createContractsScreenDIV = function(_parentDiv) 
{
    var self = this;
};

WorldEditorScreen.prototype.createLocationsScreenDIV = function(_parentDiv) 
{
    var self = this;

    // divide into 2 column - 23% and 77%
    var column = this.addColumn(23);
    _parentDiv.append(column);
    {
        var row90 = this.addRow(90, 'with-scroll-tooltip-background');
        column.append(row90);
        {
            var scrollHeader = this.addContainer(null, 4.3);
            row90.append(scrollHeader);
            {
                var column88 = this.addColumn(80);
                scrollHeader.append(column88);
                var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0); 
                column88.append(buttonLayout);
                this.mLocation.FilterButton = buttonLayout.createTextButton("Locations", function() {
                    self.changeLocationfilter();
                }, '', 4);

                var column12 = this.addColumn(20);
                scrollHeader.append(column12);
                var buttonLayout = this.addLayout(4.5, 4.1, 'is-horizontal-center');
                buttonLayout.css('top', '0.6rem') // css is retarded, fuck it
                column12.append(buttonLayout);
                var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                    //self.();
                }, '', 6);
                button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
            }

            var slotContainer = this.addContainer(null, 47.0);  //$('<div class="locations-container"/>');
            slotContainer.css('padding-top', '0.5rem');
            row90.append(slotContainer);
            var listContainerLayout = $('<div class="l-list-container"/>');
            slotContainer.append(listContainerLayout);
            this.mLocation.ListContainer = listContainerLayout.createList(2);
            this.mLocation.ListScrollContainer = this.mLocation.ListContainer.findListScrollContainer();
        }

        var row10 = this.addRow(10, 'with-small-dialog-background');
        column.append(row10);
        {
            var column20 = this.addColumn(20);
            row10.append(column20);
            var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
            column20.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/center.png', function() {
                //self.onPreviousBannerClicked();
            }, '', 6);
            button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.choosecoords' });

            var column40 = this.addColumn(40);
            row10.append(column40);
            this.createSmallInputDIV('X:', this.mCoordinate.X ,column40);

            var column40 = this.addColumn(40);
            row10.append(column40);
            this.createSmallInputDIV('Y:', this.mCoordinate.Y ,column40);
        }
    }

    var column = this.addColumn(77);
    _parentDiv.append(column);
    {
        var row40 = this.addRow(40);
        column.append(row40);
        {
            var leftColumn = this.addColumn(37.5);
            row40.append(leftColumn);
            {
                var upperHalf = this.addRow(50);
                leftColumn.append(upperHalf);
                {
                    // name input
                    var row = $('<div class="row"/>');
                    upperHalf.append(row);
                    var title = $('<div class="title title-font-big font-color-title">Location Name</div>');
                    row.append(title);
                    var inputLayout = $('<div class="l-input-big"/>');
                    row.append(inputLayout);
                    this.mLocation.Name = inputLayout.createInput('', 0, 40, 1, function (_input) {
                        //
                    }, 'title-font-big font-bold font-color-brother-name');
                }

                var lowerHalf = this.addRow(50, 'with-small-dialog-background');
                leftColumn.append(lowerHalf);
                {
                    // location image
                    var column65 = this.addColumn(65);
                    lowerHalf.append(column65);
                    var imageContainer = this.addLayout(16.0, 12.0, 'is-center');
                    column65.append(imageContainer);
                    this.mLocation.Image = imageContainer.createImage(null, function(_image) {
                        _image.fitImageToParent(0, 0);
                    }, null, '');

                    var column35 = this.addColumn(35);
                    lowerHalf.append(column35);
                    {
                        // button
                        var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                        column35.append(buttonLayout);
                        var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                            //self.();
                        }, '', 6);
                    }
                }
            }

            var midColumn = this.addColumn(37.5, 'with-medium-dialog-background');
            row40.append(midColumn);
            {
                var upperRow = this.addRow(40);
                midColumn.append(upperRow);
                {
                    var resourcesColumn = this.addColumn(50);
                    upperRow.append(resourcesColumn);
                    {
                        // name input
                        var row = $('<div class="row"/>');
                        resourcesColumn.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Resources</div>');
                        row.append(title);
                        var inputLayout = $('<div class="l-input-half-big"/>');
                        row.append(inputLayout);
                        this.mLocation.Resources = inputLayout.createInput('', 0, 4, 1, function (_input) {
                            //
                        }, 'title-font-big font-bold font-color-brother-name');
                        this.mLocation.Resources.css('background-size', '100% 4.0rem');
                    }

                    var strengthColumn = this.addColumn(50);
                    upperRow.append(strengthColumn);
                    {
                        // name input
                        var row = $('<div class="row"/>');
                        strengthColumn.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Strength</div>');
                        row.append(title);
                        var row = $('<div class="row"/>');
                        strengthColumn.append(row);
                        var inputLayout = $('<div class="strength-label-container with-input-box"/>');
                        row.append(inputLayout);
                        this.mLocation.Strength = $('<div class="strength-title is-vertical-center title-font-big font-bold font-color-brother-name"></div>');
                        inputLayout.append(this.mLocation.Strength);
                    }
                }

                var lowerRow = this.addRow(60);
                midColumn.append(lowerRow);
                {
                    var row = this.addContainer(null, 4.6);
                    row.css('margin-top', '2.0rem');
                    lowerRow.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Reroll Loots', function ()
                    {
                        //self.();
                    }, '', 4);

                    var row = this.addContainer(null, 4.6);
                    lowerRow.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Refresh Loot Scale', function ()
                    {
                        //self.();
                    }, '', 4);
                }
            }

            var rightColumn = this.addColumn(25, 'with-dirty-scroll-background');
            row40.append(rightColumn);
            {
                var scrollHeader = this.addContainer(null, 4.3);
                rightColumn.append(scrollHeader);
                {
                    var column80 = this.addColumn(80);
                    scrollHeader.append(column80);
                    var buttonLayout = this.addLayout(17.4, 4.3, 'is-center', 3.0);
                    column80.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Loots', null, '', 7);
                    button.enableButton(false);

                    var column20 = this.addColumn(20);
                    scrollHeader.append(column20);
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center'); 
                    column20.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
                }

                var slotContainer = this.addContainer(null, 18.5);
                rightColumn.append(slotContainer);

                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(1);
                this.mLocation.Loots = listContainer.findListScrollContainer();
            }
        }

        var row60 = this.addRow(60);
        column.append(row60);
        {
            var leftHalf = this.addColumn(50);
            row60.append(leftHalf);
            {

            }

            var rightHalf = this.addColumn(50, 'with-scroll-tooltip-background');
            row60.append(rightHalf);
            {
                var scrollHeader = this.addContainer(null, 4.3);
                rightHalf.append(scrollHeader);
                {
                    // button
                    var column = this.addColumn(10);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(3.9, 3.9, 'is-center');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/info.png', function() {
                        //self.();
                    }, '', 10);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.troopsinfo' });

                    // not button
                    var column = this.addColumn(50);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-horizontal-center', 3.0);
                    buttonLayout.css('bottom', '0.3rem'); // css is retarded, fuck it
                    column.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Defenders', null, '', 4);
                    button.enableButton(false);

                    // button button
                    var column = this.addColumn(10);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/buttons/sort-button.png', function() {
                        //self.();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.picktrooptemplate' });

                    // button button button
                    var column = this.addColumn(10);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                        //self.();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.refreshtroops' });

                    // button button button button
                    var column = this.addColumn(10);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/unknown_traits.png', function() {
                        //self.();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addrandomtroop' });

                    // button button button button button
                    var column = this.addColumn(10);
                    scrollHeader.append(column);
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        if(self.mLocation.Selected !== null && self.mLocation.Selected.length > 0)
                            self.createAddTroopPopupDialog();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
                }

                // troop list
                var slotContainer = this.addContainer(null, 30.0);
                rightHalf.append(slotContainer);
                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(2);
                this.mLocation.Troops = listContainer.findListScrollContainer();
            }

        }

    }
};

WorldEditorScreen.prototype.createSettlementsScreenDIV = function(_parentDiv) 
{
    var self = this;

    // divide into 2 columns - 23% and 77%
    var column = this.addColumn(23, 'with-dialog-background');
    column.css('padding-top', '0.6rem');
    _parentDiv.append(column);
    {   
        // settlement list
        var listContainerLayout = $('<div class="l-list-container"/>');
        column.append(listContainerLayout);
        this.mSettlement.ListContainer = listContainerLayout.createList(2);
        this.mSettlement.ListScrollContainer = this.mSettlement.ListContainer.findListScrollContainer();
    }

    var column = this.addColumn(77);
    _parentDiv.append(column);
    {
        var column78 = this.addColumn(78);
        column.append(column78);
        {
            var row75 = this.addRow(75);
            column78.append(row75);
            {
                var leftHalf = this.addColumn(50);
                row75.append(leftHalf);
                {
                    var row25 = this.addRow(25);
                    leftHalf.append(row25);
                    {
                        // name input
                        var row = $('<div class="row"/>');
                        row25.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Settlement Name</div>');
                        row.append(title);
                        var inputLayout = $('<div class="l-input-big"/>');
                        row.append(inputLayout);
                        this.mSettlement.Name = inputLayout.createInput('', 0, 40, 1, function (_input) {
                            
                        }, 'title-font-big font-bold font-color-brother-name');
                    }

                    var row30 = this.addRow(30, 'with-small-dialog-background');
                    leftHalf.append(row30);
                    {
                        // settlement image
                        var column75 = this.addColumn(75);
                        row30.append(column75);
                        var imageContainer = this.addLayout(16.0, 12.0, 'is-center');
                        column75.append(imageContainer);
                        this.mSettlement.Image = imageContainer.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');


                        var column25 = this.addColumn(25);
                        row30.append(column25);
                        {
                            // button
                            var buttonRow = this.addRow(50);
                            column25.append(buttonRow);
                            var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                            buttonRow.append(buttonLayout);
                            var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_retract.png', function() {
                                //self.onPreviousBannerClicked();
                            }, '', 6);

                            // button button
                            var buttonRow = this.addRow(50);
                            column25.append(buttonRow);
                            var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                            buttonRow.append(buttonLayout);
                            var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_expand.png', function() {
                                //self.onPreviousBannerClicked();
                            }, '', 6);
                        }
                    }

                    var row35 = this.addRow(35);
                    leftHalf.append(row35);
                    {
                        // title
                        var column50 = this.addColumn(50);
                        row35.append(column50);
                        var row = $('<div class="row"/>');
                        column50.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Faction</div>');
                        row.append(title);
                        // faction image banner
                        var imageContainer = $('<div class="faction-landlord-container"/>');
                        column50.append(imageContainer);
                        this.mSettlement.FactionBanner = imageContainer.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');


                        // title
                        var column50 = this.addColumn(50);
                        row35.append(column50);
                        var row = $('<div class="row"/>');
                        column50.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Owner</div>');
                        row.append(title);
                        // owner image banner
                        var imageContainer = $('<div class="faction-landlord-container"/>');
                        column50.append(imageContainer);
                        this.mSettlement.OwnerBanner = imageContainer.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');
                    }

                    var row10 = this.addRow(10);
                    leftHalf.append(row10);
                    {
                        // title, don't ask why XD
                        var row = $('<div class="row"/>');
                        row10.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Buildings</div>');
                        title.css('margin-top', '0.8rem');
                        title.css('margin-bottom', '0');
                        row.append(title);
                    }
                }

                var rightHalf = this.addColumn(50, 'with-dialog-background');
                row75.append(rightHalf);
                {
                    var upperRow = this.addRow(30);
                    rightHalf.append(upperRow);
                    {
                        var resourcesColumn = this.addColumn(50);
                        upperRow.append(resourcesColumn);
                        {
                            // name input
                            var row = $('<div class="row"/>');
                            resourcesColumn.append(row);
                            var title = $('<div class="title title-font-big font-color-title">Resources</div>');
                            row.append(title);
                            var inputLayout = $('<div class="l-input-half-big"/>');
                            row.append(inputLayout);
                            this.mSettlement.Resources = inputLayout.createInput('', 0, 4, 1, function (_input) {
                                //
                            }, 'title-font-big font-bold font-color-brother-name');
                            this.mSettlement.Resources.css('background-size', '100% 4.0rem'); // simple solution to get a smaller input without much work :evilgrins
                        }

                        var wealthColumn = this.addColumn(50);
                        upperRow.append(wealthColumn);
                        {
                            // name input
                            var row = $('<div class="row"/>');
                            wealthColumn.append(row);
                            var title = $('<div class="title title-font-big font-color-title">Wealth</div>');
                            row.append(title);
                            var inputLayout = $('<div class="l-input-half-big"/>');
                            row.append(inputLayout);
                            this.mSettlement.Wealth = inputLayout.createInput('', 0, 3, 1, function (_input) {
                            }, 'title-font-big font-bold font-color-brother-name');
                            this.mSettlement.Wealth.css('background-size', '100% 4.0rem');

                            // set up fun event listeners
                            this.mSettlement.Wealth.assignInputEventListener('focusout', function(_input, _event) {
                                _input.addPercentageToInput();
                            });
                            this.mSettlement.Wealth.assignInputEventListener('click', function(_input, _event) {
                                _input.removePercentageToInput();
                            });
                        }
                    }

                    var lowerRow = this.addRow(70);
                    rightHalf.append(lowerRow);
                    {
                        var row = this.addContainer(null, 4.6);
                        lowerRow.append(row);
                        // button
                        var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                        row.append(buttonLayout);
                        var button = buttonLayout.createTextButton('Shut Down', function ()
                        {
                            //self.();
                        }, '', 4);

                        var row = this.addContainer(null, 4.6);
                        lowerRow.append(row);
                        // button button 
                        var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                        row.append(buttonLayout);
                        var button = buttonLayout.createTextButton('Send Caravan', function ()
                        {
                            //self.();
                        }, '', 4);

                        var row = this.addContainer(null, 4.6);
                        lowerRow.append(row);
                        // button button button 
                        var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                        row.append(buttonLayout);
                        var button = buttonLayout.createTextButton('Send Mercenary', function ()
                        {
                            //self.();
                        }, '', 4);

                        var row = this.addContainer(null, 4.6);
                        lowerRow.append(row);
                        // button button button button 
                        var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                        row.append(buttonLayout);
                        var button = buttonLayout.createTextButton('Refresh Shops', function ()
                        {
                            //self.();
                        }, '', 4);

                        var row = this.addContainer(null, 4.6);
                        lowerRow.append(row);
                        // button button button button button 
                        var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                        row.append(buttonLayout);
                        var button = buttonLayout.createTextButton('Refresh Roster', function ()
                        {
                            //self.();
                        }, '', 4);
                    }
                }
            }

            var row25 = this.addRow(25, 'with-small-dialog-background');
            column78.append(row25);
            {
                var buildingsLayout = $('<div class="a-container is-center"/>');
                row25.append(buildingsLayout);

                this.mSettlement.Buildings = [];
                for (var i = 0; i < 4; i++) {
                    this.createSettlementBuildingSlot(i, buildingsLayout);
                }
            }
        }

        var column22 = this.addColumn(22);
        column.append(column22);
        {
            var row = this.addRow(35, 'with-scroll-tooltip-background');
            column22.append(row);
            {
                var scrollHeader = this.addContainer(null, 4.3);
                row.append(scrollHeader);
                {   
                    var column80 = this.addColumn(80);
                    scrollHeader.append(column80);
                    // not button
                    var buttonLayout = this.addLayout(17.4, 4.3, 'is-center', 3.0);
                    column80.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Situations', null, '', 7);
                    button.enableButton(false);

                    var column20 = this.addColumn(20);
                    scrollHeader.append(column20);
                    // button
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column20.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
                }
                

                var slotContainer = this.addContainer(null, 16.0);
                slotContainer.css('padding-top', '0.5rem');
                slotContainer.css('padding-left', '1.0rem');
                row.append(slotContainer);

                // situation list
                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(1);
                this.mSettlement.Situations = listContainer.findListScrollContainer();
            }

            var row = this.addRow(65, 'with-scroll-tooltip-background');
            column22.append(row);
            {
                var scrollHeader = this.addContainer(null, 4.3);
                row.append(scrollHeader);
                {  
                    var column80 = this.addColumn(80);
                    scrollHeader.append(column80);
                    // not button
                    var buttonLayout = this.addLayout(17.4, 4.3, 'is-center', 3.0);
                    column80.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Attachments', null, '', 7);
                    button.enableButton(false);

                    var column20 = this.addColumn(20);
                    scrollHeader.append(column20);
                    // button
                    var buttonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    column20.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.addnewentry' });
                }

                var slotContainer = this.addContainer(null, 33.0);
                slotContainer.css('padding-top', '0.3rem');
                slotContainer.css('padding-left', '1.0rem');
                row.append(slotContainer);

                // attached location list
                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(1);
                this.mSettlement.Attachments = listContainer.findListScrollContainer();
            }
        }
    }
};

WorldEditorScreen.prototype.createFactionsScreenDIV = function(_parentDiv) 
{
    var self = this;

    var column40 = this.addColumn(40, 'with-dialog-background');
    column40.css('padding-top', '0.9rem');
    _parentDiv.append(column40);
    {
        var listContainerLayout = $('<div class="l-list-container"/>');
        column40.append(listContainerLayout);
        this.mFaction.ListContainer = listContainerLayout.createList(2);
        this.mFaction.ListScrollContainer = this.mFaction.ListContainer.findListScrollContainer();
    }

    var column60 = this.addColumn(60);
    _parentDiv.append(column60);
    {
        var row80 = this.addRow(80);
        column60.append(row80);
        {
            var column = this.addColumn(50);
            row80.append(column);
            {
                var row90 = this.addRow(90);
                column.append(row90);
                {
                    // input name
                    var row = $('<div class="row"/>');
                    row90.append(row);
                    var title = $('<div class="title title-font-big font-color-title">Faction Name</div>');
                    row.append(title);
                    var inputLayout = $('<div class="l-input-big"/>');
                    row.append(inputLayout);
                    this.mFaction.Name = inputLayout.createInput('', 0, 40, 1, function (_input) {
                        
                    }, 'title-font-big font-bold font-color-brother-name');
                    
                    // relation stuffs
                    this.createSliderControlDIV(this.mFactionRelation, 'Relation', row90);
                    this.createCheckBoxControlDIV(this.mFactionFixedRelation, row90);
                }

                var row10 = this.addRow(10);
                column.append(row10);
                {
                    // another title that you shouldn't ask why
                    var row = $('<div class="row"/>');
                    row10.append(row);
                    var title = $('<div class="title title-font-big font-color-title">Available Contracts</div>');
                    title.css('margin-top', '1.0rem');
                    title.css('margin-bottom', '0');
                    row.append(title);
                }
            }

            var column = this.addColumn(50);
            row80.append(column);
            {
                var row40 = this.addRow(40, 'with-small-dialog-background');
                column.append(row40);
                {
                    var leftColumn = this.addColumn(30);
                    row40.append(leftColumn);
                    // button
                    var prevButtonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    leftColumn.append(prevButtonLayout);
                    this.mFaction.PrevButton = prevButtonLayout.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);

                    var midColumn = this.addColumn(40);
                    row40.append(midColumn);
                    var bannerContainer = this.addLayout(15.0, 20.0, 'is-center');
                    midColumn.append(bannerContainer);
                    // banner image
                    this.mFaction.Banner = bannerContainer.createImage(null, function(_image) {
                        _image.centerImageWithinParent(0, 0, 1.0);
                        _image.removeClass('display-none').addClass('display-block');
                    }, null, 'display-none');

                    var rightColumn = this.addColumn(30);
                    row40.append(rightColumn);
                    // button button
                    var nextButtonLayout = this.addLayout(4.5, 4.1, 'is-center');
                    rightColumn.append(nextButtonLayout);
                    this.mFaction.NextButton = nextButtonLayout.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                }

                var row60 = this.addRow(60, 'with-scroll-tooltip-background');
                column.append(row60);
                {
                    // button
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('View Settlements', function ()
                    {
                        //self.();
                    }, '', 4);

                    // button button
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('View Alliance', function ()
                    {
                        //self.();
                    }, '', 4);

                    // button button button
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Despawn Troops', function ()
                    {
                        //self.();
                    }, '', 4);

                    // button button button button
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Refresh Roster', function ()
                    {
                        //self.();
                    }, '', 4);

                    // button button button button button 
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Refresh Actions', function ()
                    {
                        //self.();
                    }, '', 4);

                    // button button button button button button
                    var row = this.addContainer(null, 4.6);
                    row60.append(row);
                    var buttonLayout = this.addLayout(23.0, 4.3, 'is-center', 3.0);
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton('Refresh Contracts', function ()
                    {
                        //self.();
                    }, '', 4);
                }
            }
        }

        // contract panel
        var row20 = this.addRow(20, 'with-small-dialog-background');
        column60.append(row20);
        {
            this.mFaction.Contracts = $('<div class="a-container is-center"/>');
            row20.append(this.mFaction.Contracts);
        }
    }
};

WorldEditorScreen.prototype.createPropertiesScreenDIV = function(_parentDiv) 
{   
    var self = this;

    var column50 = this.addColumn(50, 'with-dialog-background');
    _parentDiv.append(column50);
    {
        var row80 = this.addRow(80);
        column50.append(row80);
        {
            var subColumn50 = this.addColumn(50);
            row80.append(subColumn50);
            {
                var count = 0;
                var row = $('<div class="row"/>');
                subColumn50.append(row);
                var title = $('<div class="title title-font-big font-color-title">Combat Difficulty</div>');
                row.append(title);
                $.each(this.mDifficulty, function(_key, _definition) {
                    self.createRadioControlDIV(_definition, row, count, 'difficulty', 'mDifficultyLevel');
                    count++;
                });


                var row = $('<div class="row"/>');
                subColumn50.append(row);
                var title = $('<div class="title title-font-big font-color-title">Combat & Scaling</div>');
                row.append(title);
                
                $.each(this.mAssetProperties.Scaling, function(_key, _definition) {
                    self.createInputDIV(_key, _definition, row);
                });
                
                $.each(this.mAssetProperties.Combat, function(_key, _definition) {
                    self.createInputDIV(_key, _definition, row);
                });
            }

            var subColumn50 = this.addColumn(50);
            row80.append(subColumn50);
            {
                var count = 0;
                var row = $('<div class="row"/>');
                subColumn50.append(row);
                var title = $('<div class="title title-font-big font-color-title">Economic Difficulty</div>');
                row.append(title);
                $.each(this.mEconomicDifficulty, function(_key, _definition) {
                    self.createRadioControlDIV(_definition, row, count, 'economic-difficulty', 'mEconomicDifficultyLevel');
                    count++;
                });


                var row = $('<div class="row"/>');
                subColumn50.append(row);
                var title = $('<div class="title title-font-big font-color-title">Pricing</div>');
                row.append(title);
                
                $.each(this.mAssetProperties.Economy, function(_key, _definition) {
                    self.createInputDIV(_key, _definition, row);
                });
            }
        }

        var row20 = this.addRow(20);
        column50.append(row20);
        {
            this.createSliderControlDIV(this.mDifficultyMult, 'Difficulty Multiplier', row20);
        }
    }

    var column25 = this.addColumn(25);
    _parentDiv.append(column25);
    {
        var row = $('<div class="row"/>');
        column25.append(row);
        var title = $('<div class="title title-font-big font-color-title">General</div>');
        row.append(title);

        $.each(this.mAssetProperties.General, function(_key, _definition) {
            self.createInputDIV(_key, _definition, row);
        });


        var row = $('<div class="row"/>');
        row.css('padding-top', '1.0rem');
        column25.append(row);
        var title = $('<div class="title title-font-big font-color-title">Contract</div>');
        row.append(title);

        $.each(this.mAssetProperties.Contract, function(_key, _definition) {
            self.createInputDIV(_key, _definition, row);
        });
    }

    var column25 = this.addColumn(25, 'with-scroll-background');
    _parentDiv.append(column25);
    {
        var row = $('<div class="row"/>');
        column25.append(row);
        var title = $('<div class="title-black title-font-big font-color-ink">Recruit</div>');
        row.append(title);

        $.each(this.mAssetProperties.Recruit, function(_key, _definition) {
            self.createInputDIV(_key, _definition, row);
        });


        var row = $('<div class="row"/>');
        row.css('padding-top', '9.0rem');
        column25.append(row);
        var title = $('<div class="title-black title-font-big font-color-ink">Relation</div>'); //title-font-normal font-bold font-color-ink
        row.append(title);

        $.each(this.mAssetProperties.Relation, function(_key, _definition) {
            self.createInputDIV(_key, _definition, row);
        });
    }
};

WorldEditorScreen.prototype.createGeneralScreenDIV = function (_parentDiv) 
{
    var self = this;

    var leftColumn = this.addColumn(65);
    _parentDiv.append(leftColumn);
    {
        var subLeftColumn = this.addColumn(26);
        leftColumn.append(subLeftColumn);
        {
            var originImageContainer = $('<div class="origin-image-container"/>');
            subLeftColumn.append(originImageContainer);

            this.mScenario.Image = originImageContainer.createImage(Path.GFX + 'ui/events/event_141.png', function(_image) {
                _image.removeClass('opacity-none');
            }, null, 'opacity-none');
            this.mScenario.Image.bindTooltip({ contentType: 'ui-element', elementId: 'woditor.choose_origin' });
            this.mScenario.Image.click(function ()
            {
                self.createScenarioPopupDialog();
            });

            var row = $('<div class="row"/>');
            subLeftColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Assets</div>');
            //title.css('margin-bottom', '1.0rem');
            row.append(title);

            var count = 0;
            $.each(this.mAssets, function (_key, _definition) {
                self.createInputDIV(_key, _definition, row);
                count++;
            });
        }

        var subRightColumn = this.addColumn(74, 'with-dialog-background');
        leftColumn.append(subRightColumn);
        {
            // title
            var row = $('<div class="row"/>');
            subRightColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Company Avatar</div>');
            title.css('margin-bottom', '1.0rem');
            row.append(title);

            var avatarChangerContainer = this.addContainer(null, 17.0);
            row.append(avatarChangerContainer);
            {
                var buttonColumn = this.addColumn(35);
                avatarChangerContainer.append(buttonColumn);
                {
                    // button
                    var subRow = this.addContainer(null, 3.6);
                    buttonColumn.append(subRow);
                    var button = this.addLayout(17.5, 4.3, 'is-center');
                    subRow.append(button);
                    this.mAvatar.TypeButton = button.createTextButton('Human', function () 
                    {
                        //self.();
                    }, 'display-block', 1);

                    // button button
                    var subRow = this.addContainer(null, 3.6);
                    buttonColumn.append(subRow);
                    var button = this.addLayout(17.5, 4.3, 'is-center');
                    subRow.append(button);
                    this.mAvatar.FlipButton = button.createTextButton('Flip', function () 
                    {
                        //self.();
                    }, 'display-block', 1);

                    // button button button
                    var subRow = this.addContainer(null, 3.6);
                    buttonColumn.append(subRow);
                    var button = this.addLayout(17.5, 4.3, 'is-center');
                    subRow.append(button);
                    this.mAvatar.SocketButton = button.createTextButton('Socket', function () 
                    {
                        //self.();
                    }, 'display-block', 1);
                }

                var avatarColumn = this.addColumn(65, 'with-small-dialog-background');
                avatarChangerContainer.append(avatarColumn);
                {
                    var avatarContainer = this.addContainer(null, null);
                    avatarContainer.css('margin-bottom', '1.0rem');
                    avatarColumn.append(avatarContainer);

                    // button
                    var left = this.addColumn(25);
                    avatarContainer.append(left);
                    var prevAvatar = this.addLayout(4.5, 4.1, 'is-center');
                    left.append(prevAvatar);
                    this.mAvatar.PrevButton = prevAvatar.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);

                    // avatar image
                    var mid = this.addColumn(50);
                    avatarContainer.append(mid);
                    var avatarImage = this.addLayout(13.0, 16.0, 'is-center');
                    mid.append(avatarImage);
                    this.mAvatar.Image = avatarImage.createImage(Path.GFX + 'ui/icons/legends_necro.png', function(_image) {
                        _image.centerImageWithinParent(0, 0, 1.0);
                        _image.removeClass('display-none').addClass('display-block');
                    }, null, 'display-none');

                    // button button
                    var right = this.addColumn(25);
                    avatarContainer.append(right);
                    var nextAvatar = this.addLayout(4.5, 4.1, 'is-center');
                    right.append(nextAvatar);
                    this.mAvatar.NextButton = nextAvatar.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
                        //self.onNextBannerClicked();
                    }, '', 6);
                }
            }

            // name input
            var row = $('<div class="row"/>');
            row.css('padding-top', '1.0rem'); // css is retarded XD
            subRightColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Company Name</div>');
            row.append(title);
            var inputLayout = $('<div class="l-input-big"/>');
            row.append(inputLayout);
            this.mCompanyName = inputLayout.createInput('Battle Brothers', 0, 32, 1, function (_input) {
                if (_input.getInputTextLength() === 0)
                {
                    _input.val('Battle Brothers');
                }
            }, 'title-font-big font-bold font-color-brother-name');
            this.mCompanyName.setInputText('Battle Brothers');


            var row = $('<div class="row"/>');
            subRightColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Configuration Options</div>');
            row.append(title);
            var configureOptionsContainer = this.addContainer(null, 30.0);
            subRightColumn.append(configureOptionsContainer);
            {
                var column45 = this.addColumn(45);
                configureOptionsContainer.append(column45);
                var column55 = this.addColumn(55);
                configureOptionsContainer.append(column55);

                var count = 0;
                $.each(this.mConfig, function(_key, _definition) {
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
                $.each(this.mGender, function(_key, _definition) {
                    self.createRadioControlDIV(_definition, row, count, 'gender-control', 'mGenderLevel');
                    count++;
                });
            }
        }
    }

    var rightColumn = this.addColumn(35);
    _parentDiv.append(rightColumn);
    {
        // title
        var row = $('<div class="row"/>');
        rightColumn.append(row);
        var title = $('<div class="title title-font-big font-color-title">Company Banner</div>');
        row.append(title);

        // banner table copied from new campaign screen
        var bannerContainer = $('<div class="banner-container"/>');
        row.append(bannerContainer);
        {
            var table = $('<table width="100%" height="100%"><tr><td width="10%"><div class="l-button prev-banner-button" /></td><td width="80%" class="banner-image-container"></td><td width="10%"><div class="l-button next-banner-button" /></td></tr></table>');
            bannerContainer.append(table);

            var prevBanner = table.find('.prev-banner-button:first');
            this.mPrevBannerButton = prevBanner.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
                //self.onPreviousBannerClicked();
            }, '', 6);

            var nextBanner = table.find('.next-banner-button:first');
            this.mNextBannerButton = nextBanner.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
                //self.onNextBannerClicked();
            }, '', 6);

            var bannerImage = table.find('.banner-image-container:first');
            this.mBannerImage = bannerImage.createImage(Path.GFX + 'ui/banners/banner_beasts_01.png', function(_image) {
                _image.removeClass('display-none').addClass('display-block');
            }, null, 'display-none banner-image');
        }

        // roster slider
        this.createSliderControlDIV(this.mRosterTier, 'Roster Tier', rightColumn);
    }
};

WorldEditorScreen.prototype.createRadioControlDIV = function(_definition, _parentDiv, _index, _name, _result) 
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
    _definition.Checkbox.on('ifChecked', null, this, function(_event) {
        var self = _event.data;
        self[_result] = _index;
    });

    _definition.Label.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
};

WorldEditorScreen.prototype.createCheckBoxControlDIV = function(_definition, _parentDiv) 
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

    _definition.Label.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
};

WorldEditorScreen.prototype.createSliderControlDIV = function(_definition, _title, _parentDiv) 
{
    var row = $('<div class="row"></div>');
    _parentDiv.append(row);
    _definition.Title = $('<div class="title title-font-big font-bold font-color-title">' + _title + '</div>');
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

    _definition.Label = $('<div class="scale-label text-font-normal font-color-subtitle">' + _definition.Value + _definition.Postfix + '</div>');
    _definition.Label.bindTooltip({ contentType: 'ui-element', elementId: _definition.TooltipId });
    control.append(_definition.Label);
    
    _definition.Control.on("change", function () {
        _definition.Value = parseInt(_definition.Control.val());
        _definition.Label.text('' + _definition.Value + _definition.Postfix);
    });
};

WorldEditorScreen.prototype.createInputDIV = function(_key, _definition, _parentDiv)
{
    var inputRow = $('<div class="row input-row"/>');
    _parentDiv.append(inputRow);

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
    _definition.Input = inputLayout.createInput(_definition.Value, _definition.Min, _definition.Max, null, null, 'title-font-medium font-bold font-color-brother-name', function (_input) {
        //self.ConfirmAttributeChange(_input, _key);
    });
    _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    _definition.Input.css('background-size', '14.2rem 3.2rem');
    _definition.Input.css('text-align', 'center');

    _definition.Input.assignInputEventListener('mouseover', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    });

    _definition.Input.assignInputEventListener('mouseout', function(_input, _event) {
        _definition.Input.css('background-image', 'url("coui://gfx/ui/skin/barber_textbox.png")');
    });

    /*_definition.Input.assignInputEventListener('focusout', function(_input, _event)
    {
        //self.ConfirmAttributeChange(_input, _key);
    });*/

    /*_definition.Input.assignInputEventListener('click', function(_input, _event) {
        var currentText = _input.getInputText();
        var index = currentText.indexOf(' ');
        if (index > 0)
        {
            _input.setInputText(currentText.slice(0, index));
        }
    });*/

    _definition.Input.val(_definition.Value);
}

WorldEditorScreen.prototype.destroyDIV = function()
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

WorldEditorScreen.prototype.isConnected = function()
{
    return this.mSQHandle !== null;
};

WorldEditorScreen.prototype.onConnection = function(_handle)
{
    this.mSQHandle = _handle;
    this.register($('.root-screen'));
};

WorldEditorScreen.prototype.onDisconnection = function()
{
    this.mSQHandle = null;
    this.unregister();
};

WorldEditorScreen.prototype.getModule = function(_name)
{
    switch(_name)
    {
        default: return null;
    }
};

WorldEditorScreen.prototype.getModules = function()
{
    return [];
};

WorldEditorScreen.prototype.bindTooltips = function()
{
};

WorldEditorScreen.prototype.unbindTooltips = function()
{
};

WorldEditorScreen.prototype.create = function(_parentDiv)
{
    this.createDIV(_parentDiv);
    this.bindTooltips();
};

WorldEditorScreen.prototype.destroy = function()
{
    this.unbindTooltips();
    this.destroyDIV();
};

WorldEditorScreen.prototype.register = function(_parentDiv)
{
    console.log('WorldEditorScreen::REGISTER');

    if (this.mContainer !== null)
    {
        console.error('ERROR: Failed to register World Editor Screen. Reason: World Editor Screen is already initialized.');
        return;
    }

    if (_parentDiv !== null && typeof(_parentDiv) == 'object')
    {
        this.create(_parentDiv);
    }
};

WorldEditorScreen.prototype.unregister = function()
{
    console.log('WorldEditorScreen::UNREGISTER');

    if (this.mContainer === null)
    {
        console.error('ERROR: Failed to unregister World Editor Screen. Reason: World Editor Screen is not initialized.');
        return;
    }

    this.destroy();
};

WorldEditorScreen.prototype.isRegistered = function()
{
    if (this.mContainer !== null)
    {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};

WorldEditorScreen.prototype.show = function(_data)
{
    var screen = this.mLastScreen !== null && this.mLastScreen !== undefined ? this.mLastScreen : 'General';

    this.loadFromData(_data);
    this.switchScreen(screen);

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

WorldEditorScreen.prototype.hide = function(_withSlideAnimation)
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
    }
    else
    {
        this.mContainer.velocity("finish", true).velocity({ opacity: 0 },
        {
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
    }
};

WorldEditorScreen.prototype.switchScreen = function(_screen)
{
    var self = this;

    $.each(this.mScreens, function (_key, _definition) {
        if (_key === _screen) {
            _definition.removeClass('display-none').addClass('display-block');
            self.mSwitchToButton[_key].enableButton(false);
        }
        else {
            _definition.removeClass('display-block').addClass('display-none');
            self.mSwitchToButton[_key].enableButton(true);
        }
    });

    this.mLastScreen = _screen;
};

WorldEditorScreen.prototype.isVisible = function()
{
    return this.mIsVisible;
};


// simple functions so i don't have to prepare so many css elements
WorldEditorScreen.prototype.addLayout = function(_width, _height, _class, _line, _color)
{
    if (_class === undefined || _class === null)
        _class = '';

    var result = $('<div class="custom-layout-container ' + _class + '"/>');
    result.css('width', _width + 'rem'); //only accept number, no %
    result.css('height', _height + 'rem'); //only accept number, no %

    if (_line !== undefined)
        result.css('line-height', _line + 'rem'); //only accept number, no %

    if (_color !== undefined) // the border is only used for testing
        result.css('border', '1px solid ' + _color);

    return result;
};
WorldEditorScreen.prototype.addContainer = function(_width, _height, _class, _color)
{
    if (_class === undefined || _class === null)
        _class = '';

    if (_width === undefined || _width === null)
        _width = '100%';
    else if (typeof _width !== 'string') // i only use string when i add %
        _width = _width + 'rem';

    if (_height === undefined || _height === null)
        _height = '100%';
    else if (typeof _height !== 'string') // i only use string when i add %
        _height = _height + 'rem';

    var result = $('<div class="custom-container ' + _class + '"/>');
    result.css('width', _width);
    result.css('height', _height);

    if (_color !== undefined) // the border is only used for testing
        result.css('border', '1px solid ' + _color);

    return result;
};
WorldEditorScreen.prototype.addColumn = function(_width, _class, _color)
{
    if (_class === undefined || _class === null)
        _class = '';

    var result = $('<div class="custom-column ' + _class + '"/>');
    result.css('width', _width + '%');

    if (_color !== undefined)
        result.css('border', '1px solid ' + _color);

    return result;
};
WorldEditorScreen.prototype.addRow = function(_height, _class, _color)
{
    if (_class === undefined || _class === null)
        _class = '';

    var result = $('<div class="custom-row ' + _class + '"/>');
    result.css('height', _height + '%');

    if (_color !== undefined)
        result.css('border', '1px solid ' + _color);

    return result;
};
WorldEditorScreen.prototype.loadFromData = function(_data) 
{
    if ('Scenarios' in _data && _data.Scenarios !== undefined && _data.Scenarios !== null && jQuery.isArray(_data.Scenarios))
        this.mScenario.Data = _data.Scenarios;

    if ('Factions' in _data && _data.Factions !== undefined && _data.Factions !== null && jQuery.isArray(_data.Factions))
        this.addFactionsData(_data.Factions);

    if ('Settlements' in _data && _data.Settlements !== undefined && _data.Settlements !== null && jQuery.isArray(_data.Settlements))
        this.addSettlementsData(_data.Settlements);

    if ('Locations' in _data && _data.Locations !== undefined && _data.Locations !== null && jQuery.isArray(_data.Locations))
        this.addLocationsData(_data.Locations);
};

WorldEditorScreen.prototype.notifyBackendOnConnected = function()
{
    SQ.call(this.mSQHandle, 'onScreenConnected');
};

WorldEditorScreen.prototype.notifyBackendOnDisconnected = function()
{
    SQ.call(this.mSQHandle, 'onScreenDisconnected');
};

WorldEditorScreen.prototype.notifyBackendOnShown = function()
{
    SQ.call(this.mSQHandle, 'onScreenShown');
};

WorldEditorScreen.prototype.notifyBackendOnHidden = function()
{
    SQ.call(this.mSQHandle, 'onScreenHidden');
};

WorldEditorScreen.prototype.notifyBackendOnAnimating = function()
{
    SQ.call(this.mSQHandle, 'onScreenAnimating');
};

WorldEditorScreen.prototype.notifyBackendPopupDialogIsVisible = function (_visible)
{
    SQ.call(this.mSQHandle, 'onPopupDialogIsVisible', [_visible]);
};

WorldEditorScreen.prototype.notifyBackendCloseButtonPressed = function()
{
    SQ.call(this.mSQHandle, 'onCloseButtonPressed');
};

WorldEditorScreen.prototype.notifyBackendGetTroopEntries = function( _result )
{
    var self = this;
    var filter = this.mTroop.Filter;
    var troop_data = this.mLocation.Selected.data('entry').Troops;
    var key = [];

    troop_data.forEach(function (_definition) {
        key.push(_definition.Key);
    });

    SQ.call(this.mSQHandle, 'onGetTroopEntries', [ key, filter ], function(_data) {
        if (_data === undefined || _data == null || !jQuery.isArray(_data))
        {
            console.error('ERROR: Failed to get Troops Entries. Invalid data result.');
            return;
        }

        self.addTroopEntriesToPopupDialog(_data, _result.ListScrollContainer, _result.SubTitle);
    });
};


registerScreen("WorldEditorScreen", new WorldEditorScreen());


