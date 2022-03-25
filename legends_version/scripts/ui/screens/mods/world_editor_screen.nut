this.world_editor_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		PopupDialogVisible = false,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnClosePressedListener = null,

		//
		TemporaryModel = null,
		StashCapacityBefore = 0,
		BannerIsChanged = false,
	},
	function isVisible()
	{
		return this.m.Visible != null && this.m.Visible == true;
	}

	function isAnimating()
	{
		if (this.m.Animating != null)
		{
			return this.m.Animating == true || this.m.PopupDialogVisible == true;
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

	function setOnClosePressedListener( _listener )
	{
		this.m.OnClosePressedListener = _listener;
	}

	function clearEventListener()
	{
		this.m.OnConnectedListener = null;
		this.m.OnDisconnectedListener = null;
		this.m.OnClosePressedListener = null;
	}

	function create()
	{
		this.m.Visible = false;
		this.m.Animating = false;
		this.m.PopupDialogVisible = false;
		this.m.JSHandle = this.UI.connect("WorldEditorScreen", this);
	}

	function destroy()
	{
		this.clearEventListener();
		this.m.JSHandle = this.UI.disconnect(this.m.JSHandle);
	}

	function show( _withSlideAnimation = false )
	{
		this.m.BannerIsChanged = false;

		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.convertToUIData());
		}
	}

	function hide( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation);
		}

		this.m.TemporaryModel = null;
		this.World.getTemporaryRoster().clear();
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
		this.m.PopupDialogVisible = false;
	}

	function onScreenHidden()
	{
		this.m.Visible = false;
		this.m.Animating = false;
		this.m.PopupDialogVisible = false;
	}

	function onScreenAnimating()
	{
		this.m.Animating = true;
	}

	function onPopupDialogIsVisible( _data )
	{
		this.m.PopupDialogVisible = _data[0];
	}

	function onCloseButtonPressed()
	{
		if (this.m.OnClosePressedListener != null)
		{
			this.m.OnClosePressedListener();
		}

		if (this.m.BannerIsChanged) this.updatePlayerBannerOnAllThings();
	}

	function onReloadButtonPressed()
	{
		this.m.Retinue.update();
		this.World.Assets.updateLook();
		this.World.State.getPlayer().calculateModifiers();
		this.updateTopbarAssets();
		if (this.m.BannerIsChanged) this.updatePlayerBannerOnAllThings();
		this.m.JSHandle.asyncCall("loadFromData", this.convertToUIData());
	}

	function onGetTroopEntries( _data )
	{
		return this.Woditor.Helper.convertTroopEntriesToUIData(_data);
	}

	function onCollectAllianceData( _data )
	{
		return this.Woditor.Helper.convertFactionAllianceToUIData(_data);
	}

	function onUpdateFactionAlliance( _data )
	{
		local faction = this.World.FactionManager.getFaction(_data[0]);

		foreach(id in _data[1].Allies)
		{
			faction.addAlly(id);
		}

		foreach(id in _data[1].Hostile)
		{
			faction.removeAlly(id);
		}
	}

	function onUpdateAvatarModel( _data )
	{
		switch (_data[0])
		{
		case "avatar":
			this.World.Flags.set("AvatarSprite", _data[1]);
			this.m.TemporaryModel.getSprite("body").setBrush(_data[1]);
			break;

		case "socket":
			this.World.Flags.set("AvatarSocket", _data[1]);
			this.m.TemporaryModel.getSprite("base").setBrush(_data[1]);
			break;
	
		case "flip":
			this.World.Flags.set("AvatarIsFlippedHorizontally", _data[1]);
			this.m.TemporaryModel.setFlipped(_data[1]);
			break;

		default: // reset sprite back to scenario default
			this.World.Flags.remove("AvatarSprite");
			this.World.Flags.remove("AvatarSocket");
			this.World.Flags.remove("AvatarIsFlippedHorizontally");
			this.World.Assets.updateLook();
			this.m.TemporaryModel.getSprite("base").setBrush(this.World.State.getPlayer().getSprite("base").getBrush().Name);
			this.m.TemporaryModel.getSprite("body").setBrush(this.World.State.getPlayer().getSprite("body").getBrush().Name);
			this.m.TemporaryModel.setFlipped(false);
		}

		this.m.TemporaryModel.setDirty(true);
		this.m.JSHandle.asyncCall("updateAvatarImage", this.m.TemporaryModel.getImagePath());
	}

	function onChangePlayerBanner( _banner )
	{
		this.m.BannerIsChanged = true;
		this.World.Assets.m.Banner = _banner;
		this.World.Assets.m.BannerID = _banner.slice(_banner.find("_") + 1).tointeger();
	}

	function onChangeCompanyName( _name )
	{
		this.World.Assets.m.Name = _name;
	}

	function onChangeFactionBanner( _data )
	{
		local faction = this.World.FactionManager.getFaction(_data[0]);
		faction.setBanner(_data[1]);
		local bannerSmall = faction.getBannerSmall();

		foreach (settlement in faction.getSettlements()) 
		{
			local location_banner = settlement.getSprite("location_banner");
			location_banner.setBrush(bannerSmall);
			location_banner.Visible = true;
		}

		foreach (unit in faction.getUnits())
		{
			local banner = unit.getSprite("banner");
			banner.setBrush(bannerSmall);
			banner.Visible = true;
		}

		this.m.JSHandle.asyncCall("updateFactionContracts", {
			Index = _data[2],
			Contracts = this.Woditor.Helper.getContractsUI(faction)
		});
	}

	function onChangeFactionName( _data )
	{
		this.World.FactionManager.getFaction(_data[0]).setName(_data[1]);
	}

	function onDespawnFactionTroops( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
		local new = [];

		foreach( u in faction.getUnits() )
		{
			// despawn all non-quest units
			if (!u.getSprite("selection").Visible) u.die();
			else new.push(u);
		}

		faction.m.Units = new;
	}

	function onRefreshFactionOwningCharacter( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
		faction.getRoster().clear();
		faction.onUpdateRoster();

		foreach ( contract in faction.getContracts() )
		{
			contract.setEmployerID(faction.getRandomCharacter().getID());
		}
	}

	function onRefreshFactionActions( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
		faction.m.LastActionTime = 0;
		faction.m.LastActionHour = 0;

		foreach ( action in faction.m.Deck )
		{
			action.resetCooldown();
		}
	}

	function onRefreshFactionContracts( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
		faction.setLastContractTime(0);

		foreach ( action in faction.m.Deck )
		{
			action.resetCooldown();
		}

		foreach ( contract in faction.getContracts() )
		{
			if (contract.isActive()) continue;

			contract.onClear();
			local i = this.World.Contracts.getOpenContracts().find(contract);

			if (i != null)
			{
				this.World.Contracts.getOpenContracts().remove(i);
			}

			if (this.World.Contracts.m.LastShown == contract)
			{
				this.World.Contracts.m.LastShown = null;
			}
		}
	}

	function onChangeWorldEntityName( _data )
	{
		this.World.getEntityByID(_data[0]).setName(_data[1]);
	}

	function onChangeScenario( _id )
	{
		this.World.Assets.m.Origin = this.Const.ScenarioManager.getScenario(_id);
	}

	function onUpdateAssetsValue( _data )
	{
		if (_data[0] == "Stash")
		{
			local before = this.m.StashCapacityBefore;
			this.World.Flags.set("StashModifier", _data[1] - before);
		}
		else
		{
			this.World.Assets.m[_data[0]] = _data[1];
		}
	}

	function onUpdateAssetsPropertyValue( _data )
	{
		local key = _data[0];
		local value = _data[1];
		local baseValue = this.World.Assets.getBaseProperties()[key];
		local isMult = this.Woditor.AssetsProperties.Mult.find(key) != null;
		local isAdditive = this.Woditor.AssetsProperties.Additive.find(key) != null;

		if (isMult) this.World.Flags.set(key, value / baseValue * 100);
		else if (isAdditive) this.World.Flags.set(key, value - baseValue);
		else this.World.Flags.set(key, value);
	}

	function onUpdateRosterTier( _tier )
	{
		this.World.Flags.set("RosterTier", _tier);
	}

	function onUpdateDifficultyMult( _value )
	{
		this.World.Flags.set("DifficultyMult", _value / 100);
	}

	function onUpdateCombatDifficulty( _value )
	{
		this.World.Assets.m.CombatDifficulty = _value;
	}

	function onUpdateEconomicDifficulty( _value )
	{
		this.World.Assets.m.EconomicDifficulty = _value;
	}

	function onUpdateGenderLevel( _value )
	{
		this.LegendsMod.Configs().m.IsGender = _value;
	}

	function onUpdataAssetsCheckBox( _data )
	{
		if (_data[0] in this.World.Assets.m) this.World.Assets.m[_data[0]] = _data[1];
		else this.LegendsMod.Configs().m[_data[0]] = _data[1];
	}

	function updateFactionRelation( _data )
	{
		local faction = this.World.FactionManager.getFaction(_data[0]);
		faction.setPlayerRelation(_data[1]);
		return {
			Relation = faction.getPlayerRelationAsText(),
			RelationNum = this.Math.round(faction.getPlayerRelation())
		};
	}

	function onUpdataFactionRelationDeterioration( _data )
	{
		this.World.FactionManager.getFaction(_data[0]).getFlags().set("RelationDeterioration",_data[1]);
	}

	function convertToUIData()
	{
		local result = {};
		result.Assets <- this.Woditor.Helper.convertAssetsToUIData();
		result.Avatar <- this.Woditor.Helper.convertAvatarToUIData(this);
		result.Factions <- this.Woditor.Helper.convertFactionsToUIData();
		result.Settlements <- this.Woditor.Helper.convertSettlementsToUIData(result.Factions);
		result.Locations <- this.Woditor.Helper.convertLocationsToUIData(result.Factions);
		result.Scenario <- this.Woditor.Helper.convertScenariosToUIData();

		this.m.StashCapacityBefore = result.Assets.Stash;
		return result;
	}

	function updatePlayerBannerOnAllThings()
	{
		local banner = this.World.Assets.getBanner();
		local bannerID = this.World.Assets.getBannerID();
		this.World.State.getPlayer().getSprite("banner").setBrush(banner);
		this.World.State.getPlayer().getSprite("zoom_banner").setBrush(banner);
		this.changeBannerItem(bannerID);

		if (::mods_getRegisteredMod("mod_stronghold") != null)
		{
			local faction = this.Stronghold.getPlayerFaction();
			if (faction == null) return;
			faction.setBanner(bannerID);
			local bannerSmall = faction.getBannerSmall();


			foreach (settlement in faction.getMainBases()) 
			{
				settlement.m.Banner = bannerID;
				local location_banner = settlement.getSprite("location_banner");
				location_banner.setBrush(bannerSmall);
				location_banner.Visible = true;
			}

			foreach (unit in faction.getUnits()) 
			{
				local banner = unit.getSprite("banner");
				banner.setBrush(bannerSmall);
				banner.Visible = true;
			}
		}
	}

	function changeBannerItem( _bannerID )
	{
		local banner = this.World.Assets.getStash().getItemByID("weapon.player_banner");

		if (banner != null)
		{
			banner.setVariant(_bannerID);
			banner.updateVariant();
			return;
		}

		foreach ( bro in this.World.getPlayerRoster().getAll() )
		{
			local items = bro.getItems();
			local allItems = items.getAllItems();

			foreach ( i in allItems )
			{
				if (i.getID() == "weapon.player_banner")
				{
					i.setVariant(_bannerID);
					i.updateVariant();

					if (!i.isInBag())
					{
						items.unequip(i);
						items.equip(i);
					}

					return;
				}
			}
		}
	}

};

