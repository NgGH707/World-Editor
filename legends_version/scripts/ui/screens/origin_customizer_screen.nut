this.origin_customizer_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnStartButtonPressedListener = null,
		OnCancelButtonPressedListener = null,
		OnClosePressedListener = null,
		CurrentOriginID = "",
		CurrentBanner = "",
		CurrentStash = 0,
		ScenarioUI = [],
	},
	function isVisible()
	{
		return this.m.Visible != null && this.m.Visible == true;
	}

	function isAnimating()
	{
		if (this.m.Animating != null)
		{
			return this.m.Animating == true;
		}
		else
		{
			return false;
		}
	}

	function setOnConnectedListener( _listener )
	{
		this.m.OnConnectedListener = _listener;
	}

	function setOnDisconnectedListener( _listener )
	{
		this.m.OnDisconnectedListener = _listener;
	}

	function setOnStartButtonPressedListener( _listener )
	{
		this.m.OnStartButtonPressedListener = _listener;
	}

	function setOnCancelButtonPressedListener( _listener )
	{
		this.m.OnCancelButtonPressedListener = _listener;
	}

	function setOnClosePressedListener( _listener )
	{
		this.m.OnClosePressedListener = _listener;
	}

	function clearEventListener()
	{
		this.m.OnConnectedListener = null;
		this.m.OnDisconnectedListener = null;
		this.m.OnStartButtonPressedListener = null;
		this.m.OnCancelButtonPressedListener = null;
		this.m.OnClosePressedListener = null;
	}

	function create()
	{
		this.m.Visible = false;
		this.m.Animating = false;
		this.m.JSHandle = this.UI.connect("OriginCustomizerScreen", this);
		this.m.ScenarioUI = this.Const.ScenarioManager.getScenariosForUI();
		this.m.CurrentOriginID = "";
		this.m.CurrentBanner = "";
	}

	function destroy()
	{
		this.clearEventListener();
		this.m.JSHandle = this.UI.disconnect(this.m.JSHandle);
	}

	function show( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.getData());
		}
	}

	function hide( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("hide", null);
		}
	}

	function getData()
	{
		local data = this.World.Assets.getBaseAssets();
		local ret = {
			Name = this.World.Assets.getName(),
			Difficulty = this.World.Assets.getCombatDifficulty(),
			EconomicDifficulty = this.World.Assets.getEconomicDifficulty(),
			IsIronman = this.World.Assets.isIronman(),
			IsAutosave = this.World.Assets.isAutosave(),
			ItemScaling = this.LegendsMod.Configs().LegendItemScalingEnabled(),
			LocationScaling = this.LegendsMod.Configs().LegendLocationScalingEnabled(),
			AllBlueprint = this.LegendsMod.Configs().LegendAllBlueprintsEnabled(),

			Tier = this.World.Assets.getOrigin().getRosterTier(),
			TierMin = 0,
			TierMax = 6,

			XpMult = this.Math.floor(data.XPMult * 100),
			XpMultMin = 0,
			XpMultMax = 500,

			HiringMult = this.Math.floor(data.HiringCostMult * 100),
			HiringMultMin = 0,
			HiringMultMax = 500,

			WageMult = this.Math.floor(data.DailyWageMult * 100),
			WageMultMin = 0,
			WageMultMax = 500,

			SellingMult = this.Math.floor(data.SellPriceMult * 100),
			SellingMultMin = 0,
			SellingMultMax = 500,

			BuyingMult = this.Math.floor(data.BuyPriceMult * 100),
			BuyingMultMin = 0,
			BuyingMultMax = 500,

			BonusLoot = this.Math.floor(data.ExtraLootChance),
			BonusLootMin = 0,
			BonusLootMax = 100,

			BonusChampion = this.Math.floor(data.ChampionChanceAdditional),
			BonusChampionMin = 0,
			BonusChampionMax = 200,

			BonusSpeed = this.Math.floor(this.World.State.getPlayer().m.BaseMovementSpeed),
			BonusSpeedMin = 15,
			BonusSpeedMax = 300,

			ContractPaymentMult = this.Math.floor(data.ContractPaymentMult * 100),
			ContractPaymentMultMin = 0,
			ContractPaymentMultMax = 500,

			VisionRadiusMult = this.Math.floor(data.VisionRadiusMult * 100),
			VisionRadiusMultMin = 0,
			VisionRadiusMultMax = 500,

			HitpointsPerHourMult = this.Math.floor(data.HitpointsPerHourMult * 100),
			HitpointsPerHourMultMin = 0,
			HitpointsPerHourMultMax = 500,

			RepairSpeedMult = this.Math.floor(data.RepairSpeedMult * 100),
			RepairSpeedMultMix = 0,
			RepairSpeedMultMax = 500,

			BusinessReputationRate = this.Math.floor(data.BusinessReputationRate * 100),
			BusinessReputationRateMin = 0,
			BusinessReputationRateMax = 500,

			NegotiationAnnoyanceMult = this.Math.floor(data.NegotiationAnnoyanceMult * 100),
			NegotiationAnnoyanceMultMin = 0,
			NegotiationAnnoyanceMultMax = 500,

			RosterSizeAdditionalMin = this.Math.floor(data.RosterSizeAdditionalMin),
			RosterSizeAdditionalMinMin = 0,
			RosterSizeAdditionalMinMax = 20,

			RosterSizeAdditionalMax = this.Math.floor(data.RosterSizeAdditionalMax),
			RosterSizeAdditionalMaxMix = 0,
			RosterSizeAdditionalMaxMax = 20,

			TaxidermistPriceMult = this.Math.floor(data.TaxidermistPriceMult * 100),
			TaxidermistPriceMultMin = 0,
			TaxidermistPriceMultMax = 500

			TryoutPriceMult = this.Math.floor(data.TryoutPriceMult * 100),
			TryoutPriceMultMin = 0,
			TryoutPriceMultMax = 500,
			
			RelationDecayGoodMult = this.Math.floor(data.RelationDecayGoodMult * 100),
			RelationDecayGoodMultMin = 5,
			RelationDecayGoodMultMax = 500,
			
			RelationDecayBadMult = this.Math.floor(data.RelationDecayBadMult * 100),
			RelationDecayBadMultMin = 5,
			RelationDecayBadMultMax = 500,
		};
		this.addStashData(ret);
		this.addOriginData(ret);
		this.addBannerData(ret);
		return ret;
	}

	function addStashData( _result )
	{
		local stash = this.World.Assets.getStash();
		local max = this.Math.max(stash.getCapacity(), 400);
		this.m.CurrentStash = stash.getCapacity();
		_result.Stash <- this.m.CurrentStash;
		_result.StashMin <- stash.getNumberOfFilledSlots();
		_result.StashMax <- max;
	}

	function addBannerData( _result )
	{
		this.m.CurrentBanner = this.World.Assets.getBanner();
		_result.Banners <- this.Const.PlayerBanners;
		_result.BannerIndex <- this.Const.PlayerBanners.find(this.m.CurrentBanner);
	}

	function addOriginData( _result )
	{
		local UI = this.m.ScenarioUI;
		local index = 0;
		this.m.CurrentOriginID = this.World.Assets.getOrigin().getID();

		foreach ( i, s in UI )
		{
			if (s.ID == this.m.CurrentOriginID)
			{
				index = i;
				break;
			}
		}

		local description = UI[index].Description;
		_result.OriginIndex <- index;
		_result.OriginImage <- UI[index].Image;
		_result.StartingScenario <- UI;
	}

	function onCloseButtonPressed( _settings )
	{
		local data = {};
		local keys = [
			"Name",
			"Difficulty",
			"EconomicDifficulty",
			"IsIronman",
			"IsAutosave",
			"ItemScaling",
			"LocationScaling",
			"AllBlueprint",
			"Tier",
			"Stash",
			"XpMult",
			"HiringMult",
			"WageMult",
			"SellingMult",
			"BuyingMult",
			"BonusLoot",
			"BonusChampion",
			"BonusSpeed",
			"ContractPaymentMult",
			"VisionRadiusMult",
			"HitpointsPerHourMult",
			"RepairSpeedMult",
			"BusinessReputationRate",
			"NegotiationAnnoyanceMult",
			"RosterSizeAdditionalMin",
			"RosterSizeAdditionalMax",
			"TaxidermistPriceMult",
			"TryoutPriceMult",
			"RelationDecayGoodMult",
			"RelationDecayBadMult",
		];

		foreach( i, k in keys )
		{
			data[k] <- _settings[i];
		}

		this.applyChanges(data);
		this.World.State.updateTopbarAssets();

		if (this.m.OnClosePressedListener != null)
		{
			this.m.OnClosePressedListener();
		}
	}

	function applyChanges( _settings )
	{
		this.World.Assets.m.Name = this.removeFromBeginningOfText("The ", this.removeFromBeginningOfText("the ", _settings.Name));
		this.World.Assets.m.CombatDifficulty = _settings.Difficulty;
		this.World.Assets.m.EconomicDifficulty = _settings.EconomicDifficulty;
		this.World.Assets.IsIronman = _settings.IsIronman;
		this.World.Assets.IsAutosave = _settings.IsAutosave; 
		this.LegendsMod.Configs().m.IsItemScaling = _settings.ItemScaling;
		this.LegendsMod.Configs().m.IsLocationScaling = _settings.LocationScaling;
		this.LegendsMod.Configs().m.IsBlueprintsVisible = _settings.AllBlueprint;

		if (_settings.Stash != this.m.CurrentStash)
		{
			local stash = this.World.Assets.getStash();
			stash.sort();
			stash.resize(_settings.Stash);
			this.m.CurrentStash = _settings.Stash;
		}

		this.World.Flags.set("UsedOriginCustomizer", this.OriginCustomizerVersion);
		this.World.Flags.set("RosterTier", _settings.Tier);
		this.World.Flags.set("XPMult", _settings.XpMult * 0.01);
		this.World.Flags.set("DailyWageMult", _settings.HiringMult * 0.01);
		this.World.Flags.set("HiringCostMult", _settings.WageMult * 0.01);
		this.World.Flags.set("SellPriceMult", _settings.SellingMult * 0.01);
		this.World.Flags.set("BuyPriceMult", _settings.BuyingMult * 0.01);
		this.World.Flags.set("ContractPaymentMult", _settings.ContractPaymentMult * 0.01);
		this.World.Flags.set("VisionRadiusMult", _settings.VisionRadiusMult * 0.01);
		this.World.Flags.set("HitpointsPerHourMult", _settings.HitpointsPerHourMult * 0.01);
		this.World.Flags.set("RepairSpeedMult", _settings.RepairSpeedMult * 0.01);
		this.World.Flags.set("BusinessReputationRate", _settings.BusinessReputationRate * 0.01);
		this.World.Flags.set("NegotiationAnnoyanceMult", _settings.NegotiationAnnoyanceMult * 0.01);
		this.World.Flags.set("ExtraLootChance", _settings.BonusLoot);
		this.World.Flags.set("ChampionChanceAdditional", _settings.BonusChampion);
		this.World.Flags.set("BaseMovementSpeed", _settings.BonusSpeed);
		this.World.Flags.set("RosterSizeAdditionalMin", _settings.RosterSizeAdditionalMin);
		this.World.Flags.set("RosterSizeAdditionalMax", _settings.RosterSizeAdditionalMax);
		this.World.Flags.set("TaxidermistPriceMult", _settings.TaxidermistPriceMult * 0.01);
		this.World.Flags.set("TryoutPriceMult", _settings.TryoutPriceMult * 0.01);
		this.World.Flags.set("RelationDecayGoodMult", _settings.RelationDecayGoodMult * 0.01);
		this.World.Flags.set("RelationDecayBadMult", _settings.RelationDecayBadMult * 0.01);
		this.World.Retinue.update();
		this.World.State.getPlayer().updateStrength();
	}

	function onChangeScenario( _inputScenarioID )
	{
		if (this.m.CurrentOriginID != "" && _inputScenarioID != this.m.CurrentOriginID)
		{
			local scenario = _inputScenarioID == "scenario.random" ? this.Const.ScenarioManager.getRandomScenario() : this.Const.ScenarioManager.getScenario(_inputScenarioID);
			this.World.Assets.m.Origin = scenario;
			this.m.CurrentOriginID = scenario.getID();

			foreach (i, s in this.m.ScenarioUI ) 
			{
			    if (s.ID == this.m.CurrentOriginID)
			    {
			    	this.m.JSHandle.asyncCall("updateScenarioImage", s.Image);
			    	return i;
			    }
			}
		}

		return null;
	}

	function onChangeBanner( _inputBanner )
	{
		if (this.m.CurrentBanner != "" && _inputBanner != this.m.CurrentBanner)
		{
			this.World.Assets.m.Banner = _inputBanner;
			this.World.Assets.m.BannerID = _inputBanner.slice(_inputBanner.find("_") + 1).tointeger();
			this.World.State.getPlayer().getSprite("banner").setBrush(_inputBanner);
			this.World.State.getPlayer().getSprite("zoom_banner").setBrush(_inputBanner);
			this.m.CurrentBanner = _inputBanner;
			this.changeAllBanner(this.World.Assets.getBannerID());
		}
	}

	function changeAllBanner( _bannerID )
	{
		local stash = this.World.Assets.getStash();
		local banner = stash.getItemByID("weapon.player_banner");

		if (banner != null)
		{
			banner.setVariant(_bannerID);
			banner.updateVariant();
			return;
		}

		local roster = this.World.getPlayerRoster().getAll();

		foreach ( bro in roster )
		{
			local items = bro.getItems();
			local allItems = items.getAllItems();

			foreach ( i in allItems )
			{
				if (i.getID() == "weapon.player_banner")
				{
					i.setVariant(_bannerID);
					i.updateVariant();
					items.unequip(i);
					items.equip(i);
					return;
				}
			}
		}
	}

	function onStartButtonPressed()
	{
		if (this.m.OnStartButtonPressedListener != null)
		{
			this.m.OnStartButtonPressedListener();
		}
	}

	function onCancelButtonPressed()
	{
		if (this.m.OnCancelButtonPressedListener != null)
		{
			this.m.OnCancelButtonPressedListener();
		}
	}

	function onScreenConnected()
	{
		if (this.m.OnConnectedListener != null)
		{
			this.m.OnConnectedListener();
		}
	}

	function onScreenDisconnected()
	{
		if (this.m.OnDisconnectedListener != null)
		{
			this.m.OnDisconnectedListener();
		}
	}

	function onScreenShown()
	{
		this.m.Visible = true;
		this.m.Animating = false;
	}

	function onScreenHidden()
	{
		this.m.Visible = false;
		this.m.Animating = false;
	}

	function onScreenAnimating()
	{
		this.m.Animating = true;
	}

};

