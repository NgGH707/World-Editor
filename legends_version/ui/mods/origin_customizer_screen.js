"use strict";

var OriginCustomizer =
{
    Screens: ['General'   , 'Properties'   , 'Factions'   , 'Settlements'   , 'Locations'   , 'Contracts'   ],
    Classes: ['is-general', 'is-properties', 'is-factions', 'is-settlements', 'is-locations', 'is-contracts'],
    Locations: ['Locations', 'Legendary', 'Misc'],
};

var OriginCustomizerScreen = function(_parent)
{
	this.mSQHandle = null;

	// generic containers
	this.mContainer = null;
    this.mDialogContainer = null;

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
        FilterButton       : null,
        ListContainer      : null,
        ListScrollContainer: null,
        FilterType         : 0,
    };

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

    // inputs
    this.mCoordinate = 
    {
        X: {Input: null, Value: 0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, TooltipId: TooltipIdentifier.Assets.BusinessReputation},
        Y: {Input: null, Value: 0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, TooltipId: TooltipIdentifier.Assets.MoralReputation},
    }
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
    this.mAssetProperties =
    {
        // general properties
        General:
        {
            BusinessReputationRate  : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/asset_business_reputation.png', TooltipId: 'origincustomizer.renown'},
            XPMult                  : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/xp_received.png', TooltipId: 'origincustomizer.xp'},
            HitpointsPerHourMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/days_wounded.png', TooltipId: 'origincustomizer.hp'},
            RepairSpeedMult         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/repair_item.png', TooltipId: 'origincustomizer.repair'},
            VisionRadiusMult        : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/vision.png', TooltipId: 'origincustomizer.vision'},
            FootprintVision         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/tracking_disabled.png', TooltipId: 'origincustomizer.footprint'},
            MovementSpeedMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/boot.png', TooltipId: 'origincustomizer.speed'},
            FoodAdditionalDays      : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/asset_daily_food.png', TooltipId: 'origincustomizer.fooddays'},
        },

        // relation properties
        Relation:
        {
            RelationDecayGoodMult   : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/relation_good.png', TooltipId: 'origincustomizer.goodrelation'},
            RelationDecayBadMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/relation_bad.png', TooltipId: 'origincustomizer.badrelation'},
        },

        // contract properties
        Contract:
        {
            NegotiationAnnoyanceMult: {Input: null, Value: 100, ValueMin: 1, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/contract_annoyance.png', TooltipId: 'origincustomizer.negotiation'},
            ContractPaymentMult     : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/contract_payment.png', TooltipId: 'origincustomizer.contractpayment'},
            AdvancePaymentCap       : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scroll_01.png', TooltipId: 'origincustomizer.advancepaymentcap'},
        },

        // scaling properties
        Scaling:
        {
            BrothersScaleMax        : {Input: null, Value:   0, ValueMin: 1, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scaling_max.png', TooltipId: 'origincustomizer.brotherscalemax'},
            BrothersScaleMin        : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/scaling_min.png', TooltipId: 'origincustomizer.brotherscalemin'},
        },

        // recruit properties
        Recruit:
        {
            RosterSizeAdditionalMax : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/recruit_max.png', TooltipId: 'origincustomizer.recruitmax'},
            RosterSizeAdditionalMin : {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 2, IconPath: Path.GFX + 'ui/icons/recruit_min.png', TooltipId: 'origincustomizer.recruitmin'},
            HiringCostMult          : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/hiring_cost.png', TooltipId: 'origincustomizer.hiring'},
            TryoutPriceMult         : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/tryout_cost.png', TooltipId: 'origincustomizer.tryout'},
            DailyWageMult           : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/asset_daily_money.png', TooltipId: 'origincustomizer.wage'},
            TrainingPriceMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/training_cost.png', TooltipId: 'origincustomizer.trainingprice'},
        },

        // economy properties
        Economy:
        {
            TaxidermistPriceMult    : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/crafting_cost.png', TooltipId: 'origincustomizer.craft'},
            BuyPriceMult            : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/buying.png', TooltipId: 'origincustomizer.buying'},
            SellPriceMult           : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/selling.png', TooltipId: 'origincustomizer.selling'},
            BuyPriceTradeMult       : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/buying_player.png', TooltipId: 'origincustomizer.buying_trade'},
            SellPriceTradeMult      : {Input: null, Value: 100, ValueMin: 0, ValueMax: null, Min: 0, Max: 4, IconPath: Path.GFX + 'ui/icons/selling_player.png', TooltipId: 'origincustomizer.selling_trade'},
        },

        // combat properties
        Combat:
        {
            ChampionChanceAdditional: {Input: null, Value:   0, ValueMin: 0, ValueMax: null, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/miniboss.png', TooltipId: 'origincustomizer.champion'},
            ExtraLootChance         : {Input: null, Value:   0, ValueMin: 0, ValueMax:  100, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/bag.png', TooltipId: 'origincustomizer.loot'},
            EquipmentLootChance     : {Input: null, Value:   0, ValueMin: 0, ValueMax:  100, Min: 0, Max: 3, IconPath: Path.GFX + 'ui/icons/grab.png', TooltipId: 'origincustomizer.equipmentloot'},
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
    this.mFactionFixedRelation = {Checkbox: null, Label: null, Name: 'Stop Relation Deterioration', TooltipId: 'origincustomizer.fixedrelation'};

    // sliders
    this.mRosterTier           = {Control: null, Title: null, Min: 1, Max:  10, Value:   2, Step: 1, TooltipId: 'origincustomizer.rostertier', Postfix: ''};
    this.mDifficultyMult       = {Control: null, Title: null, Min: 5, Max: 300, Value: 100, Step: 5, TooltipId: 'origincustomizer.difficultymult', Postfix: '%'};
    this.mFactionRelation      = {Control: null, Title: null, Min: 0, Max: 100, Value:  50, Step: 5, TooltipId: TooltipIdentifier.RelationsScreen.Relations, Postfix: ''};

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

OriginCustomizerScreen.prototype.createDIV = function(_parentDiv)
{
    var self = this;

    // create: containers (init hidden!)
    this.mContainer = $('<div class="origin-customizer-screen ui-control dialog-modal-background display-none opacity-none"/>');
    _parentDiv.append(this.mContainer);

    // create: dialog layout (init hidden!)
    var dialogLayout = $('<div class="l-origin-customizer-dialog-container"/>');
    this.mContainer.append(dialogLayout);

    // create: dialog
    this.mDialogContainer = dialogLayout.createDialog('Origin Customizer', '', '', true, 'dialog-1280-768');

    // create tabs
    var tabContainer = $('<div class="l-tab-container"/>');
    this.mDialogContainer.findDialogTabContainer().append(tabContainer);
    {
        var buttonPanel = $('<div class="tab-button-panel"/>');
        tabContainer.append(buttonPanel);

        // create the buttons to switch to other screens
        var index = 0;
        $.each(this.mSwitchToButton, function(_key, _definition) {
            var buttonLayout = $('<div class="l-tab-button ' + OriginCustomizer.Classes[index] + '"/>');
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
        this.mSaveButton.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.save_button' });
    }


    // create content
    var content = this.mDialogContainer.findDialogContentContainer();
    {
        // create content screens
        $.each(this.mScreens, function(_key, _definition) {
            self.mScreens[_key] = $('<div class="display-none"/>'); // display-none display-block
            content.append(self.mScreens[_key]);
            self['create' + _key + 'PanelDIV'](self.mScreens[_key]);
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

OriginCustomizerScreen.prototype.createContractsPanelDIV = function(_parentDiv) 
{
    var self = this;
};

OriginCustomizerScreen.prototype.createLocationsPanelDIV = function(_parentDiv) 
{
    var self = this;

    // divide into 2 column - 23% and 77%
    var column = this.addColumn(23);
    _parentDiv.append(column);
    {
        var row90 = this.addRow(90, 'with-scroll-tooltip-background');
        column.append(row90);
        {
            var scrollHeader = $('<div class="title-scroll-header-container"/>');
            row90.append(scrollHeader);
            {
                var column88 = this.addColumn(85);
                scrollHeader.append(column88);
                var buttonLayout = $('<div class="location-filter-button is-center"/>');
                column88.append(buttonLayout);
                this.mLocation.FilterButton = buttonLayout.createTextButton("Locations", function() {
                    self.changeLocationfilter();
                }, '', 4);

                var column12 = this.addColumn(15);
                scrollHeader.append(column12);
                var buttonLayout = $('<div class="position-button is-center"/>');
                buttonLayout.css('top', '0.5rem') // css is retarded, fuck it
                column12.append(buttonLayout);
                var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                    //self.onPreviousBannerClicked();
                }, '', 6);
                button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });
            }

            var slotContainer = $('<div class="locations-container"/>');
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
            var buttonLayout = $('<div class="position-button is-center"/>');
            column20.append(buttonLayout);
            var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/center.png', function() {
                //self.onPreviousBannerClicked();
            }, '', 6);
            button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.choosecoords' });

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
        var column50 = this.addColumn(50);
        column.append(column50);
        {

        }

        var column50 = this.addColumn(50);
        column.append(column50);
        {
            var upperHalf = this.addRow(40);
            column50.append(upperHalf);
            {

            }

            var lowerHalf = this.addRow(60, 'with-dirty-scroll-background');
            column50.append(lowerHalf);
            {
                var scrollHeader = $('<div class="title-scroll-header-container"/>');
                lowerHalf.append(scrollHeader);
                {
                    var column = this.addColumn(50, undefined, 'blue');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="location-filter-button is-horizontal-center"/>');
                    buttonLayout.css('bottom', '0.5rem'); // css is retarded, fuck it
                    column.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Defenders", function() {
                        //self.changeLocationfilter();
                    }, '', 4);

                    var column = this.addColumn(10, undefined, 'red');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });

                    var column = this.addColumn(10, undefined, 'red');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });

                    var column = this.addColumn(10, undefined, 'red');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });

                    var column = this.addColumn(10, undefined, 'red');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_wait.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });

                    var column = this.addColumn(10, undefined, 'red');
                    scrollHeader.append(column);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });
                }

                var slotContainer = $('<div class="troops-container"/>');
                lowerHalf.append(slotContainer);
                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(2);
                this.mLocation.Troops = listContainer.findListScrollContainer();
            }
        }
    }
};

