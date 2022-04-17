this.world_editor_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		PopupDialogVisible = false,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnClosePressedListener = null,

		// some stuffs to help
		IDToShowOnMap = null,
		TemporaryModel = null,
		StashCapacityBefore = 0,
		RosterTierIsChanged = false,
		StashIsChanged = false,
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

	function onDeserialize()
	{
		if (::World.Flags.has("InvalidContracts"))
		{
			::Woditor.InvalidContracts = split(::World.Flags.get("InvalidContracts"), "/");
		}

		::Woditor.PrepareContractOnCampaignStart();
	}

	function onSerialize()
	{
		if (::Woditor.InvalidContracts.len() == 0)
		{
			::World.Flags.remove("InvalidContracts");
			return;
		}

		local string = "";
		local max = ::Woditor.InvalidContracts.len() - 1;
		foreach (i, id in ::Woditor.InvalidContracts)
		{
			string += id;

			if (i != max)
			{
				string += "/";
			} 
		}

		if (string.len() == 0) return;
		::World.Flags.set("InvalidContracts", string);
	}

	function destroy()
	{
		this.clearEventListener();
		this.m.JSHandle = this.UI.disconnect(this.m.JSHandle);
	}

	function show( _withSlideAnimation = false )
	{
		this.m.IDToShowOnMap = false;
		this.m.StashIsChanged = false;
		this.m.BannerIsChanged = false;
		this.m.RosterTierIsChanged = false;

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

	function updateSomeShit()
	{
		if (this.m.StashIsChanged) this.World.State.getPlayer().forceRecalculateStashModifier();
		if (this.m.BannerIsChanged) this.updatePlayerBannerOnAllThings();
		if (this.m.IDToShowOnMap == null) return;

		local entity = this.World.getEntityByID(this.m.IDToShowOnMap);

		if (entity == null) return;
		local entityTile = entity.getTile();
		entity.setDiscovered(true);
		this.World.uncoverFogOfWar(entityTile.Pos, 500.0);
		this.World.getCamera().Zoom = 1.0;
		this.World.getCamera().setPos(entityTile.Pos);
		this.m.IDToShowOnMap = null;
	}

	function onCloseButtonPressed()
	{
		if (this.m.OnClosePressedListener != null)
		{
			this.m.OnClosePressedListener();
		}
	}

	function onShowWorldEntityOnMap( _id )
	{
		this.m.IDToShowOnMap = _id;
		this.onCloseButtonPressed();
	}

	function onReloadButtonPressed()
	{
		this.World.Retinue.update();
		this.World.Assets.updateLook();
		this.World.State.updateTopbarAssets();
		if (this.m.StashIsChanged) this.World.State.getPlayer().forceRecalculateStashModifier();
		if (this.m.BannerIsChanged) this.updatePlayerBannerOnAllThings();
		this.m.JSHandle.asyncCall("loadFromData", this.convertToUIData());
	}

	function onShowAllItems( _filter )
	{
		return ::Woditor.Items[_filter];
	}

	function onSeachItemBy( _data )
	{
		return ::Woditor.SearchItems(_data[0], _data[1]);
	}

	function onGetWolrdEntityImagePath( _id )
	{
		return ::Woditor.Helper.getWolrdEntityImagePath(_id);
	}

	function onGetBuildingEntries( _id )
	{
		return ::Woditor.Helper.convertBuildingEntriesToUIData(_id);
	}

	function onGetAttachedLocationEntries( _id )
	{
		return ::Woditor.Helper.convertAttachedLocationEntriesToUIData(_id);
	}

	function onGetSituationEntries( _id )
	{
		return ::Woditor.Helper.convertSituationEntriesToUIData(_id);
	}

	function onGetBannerSpriteEntries( _id )
	{
		return ::Woditor.Helper.convertBannerSpriteEntriesToUIData(_id);
	}

	function onGetUnitSpriteEntries( _id )
	{
		return ::Woditor.Helper.convertUnitSpriteEntriesToUIData(_id);
	}

	function onGetLocationSpriteEntries( _id )
	{
		return ::Woditor.Helper.convertLocationSpriteEntriesToUIData(_id);
	}

	function onGetTroopEntries( _data )
	{
		return ::Woditor.Helper.convertTroopEntriesToUIData(_data);
	}

	function onGetTroopTemplate( _type )
	{
		return ::Woditor.Helper.convertTroopTemplateToUIData(_type);
	}

	function onGetFactionLeaders( _id )
	{
		return ::Woditor.Helper.convertFactionLeadersToUIData(_id);
	}

	function onGetAvailableContracts( _emptyArray )
	{
		return ::Woditor.Helper.convertAvailableContractToUIData(_emptyArray);
	}

	function onCollectAllianceData( _data )
	{
		return ::Woditor.Helper.convertFactionAllianceToUIData(_data);
	}

	function onRefreshAllContracts( _emptyArray )
	{
		::World.Contracts.clearAllContracts();

		local factions = [];
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.Settlement));
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.NobleHouse));
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.OrientalCityState));
		
		foreach (f in factions)
		{
			f.setLastContractTime(0);

			foreach ( action in f.m.Deck )
			{
				action.resetCooldown();
			}

			for (local i = 0; i < 10; ++i)
			{
				f.update(true);
			}
		}
		
		this.log("Refreshed contract!");
		return ::Woditor.Helper.convertContractsToUIData();
	}

	function onRemoveContract( _id )
	{
		local contract = ::World.Contracts.removeContractByID(_id);

		if (contract == null)
		{
			return this.log("Failed to remove " + contract.getType() + " contract. Reason: can\'t find contract", true);
		}

		this.log("Successfully removed " + ::Const.UI.getColorized(contract.getType(), "#1e468f"));
	}

	function onAddNewContract( _script )
	{
		local contract = this.new(_script);
		local factions = [];
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.Settlement));
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.NobleHouse));
		factions.extend(::World.FactionManager.getFactionsOfType(::Const.FactionType.OrientalCityState));
		local faction; 
		do
		{
			faction = ::MSU.Array.getRandom(factions);
		}
		while(faction.getSettlements().len() == 0)
		local settlement = faction.getSettlements()[0];
		local employer = faction.getRandomCharacter();
		contract.setFaction(faction.getID());
		contract.setEmployerID(employer.getID());
		contract.setOrigin(settlement);
		contract.setHome(settlement);
		::World.Contracts.addContractByForce(contract);
		this.log("Added " + ::Const.UI.getColorized(contract.getType(), "#1e468f"));
		return {
			ID = contract.getID(),
			Name = contract.getName(),
			Type = contract.getType(),
			Icon = contract.getBanner() + ".png",
			Faction = faction.getID(),
			IsNegotiated = contract.isNegotiated(),
			DifficultyIcon = contract.getUIDifficultySmall() + ".png",
			DifficultyMult = ::Math.floor(contract.getDifficultyMult() * 100),
			PaymentMult = ::Math.floor(contract.getPaymentMult() * 100),
			Expire = ::Math.max(1, ::Math.abs(::Time.getVirtualTimeF() - contract.m.TimeOut) / ::World.getTime().SecondsPerDay),
			Origin = settlement.getID(),
			Home = settlement.getID()
			Employer = employer.getImagePath(),
			Objective = null,
		};
	}

	function onChangeContractFaction( _data )
	{
		local faction = ::World.FactionManager.getFaction(_data[1]);

		if (faction.getSettlements().len() == 0)
		{
			return this.log("Failed to change " + contract.getType() + " faction. Reason: selected faction has no settlement", true);
		}

		local contract = ::World.Contracts.getContractByID(_data[0]);

		if (contract == null)
		{
			return this.log("Failed to change faction of contract. Reason: can\'t find contract", true);
		}

		local result = {};
		local settlement = faction.getSettlements()[0];
		local employer = faction.getRandomCharacter();
		contract.setFaction(_data[1]);
		contract.setEmployerID(employer.getID());
		result.Faction <- _data[1];
		result.Employer <- employer.getImagePath();

		if (contract.getHome() != null && !contract.getHome().isNull())
		{
			contract.setHome(settlement);
			result.Home <- settlement.getID();
		}

		if (contract.getOrigin() != null && !contract.getOrigin().isNull())
		{
			contract.setOrigin(settlement);
			result.Origin <- settlement.getID();
		}
		
		this.log("Successfully changed " + ::Const.UI.getColorized(contract.getType(), "#1e468f") + " faction");
		this.m.JSHandle.asyncCall("refreshContractDetailPanel", result);
	}

	function onChangeLocationForContract( _data )
	{
		local contract = ::World.Contracts.getContractByID(_data[0]);
		local result = {};

		if (contract == null)
		{
			return this.log("Failed to change " + contract.getType() + " faction. Reason: can\'t find contract", true);
		}

		local world_entity = ::World.getEntityByID(_data[2]);

		switch (_data[1])
		{
		case "Home":
			contract.setHome(world_entity);
			result.Home <- world_entity.getID();
			this.log("Changed " + ::Const.UI.getColorized(contract.getType(), "#1e468f") + " Home to " + ::Const.UI.getColorized(world_entity.getName(), "#1e468f"));
			break;
	
		case "Origin":
			contract.setOrigin(world_entity);
			result.Origin <- world_entity.getID();
			this.log("Changed " + ::Const.UI.getColorized(contract.getType(), "#1e468f") + " Origin to " + ::Const.UI.getColorized(world_entity.getName(), "#1e468f"));
			break;
		}

		this.m.JSHandle.asyncCall("refreshContractDetailPanel", result);
	}

	function onContractInputChanges( _data )
	{
		local contract = this.World.Contracts.getContractByID(_data[0]);

		if (contract == null)
		{
			return this.log("Failed to change " + _data[1] + " of contract. Reason: can\'t find contract", true);
		}

		if (_data[1] == "Expiration")
		{
			contract.m.TimeOut = this.Time.getVirtualTimeF() + this.World.getTime().SecondsPerDay * _data[2];
			this.m.JSHandle.asyncCall("updateContractExpiration", null);
		}
		else
		{
			contract.m[_data[1]] = _data[2] * 0.01;

			if (_data[1] == "DifficultyMult")
			{
				this.m.JSHandle.asyncCall("updateContractDifficultyIcon", {DifficultyIcon = contract.getUIDifficultySmall() + ".png"});
			}
		}
	}

	function onInvalidContract( _data )
	{
		if (_data[1] == true)
		{
			local find = ::Woditor.InvalidContracts.find(_data[0]);

			if (find == null)
			{
				::Woditor.InvalidContracts.push(_data[0]);
			}

			return;
		}

		local find = ::Woditor.InvalidContracts.find(_data[0]);

		if (find != null)
		{
			::Woditor.InvalidContracts.remove(find);
		}
	}

	function onGetAllNonHostileFactionsOfThisFaction( _factionID )
	{
		local faction = ::World.FactionManager.getFaction(_factionID);
		local allies = faction.getAllies();
		local valid = [_factionID];

		foreach ( id in allies )
		{
			if (id > 2 && valid.find(id) == null) 
			{
				valid.push(id);
			}
		}

		return valid;
	}

	function onGetValidSettlementsToSendCaravan( _id )
	{
		local entity = ::World.getEntityByID(_id);
		local result = [];

		foreach(settlement in ::World.EntityManager.getSettlements())
		{
			if (settlement.getID() == _id) continue;
			if (entity.isAlliedWith(settlement)) continue;
			if (settlement.getOwner() != null && !settlement.getOwner().isNull() && entity.isAlliedWith(settlement.getOwner())) continue;
			result.push(settlement.getID());
		}

		return result;
	}

	function onUpdateNewOwnerFor( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local faction = ::World.FactionManager.getFaction(_data[1]);
		local currentOwner = world_entity.getOwner();

		if (currentOwner != null && world_entity.getFactions().len() > 1)
		{
			world_entity.removeFaction(currentOwner.getID());
		}

		world_entity.setOwner(faction);
		this.m.JSHandle.asyncCall("updateSettlementNewOwner", {Owner = _data[1]});
	}

	function onUpdateNewFactionFor( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);

		if (world_entity.isLocation() && world_entity.isLocationType(::Const.World.LocationType.Settlement))
		{
			if (world_entity.getOwner() != null && world_entity.getOwner().getID() != _data[2])
			{
				world_entity.removeFaction(_data[2]);
			}

			world_entity.addFaction(_data[1]);
			this.m.JSHandle.asyncCall("updateSettlementNewFaction", {Faction = _data[1]});
			return;
		}
		
		world_entity.setFaction(_data[1]);

		foreach ( troop in world_entity.getTroops() )
		{
			troop.Faction = world_entity.getFaction();
		}

		this.m.JSHandle.asyncCall((world_entity.isParty() ? "updateUnitNewFaction" : "updateLocationNewFaction"), {Faction = _data[1]});
	}

	function onUpdateFactionAlliance( _data )
	{
		local faction = ::World.FactionManager.getFaction(_data[0]);

		foreach(id in _data[1].Allies)
		{
			local f = ::World.FactionManager.getFaction(id);
			f.addAlly(_data[0]);
			faction.addAlly(id);
		}

		foreach(id in _data[1].Hostile)
		{
			local f = ::World.FactionManager.getFaction(id);
			f.removeAlly(_data[0]);
			faction.removeAlly(id);
		}

		this.log("Updated the alliance between " + ::Const.UI.getColorized(faction.getName(), "#1e468f") + " and other factions");
	}

	function onUpdateAvatarModel( _data )
	{
		switch (_data[0])
		{
		case "avatar":
			::World.Flags.set("AvatarSprite", _data[1]);
			this.m.TemporaryModel.getSprite("body").setBrush(_data[1]);
			break;

		case "socket":
			::World.Flags.set("AvatarSocket", _data[1]);
			this.m.TemporaryModel.getSprite("base").setBrush(_data[1]);
			break;
	
		case "flip":
			::World.Flags.set("AvatarIsFlippedHorizontally", _data[1]);
			this.m.TemporaryModel.setFlipped(_data[1]);
			break;

		default: // reset sprite back to scenario default
			::World.Flags.remove("AvatarSprite");
			::World.Flags.remove("AvatarSocket");
			::World.Flags.remove("AvatarIsFlippedHorizontally");
			::World.Assets.updateLook();
			this.m.TemporaryModel.getSprite("base").setBrush(::World.State.getPlayer().getSprite("base").getBrush().Name);
			this.m.TemporaryModel.getSprite("body").setBrush(::World.State.getPlayer().getSprite("body").getBrush().Name);
			this.m.TemporaryModel.setFlipped(false);
		}

		this.m.TemporaryModel.setDirty(true);
		this.m.JSHandle.asyncCall("updateAvatarImage", this.m.TemporaryModel.getImagePath());
	}

	function onChangePlayerBanner( _banner )
	{
		this.m.BannerIsChanged = true;
		::World.Assets.m.Banner = _banner;
		::World.Assets.m.BannerID = _banner.slice(_banner.find("_") + 1).tointeger();
	}

	function onChangeCompanyName( _name )
	{
		::World.Assets.m.Name = _name;
	}

	function onChangeFactionBanner( _data )
	{
		// find banner
		if (_data[0] > ::Const.NobleBanners.len() - 1 && _data[0] > ::Const.OtherBanner.len() - 1) return;

		local faction = ::World.FactionManager.getFaction(_data[1]);
		faction.setBanner(_data[0]);
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

		this.m.JSHandle.asyncCall("updateFactionContracts", ::Woditor.Helper.getContractsUI(faction));
	}

	function onChangeFactionName( _data )
	{
		::World.FactionManager.getFaction(_data[0]).setName(_data[1]);
	}

	function onChangeFactionMotto( _data )
	{
		::World.FactionManager.getFaction(_data[0]).setMotto(_data[1]);
	}

	function onDespawnFactionTroops( _id )
	{
		local faction = ::World.FactionManager.getFaction(_id);
		local new = [];

		foreach( u in faction.getUnits() )
		{
			// despawn all non-quest units
			if (!u.getSprite("selection").Visible) u.die();
			else new.push(u);
		}

		faction.m.Units = new;
	}

	function onRefreshFactionLeader( _id )
	{
		local faction = ::World.FactionManager.getFaction(_id);
		faction.getRoster().clear();
		faction.onUpdateRoster();

		foreach ( contract in faction.getContracts() )
		{
			contract.setEmployerID(faction.getRandomCharacter().getID());
		}

		return ::Woditor.Helper.convertFactionLeadersToUIData(_id);
	}

	function onRefreshFactionActions( _id )
	{
		local faction = ::World.FactionManager.getFaction(_id);
		faction.m.LastActionTime = 0;
		faction.m.LastActionHour = 0;

		foreach ( action in faction.m.Deck )
		{
			action.resetCooldown();
		}
	}

	function onRefreshFactionContracts( _id )
	{
		local faction = ::World.FactionManager.getFaction(_id);
		faction.setLastContractTime(0);

		foreach ( action in faction.m.Deck )
		{
			action.resetCooldown();
		}

		foreach ( contract in faction.getContracts() )
		{
			if (contract.isActive()) continue;

			contract.onClear();
			local i = ::World.Contracts.getOpenContracts().find(contract);

			if (i != null)
			{
				::World.Contracts.getOpenContracts().remove(i);
			}

			if (::World.Contracts.m.LastShown == contract)
			{
				::World.Contracts.m.LastShown = null;
			}
		}

		this.m.JSHandle.asyncCall("addContractsData", ::Woditor.Helper.convertContractsToUIData());
		this.log("Refreshed contracts of faction " + ::Const.UI.getColorized(faction.getName(), "#1e468f") + "!");
	}

	function onChangeWorldEntityName( _data )
	{
		::World.getEntityByID(_data[0]).setName(_data[1]);
	}

	function onChangeWorldEntityBanner( _data )
	{
		::World.getEntityByID(_data[0]).setBanner(_data[1]);
	}

	function onChangeWorldEntitySprite( _data )
	{
		::World.getEntityByID(_data[0]).getSprite("body").setBrush(_data[1]);
	}

	function onUpdateWorldEntityBaseMovementSpeed( _data )
	{
		::World.getEntityByID(_data[0]).setMovementSpeed(_data[1]);
	}

	function onUpdateWorldEntityVisibilityMult( _data )
	{
		::World.getEntityByID(_data[0]).setVisibilityMult(_data[1] / 100);
	}

	function onUpdateWorldEntityLootScale( _data )
	{
		::World.getEntityByID(_data[0]).setLootScale(_data[1] / 100);
	}

	function onChangeScenario( _id )
	{
		::World.Assets.m.Origin = ::Const.ScenarioManager.getScenario(_id);
	}

	function onChangeActiveStatusOfSettlement( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		world_entity.setActive(_data[1], false);
		this.log(::Const.UI.getColorized(world_entity.getName(), "#1e468f") + " has become " + (_data[1] ? "active." : "inactive."));
	}

	function onRefreshSettlementShop( _id )
	{
		local world_entity = ::World.getEntityByID(_id)
		world_entity.resetShop();
		this.log(::Const.UI.getColorized(world_entity.getName(), "#1e468f") + "\'s shops have refreshed their stocks.");
	}

	function onRefreshSettlementRoster( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		world_entity.resetRoster(true);
		this.log(::Const.UI.getColorized(world_entity.getName(), "#1e468f") + " has refreshed its recruit roster.");
	}

	function onAddHouse( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local isAddHouse = _data[1];

		if (isAddHouse)
		{
			if (!world_entity.buildHouse())
			{
				this.log("Failed to build house. Reason: can\'t find suitable tile to build", true);
			}
		}
		else
		{
			if (!world_entity.destroyHouse())
			{
				this.log("Failed to destroy house. Reason: there is no house", true);
			}
		}
	}

	function onAddBuildingToSlot( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local slot = _data[1];
		local logText = "Added ";

		if (world_entity.m.Buildings[slot] != null)
		{
			logText = "Replaced " + ::Const.UI.getColorized(world_entity.m.Buildings[slot].getName(), "#1e468f") + " with ";
			world_entity.m.Buildings[slot].m.Settlement = null;
			world_entity.m.Buildings[slot] = null;
		}

		local building = ::new(_data[2]);
		building.setSettlement(world_entity);
		world_entity.m.Buildings[slot] = building;
		logText += ::Const.UI.getColorized(building.getName(), "#1e468f");

		if ("getStash" in building)
		{
			building.onUpdateShopList();
		}
		
		this.m.JSHandle.asyncCall("updateSettlementBuildingSlot", {
			Slot = _data[1],
			Data = {
				ID = building.getID(),
				ImagePath = building.m.UIImage + ".png",
				TooltipId = building.m.Tooltip,
			},
		});
		this.log(logText);
	}

	function onRemoveBuilding( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local slot = _data[1];
		local id = _data[2];
		local name = "";

		if (world_entity.m.Buildings[slot] == null || world_entity.m.Buildings[slot].getID() != id) return;

		world_entity.m.Buildings[slot].m.Settlement = null;
		name = ::Const.UI.getColorized(world_entity.m.Buildings[slot].getName(), "#1e468f");
		world_entity.m.Buildings[slot] = null;

		this.m.JSHandle.asyncCall("updateSettlementBuildingSlot", {
			Slot = _data[1],
			Data = null,
		});
		this.log("Removed " + name + " building");
	}

	function onAddAttachedLocationToSlot( _data )
	{
		local result = [];
		local world_entity = ::World.getEntityByID(_data[0]);
		local nearRoad = ::Const.NearRoadAttachedLocations.find(_data[1]) != null;
		local additionalTile = ::Math.rand(0, 1);
		local attachment = this.buildAttachedLocation(world_entity, _data[1], additionalTile, nearRoad);
		local tries = 0

		while(attachment == null && tries < 6)
		{
			++additionalTile;
			attachment = this.buildAttachedLocation(world_entity, _data[1], additionalTile, nearRoad);
		}

		if (attachment == null) 
		{
			this.log("Failed to add new attached location. Reason: can\'t find suitable tile to spawn", true);
			return;
		} 

		world_entity.updateProduce();

		foreach( attached in world_entity.getAttachedLocations() )
		{
			if (attached.getTypeID() == "attached_location.harbor")
			{
				continue;
			}

			result.push({
				ID = attached.getTypeID(),
				ImagePath = attached.getUIImage(),
			});
		}

		this.m.JSHandle.asyncCall("updateAttachmentList", {
			Attachments = result,
			IsUpdating = true
		});
		this.log("Added " + ::Const.UI.getColorized(attachment.getName(), "#1e468f") + " attached location");
	}

	function onRemoveAttachedLocation( _data )
	{
		local entity = ::World.getEntityByID(_data[0]);
		local id = _data[1];
		local find;

		foreach(i, attachment in entity.getAttachedLocations() )
		{
			if (attachment.getTypeID() == id)
			{
				find = i;
				break;
			}
		}

		if (find == null) 
		{
			this.log("Failed to remove attached location. Reason: selected attached location don\'t exist", true);
			return;
		}

		local result = [];
		local remove = entity.getAttachedLocations().remove(find);
		local name = remove.getName();
		remove.die();

		foreach( attachment in entity.getAttachedLocations() )
		{
			if (attachment.getTypeID() == "attached_location.harbor")
			{
				continue;
			}

			result.push({
				ID = attachment.getTypeID(),
				ImagePath = attachment.getUIImage(),
			});
		}

		this.m.JSHandle.asyncCall("updateAttachmentList", {
			Attachments = result,
			IsUpdating = true
		});
		this.log("Removed " + ::Const.UI.getColorized(name, "#1e468f") + " attached location");
	}

	function onAddSituationToSlot( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local result = [];
		local added = _data[1].len();
		local before = world_entity.getSituations().len();

		foreach (script in _data[1])
		{
			local situation = ::new(script);
			world_entity.addSituation(situation, 7); // i set up the default duration of the situaton to be 7 days
		}

		foreach (situation in world_entity.getSituations())
		{
			result.push({
				ID = situation.getID(),
				ImagePath = situation.getIcon()
			});
		}
		
		this.m.JSHandle.asyncCall("updateSituationList", {
			Situations = result,
			IsUpdating = true
		});

		if (before + added > 10)
		{
			local overflow = before + added - 10;
			this.log("Added " + ::Const.UI.getColorized(added, "#135213") + " situation" + (added > 1 ? "s" : "") + " and removed " + ::Const.UI.getColorized(overflow, "#8f1e1e") + " situation" + (overflow > 1 ? "s" : "") + " due to overflow");
		}
		else
		{
			this.log("Added " + ::Const.UI.getColorized(added, "#135213") + " situation" + (added > 1 ? "s" : ""));
		}
	}

	function onRemoveSituation( _data )
	{
		local entity = ::World.getEntityByID(_data[0]);
		local result = [];
		entity.removeSituationByID(_data[1]);

		foreach( situation in entity.getSituations() )
		{
			result.push({
				ID = situation.getID(),
				ImagePath = situation.getIcon()
			});
		}

		this.m.JSHandle.asyncCall("updateSituationList", {
			Situations = result,
			IsUpdating = true
		});
		this.log("Removed a situation");
	}

	function onRemoveLoot( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local remove = world_entity.getLoot().getItemByInstanceID(_data[1]);
		local result = [];

		if (remove == null) 
		{
			return this.log("Failed to remove the item from loot pool. Reason: can\'t find item", true);
		}
		else
		{
			world_entity.getLoot().removeByIndex(remove.index);
			world_entity.getLoot().sort();
		}

		foreach ( item in world_entity.getLoot().m.Items )
		{
			if (item != null)
			{
				result.push(::Woditor.Helper.convertItemToUIData(item, _data[0]));
			}
		}

		this.m.JSHandle.asyncCall("updateLocationLoots", {
			Loots = result,
			IsUpdating = true
		});
		this.log("Removed " + ::Const.UI.getColorized(remove.item.getName(), "#135213") + " from loot pool");
	}

	function onRerollLoots( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		local result = [];
		world_entity.getLoot().clear();
		world_entity.location.onSpawned();

		foreach ( item in world_entity.getLoot().m.Items )
		{
			if (item != null)
			{
				result.push(::Woditor.Helper.convertItemToUIData(item, _id));
			}
		}

		this.m.JSHandle.asyncCall("updateLocationLoots", {
			Loots = result,
			IsUpdating = true
		});
		this.log("Loots has been refreshed!");
	}

	function onAddItemToLoot( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local newItem = ::new(_data[1]);
		local result = [];
		world_entity.getLoot().add(newItem);

		foreach ( item in world_entity.getLoot().m.Items )
		{
			if (item != null)
			{
				result.push(::Woditor.Helper.convertItemToUIData(item, _data[0]));
			}
		}

		this.m.JSHandle.asyncCall("updateLocationLoots", {
			Loots = result,
			IsUpdating = true
		});
		this.log("Added " + ::Const.UI.getColorized(newItem.getName(), "#135213") + " to loot pool");
	}

	function onAddRandomNamedItem( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		local result = [];
		local items = [];
		local pick;

		switch (::Math.rand(1, 4))
		{
		case 1:
			items.extend(::Const.Items.NamedHelmets);
			if (world_entity.m.NamedHelmetsList != null && world_entity.m.NamedHelmetsList.len() != 0)
			{
				items.extend(world_entity.m.NamedHelmetsList);
				items.extend(world_entity.m.NamedHelmetsList);
			}
			if (::LegendsMod.Configs().LegendArmorsEnabled())
			{
				local weightName = ::Const.World.Common.convNameToList(items);
				pick = ::Const.World.Common.pickHelmet(weightName);
			}
			break;

		case 2:
			items.extend(::Const.Items.NamedArmors);
			if (world_entity.m.NamedArmorsList != null && world_entity.m.NamedArmorsList.len() != 0)
			{
				items.extend(world_entity.m.NamedArmorsList);
				items.extend(world_entity.m.NamedArmorsList);
			}
			if (::LegendsMod.Configs().LegendArmorsEnabled())
			{
				local weightName = ::Const.World.Common.convNameToList(items);
				pick = ::Const.World.Common.pickArmor(weightName);
			}
			break;

		case 3:
			items.extend(::Const.Items.NamedShields);
			if (world_entity.m.NamedShieldsList != null && world_entity.m.NamedShieldsList.len() != 0)
			{
				items.extend(world_entity.m.NamedShieldsList);
				items.extend(world_entity.m.NamedShieldsList);
			}
			break;

		default:
			items.extend(::Const.Items.NamedWeapons);
			if (world_entity.m.NamedWeaponsList != null && world_entity.m.NamedWeaponsList.len() != 0)
			{
				items.extend(world_entity.m.NamedWeaponsList);
				items.extend(world_entity.m.NamedWeaponsList);
			}
		}

		if (pick == null)
		{
			if (items.len() > 0)
			{
				pick = ::new("scripts/items/" + ::MSU.Array.getRandom(items));
			}
			else
			{
				return this.log("Failed to add a random named item. Reason: the named item table is empty", true);
			}
		}
			
		world_entity.getLoot().add(pick);

		foreach ( item in world_entity.getLoot().m.Items )
		{
			if (item != null)
			{
				result.push(::Woditor.Helper.convertItemToUIData(item, _id));
			}
		}

		this.m.JSHandle.asyncCall("updateLocationLoots", {
			Loots = result,
			IsUpdating = true
		});
		this.log("Randomly picked and added " + ::Const.UI.getColorized(pick.getName(), "#135213") + " to loot pool");
	}

	function onAddRandomLootItem( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		local pick = ::new("scripts/items/" + ::MSU.Array.getRandom(::Const.RandomTreasure));
		local result = [];
		world_entity.getLoot().add(pick);

		foreach ( item in world_entity.getLoot().m.Items )
		{
			if (item != null)
			{
				result.push(::Woditor.Helper.convertItemToUIData(item, _id));
			}
		}

		this.m.JSHandle.asyncCall("updateLocationLoots", {
			Loots = result,
			IsUpdating = true
		});
		this.log("Randomly picked and added " + ::Const.UI.getColorized(pick.getName(), "#135213") + " to loot pool");
	}

	function onRerollTroop( _id )
	{
		local world_entity = ::World.getEntityByID(_id);

		if (world_entity.isLocation())
		{
			world_entity.m.LastSpawnTime = 0.0;
			world_entity.createDefenders();
			this.m.JSHandle.asyncCall("updateLocationTroops", {
				Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
				IsUpdating = true
			});
		}
		else
		{
			
		}

		this.log("Troop list has been refreshed!");
	}

	function onRemoveTroop( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local troop = _data[1];
		local new = [];

		foreach ( t in world_entity.getTroops() )
		{
			if (troop.Key == ::Woditor.getTroopKey(t) && troop.IsChampion == (t.Variant != 0)) 
			{
				continue;
			}

			new.push(t);
		}

		world_entity.m.Troops = new;
		world_entity.updateStrength();
		this.m.JSHandle.asyncCall((world_entity.isParty() ? "updateUnitTroops" : "updateLocationTroops"), {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log("Removed " + ::Const.UI.getColorized(troop.Name, "#135213") + " from troop list, " + ::Const.UI.getColorized(troop.Num, "#135213") + " in total");
	}

	function onAddRandomTroop( _data )
	{
		local list = clone ::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All];
		local world_entity = ::World.getEntityByID(_data[0]);
		local result = [];

		foreach( key in _data[1] )
		{
			local i = list.find(key);

			if (i != null)
			{
				list.remove(i);
			}
		}

		local t = clone ::Const.World.Spawn.Troops[::MSU.Array.getRandom(list)];
		t.Party <- ::WeakTableRef(world_entity);
		t.Faction <- world_entity.getFaction();
		t.Name <- "";
		t.Variant = 0;
		world_entity.getTroops().push(t);
		world_entity.updateStrength();
		this.m.JSHandle.asyncCall((world_entity.isParty() ? "updateUnitTroops" : "updateLocationTroops"), {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log("Randomly picked and added " + ::Const.UI.getColorized(::Woditor.getTroopName(t), "#135213") + " to troop list");
	}

	function onAddNewTroop( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);

		foreach( key in _data[1] )
		{
			local t = clone ::Const.World.Spawn.Troops[key];
			t.Party <- ::WeakTableRef(world_entity);
			t.Faction <- world_entity.getFaction();
			t.Name <- "";
			t.Variant = 0;
			world_entity.getTroops().push(t);
			this.log("Added " + ::Const.UI.getColorized(::Woditor.getTroopName(t), "#135213") + " to troop list");
		}

		world_entity.updateStrength();
		this.m.JSHandle.asyncCall((world_entity.isParty() ? "updateUnitTroops" : "updateLocationTroops"), {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
	}

	function onChangeTroopNum( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local troops = world_entity.getTroops();
		local troop = _data[1];
		local different = _data[2];
		local text = "";
		
		if (different > 0)
		{
			text = "Removed " + different + " " + ::Const.UI.getColorized(troop.Name, "#135213") + " from troop list";
			for (local i = troops.len() - 1; i >= 0; --i) 
			{
		        local t = troops[i];

		        if (troop.Key == ::Woditor.getTroopKey(t) && troop.IsChampion == (t.Variant != 0)) 
				{
					troops.remove(i);

					if (--different == 0)
					{
						break;
					}
				}
		    }
		}
		else
		{
			text = "Added " + ::Math.abs(different) + " more " + ::Const.UI.getColorized(troop.Name, "#135213") + " to troop list";
			while (different < 0)
			{
				local t = clone ::Const.World.Spawn.Troops[troop.Key];
				t.Party <- ::WeakTableRef(world_entity);
				t.Faction <- world_entity.getFaction();
				t.Name <- "";
				t.Variant = 0;

				if (troop.IsChampion)
				{
					if ("NameList" in ::Const.World.Spawn.Troops[troop.Key])
					{
						t.Name = ::Const.World.Common.generateName(::Const.World.Spawn.Troops[troop.Key].NameList) + ((::Const.World.Spawn.Troops[troop.Key].TitleList != null) ? " " + ::MSU.Array.getRandom(::Const.World.Spawn.Troops[troop.Key].TitleList) : "");
					}
					else
					{
						t.Name = "Champion " + ::Const.Strings.EntityName[t.ID];
					}

					t.Variant = ::Math.rand(1, 255);
					t.Strength = ::Math.round(t.Strength * 1.35);
				}

				world_entity.getTroops().push(t);
				++different;
			}
		}

		world_entity.updateStrength();
		this.log(text);
	}

	function onConvertTroopToChampion( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local troop = _data[1];
		local text = "";

		if (!troop.IsChampion)
		{
			text = "Convert a " + ::Const.UI.getColorized(troop.Name, "#135213") + " into a champion";
			foreach ( t in world_entity.getTroops() )
			{
				local key = ::Woditor.getTroopKey(t);

				if (t.Variant == 0 && troop.Key == key)
				{
					if ("NameList" in ::Const.World.Spawn.Troops[key])
					{
						t.Name = ::Const.World.Common.generateName(::Const.World.Spawn.Troops[key].NameList) + ((this.Const.World.Spawn.Troops[key].TitleList != null) ? " " + ::MSU.Array.getRandom(::Const.World.Spawn.Troops[troop.Key].TitleList) : "");
					}
					else
					{
						t.Name = "Champion " + ::Const.Strings.EntityName[t.ID];
					}

					t.Variant = ::Math.rand(1, 255);
					t.Strength = ::Math.round(t.Strength * 1.35);
					break;
				}
			}
		}
		else
		{
			text = "Revert a champion " + ::Const.UI.getColorized(troop.Name, "#135213") + " back to a normal one";
			foreach ( t in world_entity.getTroops() )
			{
				local key = ::Woditor.getTroopKey(t);

				if (t.Variant != 0 && troop.Key == key)
				{
					t.Name = "";
					t.Variant = 0;
					t.Strength = ::Const.World.Spawn.Troops[key].Strength;
					break;
				}
			}
		}

		world_entity.updateStrength();
		this.m.JSHandle.asyncCall((world_entity.isParty() ? "updateUnitTroops" : "updateLocationTroops"), {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log(text);
	}

	function onUpdateResourseValue( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		world_entity.setResources(_data[1]);

		if (world_entity.isParty())
		{
			return;
		}
		
		if (world_entity.isLocationType(::Const.World.LocationType.Settlement))
		{
			this.m.JSHandle.asyncCall("updateSettlementWealth", {
				Wealth = world_entity.getWealth(),
				IsUpdating = true
			});
		}
		else
		{
			this.m.JSHandle.asyncCall("updateLocationNamedItemChance", {
				NamedItemChance = world_entity.getNameItemChance(),
				IsUpdating = true
			});
		}
	}

	function onUpdateWealthValue( _data )
	{
		local world_entity = ::World.getEntityByID(_data[0]);
		local baseLevel = 0.0;

		if (world_entity.isMilitary()) baseLevel = baseLevel + 50.0;
		if (::isKindOf(world_entity, "city_state")) baseLevel = baseLevel + 100;

		switch(world_entity.getSize())
		{
		case 1:
			baseLevel = baseLevel + 100.0;
			break;

		case 2:
			baseLevel = baseLevel + 150.0;
			break;

		case 3:
			baseLevel = baseLevel + 200.0;
			break;
		}

		local resources = ::Math.round(_data[1] * baseLevel / 100);
		world_entity.setResources(resources);
		this.m.JSHandle.asyncCall("updateSettlementResources", {
			Resources = resources,
			IsUpdating = true
		});
	}

	function onUpdateAssetsValue( _data )
	{
		if (_data[0] == "Stash")
		{
			local before = this.m.StashCapacityBefore;

			if (_data[1] != before) {
				this.m.StashIsChanged = true;
			}

			::World.Flags.set("StashModifier", _data[1] - before);
		}
		else
		{
			::World.Assets.m[_data[0]] = _data[1];
		}
	}

	function onUpdateAssetsPropertyValue( _data )
	{
		local key = _data[0];
		local value = _data[1];
		local baseValue = ::World.Assets.getBaseProperties()[key];
		local isMult = ::Woditor.AssetsProperties.Mult.find(key) != null;
		local isAdditive = ::Woditor.AssetsProperties.Additive.find(key) != null;

		if (isMult) ::World.Flags.set(key, value / baseValue * 100);
		else if (isAdditive) ::World.Flags.set(key, value - baseValue);
		else ::World.Flags.set(key, value);
	}

	function onUpdateRosterTier( _tier )
	{
		::World.Flags.set("RosterTier", _tier);
	}

	function onUpdateDifficultyMult( _value )
	{
		::World.Flags.set("DifficultyMult", _value / 100);
	}

	function onUpdateCombatDifficulty( _value )
	{
		::World.Assets.m.CombatDifficulty = _value;
	}

	function onUpdateEconomicDifficulty( _value )
	{
		::World.Assets.m.EconomicDifficulty = _value;
	}

	function onUpdateGenderLevel( _value )
	{
		::LegendsMod.Configs().m.IsGender = _value;
	}

	function onUpdateAssetsCheckBox( _data )
	{
		if (_data[0] in ::World.Assets.m) ::World.Assets.m[_data[0]] = _data[1];
		else ::LegendsMod.Configs().m[_data[0]] = _data[1];
	}

	function onUpdateUnitCheckBox( _data )
	{
		::World.getEntityByID(_data[0]).m[_data[1]] = _data[2];
	}

	function updateFactionRelation( _data )
	{
		local faction = ::World.FactionManager.getFaction(_data[0]);
		faction.setPlayerRelation(_data[1]);
		return {
			Relation = faction.getPlayerRelationAsText(),
			RelationNum = ::Math.round(faction.getPlayerRelation())
		};
	}

	function onUpdateFactionRelationDeterioration( _data )
	{
		::World.FactionManager.getFaction(_data[0]).getFlags().set("RelationDeterioration",_data[1]);
	}

	function onSendCaravanTo( _data )
	{
		local resources = _data[2];
		local start = ::World.getEntityByID(_data[0]);
		local destination = ::World.getEntityByID(_data[1]);
		local faction =  ::World.FactionManager.getFaction(::MSU.Array.getRandom(start.getFactions()));

		if (_data[3].find("Noble") != null && faction.getType() != ::Const.FactionType.NobleHouse)
		{
			local owner = start.getOwner();

			if (owner != null && !owner.isNull() && owner.getType() == ::Const.FactionType.NobleHouse)
			{
				faction = owner.get();
			}
			else
			{
				_data[3] = "CaravanSouthern";
			}
		}

		local party = faction.spawnEntity(start.getTile(), "Trading Caravan", false, ::Const.World.Spawn[_data[3]], resources);
		party.getSprite("banner").Visible = false;
		party.getSprite("base").Visible = false;
		party.setDescription("A trading caravan from " + start.getName() + " that is transporting all manner of goods between settlements.");
		party.setFootprintType(::Const.World.FootprintsType.Caravan);
		party.setMirrored(true);
		party.setAttackableByAI(_data[4]);
		party.setSlowerAtNight(_data[5]);
		party.setLootScale(_data[6] ? 2.0 : 1.0);
		party.getFlags().set("IsCaravan", true);
		party.getFlags().set("IsRandomlySpawned", true);

		if (::World.Assets.m.IsBrigand)
		{
			party.setVisibleInFogOfWar(true);
			party.setImportant(true);
			party.setDiscovered(true);
		}

		if (start.getProduce().len() == 0) start.updateProduce();
	
		local produce = 3
		if(::LegendsMod.Configs().LegendWorldEconomyEnabled())
		{
			produce = ::Math.max(3, 3 + ::Math.round(0.025 * resources));
		}

		for( local j = 0; j < produce; j = ++j )
		{
			party.addToInventory(::MSU.Array.getRandom(start.getProduce()));
		}

		party.getLoot().Money = ::Math.rand(0, 100);
		party.getLoot().ArmorParts = ::Math.rand(0, 10);
		party.getLoot().Medicine = ::Math.rand(0, 10);
		party.getLoot().Ammo = ::Math.rand(0, 25);

		if(::LegendsMod.Configs().LegendWorldEconomyEnabled())
		{
			local investment = ::Math.max(1, ::Math.round(0.033 * resources));
			start.setResources(::Math.max(10, start.getResources() - investment));
			party.setResources(investment);

			local r = ::Math.rand(1,3);
			for( local j = 0; j < r; j = ++j )
			{
				local items = [
					[0, "supplies/bread_item"],
					[0, "supplies/roots_and_berries_item"],
					[0, "supplies/dried_fruits_item"],
					[0, "supplies/ground_grains_item"],
					[0, "supplies/dried_fish_item"],
					[0, "supplies/beer_item"],
					[0, "supplies/goat_cheese_item"],
					[1, "supplies/legend_fresh_fruit_item"],
					[1, "supplies/legend_fresh_meat_item"],
					[1, "supplies/legend_pie_item"],
					[1, "supplies/legend_porridge_item"],
					[1, "supplies/legend_pudding_item"],
					[0, "supplies/mead_item"],
					[0, "supplies/medicine_item"],
					[0, "supplies/pickled_mushrooms_item"],
					[0, "supplies/preserved_mead_item"],
					[0, "supplies/smoked_ham_item"],
					[0, "supplies/wine_item"]
				]

				local item = ::Const.World.Common.pickItem(items)
				party.addToInventory(item);
			}
		}
		else
		{
			local supplies = ["bread_item", "roots_and_berries_item", "dried_fruits_item", "ground_grains_item"];
			party.addToInventory("supplies/" + ::MSU.Array.getRandom(supplies));
		}

		local c = party.getController();
		c.getBehavior(::Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		c.getBehavior(::Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		local move = ::new("scripts/ai/world/orders/move_order");
		move.setDestination(destination.getTile());
		move.setRoadsOnly(true);
		local unload = ::new("scripts/ai/world/orders/unload_order");
		local despawn = ::new("scripts/ai/world/orders/despawn_order");
		c.addOrder(move);
		c.addOrder(unload);
		c.addOrder(despawn);

		this.log("Successfully sent a caravan from " + ::Const.UI.getColorized(start.getName(), "#1e468f") + " to " + ::Const.UI.getColorized(destination.getName(), "#1e468f"));
	}

	function onSendMercenaryTo( _data )
	{
		local resources = _data[2];
		local start = ::World.getEntityByID(_data[0]);
		local destination = ::World.getEntityByID(_data[1]);
		local faction =  ::World.FactionManager.getFaction(::MSU.Array.getRandom(start.getFactions()));
		local party = ::World.spawnEntity("scripts/entity/world/party", start.getTile().Coords);
		party.setPos(::createVec(party.getPos().X - 50, party.getPos().Y - 50));
		party.setDescription("A free mercenary company travelling the lands and lending their swords to the highest bidder.");
		party.setFootprintType(::Const.World.FootprintsType.Mercenaries);
		party.setAttackableByAI(_data[4]);
		party.setSlowerAtNight(_data[5]);
		party.setLootScale(_data[6] ? 2.0 : 1.0);
		party.getSprite("base").setBrush("world_base_07");
		party.getFlags().set("IsMercenaries", true);

		if (start.getFactions().len() == 1)
		{
			party.setFaction(start.getOwner().getID());
		}
		else
		{
			party.setFaction(start.getFactionOfType(::Const.FactionType.Settlement).getID());
		}

		::Const.World.Common.assignTroops(party, ::Const.World.Spawn[_data[3]], resources);
		party.getLoot().Money = ::Math.rand(300, 600);
		party.getLoot().ArmorParts = ::Math.rand(0, 25);
		party.getLoot().Medicine = ::Math.rand(0, 10);
		party.getLoot().Ammo = ::Math.rand(0, 50);

		if (_data[3] == "Assassins")
		{
			party.getSprite("body").setBrush("figure_mercenary_0" + ::Math.rand(1, 2));
		}

		local supplies = ["bread_item", "roots_and_berries_item", "dried_fruits_item", "ground_grains_item"];
		local loots = [
			"silver_bowl_item", "jeweled_crown_item", "ancient_amber_item", "webbed_valuables_item", "looted_valuables_item",
			"white_pearls_item", "rainbow_scale_item", "lindwurm_hoard_item", "silverware_item",
		];
		party.addToInventory("supplies/" + ::MSU.Array.getRandom(supplies));
		party.addToInventory("loot/" + ::MSU.Array.getRandom(loots));

		local c = party.getController();
		local wait1 = ::new("scripts/ai/world/orders/wait_order");
		wait1.setTime(::Math.rand(5, 7) * 1.0);
		local move = ::new("scripts/ai/world/orders/move_order");
		move.setDestination(destination.getTile());
		move.setRoadsOnly(false);
		local wait2 = ::new("scripts/ai/world/orders/wait_order");
		wait2.setTime(::Math.rand(10, 60) * 1.0);
		local mercenary = ::new("scripts/ai/world/orders/mercenary_order");
		mercenary.setSettlement(destination);
		c.addOrder(wait1);
		c.addOrder(move);
		c.addOrder(wait2);
		c.addOrder(mercenary);

		while (true)
		{
			local name = ::MSU.Array.getRandom(::Const.Strings.MercenaryCompanyNames);

			if (name == ::World.Assets.getName())
			{
				continue;
			}

			local abort = false;

			foreach( p in ::World.EntityManager.m.Mercenaries )
			{
				if (p.getName() == name)
				{
					abort = true;
					break;
				}
			}

			if (abort)
			{
				continue;
			}

			party.setName(name);
			break;
		}

		while (true)
		{
			local banner = ::MSU.Array.getRandom(::Const.PlayerBanners);

			if (banner == ::World.Assets.getBanner())
			{
				continue;
			}

			local abort = false;

			foreach( p in ::World.EntityManager.m.Mercenaries )
			{
				if (p.getBanner() == banner)
				{
					abort = true;
					break;
				}
			}

			if (abort)
			{
				continue;
			}

			party.getSprite("banner").setBrush(banner);
			break;
		}

		::World.EntityManager.m.Mercenaries.push(::WeakTableRef(party));
		this.log("Successfully sent a mercenary company from " + ::Const.UI.getColorized(start.getName(), "#1e468f") + " to " + ::Const.UI.getColorized(destination.getName(), "#1e468f"));
	}

	function convertToUIData()
	{
		local result = {};
		result.Assets <- ::Woditor.Helper.convertAssetsToUIData();
		result.Avatar <- ::Woditor.Helper.convertAvatarToUIData(this);
		result.Factions <- ::Woditor.Helper.convertFactionsToUIData();
		result.Contracts <- ::Woditor.Helper.convertContractsToUIData();
		result.Settlements <- ::Woditor.Helper.convertSettlementsToUIData();
		result.Locations <- ::Woditor.Helper.convertLocationsToUIData();
		result.Units <- ::Woditor.Helper.convertUnitsToUIData();
		result.Filter <- ::Woditor.Helper.convertToUIFilterData(result.Factions);
		result.Scenario <- ::Woditor.Helper.convertScenariosToUIData();
		this.m.StashCapacityBefore = result.Assets.Stash;
		return result;
	}

	function updatePlayerBannerOnAllThings()
	{
		local banner = ::World.Assets.getBanner();
		local bannerID = ::World.Assets.getBannerID();
		::World.State.getPlayer().getSprite("banner").setBrush(banner);
		::World.State.getPlayer().getSprite("zoom_banner").setBrush(banner);
		this.changeBannerItem(bannerID);

		if (::mods_getRegisteredMod("mod_stronghold") != null)
		{
			local faction = ::Stronghold.getPlayerFaction();
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
		local banner = ::World.Assets.getStash().getItemByID("weapon.player_banner");

		if (banner != null)
		{
			banner.setVariant(_bannerID);
			banner.updateVariant();
			return;
		}

		foreach ( bro in ::World.getPlayerRoster().getAll() )
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

	function buildAttachedLocation(_settlement, _script, _additionalDistance = 0, _mustBeNearRoad = false, _clearTile = true)
	{
		local terrain = [
			::Const.World.TerrainType.Plains,
			::Const.World.TerrainType.Swamp,
			::Const.World.TerrainType.Hills,
			::Const.World.TerrainType.Forest,
			::Const.World.TerrainType.SnowyForest,
			::Const.World.TerrainType.LeaveForest,
			::Const.World.TerrainType.AutumnForest,
			::Const.World.TerrainType.Mountains,
			::Const.World.TerrainType.Snow,
			::Const.World.TerrainType.Badlands,
			::Const.World.TerrainType.Tundra,
			::Const.World.TerrainType.Steppe,
			::Const.World.TerrainType.Desert,
			::Const.World.TerrainType.Oasis,
		];
		local tries = 0;
		local myTile = _settlement.getTile();
		local entity;

		while (tries++ < 1000)
		{
			local x = ::Math.rand(myTile.SquareCoords.X - 2 - _additionalDistance, myTile.SquareCoords.X + 2 + _additionalDistance);
			local y = ::Math.rand(myTile.SquareCoords.Y - 2 - _additionalDistance, myTile.SquareCoords.Y + 2 + _additionalDistance);

			if (!::World.isValidTileSquare(x, y))
			{
				continue;
			}

			local tile = ::World.getTileSquare(x, y);

			if (tile.IsOccupied)
			{
				continue;
			}

			if (_mustBeNearRoad && tile.HasRoad)
			{
				continue;
			}

			if (tile.getDistanceTo(myTile) == 1 && _additionalDistance >= 0 || tile.getDistanceTo(myTile) < _additionalDistance)
			{
				continue;
			}

			local terrainFits = false;

			foreach( t in terrain )
			{
				if (t == tile.Type)
				{
					if (!_mustBeNearRoad)
					{
						terrainFits = true;
					}
					else
					{
						for( local i = 0; i < 6; ++i )
						{
							if (!tile.hasNextTile(i))
							{
							}
							else
							{
								local next = tile.getNextTile(i);

								if (_mustBeNearRoad && !next.HasRoad)
								{
								}
								else
								{
									terrainFits = true;

									if (terrainFits)
									{
										break;
									}
								}
							}
						}
					}

					if (terrainFits)
					{
						break;
					}
				}
			}

			if (!terrainFits)
			{
				continue;
			}

			if (tile.getDistanceTo(myTile) > 2)
			{
				local navSettings = ::World.getNavigator().createSettings();
				navSettings.ActionPointCosts = ::Const.World.TerrainTypeNavCost_Flat;
				local path = ::World.getNavigator().findPath(myTile, tile, navSettings, 0);

				if (path.isEmpty())
				{
					continue;
				}
			}

			if (_clearTile)
			{
				tile.clearAllBut(::Const.World.DetailType.Shore);
			}
			else
			{
				tile.clear(::Const.World.DetailType.NotCompatibleWithRoad);
			}

			entity = ::World.spawnLocation(_script, tile.Coords);
			entity.setSettlement(_settlement);

			if (entity.onBuild())
			{
				_settlement.m.AttachedLocations.push(entity);
				break;
			}
			else
			{
				entity.die();
				entity = null;
				continue;
			}
		}

		return entity;
	}

	function log( _text, _isError = false)
	{
		if (_isError)
		{
			this.logError(_text);
			_text = ::Const.UI.getColorized(_text, "#8f1e1e");
		}

		this.m.JSHandle.asyncCall("printLog", _text);
	}

};

