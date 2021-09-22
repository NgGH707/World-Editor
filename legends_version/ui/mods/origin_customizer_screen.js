/*
 *  @Project:		Battle Brothers
 *	@Company:		Overhype Studios
 *
 *	@Copyright:		(c) Overhype Studios | 2015
 *
 *  @Author:		Overhype Studios
 *  @Date:			03.03.2015
 *  @Description:	New Campaign Menu Module JS
 */
"use strict";

var OriginCustomizerScreen = function(_parent)
{
	this.mSQHandle = null;

	// event listener
	this.mEventListener = null;

	// generic containers
	this.mContainer = null;
	this.mDialogContainer = null;

	this.mOriginPanel = null;
	this.mDifficultyPanel = null;
	this.mFirstConfigPanel = null;
	this.mSecondConfigPanel = null;
	this.mChooseOriginPanel = null;

	this.mChooseOriginButton = null;
	this.mOriginImage = null;
	this.mCompanyName = null;

	this.mAcceptBannerButton = null;
	this.mPrevBannerButton = null;
	this.mNextBannerButton = null;
	this.mBannerImage = null;

	// buttons
	this.mStartButton = null;
	this.mCancelButton = null;
	this.mDoneButton = null;

	// banners
	this.mBanners = null;
	this.mCurrentBannerIndex = 0;
	this.mSelectedBannerIndex = 0;

	// difficulty
	this.mDifficulty = 0;
	this.mEconomicDifficulty = 0;

	// scenario
	this.mScenarioCurentIndex = 0;
	this.mScenarios = null;
	this.mScenarioContainer = null;
	this.mScenarioScrollContainer = null;

	// controls
	this.mLegendAllBlueprintsCheckbox = null;
	this.mLegendAllBlueprintsCheckboxLabel = null;

	this.mDifficultyEasyCheckbox = null;
	this.mDifficultyEasyLabel = null;
	this.mDifficultyNormalCheckbox = null;
	this.mDifficultyNormalLabel = null;
	this.mDifficultyHardCheckbox = null;
	this.mDifficultyHardLabel = null;
	this.mDifficultyLegendaryCheckbox = null;
	this.mDifficultyLegendaryLabel = null;

	this.mEconomicDifficultyEasyCheckbox = null;
	this.mEconomicDifficultyEasyLabel = null;
	this.mEconomicDifficultyNormalCheckbox = null;
	this.mEconomicDifficultyNormalLabel = null;
	this.mEconomicDifficultyHardCheckbox = null;
	this.mEconomicDifficultyHardLabel = null;
	this.mEconomicDifficultyLegendaryCheckbox = null;
	this.mEconomicDifficultyLegendaryLabel = null;

	// origin config
	this.mOriginOptions = {
		Tier: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.tier',
			Min: 0,
			Max: 6,
			Value: 0,
			Step: 1
		},
		Stash: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.stash',
			Min: 100,
			Max: 400,
			Value: 100,
			Step: 2
		},
		XpMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.xp',
			Min: 1,
			Max: 0,
			Value: 0,
			Step: 5
		},
		HiringMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.hiring',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		WageMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.wage',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		SellingMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.selling',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		BuyingMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.buying',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		BonusLoot: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.loot',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		BonusChampion: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.champion',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5,
		},
		BonusSpeed: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.speed',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		ContractPayment: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.contractpayment',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		VisionRadius: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.vision',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		HitpointsPerHourMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.hp',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		RepairSpeedMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.repair',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		BusinessReputationRate: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.renown',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		NegotiationAnnoyanceMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.negotiation',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		RosterSizeAdditionalMin: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.recruitmin',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 1
		},
		RosterSizeAdditionalMax: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.recruitmax',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 1
		},
		TaxidermistPriceMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.craft',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		TryoutPriceMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.tryout',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		RelationDecayBadMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.goodrelation',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},
		RelationDecayGoodMult: {
			Control: null,
			Title: null,
			OptionsKey: 'origin.badrelation',
			Min: 0,
			Max: 0,
			Value: 0,
			Step: 5
		},	
	};

	this.mOriginConfigOpts = {};

	// generics
	this.mIsVisible = false;
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

OriginCustomizerScreen.prototype.create = function (_parentDiv) 
{
	this.createDIV(_parentDiv);
	this.bindTooltips();
};

OriginCustomizerScreen.prototype.destroy = function () 
{
	this.unbindTooltips();
	this.destroyDIV();
};


OriginCustomizerScreen.prototype.register = function (_parentDiv) 
{
	console.log('OriginCustomizerScreen::REGISTER');

	if (this.mContainer !== null) 
	{
		console.error('ERROR: Failed to register New Campaign Menu Module. Reason: New Campaign Menu Module is already initialized.');
		return;
	}

	if (_parentDiv !== null && typeof (_parentDiv) == 'object') 
	{
		this.create(_parentDiv);
	}
};