OriginCustomizerScreen.prototype.createSettlementsPanelDIV = function(_parentDiv) 
{
    var self = this;

    // divide into 2 column - 23% and 77%
    var column = this.addColumn(23, 'with-dialog-background');
    column.css('padding-top', '0.6rem');
    _parentDiv.append(column);
    {
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
                        var column75 = this.addColumn(75);
                        row30.append(column75);
                        var imageContainer = $('<div class="s-image-container"/>');
                        column75.append(imageContainer);

                        this.mSettlement.Image = imageContainer.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');

                        var column25 = this.addColumn(25);
                        row30.append(column25);

                        var buttonRow = $('<div class="s-button-row"/>');
                        column25.append(buttonRow);
                        var buttonLayout = $('<div class="s-image-button-center"/>');
                        buttonRow.append(buttonLayout);
                        var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_retract.png', function() {
                            //self.onPreviousBannerClicked();
                        }, '', 6);

                        var buttonRow = $('<div class="s-button-row"/>');
                        column25.append(buttonRow);
                        var buttonLayout = $('<div class="s-image-button-center"/>');
                        buttonRow.append(buttonLayout);
                        var button = buttonLayout.createImageButton(Path.GFX + 'ui/skin/icon_expand.png', function() {
                            //self.onPreviousBannerClicked();
                        }, '', 6);
                    }

                    var row35 = this.addRow(35);
                    leftHalf.append(row35);
                    {
                        var column50 = this.addColumn(50);
                        row35.append(column50);
                        var row = $('<div class="row"/>');
                        column50.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Faction</div>');
                        title.css('text-align', 'center');
                        row.append(title);

                        var ownerContainer = $('<div class="faction-landlord-container"/>');
                        column50.append(ownerContainer);
                        this.mSettlement.FactionBanner = ownerContainer.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');


                        var column50 = this.addColumn(50);
                        row35.append(column50);
                        var row = $('<div class="row"/>');
                        column50.append(row);
                        var title = $('<div class="title title-font-big font-color-title">Owner</div>');
                        title.css('text-align', 'center');
                        row.append(title);

                        this.mSettlement.OwnerBanner = $('<div class="faction-landlord-container"/>');
                        column50.append(this.mSettlement.OwnerBanner);
                        var image = this.mSettlement.OwnerBanner.createImage(null, function(_image) {
                            _image.fitImageToParent(0, 0);
                        }, null, '');
                    }

                    var row10 = this.addRow(10);
                    leftHalf.append(row10);
                    {
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
                    var row = $('<div class="faction-button-row"></div>');
                    row.css('margin-top', '2.0rem');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Shut Down", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    var row = $('<div class="faction-button-row"></div>');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Change Type", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);


                    var row = $('<div class="faction-button-row"></div>');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Send Caravan", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    
                    var row = $('<div class="faction-button-row"></div>');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Send Mercenary", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    
                    var row = $('<div class="faction-button-row"></div>');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Refresh Shops", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    
                    var row = $('<div class="faction-button-row"></div>');
                    rightHalf.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Refresh Roster", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);
                }
            }

            var row25 = this.addRow(25, 'with-small-dialog-background');
            column78.append(row25);
            {
                var buildingsContainer = $('<div class="s-building-container"/>');
                row25.append(buildingsContainer);

                this.mSettlement.Buildings = [];
                for (var i = 0; i < 4; i++) {
                    this.createSettlementBuildingSlot(i, buildingsContainer);
                }
            }
        }

        var column22 = this.addColumn(22);
        column.append(column22);
        {
            var row = this.addRow(35, 'with-scroll-tooltip-background');
            column22.append(row);
            {
                var scrollHeader = $('<div class="title-scroll-header-container"/>');
                row.append(scrollHeader);
                {
                    var column80 = this.addColumn(80);
                    scrollHeader.append(column80);
                    var buttonLayout = $('<div class="s-button-center"/>');
                    column80.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Situations", function ()
                    {
                        //self.switchBetweenSituationsAttachments();
                    }, '', 7);

                    var column20 = this.addColumn(20);
                    scrollHeader.append(column20);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column20.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });
                }
                

                var slotContainer = $('<div class="s-attach-container"/>');
                slotContainer.css('height', '16.0rem');
                row.append(slotContainer);

                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(1);
                this.mSettlement.Situations = listContainer.findListScrollContainer();
            }

            var row = this.addRow(65, 'with-scroll-tooltip-background');
            column22.append(row);
            {
                var scrollHeader = $('<div class="title-scroll-header-container"/>');
                row.append(scrollHeader);
                {  
                    var column80 = this.addColumn(80);
                    scrollHeader.append(column80);
                    var buttonLayout = $('<div class="s-button-center"/>');
                    column80.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Attachments", function ()
                    {
                        //self.switchBetweenSituationsAttachments();
                    }, '', 7);

                    var column20 = this.addColumn(20);
                    scrollHeader.append(column20);
                    var buttonLayout = $('<div class="position-button is-center"/>');
                    column20.append(buttonLayout);
                    var button = buttonLayout.createImageButton(Path.GFX + 'ui/icons/add_entry.png', function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                    button.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.addnewentry' });
                }

                var slotContainer = $('<div class="s-attach-container"/>');
                slotContainer.css('height', '33.0rem');
                row.append(slotContainer);

                var listContainerLayout = $('<div class="l-list-container"/>');
                slotContainer.append(listContainerLayout);
                var listContainer = listContainerLayout.createList(1);
                this.mSettlement.Attachments = listContainer.findListScrollContainer();
            }
        }
    }
};

