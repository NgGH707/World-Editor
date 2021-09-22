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
		};
		this.addOriginData(ret);
		this.addBannerData(ret);
		return ret;
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

	function onChooseOrigin( _index )
	{
		local image = this.m.ScenarioUI[_index].Image;
		this.m.JSHandle.asyncCall("updateScenarioImage", image);
	}

	function onCloseButtonPressed( _settings )
	{
		local keys = [
			"Name",
			"Banner",
			"ScenariosID",
			"Difficulty",
			"EconomicDifficulty",
			"AllBlueprint",
			"Tier",
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
		];
		local data = {};

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

		if (this.m.CurrentBanner != "" && _settings.Banner != this.m.CurrentBanner)
		{
			this.World.Assets.m.Banner = _settings.Banner;
			this.World.Assets.m.BannerID = _settings.Banner.slice(_settings.Banner.find("_") + 1).tointeger();
			this.changeBanner(this.World.Assets.getBannerID());
			this.World.State.getPlayer().getSprite("banner").setBrush(this.World.Assets.getBanner());
			this.World.State.getPlayer().getSprite("zoom_banner").setBrush(this.World.Assets.getBanner());
		}

		this.World.Assets.m.CombatDifficulty = _settings.Difficulty;
		this.World.Assets.m.EconomicDifficulty = _settings.EconomicDifficulty;
		this.LegendsMod.Configs().m.IsBlueprintsVisible = _settings.AllBlueprint;
		this.World.Flags.set("RosterTier", _settings.Tier);

		if (this.m.CurrentOriginID != "" && _settings.ScenariosID != this.m.CurrentOriginID)
		{
			this.World.Assets.m.Origin = _settings.ScenariosID == "scenario.random" ? this.Const.ScenarioManager.getRandomScenario() : this.Const.ScenarioManager.getScenario(_settings.ScenariosID);
			this.World.Assets.m.Origin.onInit();
		}

		this.World.Flags.set("UsedOriginCustomizer", this.OriginCustomizerVersion);
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
		this.World.Retinue.update();
	}

	function changeBanner( _bannerID )
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