OriginCustomizerScreen.prototype.unregister = function () 
{
	console.log('OriginCustomizerScreen::UNREGISTER');

	if (this.mContainer === null) 
	{
		console.error('ERROR: Failed to unregister New Campaign Menu Module. Reason: New Campaign Menu Module is not initialized.');
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

OriginCustomizerScreen.prototype.show = function ( _data ) 
{
	// reset panels
	this.loadFromData(_data);

	this.mOriginPanel.addClass('display-block').removeClass('display-none');
	this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
	this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
	this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
	this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
	this.mStartButton.changeButtonText("Next");
	this.mCancelButton.changeButtonText("Previous");
	this.mDoneButton.removeClass('display-none').addClass('display-block');

	var self = this;

	var offset = -(this.mContainer.parent().width() + this.mContainer.width());
	this.mContainer.css({
		'left': offset
	});
	this.mContainer.velocity("finish", true).velocity({
		opacity: 1,
		left: '0',
		right: '0'
	}, {
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

OriginCustomizerScreen.prototype.hide = function () 
{
	var self = this;
	var offset = -(this.mContainer.parent().width() + this.mContainer.width());
	this.mContainer.velocity("finish", true).velocity({
		opacity: 0,
		left: offset
	}, {
		duration: Constants.SCREEN_SLIDE_IN_OUT_DELAY,
		easing: 'swing',
		begin: function () {
			self.notifyBackendOnAnimating();
		},
		complete: function () {
			self.mIsVisible = false;
			$(this).removeClass('display-block').addClass('display-none');
			self.notifyBackendOnHidden();
		}
	});
};

OriginCustomizerScreen.prototype.isVisible = function () 
{
	return this.mIsVisible;
};

OriginCustomizerScreen.prototype.destroyDIV = function () {
	// controls
	this.mDifficultyEasyCheckbox.remove();
	this.mDifficultyEasyCheckbox = null;
	this.mDifficultyEasyLabel.remove();
	this.mDifficultyEasyLabel = null;
	this.mDifficultyNormalCheckbox.remove();
	this.mDifficultyNormalCheckbox = null;
	this.mDifficultyNormalLabel.remove();
	this.mDifficultyNormalLabel = null;
	this.mDifficultyHardCheckbox.remove();
	this.mDifficultyHardCheckbox = null;
	this.mDifficultyHardLabel.remove();
	this.mDifficultyHardLabel = null;
	this.mDifficultyLegendaryCheckbox.remove();
	this.mDifficultyLegendaryCheckbox = null;
	this.mDifficultyLegendaryLabel.remove();
	this.mDifficultyLegendaryLabel = null;
	this.mCompanyName.remove();
	this.mCompanyName = null;

	this.mPrevBannerButton.remove();
	this.mPrevBannerButton = null;
	this.mNextBannerButton.remove();
	this.mNextBannerButton = null;
	this.mAcceptBannerButton.remove();
	this.mAcceptBannerButton = null;
	this.mBannerImage.remove();
	this.mBannerImage = null;

	this.mOriginImage.remove();
	this.mOriginImage = null;

	// buttons
	this.mStartButton.remove();
	this.mStartButton = null;
	this.mCancelButton.remove();
	this.mCancelButton = null;
	this.mDoneButton.remove();
	this.mDoneButton = null;

	this.mScenarioScrollContainer.empty();
	this.mScenarioScrollContainer = null;
	this.mScenarioContainer.destroyList();
	this.mScenarioContainer.remove();
	this.mScenarioContainer = null;

	this.mOriginPanel.empty();
	this.mOriginPanel.remove();
	this.mOriginPanel = null;

	this.mDifficultyPanel.empty();
	this.mDifficultyPanel.remove();
	this.mDifficultyPanel = null;

	this.mFirstConfigPanel.empty();
	this.mFirstConfigPanel.remove();
	this.mFirstConfigPanel = null;

	this.mSecondConfigPanel.empty();
	this.mSecondConfigPanel.remove();
	this.mSecondConfigPanel = null;

	this.mChooseOriginPanel.empty();
	this.mChooseOriginPanel.remove();
	this.mChooseOriginPanel = null;

	this.mDialogContainer.empty();
	this.mDialogContainer.remove();
	this.mDialogContainer = null;

	this.mContainer.empty();
	this.mContainer.remove();
	this.mContainer = null;
};

OriginCustomizerScreen.prototype.createDIV = function (_parentDiv) {
	var self = this;

	// create: dialog container
	this.mContainer = $('<div class="origin-customizer-screen display-none"/>');
	_parentDiv.append(this.mContainer);
	this.mDialogContainer = this.mContainer.createDialog('Origin Customizer', null, null , false, 'dialog-800-720-2');

	// create: content
	var contentContainer = this.mDialogContainer.findDialogContentContainer();

	this.mOriginImage = $('<div class="origin-customizer-origin-button"/>');
	this.mDialogContainer.append(this.mOriginImage);
	this.mOriginImage.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function () {
		self.switchToOriginScreen();
	}, 'display-block', 150);

	this.mOriginPanel = $('<div class="display-block"/>');
	contentContainer.append(this.mOriginPanel); 
	{
		var leftColumn = $('<div class="below-origin-button-column"/>');
		this.mOriginPanel.append(leftColumn);
		var rightColumn = $('<div class="column"/>');
		this.mOriginPanel.append(rightColumn);

		// name
		var row = $('<div class="row" />');
		leftColumn.append(row);
		var title = $('<div class="title title-font-big font-color-title">Company Name</div>');
		row.append(title);

		var inputLayout = $('<div class="l-input"/>');
		row.append(inputLayout);
		this.mCompanyName = inputLayout.createInput('Battle Brothers', 0, 32, 1, function (_input) {
			if (self.mDoneButton !== null) self.mDoneButton.enableButton(_input.getInputTextLength() >= 1);
		}, 'title-font-big font-bold font-color-brother-name');
		this.mCompanyName.setInputText('Battle Brothers');
		this.createSliderControlDIV(this.mOriginOptions.Tier, 'Roster Tier', leftColumn);
		this.createSliderControlDIV(this.mOriginOptions.Stash, 'Stash', leftColumn);

		// banner
		var row = $('<div class="row" />');
		rightColumn.append(row);
		//var title = $('<div class="title title-font-big font-color-title">Banner</div>');
		//row.append(title);

		var bannerContainer = $('<div class="banner-container" />');
		row.append(bannerContainer);

		var table = $('<table width="100%" height="100%"><tr><td width="10%"><div class="l-button prev-banner-button" /></td><td width="80%" class="banner-image-container"></td><td width="10%"><div class="l-button next-banner-button" /></td></tr><tr><td></td><td width="100%"><div class="l-button accept-banner-button" /></td><td></td></tr></table>');
		bannerContainer.append(table);

		var prevBanner = table.find('.prev-banner-button:first');
		this.mPrevBannerButton = prevBanner.createImageButton(Path.GFX + Asset.BUTTON_PREVIOUS_BANNER, function () {
			self.onPreviousBannerClicked();
		}, '', 6);

		var nextBanner = table.find('.next-banner-button:first');
		this.mNextBannerButton = nextBanner.createImageButton(Path.GFX + Asset.BUTTON_NEXT_BANNER, function () {
			self.onNextBannerClicked();
		}, '', 6);

		var bannerImage = table.find('.banner-image-container:first');
		this.mBannerImage = bannerImage.createImage(Path.GFX + 'ui/banners/banner_01.png', function (_image) {
			_image.removeClass('display-none').addClass('display-block');
			//_image.centerImageWithinParent();
		}, null, 'display-none banner-image');

		var acceptBanner = table.find('.accept-banner-button:first');
		this.mAcceptBannerButton = acceptBanner.createImageButton(Path.GFX + Asset.BUTTON_END_TURN, function () {
			self.onAcceptBannerClicked();
		}, '', 6);

		//blueprint
		var row = $('<div class="row"></div>');
		rightColumn.append(row);
		var control = $('<div class="control"/>');
		row.append(control);
		this.mLegendAllBlueprintsCheckbox = $('<input type="checkbox" id="cb-legendallblueprints"/>');
		control.append(this.mLegendAllBlueprintsCheckbox);
		this.mLegendAllBlueprintsCheckboxLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-legendallblueprints">All Crafting Recipes Unlocked</label>');
		control.append(this.mLegendAllBlueprintsCheckboxLabel);
		this.mLegendAllBlueprintsCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
	}

	this.mDifficultyPanel = $('<div class="display-none"/>');
	contentContainer.append(this.mDifficultyPanel); {
		var leftColumn = $('<div class="column"/>');
		this.mDifficultyPanel.append(leftColumn);
		var rightColumn = $('<div class="column"/>');
		this.mDifficultyPanel.append(rightColumn);

		// combat difficulty
		var row = $('<div class="row" />');
		rightColumn.append(row);
		var title = $('<div class="title title-font-big font-color-title">Combat Difficulty</div>');
		row.append(title);

		var easyDifficultyControl = $('<div class="control"></div>');
		row.append(easyDifficultyControl);
		this.mDifficultyEasyCheckbox = $('<input type="radio" id="cb-difficulty-easy" name="difficulty" checked />');
		easyDifficultyControl.append(this.mDifficultyEasyCheckbox);
		this.mDifficultyEasyLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-difficulty-easy">Beginner</label>');
		easyDifficultyControl.append(this.mDifficultyEasyLabel);
		this.mDifficultyEasyCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mDifficultyEasyCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mDifficulty = 0;
		});

		var normalDifficultyControl = $('<div class="control"></div>');
		row.append(normalDifficultyControl);
		this.mDifficultyNormalCheckbox = $('<input type="radio" id="cb-difficulty-normal" name="difficulty" />');
		normalDifficultyControl.append(this.mDifficultyNormalCheckbox);
		this.mDifficultyNormalLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-difficulty-normal">Veteran</label>');
		normalDifficultyControl.append(this.mDifficultyNormalLabel);
		this.mDifficultyNormalCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mDifficultyNormalCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mDifficulty = 1;
		});

		var hardDifficultyControl = $('<div class="control"></div>');
		row.append(hardDifficultyControl);
		this.mDifficultyHardCheckbox = $('<input type="radio" id="cb-difficulty-hard" name="difficulty" />');
		hardDifficultyControl.append(this.mDifficultyHardCheckbox);
		this.mDifficultyHardLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-difficulty-hard">Expert</label>');
		hardDifficultyControl.append(this.mDifficultyHardLabel);
		this.mDifficultyHardCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mDifficultyHardCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mDifficulty = 2;
		});

		var LegendaryDifficultyControl = $('<div class="control"></div>');
		row.append(LegendaryDifficultyControl);
		this.mDifficultyLegendaryCheckbox = $('<input type="radio" id="cb-difficulty-Legendary" name="difficulty" />');
		LegendaryDifficultyControl.append(this.mDifficultyLegendaryCheckbox);
		this.mDifficultyLegendaryLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-difficulty-Legendary">Legendary</label>');
		LegendaryDifficultyControl.append(this.mDifficultyLegendaryLabel);
		this.mDifficultyLegendaryCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mDifficultyLegendaryCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mDifficulty = 3;
		});

		// economic difficulty
		var row = $('<div class="row" />');
		rightColumn.append(row);
		var title = $('<div class="title title-font-big font-color-title">Economic Difficulty</div>');
		row.append(title);

		var easyDifficultyControl = $('<div class="control"></div>');
		row.append(easyDifficultyControl);
		this.mEconomicDifficultyEasyCheckbox = $('<input type="radio" id="cb-economic-difficulty-easy" name="economic-difficulty" checked />');
		easyDifficultyControl.append(this.mEconomicDifficultyEasyCheckbox);
		this.mEconomicDifficultyEasyLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-economic-difficulty-easy">Beginner</label>');
		easyDifficultyControl.append(this.mEconomicDifficultyEasyLabel);
		this.mEconomicDifficultyEasyCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mEconomicDifficultyEasyCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mEconomicDifficulty = 0;
		});

		var normalDifficultyControl = $('<div class="control"></div>');
		row.append(normalDifficultyControl);
		this.mEconomicDifficultyNormalCheckbox = $('<input type="radio" id="cb-economic-difficulty-normal" name="economic-difficulty" />');
		normalDifficultyControl.append(this.mEconomicDifficultyNormalCheckbox);
		this.mEconomicDifficultyNormalLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-economic-difficulty-normal">Veteran</label>');
		normalDifficultyControl.append(this.mEconomicDifficultyNormalLabel);
		this.mEconomicDifficultyNormalCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mEconomicDifficultyNormalCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mEconomicDifficulty = 1;
		});

		var hardDifficultyControl = $('<div class="control"></div>');
		row.append(hardDifficultyControl);
		this.mEconomicDifficultyHardCheckbox = $('<input type="radio" id="cb-economic-difficulty-hard" name="economic-difficulty" />');
		hardDifficultyControl.append(this.mEconomicDifficultyHardCheckbox);
		this.mEconomicDifficultyHardLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-economic-difficulty-hard">Expert</label>');
		hardDifficultyControl.append(this.mEconomicDifficultyHardLabel);
		this.mEconomicDifficultyHardCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mEconomicDifficultyHardCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mEconomicDifficulty = 2;
		});

		var LegendaryDifficultyControl = $('<div class="control"></div>');
		row.append(LegendaryDifficultyControl);
		this.mEconomicDifficultyLegendaryCheckbox = $('<input type="radio" id="cb-economic-difficulty-Legendary" name="economic-difficulty" />');
		LegendaryDifficultyControl.append(this.mEconomicDifficultyLegendaryCheckbox);
		this.mEconomicDifficultyLegendaryLabel = $('<label class="text-font-normal font-color-subtitle" for="cb-economic-difficulty-Legendary">Legendary</label>');
		LegendaryDifficultyControl.append(this.mEconomicDifficultyLegendaryLabel);
		this.mEconomicDifficultyLegendaryCheckbox.iCheck({
			checkboxClass: 'icheckbox_flat-orange',
			radioClass: 'iradio_flat-orange',
			increaseArea: '30%'
		});
		this.mEconomicDifficultyLegendaryCheckbox.on('ifChecked', null, this, function (_event) {
			var self = _event.data;
			self.mEconomicDifficulty = 3;
		});
	}

	this.mFirstConfigPanel = $('<div class="display-none"/>');
	contentContainer.append(this.mFirstConfigPanel);
	this.buildFirstConfigPage();

	this.mSecondConfigPanel = $('<div class="display-none"/>');
	contentContainer.append(this.mSecondConfigPanel);
	this.buildSecondConfigPage();

	this.mChooseOriginPanel = $('<div class="display-none"/>');
	contentContainer.append(this.mChooseOriginPanel); 
	{
		var leftColumn = $('<div class="column2"/>');
		this.mChooseOriginPanel.append(leftColumn);
		var rightColumn = $('<div class="column3"/>');
		this.mChooseOriginPanel.append(rightColumn);

		var listContainerLayout = $('<div class="l-list-container"/>');
		this.mChooseOriginPanel.append(listContainerLayout);
		this.mScenarioContainer = listContainerLayout.createList(18);
		this.mScenarioScrollContainer = this.mScenarioContainer.findListScrollContainer();

		var row = $('<div class="row3 text-font-medium font-color-description" />');
		rightColumn.append(row);
		this.mScenariosDesc = row;

		this.mScenariosDifficulty = row.createImage('', function (_image) {
			_image.removeClass('display-none').addClass('display-block');
		}, null, 'display-none difficulty');
		rightColumn.append(this.mScenariosDifficulty);
	}

	// create footer button bar
	var footerButtonBar = $('<div class="l-button-bar"></div>');
	this.mDialogContainer.findDialogFooterContainer().append(footerButtonBar);

	var layout = $('<div class="l-done-button"/>');
	footerButtonBar.append(layout);
	this.mDoneButton = layout.createTextButton("Done", function () {
		self.notifyBackendCloseButtonPressed();
	}, '', 1);

	var layout = $('<div class="l-ok-button"/>');
	footerButtonBar.append(layout);
	this.mStartButton = layout.createTextButton("Next", function () {
		self.advanceScreen();
	}, '', 1);

	layout = $('<div class="l-cancel-button"/>');
	footerButtonBar.append(layout);
	this.mCancelButton = layout.createTextButton("Previous", function () {
		self.returnScreen();
	}, '', 1);

	this.mIsVisible = false;
};