OriginCustomizerScreen.prototype.createFactionsPanelDIV = function(_parentDiv) 
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
                    var row = $('<div class="row"/>');
                    row90.append(row);
                    var title = $('<div class="title title-font-big font-color-title">Faction Name</div>');
                    row.append(title);
                    var inputLayout = $('<div class="l-input-big"/>');
                    row.append(inputLayout);
                    this.mFaction.Name = inputLayout.createInput('', 0, 40, 1, function (_input) {
                        
                    }, 'title-font-big font-bold font-color-brother-name');
                    
                    this.createSliderControlDIV(this.mFactionRelation, 'Relation', row90);
                    this.createCheckBoxControlDIV(this.mFactionFixedRelation, row90);

                    /*this.mFaction.LandlordContainer = $('<div class="row"/>');
                    row90.append(this.mFaction.LandlordContainer);
                    var title = $('<div class="title title-font-big font-color-title">Landlord</div>');
                    this.mFaction.LandlordContainer.append(title);

                    var landlordContainer = $('<div class="faction-landlord-container"/>');
                    this.mFaction.LandlordContainer.append(landlordContainer);
                    this.mFaction.Landlord = landlordContainer.createImage(null, function(_image) {
                        _image.fitImageToParent(0, 0);
                    }, null, '');*/
                }
                

                var row10 = this.addRow(10);
                column.append(row10);
                {
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
                    var prevButtonLayout = $('<div class="faction-banner-button"/>');
                    leftColumn.append(prevButtonLayout);
                    this.mFaction.PrevButton = prevButtonLayout.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);

                    var midColumn = this.addColumn(40);
                    row40.append(midColumn);
                    var bannerContainer = $('<div class="faction-banner-container"/>');
                    midColumn.append(bannerContainer);
                    this.mFaction.Banner = bannerContainer.createImage(null, function(_image) {
                        _image.centerImageWithinParent(0, 0, 1.0);
                        _image.removeClass('display-none').addClass('display-block');
                    }, null, 'display-none');

                    var rightColumn = this.addColumn(30);
                    row40.append(rightColumn);
                    var nextButtonLayout = $('<div class="faction-banner-button"/>');
                    rightColumn.append(nextButtonLayout);
                    this.mFaction.NextButton = nextButtonLayout.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);
                }

                var row60 = this.addRow(60, 'with-scroll-tooltip-background');
                column.append(row60);
                {
                    // 1st button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("View Settlements", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    // 2nd button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("View Alliance", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    // 3rd button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Despawn Troops", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    // 4th button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Refresh Roster", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    // 5th button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Refresh Actions", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);

                    // 6th button
                    var row = $('<div class="faction-button-row"></div>');
                    row60.append(row);
                    var buttonLayout = $('<div class="f-button-center"></div>');
                    row.append(buttonLayout);
                    var button = buttonLayout.createTextButton("Refresh Contracts", function ()
                    {
                        //self.notifyBackendNewCampaignButtonPressed();
                    }, '', 4);
                }
            }
        }

        // contract panel
        var row20 = this.addRow(20, 'with-small-dialog-background');
        column60.append(row20);
        {
            this.mFaction.Contracts = $('<div class="f-contracts-container"/>');
            row20.append(this.mFaction.Contracts);
        }
    }
};