OriginCustomizerScreen.prototype.buildFirstConfigPage = function () {
	var leftColumn = $('<div class="column"></div>');
	this.mFirstConfigPanel.append(leftColumn);
	var rightColumn = $('<div class="column"></div>');
	this.mFirstConfigPanel.append(rightColumn);

	this.createSliderControlDIV(this.mOriginOptions.HiringMult, 'Hiring Cost', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.TryoutPriceMult, 'Tryout Price', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.WageMult, 'Daily Wage', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.RosterSizeAdditionalMax, 'Maximum Recruits', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.RosterSizeAdditionalMin, 'Minimum Recruits', leftColumn);

	this.createSliderControlDIV(this.mOriginOptions.SellingMult, 'Selling Price', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.BuyingMult, 'Buying Price', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.TaxidermistPriceMult, 'Taxidermist Cost', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.ContractPayment, 'Contract Payment', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.NegotiationAnnoyanceMult, 'Negotiation Annoyance', rightColumn);
};

OriginCustomizerScreen.prototype.buildSecondConfigPage = function () {
	var leftColumn = $('<div class="column"></div>');
	this.mSecondConfigPanel.append(leftColumn);
	var rightColumn = $('<div class="column"></div>');
	this.mSecondConfigPanel.append(rightColumn);

	this.createSliderControlDIV(this.mOriginOptions.XpMult, 'XP Gained', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.BusinessReputationRate, 'Renown Gained', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.BonusSpeed, 'Movement Speed', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.BonusLoot, 'Chance For Bonus Loot', leftColumn);
	this.createSliderControlDIV(this.mOriginOptions.BonusChampion, 'Bonus Champion Chance', leftColumn);
	
	this.createSliderControlDIV(this.mOriginOptions.VisionRadius, 'Vision Radius', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.HitpointsPerHourMult, 'Hitpoints Recovery Speed', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.RepairSpeedMult, 'Repair Speed', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.RelationDecayGoodMult, 'Good Relation Recovery', rightColumn);
	this.createSliderControlDIV(this.mOriginOptions.RelationDecayBadMult, 'Bad Relation Decay', rightColumn);
};

OriginCustomizerScreen.prototype.createSliderControlDIV = function (_definition, _label, _parentDiv) {
	var row = $('<div class="row"></div>');
	_parentDiv.append(row);
	_definition.Title = $('<div class="title title-font-big font-bold font-color-title">' + _label + '</div>');
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
	control.append(_definition.Label);

	_definition.Control.on("change", function () {
		_definition.Value = parseInt(_definition.Control.val());
		_definition.Label.text('' + _definition.Value);
	});
};

OriginCustomizerScreen.prototype.returnScreen = function () {
	if (this.mChooseOriginPanel.hasClass('display-block')) {
		this.cancelChooseOrigin();
		this.mOriginPanel.removeClass('display-none').addClass('display-block');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');

		this.mDoneButton.removeClass('display-none').addClass('display-block');
		this.mStartButton.changeButtonText("Next");
		this.mCancelButton.changeButtonText("Previous");
		this.mOriginImage.removeClass('display-none').addClass('display-block');

	} else if (this.mOriginPanel.hasClass('display-block')) {

		this.mSecondConfigPanel.removeClass('display-none').addClass('display-block');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');

	} else if (this.mDifficultyPanel.hasClass('display-block')) {

		this.mOriginPanel.removeClass('display-none').addClass('display-block');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		
		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-none').addClass('display-block');

	} else if (this.mFirstConfigPanel.hasClass('display-block')) {

		this.mDifficultyPanel.removeClass('display-none').addClass('display-block');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		
		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');

	} else {

		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-none').addClass('display-block');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');
	}
}

OriginCustomizerScreen.prototype.advanceScreen = function () {
	if (this.mChooseOriginPanel.hasClass('display-block')) {
		this.chooseOrigin();
		this.mOriginPanel.removeClass('display-none').addClass('display-block');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		this.mDoneButton.removeClass('display-none').addClass('display-block');
		this.mStartButton.changeButtonText("Next");
		this.mCancelButton.changeButtonText("Previous");
		this.mOriginImage.removeClass('display-none').addClass('display-block');

	} else if (this.mOriginPanel.hasClass('display-block')) {

		this.mDifficultyPanel.removeClass('display-none').addClass('display-block');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');

	} else if (this.mDifficultyPanel.hasClass('display-block')) {

		this.mFirstConfigPanel.removeClass('display-none').addClass('display-block');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		
		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');

	} else if (this.mFirstConfigPanel.hasClass('display-block')) {

		this.mSecondConfigPanel.removeClass('display-none').addClass('display-block');
		this.mOriginPanel.removeClass('display-block').addClass('display-none');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		
		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-block').addClass('display-none');

	} else {

		this.mOriginPanel.removeClass('display-none').addClass('display-block');
		this.mDifficultyPanel.removeClass('display-block').addClass('display-none');
		this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
		this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');

		this.mChooseOriginPanel.removeClass('display-block').addClass('display-none');
		this.mOriginImage.removeClass('display-none').addClass('display-block');
	}
}

OriginCustomizerScreen.prototype.switchToOriginScreen = function () {
	this.mChooseOriginPanel.removeClass('display-none').addClass('display-block');
	this.mOriginPanel.removeClass('display-block').addClass('display-none');
	this.mFirstConfigPanel.removeClass('display-block').addClass('display-none');
	this.mSecondConfigPanel.removeClass('display-block').addClass('display-none');
	this.mDifficultyPanel.removeClass('display-block').addClass('display-none');

	this.mOriginImage.removeClass('display-block').addClass('display-none');
	this.mDoneButton.removeClass('display-block').addClass('display-none');
	this.mStartButton.changeButtonText("Accept");
	this.mCancelButton.changeButtonText("Cancel");
}