OriginCustomizerScreen.prototype.createPropertiesPanelDIV = function(_parentDiv) 
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

OriginCustomizerScreen.prototype.createGeneralPanelDIV = function (_parentDiv) 
{
    var self = this;

    var leftColumn = $('<div class="column-left"/>');
    _parentDiv.append(leftColumn);
    {
        var subLeftColumn = this.addColumn(26);
        leftColumn.append(subLeftColumn);
        {
            var originImageContainer = $('<div class="origin-image-container"/>');
            subLeftColumn.append(originImageContainer);

            this.mScenario.Image = originImageContainer.createImage(Path.GFX + 'ui/events/event_99.png', function(_image) {
                _image.removeClass('opacity-none');
            }, null, 'opacity-none');
            this.mScenario.Image.bindTooltip({ contentType: 'ui-element', elementId: 'origincustomizer.choose_origin' });
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
            var row = $('<div class="row"/>');
            subRightColumn.append(row);
            var title = $('<div class="title title-font-big font-color-title">Company Avatar</div>');
            title.css('margin-bottom', '1.0rem');
            row.append(title);

            var avatarChangerContainer = $('<div class="avatar-changer-container"/>');
            row.append(avatarChangerContainer);
            {
                var buttonColumn = this.addColumn(35);
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

                var avatarColumn = this.addColumn(65, 'with-small-dialog-background');
                avatarChangerContainer.append(avatarColumn);
                {
                    var avatarContainer = $('<div class="avatar-container"/>');
                    avatarColumn.append(avatarContainer);

                    var left = this.addColumn(25);
                    avatarContainer.append(left);
                    var prevAvatar = $('<div class="avatar-button"/>');
                    left.append(prevAvatar);
                    this.mAvatar.PrevButton = prevAvatar.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function() {
                        //self.onPreviousBannerClicked();
                    }, '', 6);

                    var mid = this.addColumn(50);
                    avatarContainer.append(mid);
                    var avatarImage = $('<div class="avatar-image-container"/>');
                    mid.append(avatarImage);
                    this.mAvatar.Image = avatarImage.createImage(Path.GFX + 'ui/icons/legends_party.png', function(_image) {
                        _image.centerImageWithinParent(0, 0, 1.0);
                        _image.removeClass('display-none').addClass('display-block');
                    }, null, 'display-none');

                    var right = this.addColumn(25);
                    avatarContainer.append(right);
                    var nextAvatar = $('<div class="avatar-button"/>');
                    right.append(nextAvatar);
                    this.mAvatar.NextButton = nextAvatar.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function() {
                        //self.onNextBannerClicked();
                    }, '', 6);
                }
            }


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
            var configureOptionsContainer = $('<div class="configure-container"/>');
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

    var rightColumn = $('<div class="column-right"/>');
    _parentDiv.append(rightColumn);
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

        // rostier slider
        this.createSliderControlDIV(this.mRosterTier, 'Roster Tier', rightColumn);
    }
};