OriginCustomizerScreen.prototype.bindTooltips = function () {
	this.mCompanyName.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.CompanyName
	});

	this.mDifficultyEasyLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyEasy
	});
	this.mDifficultyEasyCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyEasy
	});

	this.mDifficultyNormalLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyNormal
	});
	this.mDifficultyNormalCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyNormal
	});

	this.mDifficultyHardLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyHard
	});
	this.mDifficultyHardCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyHard
	});

	this.mDifficultyLegendaryLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyLegendary
	});
	this.mDifficultyLegendaryCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.DifficultyLegendary
	});

	this.mEconomicDifficultyEasyLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyEasy
	});
	this.mEconomicDifficultyEasyCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyEasy
	});

	this.mEconomicDifficultyNormalLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyNormal
	});
	this.mEconomicDifficultyNormalCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyNormal
	});

	this.mEconomicDifficultyHardLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyHard
	});
	this.mEconomicDifficultyHardCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyHard
	});

	this.mEconomicDifficultyLegendaryLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyLegendary
	});
	this.mEconomicDifficultyLegendaryCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: TooltipIdentifier.MenuScreen.NewCampaign.EconomicDifficultyLegendary
	});

	this.mLegendAllBlueprintsCheckbox.bindTooltip({
		contentType: 'ui-element',
		elementId: 'mapconfig.legendallblueprints'
	});
	this.mLegendAllBlueprintsCheckboxLabel.bindTooltip({
		contentType: 'ui-element',
		elementId: 'mapconfig.legendallblueprints'
	});

	this.mOriginOptions.Tier.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.tier'
	});
	this.mOriginOptions.Tier.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.tier'
	});

	this.mOriginOptions.Stash.Control.bindTooltip({ 
		contentType: 'ui-element', 
		elementId: TooltipIdentifier.Stash.FreeSlots 
	});
	this.mOriginOptions.Stash.Title.bindTooltip({ 
		contentType: 'ui-element', 
		elementId: TooltipIdentifier.Stash.FreeSlots 
	});

	this.mOriginOptions.XpMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.xp'
	});
	this.mOriginOptions.XpMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.xp'
	});

	this.mOriginOptions.HiringMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.hiring'
	});
	this.mOriginOptions.HiringMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.hiring'
	});

	this.mOriginOptions.WageMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.wage'
	});
	this.mOriginOptions.WageMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.wage'
	});

	this.mOriginOptions.SellingMult.Control.bindTooltip({
	 	contentType: 'ui-element',
		elementId: 'customeorigin.selling'
	});
	this.mOriginOptions.SellingMult.Title.bindTooltip({
	 	contentType: 'ui-element',
	 	elementId: 'customeorigin.selling'
	});

	this.mOriginOptions.BuyingMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.buying'
	});
	this.mOriginOptions.BuyingMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.buying'
	});

	this.mOriginOptions.BonusLoot.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.loot'
	});
	this.mOriginOptions.BonusLoot.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.loot'
	});

	this.mOriginOptions.BonusChampion.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.champion'
	});
	this.mOriginOptions.BonusChampion.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.champion'
	});

	this.mOriginOptions.BonusSpeed.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.speed'
	});
	this.mOriginOptions.BonusSpeed.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.speed'
	});

	this.mOriginOptions.ContractPayment.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.contractpayment'
	});
	this.mOriginOptions.ContractPayment.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.contractpayment'
	});

	this.mOriginOptions.VisionRadius.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.vision'
	});
	this.mOriginOptions.VisionRadius.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.vision'
	});

	this.mOriginOptions.HitpointsPerHourMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.hp'
	});

	this.mOriginOptions.HitpointsPerHourMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.hp'
	});

	this.mOriginOptions.RepairSpeedMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.repair'
	});
	this.mOriginOptions.RepairSpeedMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.repair'
	});

	this.mOriginOptions.BusinessReputationRate.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.renown'
	});
	this.mOriginOptions.BusinessReputationRate.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.renown'
	});

	this.mOriginOptions.NegotiationAnnoyanceMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.negotiation'
	});
	this.mOriginOptions.NegotiationAnnoyanceMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.negotiation'
	});

	this.mOriginOptions.RosterSizeAdditionalMin.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.recruitmin'
	});
	this.mOriginOptions.RosterSizeAdditionalMin.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.recruitmin'
	});

	this.mOriginOptions.RosterSizeAdditionalMax.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.recruitmax'
	});
	this.mOriginOptions.RosterSizeAdditionalMax.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.recruitmax'
	});

	this.mOriginOptions.TaxidermistPriceMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.craft'
	});
	this.mOriginOptions.TaxidermistPriceMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.craft'
	});

	this.mOriginOptions.TryoutPriceMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.tryout'
	});
	this.mOriginOptions.TryoutPriceMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.tryout'
	});

	this.mOriginOptions.RelationDecayBadMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.badrelation'
	});
	this.mOriginOptions.RelationDecayBadMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.badrelation'
	});

	this.mOriginOptions.RelationDecayGoodMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.goodrelation'
	});
	this.mOriginOptions.RelationDecayGoodMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.goodrelation'
	});

	this.mAcceptBannerButton.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.accept_banner'
	});

	this.mOriginImage.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.choose_origin'
	});
};

OriginCustomizerScreen.prototype.unbindTooltips = function () {
	this.mCompanyName.unbindTooltip();

	this.mDifficultyEasyLabel.unbindTooltip();
	this.mDifficultyEasyCheckbox.unbindTooltip();

	this.mDifficultyNormalLabel.unbindTooltip();
	this.mDifficultyNormalCheckbox.unbindTooltip();

	this.mDifficultyHardLabel.unbindTooltip();
	this.mDifficultyHardCheckbox.unbindTooltip();

	this.mDifficultyLegendaryLabel.unbindTooltip();
	this.mDifficultyLegendaryCheckbox.unbindTooltip();

	this.mEconomicDifficultyEasyLabel.unbindTooltip();
	this.mEconomicDifficultyEasyCheckbox.unbindTooltip();

	this.mEconomicDifficultyNormalLabel.unbindTooltip();
	this.mEconomicDifficultyNormalCheckbox.unbindTooltip();

	this.mEconomicDifficultyHardLabel.unbindTooltip();
	this.mEconomicDifficultyHardCheckbox.unbindTooltip();

	this.mEconomicDifficultyLegendaryLabel.unbindTooltip();
	this.mEconomicDifficultyLegendaryCheckbox.unbindTooltip();

	this.mLegendAllBlueprintsCheckbox.unbindTooltip();
	this.mLegendAllBlueprintsCheckboxLabel.unbindTooltip();

	this.mOriginOptions.Tier.Control.unbindTooltip();
	this.mOriginOptions.Tier.Title.unbindTooltip();

	this.mOriginOptions.XpMult.Control.unbindTooltip();
	this.mOriginOptions.XpMult.Title.unbindTooltip();

	this.mOriginOptions.HiringMult.Control.unbindTooltip();
	this.mOriginOptions.HiringMult.Title.unbindTooltip();

	this.mOriginOptions.WageMult.Control.unbindTooltip();
	this.mOriginOptions.WageMult.Title.unbindTooltip();

	this.mOriginOptions.SellingMult.Control.unbindTooltip();
	this.mOriginOptions.SellingMult.Title.unbindTooltip();

	this.mOriginOptions.BuyingMult.Control.unbindTooltip();
	this.mOriginOptions.BuyingMult.Title.unbindTooltip();

	this.mOriginOptions.BonusLoot.Control.unbindTooltip();
	this.mOriginOptions.BonusLoot.Title.unbindTooltip();

	this.mOriginOptions.BonusChampion.Control.unbindTooltip();
	this.mOriginOptions.BonusChampion.Title.unbindTooltip();

	this.mOriginOptions.BonusSpeed.Control.unbindTooltip();
	this.mOriginOptions.BonusSpeed.Title.unbindTooltip();

	this.mOriginOptions.ContractPayment.Control.unbindTooltip();
	this.mOriginOptions.ContractPayment.Title.unbindTooltip();

	this.mOriginOptions.VisionRadius.Control.unbindTooltip();
	this.mOriginOptions.VisionRadius.Title.unbindTooltip();

	this.mOriginOptions.HitpointsPerHourMult.Control.unbindTooltip();
	this.mOriginOptions.HitpointsPerHourMult.Title.unbindTooltip();

	this.mOriginOptions.RepairSpeedMult.Control.unbindTooltip();
	this.mOriginOptions.RepairSpeedMult.Title.unbindTooltip();

	this.mOriginOptions.BusinessReputationRate.Control.unbindTooltip();
	this.mOriginOptions.BusinessReputationRate.Title.unbindTooltip();

	this.mOriginOptions.NegotiationAnnoyanceMult.Control.unbindTooltip();
	this.mOriginOptions.NegotiationAnnoyanceMult.Title.unbindTooltip();

	this.mOriginOptions.RosterSizeAdditionalMin.Control.unbindTooltip();
	this.mOriginOptions.RosterSizeAdditionalMin.Title.unbindTooltip();

	this.mOriginOptions.RosterSizeAdditionalMax.Control.unbindTooltip();
	this.mOriginOptions.RosterSizeAdditionalMax.Title.unbindTooltip();

	this.mOriginOptions.TaxidermistPriceMult.Control.unbindTooltip();
	this.mOriginOptions.TaxidermistPriceMult.Title.unbindTooltip();

	this.mOriginOptions.TryoutPriceMult.Control.unbindTooltip();
	this.mOriginOptions.TryoutPriceMult.Title.unbindTooltip();

	this.mOriginOptions.RelationDecayBadMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.badrelation'
	});
	this.mOriginOptions.RelationDecayBadMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.badrelation'
	});

	this.mOriginOptions.RelationDecayGoodMult.Control.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.goodrelation'
	});
	this.mOriginOptions.RelationDecayGoodMult.Title.bindTooltip({
		contentType: 'ui-element',
		elementId: 'customeorigin.goodrelation'
	});

	this.mAcceptBannerButton.unbindTooltip();
	this.mOriginImage.unbindTooltip();
};



OriginCustomizerScreen.prototype.onPreviousBannerClicked = function () 
{
	--this.mCurrentBannerIndex;

	if (this.mCurrentBannerIndex < 0)
		this.mCurrentBannerIndex = this.mBanners.length - 1;

	this.onUpdateBannerButton();
};


OriginCustomizerScreen.prototype.onNextBannerClicked = function () 
{
	++this.mCurrentBannerIndex;

	if (this.mCurrentBannerIndex >= this.mBanners.length)
		this.mCurrentBannerIndex = 0;

	this.onUpdateBannerButton();
};

OriginCustomizerScreen.prototype.onAcceptBannerClicked = function () 
{
	this.mSelectedBannerIndex = this.mCurrentBannerIndex;
	this.notifyBackendOnChangingBanner(this.mBanners[this.mSelectedBannerIndex]);
	this.onUpdateBannerButton();
};

OriginCustomizerScreen.prototype.onUpdateBannerButton = function () 
{
	if(this.mCurrentBannerIndex === this.mSelectedBannerIndex)
    {
        this.mAcceptBannerButton.enableButton(false);
    }
    else
    {
        this.mAcceptBannerButton.enableButton(true);
    }

    this.mBannerImage.attr('src', Path.GFX + 'ui/banners/' + this.mBanners[this.mCurrentBannerIndex] + '.png');
};

OriginCustomizerScreen.prototype.setBanners = function (_data, _currentBanner) 
{
	if (_data !== null && jQuery.isArray(_data)) 
	{
		this.mBanners = _data;
		this.mCurrentBannerIndex = _currentBanner;
		this.mSelectedBannerIndex = _currentBanner;

		if (this.mCurrentBannerIndex === null)
		{
			this.mCurrentBannerIndex = Math.floor(Math.random() * _data.length);
		}

		this.onUpdateBannerButton();
		this.mBannerImage.attr('src', Path.GFX + 'ui/banners/' + _data[this.mCurrentBannerIndex] + '.png');
	} else 
	{
		console.error('ERROR: No banners specified for OriginCustomizerScreen::setBanners');
	}
};



OriginCustomizerScreen.prototype.setStartingScenarios = function (_data, _currentScenario, _image ) 
{
	if (_data !== null && jQuery.isArray(_data)) {
		this.mScenarios = _data;
		this.mScenarioCurentIndex = _currentScenario;

		for (var i = 0; i < _data.length; ++i) {
			var isChosen = i === _currentScenario;
			this.addStartingScenario(_data[i], isChosen);
		}
		this.updateScenarioImage(this.mScenarios[this.mScenarioCurentIndex].Image);
	}
};

OriginCustomizerScreen.prototype.addStartingScenario = function (_data, _isChosen)
{
	var row = $('<div class="l-row"/>');
	var entry = $('<div class="list-entry list-entry-small"><span class="label text-font-normal font-color-label">' + _data['Name'] + '</span></div></div>');
    entry.data('scenario', _data);
	entry.click(this, this.onSelectScenario);
	entry.mouseenter(this, this.onMouseHoverScenario);
	entry.mouseleave(this, this.onMouseLeaveScenario);
    row.append(entry);
	this.mScenarioScrollContainer.append(row);

	if (_isChosen)
	{
		entry.addClass('is-selected');
		this.updateStartingScenarioDescription(_data);
	}
};

OriginCustomizerScreen.prototype.updateScenarioImage = function (_image) 
{
	this.mOriginImage = this.mOriginImage.changeButtonImage(Path.GFX + 'ui/' + _image + '.png');
};

OriginCustomizerScreen.prototype.updateStartingScenarioDescription = function (_data)
{
	var _desc = _data['Description'];
	var _difficulty = _data['Difficulty'];
	var parsedText = XBBCODE.process({
		text: _desc,
		removeMisalignedTags: false,
		addInLineBreaks: true
	});

	this.mScenariosDesc.html(parsedText.html);
	this.mScenariosDifficulty.attr('src', Path.GFX + 'ui/images/' + _difficulty + '.png');
};

OriginCustomizerScreen.prototype.onSelectScenario = function(_event)
{
	var self = _event.data;
	var buttonDiv = $(this);

	// check if this is already selected
	if (buttonDiv.hasClass('is-selected') !== true)
	{
		// deselect all entries first
		self.mScenarioScrollContainer.find('.is-selected:first').each(function (index, element)
		{
			$(element).removeClass('is-selected');
		});

		buttonDiv.addClass('is-selected');
	}
};

OriginCustomizerScreen.prototype.onMouseHoverScenario = function(_event)
{
	var self = _event.data;
	var buttonDiv = $(this);
	var data = buttonDiv.data('scenario');

	// show description
	self.updateStartingScenarioDescription(data);
};

OriginCustomizerScreen.prototype.onMouseLeaveScenario = function(_event)
{
	var self = _event.data;
	
	// find current selected and show its description
	var selectedEntry = self.mScenarioScrollContainer.find('.is-selected:first');
	if (selectedEntry.length > 0)
	{
		self.updateStartingScenarioDescription(selectedEntry.data('scenario'));
	}
};

OriginCustomizerScreen.prototype.cancelChooseOrigin = function ()
{
	var Scenario = this.mScenarios[this.mScenarioCurentIndex];
	this.updateScenarioImage(Scenario.Image);
};

OriginCustomizerScreen.prototype.chooseOrigin = function ()
{
	var selectedEntry = this.mScenarioScrollContainer.find('.is-selected:first');
	var data = null;
    if (selectedEntry.length > 0)
    {
        data = selectedEntry.data('scenario');
    }

    if (data !== null)
    {
	    for (var i = 0; i < this.mScenarios.length; ++i)
		{
			var Scenario = this.mScenarios[i];

			if (Scenario !== null && Scenario.ID === data.ID)
			{
				this.mScenarioCurentIndex = i;
				break;
			}
		}
	}
	else
	{
		this.mScenarioCurentIndex = 0;
	}

	var self = this;
	var ScenarioData = this.mScenarios[this.mScenarioCurentIndex];
	this.notifyBackendOnChoosingOrigin(ScenarioData.ID, function(_result) {
		if (_result === null) {
			self.updateScenarioImage(ScenarioData.Image);
		}
		else {
			self.mScenarioCurentIndex = _result;
		}
	});
};