OriginCustomizerScreen.prototype.createRadioControlDIV = function(_definition, _parentDiv, _index, _name, _result) 
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

OriginCustomizerScreen.prototype.createCheckBoxControlDIV = function(_definition, _parentDiv) 
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

OriginCustomizerScreen.prototype.createSliderControlDIV = function(_definition, _title, _parentDiv) 
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

OriginCustomizerScreen.prototype.createInputDIV = function(_key, _definition, _parentDiv)
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

OriginCustomizerScreen.prototype.destroyDIV = function()
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

OriginCustomizerScreen.prototype.isConnected = function()
{
    return this.mSQHandle !== null;
};

OriginCustomizerScreen.prototype.onConnection = function(_handle)
{
    this.mSQHandle = _handle;
    this.register($('.root-screen'));
};

OriginCustomizerScreen.prototype.onDisconnection = function()
{
    this.mSQHandle = null;
    this.unregister();
};

OriginCustomizerScreen.prototype.getModule = function(_name)
{
    switch(_name)
    {
        default: return null;
    }
};

OriginCustomizerScreen.prototype.getModules = function()
{
    return [];
};

OriginCustomizerScreen.prototype.bindTooltips = function()
{
};

OriginCustomizerScreen.prototype.unbindTooltips = function()
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

OriginCustomizerScreen.prototype.register = function(_parentDiv)
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

OriginCustomizerScreen.prototype.unregister = function()
{
    console.log('OriginCustomizerScreen::UNREGISTER');

    if (this.mContainer === null)
    {
        console.error('ERROR: Failed to unregister Origin Customizer Screen. Reason: Origin Customizer Screen is not initialized.');
        return;
    }

    this.destroy();
};

OriginCustomizerScreen.prototype.isRegistered = function()
{
    if (this.mContainer !== null)
    {
        return this.mContainer.parent().length !== 0;
    }

    return false;
};

OriginCustomizerScreen.prototype.show = function(_data)
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

OriginCustomizerScreen.prototype.hide = function(_withSlideAnimation)
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

OriginCustomizerScreen.prototype.switchScreen = function(_screen)
{
    $.each(this.mScreens, function (_key, _definition) {
        if (_key === _screen)
            _definition.removeClass('display-none').addClass('display-block');
        else
            _definition.removeClass('display-block').addClass('display-none');
    });

    $.each(this.mSwitchToButton, function (_key, _definition) {
        if (_key === _screen)
            _definition.enableButton(false);
        else
            _definition.enableButton(true);
    });

    this.mLastScreen = _screen;
};

OriginCustomizerScreen.prototype.isVisible = function()
{
    return this.mIsVisible;
};

OriginCustomizerScreen.prototype.addColumn = function(_width, _class, _color)
{
    if (_class === undefined)
        _class = '';
    else
        _class = ' ' + _class;

    var result = $('<div class="custom-column' + _class + '"/>');
    result.css('width', _width + '%');

    if (_color !== undefined)
        result.css('border', '1px solid ' + _color);

    return result;
}

OriginCustomizerScreen.prototype.addRow = function(_height, _class, _color)
{
    if (_class === undefined)
        _class = '';
    else
        _class = ' ' + _class;

    var result = $('<div class="custom-row' + _class + '"/>');
    result.css('height', _height + '%');

    if (_color !== undefined)
        result.css('border', '1px solid ' + _color);

    return result;
}

OriginCustomizerScreen.prototype.loadFromData = function(_data) 
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

OriginCustomizerScreen.prototype.notifyBackendOnConnected = function()
{
    SQ.call(this.mSQHandle, 'onScreenConnected');
};

OriginCustomizerScreen.prototype.notifyBackendOnDisconnected = function()
{
    SQ.call(this.mSQHandle, 'onScreenDisconnected');
};

OriginCustomizerScreen.prototype.notifyBackendOnShown = function()
{
    SQ.call(this.mSQHandle, 'onScreenShown');
};

OriginCustomizerScreen.prototype.notifyBackendOnHidden = function()
{
    SQ.call(this.mSQHandle, 'onScreenHidden');
};

OriginCustomizerScreen.prototype.notifyBackendOnAnimating = function()
{
    SQ.call(this.mSQHandle, 'onScreenAnimating');
};

OriginCustomizerScreen.prototype.notifyBackendPopupDialogIsVisible = function (_visible)
{
    SQ.call(this.mSQHandle, 'onPopupDialogIsVisible', [_visible]);
};

OriginCustomizerScreen.prototype.notifyBackendCloseButtonPressed = function()
{
    SQ.call(this.mSQHandle, 'onCloseButtonPressed');
};


registerScreen("OriginCustomizerScreen", new OriginCustomizerScreen());