OriginCustomizerScreen.prototype.loadFromData = function (_data) 
{
	if(_data === undefined || _data === null)
    {
        return;
    }

    if ('Name' in _data)
    {
    	this.mCompanyName.setInputText(_data['Name']);
    }

    if ('Banners' in _data)
    {
    	this.setBanners(_data['Banners'], _data['BannerIndex']);
    }

    if ('StartingScenario' in _data)
    {
    	this.setStartingScenarios(_data['StartingScenario'], _data['OriginIndex']);
    }

    this.setConfigOpts(_data);
};

OriginCustomizerScreen.prototype.updateOriginConfig = function () {
	var controls = [
		this.mOriginOptions.Tier,
		this.mOriginOptions.Stash,
		this.mOriginOptions.XpMult,
		this.mOriginOptions.HiringMult,
		this.mOriginOptions.WageMult,
		this.mOriginOptions.SellingMult,
		this.mOriginOptions.BuyingMult,
		this.mOriginOptions.BonusLoot,
		this.mOriginOptions.BonusChampion,
		this.mOriginOptions.BonusSpeed,
		this.mOriginOptions.ContractPayment,
		this.mOriginOptions.VisionRadius,
		this.mOriginOptions.HitpointsPerHourMult,
		this.mOriginOptions.RepairSpeedMult,
		this.mOriginOptions.BusinessReputationRate,
		this.mOriginOptions.NegotiationAnnoyanceMult,
		this.mOriginOptions.RosterSizeAdditionalMin,
		this.mOriginOptions.RosterSizeAdditionalMax
		this.mOriginOptions.TaxidermistPriceMult
		this.mOriginOptions.TryoutPriceMult
		this.mOriginOptions.RelationDecayGoodMult
		this.mOriginOptions.RelationDecayBadMult
	]
	controls.forEach(function (_definition) {
		_definition.Control.attr('min', _definition.Min);
		_definition.Control.attr('max', _definition.Max);
		_definition.Control.attr('step', _definition.Step);
		_definition.Control.val(_definition.Value);
		_definition.Label.text('' + _definition.Value);
	});
};

OriginCustomizerScreen.prototype.setConfigOpts = function (_data) {
	if (_data !== null) {
		this.mOriginConfigOpts = _data;

		if (('Difficulty' in _data) && _data['Difficulty'] !== 0) {
			this.mDifficulty = _data['Difficulty'];

			if (this.mDifficulty === 1) {
				this.mDifficultyNormalCheckbox.iCheck('check');
			}
			else if (this.mDifficulty === 2) {
				this.mDifficultyHardCheckbox.iCheck('check');
			}
			else {
				this.mDifficultyLegendaryCheckbox.iCheck('check');
			}
		}
		if (('EconomicDifficulty' in _data) && _data['EconomicDifficulty'] !== 0) {
			this.mEconomicDifficulty = _data['EconomicDifficulty'];
	
			if (this.mEconomicDifficulty === 1) {
				this.mEconomicDifficultyNormalCheckbox.iCheck('check');
			}
			else if (this.mEconomicDifficulty === 2) {
				this.mEconomicDifficultyHardCheckbox.iCheck('check');
			}
			else {
				this.mEconomicDifficultyLegendaryCheckbox.iCheck('check');
			}
		}
		if ('AllBlueprint' in _data) {
			if (_data['AllBlueprint']) {
				this.mLegendAllBlueprintsCheckbox.iCheck('check');
			}
		}
		if ('Tier' in _data) {
			this.mOriginOptions.Tier.Value = _data['Tier'];
			this.mOriginOptions.Tier.Min = _data['TierMin'];
			this.mOriginOptions.Tier.Max = _data['TierMax'];
		}
		if ('Stash' in _data) {
			this.mOriginOptions.Stash.Value = _data['Stash'];
			this.mOriginOptions.Stash.Min = _data['StashMin'];
			this.mOriginOptions.Stash.Max = _data['StashMax'];
		}
		if ('XpMult' in _data) {
			this.mOriginOptions.XpMult.Value = _data['XpMult'];
			this.mOriginOptions.XpMult.Min = _data['XpMultMin'];
			this.mOriginOptions.XpMult.Max = _data['XpMultMax'];
		}
		if ('HiringMult' in _data) {
			this.mOriginOptions.HiringMult.Value = _data['HiringMult'];
			this.mOriginOptions.HiringMult.Min = _data['HiringMultMin'];
			this.mOriginOptions.HiringMult.Max = _data['HiringMultMax'];
		}
		if ('WageMult' in _data) {
			this.mOriginOptions.WageMult.Value = _data['WageMult'];
			this.mOriginOptions.WageMult.Min = _data['WageMultMin'];
			this.mOriginOptions.WageMult.Max = _data['WageMultMax'];
		}
		if ('SellingMult' in _data) {
			this.mOriginOptions.SellingMult.Value = _data['SellingMult'];
			this.mOriginOptions.SellingMult.Min = _data['SellingMultMin'];
			this.mOriginOptions.SellingMult.Max = _data['SellingMultMax'];
		}
		if ('BuyingMult' in _data) {
			this.mOriginOptions.BuyingMult.Value = _data['BuyingMult'];
			this.mOriginOptions.BuyingMult.Min = _data['BuyingMultMin'];
			this.mOriginOptions.BuyingMult.Max = _data['BuyingMultMax'];
		}
		if ('BonusLoot' in _data) {
			this.mOriginOptions.BonusLoot.Value = _data['BonusLoot'];
			this.mOriginOptions.BonusLoot.Min = _data['BonusLootMin'];
			this.mOriginOptions.BonusLoot.Max = _data['BonusLootMax'];
		}
		if ('BonusChampion' in _data) {
			this.mOriginOptions.BonusChampion.Value = _data['BonusChampion'];
			this.mOriginOptions.BonusChampion.Min = _data['BonusChampionMin'];
			this.mOriginOptions.BonusChampion.Max = _data['BonusChampionMax'];
		}
		if ('BonusSpeed' in _data) {
			this.mOriginOptions.BonusSpeed.Value = _data['BonusSpeed'];
			this.mOriginOptions.BonusSpeed.Min = _data['BonusSpeedMin'];
			this.mOriginOptions.BonusSpeed.Max = _data['BonusSpeedMax'];
		}
		if ('ContractPaymentMult' in _data) {
			this.mOriginOptions.ContractPayment.Value = _data['ContractPaymentMult'];
			this.mOriginOptions.ContractPayment.Min = _data['ContractPaymentMultMin'];
			this.mOriginOptions.ContractPayment.Max = _data['ContractPaymentMultMax'];
		}
		if ('VisionRadiusMult' in _data) {
			this.mOriginOptions.VisionRadius.Value = _data['VisionRadiusMult'];
			this.mOriginOptions.VisionRadius.Min = _data['VisionRadiusMultMin'];
			this.mOriginOptions.VisionRadius.Max = _data['VisionRadiusMultMax'];
		}

		if ('HitpointsPerHourMult' in _data) {
			this.mOriginOptions.HitpointsPerHourMult.Value = _data['HitpointsPerHourMult'];
			this.mOriginOptions.HitpointsPerHourMult.Min = _data['HitpointsPerHourMultMin'];
			this.mOriginOptions.HitpointsPerHourMult.Max = _data['HitpointsPerHourMultMax'];
		}
		if ('RepairSpeedMult' in _data) {
			this.mOriginOptions.RepairSpeedMult.Value = _data['RepairSpeedMult'];
			this.mOriginOptions.RepairSpeedMult.Min = _data['RepairSpeedMultMin'];
			this.mOriginOptions.RepairSpeedMult.Max = _data['RepairSpeedMultMax'];
		}
		if ('BusinessReputationRate' in _data) {
			this.mOriginOptions.BusinessReputationRate.Value = _data['BusinessReputationRate'];
			this.mOriginOptions.BusinessReputationRate.Min = _data['BusinessReputationRateMin'];
			this.mOriginOptions.BusinessReputationRate.Max = _data['BusinessReputationRateMax'];
		}
		if ('NegotiationAnnoyanceMult' in _data) {
			this.mOriginOptions.NegotiationAnnoyanceMult.Value = _data['NegotiationAnnoyanceMult'];
			this.mOriginOptions.NegotiationAnnoyanceMult.Min = _data['NegotiationAnnoyanceMultMin'];
			this.mOriginOptions.NegotiationAnnoyanceMult.Max = _data['NegotiationAnnoyanceMultMax'];
		}
		if ('RosterSizeAdditionalMin' in _data) {
			this.mOriginOptions.RosterSizeAdditionalMin.Value = _data['RosterSizeAdditionalMin'];
			this.mOriginOptions.RosterSizeAdditionalMin.Min = _data['RosterSizeAdditionalMinMin'];
			this.mOriginOptions.RosterSizeAdditionalMin.Max = _data['RosterSizeAdditionalMinMax'];
		}
		if ('RosterSizeAdditionalMax' in _data) {
			this.mOriginOptions.RosterSizeAdditionalMax.Value = _data['RosterSizeAdditionalMax'];
			this.mOriginOptions.RosterSizeAdditionalMax.Min = _data['RosterSizeAdditionalMaxMin'];
			this.mOriginOptions.RosterSizeAdditionalMax.Max = _data['RosterSizeAdditionalMaxMax'];
		}
		if ('TaxidermistPriceMult' in _data) {
			this.mOriginOptions.TaxidermistPriceMult.Value = _data['TaxidermistPriceMult'];
			this.mOriginOptions.TaxidermistPriceMult.Min = _data['TaxidermistPriceMultMin'];
			this.mOriginOptions.TaxidermistPriceMult.Max = _data['TaxidermistPriceMultMax'];
		}
		if ('TryoutPriceMult' in _data) {
			this.mOriginOptions.TryoutPriceMult.Value = _data['TryoutPriceMult'];
			this.mOriginOptions.TryoutPriceMult.Min = _data['TryoutPriceMultMin'];
			this.mOriginOptions.TryoutPriceMult.Max = _data['TryoutPriceMultMax'];
		}
		if ('RelationDecayGoodMult' in _data) {
			this.mOriginOptions.RelationDecayGoodMult.Value = _data['RelationDecayGoodMult'];
			this.mOriginOptions.RelationDecayGoodMult.Min = _data['RelationDecayGoodMultMin'];
			this.mOriginOptions.RelationDecayGoodMult.Max = _data['RelationDecayGoodMultMax'];
		}
		if ('RelationDecayBadMult' in _data) {
			this.mOriginOptions.RelationDecayBadMult.Value = _data['RelationDecayBadMult'];
			this.mOriginOptions.RelationDecayBadMult.Min = _data['RelationDecayBadMultMin'];
			this.mOriginOptions.RelationDecayBadMult.Max = _data['RelationDecayBadMultMax'];
		}

	} else {
		console.error('ERROR: No opts specified for OriginCustomizerScreen::setConfigOpts');
	}
	this.updateOriginConfig();
};

OriginCustomizerScreen.prototype.collectSettings = function () {
	var settings = [];

	// company name
	settings.push(this.mCompanyName.getInputText());

	// difficulty
	settings.push(this.mDifficulty);
	settings.push(this.mEconomicDifficulty);
	settings.push(this.mLegendAllBlueprintsCheckbox.is(":checked"));
	settings.push(this.mOriginOptions.Tier.Value);
	settings.push(this.mOriginOptions.Stash.Value);
	settings.push(this.mOriginOptions.XpMult.Value);
	settings.push(this.mOriginOptions.HiringMult.Value);
	settings.push(this.mOriginOptions.WageMult.Value);
	settings.push(this.mOriginOptions.SellingMult.Value);
	settings.push(this.mOriginOptions.BuyingMult.Value);
	settings.push(this.mOriginOptions.BonusLoot.Value);
	settings.push(this.mOriginOptions.BonusChampion.Value);
	settings.push(this.mOriginOptions.BonusSpeed.Value);
	settings.push(this.mOriginOptions.ContractPayment.Value);
	settings.push(this.mOriginOptions.VisionRadius.Value);
	settings.push(this.mOriginOptions.HitpointsPerHourMult.Value);
	settings.push(this.mOriginOptions.RepairSpeedMult.Value);
	settings.push(this.mOriginOptions.BusinessReputationRate.Value);
	settings.push(this.mOriginOptions.NegotiationAnnoyanceMult.Value);
	settings.push(this.mOriginOptions.RosterSizeAdditionalMin.Value);
	settings.push(this.mOriginOptions.RosterSizeAdditionalMax.Value);
	settings.push(this.mOriginOptions.TaxidermistPriceMult.Value);
	settings.push(this.mOriginOptions.TryoutPriceMult.Value);
	settings.push(this.mOriginOptions.RelationDecayGoodMult.Value);
	settings.push(this.mOriginOptions.RelationDecayBadMult.Value);
	return settings;
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

OriginCustomizerScreen.prototype.notifyBackendOnChangingBanner = function(_inputBanner) {
	if (this.mSQHandle !== null) {
		SQ.call(this.mSQHandle, 'onChangeBanner', _inputBanner);
	}
};

OriginCustomizerScreen.prototype.notifyBackendOnChoosingOrigin = function (_inputID, _callback) {
	if (this.mSQHandle !== null) {
		SQ.call(this.mSQHandle, 'onChangeScenario', _inputID, _callback);
	}
};

OriginCustomizerScreen.prototype.notifyBackendCloseButtonPressed = function () {
	if (this.mSQHandle !== null) {
		var settings = this.collectSettings();
		SQ.call(this.mSQHandle, 'onCloseButtonPressed', settings);
	}
};

OriginCustomizerScreen.prototype.notifyBackendStartButtonPressed = function () {
	if (this.mSQHandle !== null) {
		SQ.call(this.mSQHandle, 'onStartButtonPressed');
	}
};

OriginCustomizerScreen.prototype.notifyBackendCancelButtonPressed = function () {
	if (this.mSQHandle !== null) {
		SQ.call(this.mSQHandle, 'onCancelButtonPressed');
	}
};

registerScreen("OriginCustomizerScreen", new OriginCustomizerScreen());