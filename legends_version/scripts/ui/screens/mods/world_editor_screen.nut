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

	function onCollectAllianceData( _data )
	{
		return ::Woditor.Helper.convertFactionAllianceToUIData(_data);
	}

	function onGetAllNonHostileFactionsOfThisFaction( _factionID )
	{
		local faction = this.World.FactionManager.getFaction(_factionID);
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
		local entity = this.World.getEntityByID(_id);
		local result = [];

		foreach(settlement in this.World.EntityManager.getSettlements())
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local faction = this.World.FactionManager.getFaction(_data[1]);
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
		local world_entity = this.World.getEntityByID(_data[0]);

		if (world_entity.isLocationType(this.Const.World.LocationType.Settlement))
		{
			if (world_entity.getOwner() != null && world_entity.getOwner().getID() != _data[2])
			{
				world_entity.removeFaction(_data[2]);
			}

			world_entity.addFaction(_data[1]);
			this.m.JSHandle.asyncCall("updateSettlementNewFaction", {Faction = _data[1]});
		}
		else
		{
			world_entity.setFaction(_data[1]);

			foreach ( troop in world_entity.getTroops() )
			{
				troop.Faction = world_entity.getFaction();
			}

			this.m.JSHandle.asyncCall("updateLocationNewFaction", {Faction = _data[1]});
		}
	}

	function onUpdateFactionAlliance( _data )
	{
		local faction = this.World.FactionManager.getFaction(_data[0]);

		foreach(id in _data[1].Allies)
		{
			local f = this.World.FactionManager.getFaction(id);
			f.addAlly(_data[0]);
			faction.addAlly(id);
		}

		foreach(id in _data[1].Hostile)
		{
			local f = this.World.FactionManager.getFaction(id);
			f.removeAlly(_data[0]);
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
		// find banner
		if (_data[0] > this.Const.NobleBanners.len() - 1 && _data[0] > this.Const.OtherBanner.len() - 1) return;

		local faction = this.World.FactionManager.getFaction(_data[1]);
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
		this.World.FactionManager.getFaction(_data[0]).setName(_data[1]);
	}

	function onChangeFactionMotto( _data )
	{
		this.World.FactionManager.getFaction(_data[0]).setMotto(_data[1]);
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

	function onRefreshFactionLeader( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
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

	function onChangeLocationSprite( _data )
	{
		this.World.getEntityByID(_data[0]).getSprite("body").setBrush(_data[1]);
	}

	function onChangeScenario( _id )
	{
		this.World.Assets.m.Origin = this.Const.ScenarioManager.getScenario(_id);
	}

	function onChangeActiveStatusOfSettlement( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		world_entity.setActive(_data[1], false);
		this.log(this.Const.UI.getColorized(world_entity.getName(), "#1e468f") + " has become " + (_data[1] ? "active." : "inactive."));
	}

	function onRefreshSettlementShop( _id )
	{
		local world_entity = this.World.getEntityByID(_id)
		world_entity.resetShop();
		this.log(this.Const.UI.getColorized(world_entity.getName(), "#1e468f") + "\'s shops have refreshed their stocks.");
	}

	function onRefreshSettlementRoster( _id )
	{
		local world_entity = this.World.getEntityByID(_id);
		world_entity.resetRoster(true);
		this.log(this.Const.UI.getColorized(world_entity.getName(), "#1e468f") + " has refreshed its recruit roster.");
	}

	function onAddHouse( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		local isAddHouse = _data[1];

		if (isAddHouse)
		{
			if (!world_entity.buildHouse())
			{
				this.log(this.Const.UI.getColorized("Failed to build house. Reason: can\'t find suitable tile to build", "#8f1e1e"));
			}
		}
		else
		{
			if (!world_entity.destroyHouse())
			{
				this.log(this.Const.UI.getColorized("Failed to destroy house. Reason: there is no house", "#8f1e1e"));
			}
		}
	}

	function onAddBuildingToSlot( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		local slot = _data[1];
		local logText = "Added ";

		if (world_entity.m.Buildings[slot] != null)
		{
			logText = "Replaced " + this.Const.UI.getColorized(world_entity.m.Buildings[slot].getName(), "#1e468f") + " with ";
			world_entity.m.Buildings[slot].m.Settlement = null;
			world_entity.m.Buildings[slot] = null;
		}

		local building = this.new(_data[2]);
		building.setSettlement(world_entity);
		world_entity.m.Buildings[slot] = building;
		logText += this.Const.UI.getColorized(building.getName(), "#1e468f");

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
		local world_entity = this.World.getEntityByID(_data[0]);
		local slot = _data[1];
		local id = _data[2];
		local name = "";

		if (world_entity.m.Buildings[slot] == null || world_entity.m.Buildings[slot].getID() != id) return;

		world_entity.m.Buildings[slot].m.Settlement = null;
		name = this.Const.UI.getColorized(world_entity.m.Buildings[slot].getName(), "#1e468f");
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local nearRoad = this.Const.NearRoadAttachedLocations.find(_data[1]) != null;
		local additionalTile = this.Math.rand(0, 1);
		local attachment = this.buildAttachedLocation(world_entity, _data[1], additionalTile, nearRoad);
		local tries = 0

		while(attachment == null && tries < 6)
		{
			++additionalTile;
			attachment = this.buildAttachedLocation(world_entity, _data[1], additionalTile, nearRoad);
		}

		if (attachment == null) 
		{
			this.log(this.Const.UI.getColorized("Failed to add new attached location. Reason: can\'t find suitable tile to spawn", "#8f1e1e"));
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
		this.log("Added " + this.Const.UI.getColorized(attachment.getName(), "#1e468f") + " attached location");
	}

	function onRemoveAttachedLocation( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
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
			this.log(this.Const.UI.getColorized("Failed to remove attached location. Reason: selected attached location don\'t exist", "#8f1e1e"));
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
		this.log("Removed " + this.Const.UI.getColorized(name, "#1e468f") + " attached location");
	}

	function onAddSituationToSlot( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		local result = [];
		local added = _data[1].len();
		local before = world_entity.getSituations().len();

		foreach (script in _data[1])
		{
			local situation = this.new(script);
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
			this.log("Added " + this.Const.UI.getColorized(added, "#135213") + " situation" + (added > 1 ? "s" : "") + " and removed " + this.Const.UI.getColorized(overflow, "#8f1e1e") + " situation" + (overflow > 1 ? "s" : "") + " due to overflow");
		}
		else
		{
			this.log("Added " + this.Const.UI.getColorized(added, "#135213") + " situation" + (added > 1 ? "s" : ""));
		}
	}

	function onRemoveSituation( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local remove = world_entity.getLoot().getItemByInstanceID(_data[1]);
		local result = [];

		if (remove == null) 
		{
			return this.log(this.Const.UI.getColorized("Failed to remove the item from loot pool. Reason: can\'t find item", "#8f1e1e"));
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
		this.log("Removed " + this.Const.UI.getColorized(remove.item.getName(), "#135213") + " from loot pool");
	}

	function onRerollLoots( _id )
	{
		local world_entity = this.World.getEntityByID(_id);
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local newItem = this.new(_data[1]);
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
		this.log("Added " + this.Const.UI.getColorized(newItem.getName(), "#135213") + " to loot pool");
	}

	function onAddRandomNamedItem( _id )
	{
		local world_entity = this.World.getEntityByID(_id);
		local result = [];
		local items = [];
		local pick;

		switch (this.Math.rand(1, 4))
		{
		case 1:
			items.extend(this.Const.Items.NamedHelmets);
			if (world_entity.m.NamedHelmetsList != null && world_entity.m.NamedHelmetsList.len() != 0)
			{
				items.extend(world_entity.m.NamedHelmetsList);
				items.extend(world_entity.m.NamedHelmetsList);
			}
			if (this.LegendsMod.Configs().LegendArmorsEnabled())
			{
				local weightName = this.Const.World.Common.convNameToList(items);
				pick = this.Const.World.Common.pickHelmet(weightName);
			}
			break;

		case 2:
			items.extend(this.Const.Items.NamedArmors);
			if (world_entity.m.NamedArmorsList != null && world_entity.m.NamedArmorsList.len() != 0)
			{
				items.extend(world_entity.m.NamedArmorsList);
				items.extend(world_entity.m.NamedArmorsList);
			}
			if (this.LegendsMod.Configs().LegendArmorsEnabled())
			{
				local weightName = this.Const.World.Common.convNameToList(items);
				pick = this.Const.World.Common.pickArmor(weightName);
			}
			break;

		case 3:
			items.extend(this.Const.Items.NamedShields);
			if (world_entity.m.NamedShieldsList != null && world_entity.m.NamedShieldsList.len() != 0)
			{
				items.extend(world_entity.m.NamedShieldsList);
				items.extend(world_entity.m.NamedShieldsList);
			}
			break;

		default:
			items.extend(this.Const.Items.NamedWeapons);
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
				pick = this.new("scripts/items/" + this.MSU.Array.getRandom(items));
			}
			else
			{
				return this.log(this.Const.UI.getColorized("Failed to add a random named item. Reason: the named item table is empty", "#8f1e1e"));
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
		this.log("Randomly picked and added " + this.Const.UI.getColorized(pick.getName(), "#135213") + " to loot pool");
	}

	function onRerollTroop( _id )
	{
		local world_entity = this.World.getEntityByID(_id);
		world_entity.m.LastSpawnTime = 0.0;
		world_entity.createDefenders();
		this.m.JSHandle.asyncCall("updateLocationTroops", {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log("Troop list has been refreshed!");
	}

	function onRemoveTroop( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
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
		this.m.JSHandle.asyncCall("updateLocationTroops", {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log("Removed " + this.Const.UI.getColorized(troop.Name, "#135213") + " from troop list, " + this.Const.UI.getColorized(troop.Num, "#135213") + " in total");
	}

	function onAddRandomTroop( _data )
	{
		local list = clone ::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All];
		local world_entity = this.World.getEntityByID(_data[0]);
		local result = [];

		foreach( key in _data[1] )
		{
			local i = list.find(key);

			if (i != null)
			{
				list.remove(i);
			}
		}

		local t = clone this.Const.World.Spawn.Troops[::MSU.Array.getRandom(list)];
		t.Party <- this.WeakTableRef(world_entity);
		t.Faction <- world_entity.getFaction();
		t.Name <- "";
		t.Variant = 0;
		world_entity.getTroops().push(t);
		world_entity.updateStrength();
		this.m.JSHandle.asyncCall("updateLocationTroops", {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log("Randomly picked and added " + this.Const.UI.getColorized(::Woditor.getTroopName(t), "#135213") + " to troop list");
	}

	function onAddNewTroop( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);

		foreach( key in _data[1] )
		{
			local t = clone this.Const.World.Spawn.Troops[key];
			t.Party <- this.WeakTableRef(world_entity);
			t.Faction <- world_entity.getFaction();
			t.Name <- "";
			t.Variant = 0;
			world_entity.getTroops().push(t);
			this.log("Added " + this.Const.UI.getColorized(::Woditor.getTroopName(t), "#135213") + " to troop list");
		}

		world_entity.updateStrength();
		this.m.JSHandle.asyncCall("updateLocationTroops", {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
	}

	function onChangeTroopNum( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		local troops = world_entity.getTroops();
		local troop = _data[1];
		local different = _data[2];
		local text = "";
		
		if (different > 0)
		{
			text = "Removed " + different + " " + this.Const.UI.getColorized(troop.Name, "#135213") + " from troop list";
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
			text = "Added " + this.Math.abs(different) + " more " + this.Const.UI.getColorized(troop.Name, "#135213") + " to troop list";
			while (different < 0)
			{
				local t = clone this.Const.World.Spawn.Troops[troop.Key];
				t.Party <- this.WeakTableRef(world_entity);
				t.Faction <- world_entity.getFaction();
				t.Name <- "";
				t.Variant = 0;

				if (troop.IsChampion)
				{
					if ("NameList" in this.Const.World.Spawn.Troops[troop.Key])
					{
						t.Name = this.Const.World.Common.generateName(this.Const.World.Spawn.Troops[troop.Key].NameList) + ((this.Const.World.Spawn.Troops[troop.Key].TitleList != null) ? " " + this.Const.World.Spawn.Troops[troop.Key].TitleList[this.Math.rand(0, this.Const.World.Spawn.Troops[troop.Key].TitleList.len() - 1)] : "");
					}
					else
					{
						t.Name = "Champion " + this.Const.Strings.EntityName[t.ID];
					}

					t.Variant = this.Math.rand(1, 255);
					t.Strength = this.Math.round(t.Strength * 1.35);
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local troop = _data[1];
		local text = "";

		if (!troop.IsChampion)
		{
			text = "Convert a " + this.Const.UI.getColorized(troop.Name, "#135213") + " into a champion";
			foreach ( t in world_entity.getTroops() )
			{
				local key = ::Woditor.getTroopKey(t);

				if (t.Variant == 0 && troop.Key == key)
				{
					if ("NameList" in this.Const.World.Spawn.Troops[key])
					{
						t.Name = this.Const.World.Common.generateName(this.Const.World.Spawn.Troops[key].NameList) + ((this.Const.World.Spawn.Troops[key].TitleList != null) ? " " + this.Const.World.Spawn.Troops[key].TitleList[this.Math.rand(0, this.Const.World.Spawn.Troops[key].TitleList.len() - 1)] : "");
					}
					else
					{
						t.Name = "Champion " + this.Const.Strings.EntityName[t.ID];
					}

					t.Variant = this.Math.rand(1, 255);
					t.Strength = this.Math.round(t.Strength * 1.35);
					break;
				}
			}
		}
		else
		{
			text = "Revert a champion " + this.Const.UI.getColorized(troop.Name, "#135213") + " back to a normal one";
			foreach ( t in world_entity.getTroops() )
			{
				local key = ::Woditor.getTroopKey(t);

				if (t.Variant != 0 && troop.Key == key)
				{
					t.Name = "";
					t.Variant = 0;
					t.Strength = this.Const.World.Spawn.Troops[key].Strength;
					break;
				}
			}
		}

		world_entity.updateStrength();
		this.m.JSHandle.asyncCall("updateLocationTroops", {
			Troops = ::Woditor.Helper.convertTroopsToUIData(world_entity),
			IsUpdating = true
		});
		this.log(text);
	}

	function onUpdateResourseValue( _data )
	{
		local world_entity = this.World.getEntityByID(_data[0]);
		world_entity.setResources(_data[1]);

		if (world_entity.isLocationType(this.Const.World.LocationType.Settlement))
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
		local world_entity = this.World.getEntityByID(_data[0]);
		local baseLevel = 0.0;

		if (world_entity.isMilitary()) baseLevel = baseLevel + 50.0;
		if (this.isKindOf(world_entity, "city_state")) baseLevel = baseLevel + 100;

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

		local resources = this.Math.round(_data[1] * baseLevel / 100);
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
		local isMult = ::Woditor.AssetsProperties.Mult.find(key) != null;
		local isAdditive = ::Woditor.AssetsProperties.Additive.find(key) != null;

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

	function onSendCaravanTo( _data )
	{
		local resources = _data[2];
		local start = this.World.getEntityByID(_data[0]);
		local destination = this.World.getEntityByID(_data[1]);
		local faction =  this.World.FactionManager.getFaction(this.MSU.Array.getRandom(start.getFactions()));

		if (_data[3].find("Noble") != null && faction.getType() != this.Const.FactionType.NobleHouse)
		{
			local owner = start.getOwner();

			if (owner != null && !owner.isNull() && owner.getType() == this.Const.FactionType.NobleHouse)
			{
				faction = owner.get();
			}
			else
			{
				_data[3] = "CaravanSouthern";
			}
		}

		local party = faction.spawnEntity(start.getTile(), "Trading Caravan", false, this.Const.World.Spawn[_data[3]], resources);
		party.getSprite("banner").Visible = false;
		party.getSprite("base").Visible = false;
		party.setDescription("A trading caravan from " + start.getName() + " that is transporting all manner of goods between settlements.");
		party.setFootprintType(this.Const.World.FootprintsType.Caravan);
		party.setMirrored(true);
		party.setAttackableByAI(_data[4]);
		party.setSlowerAtNight(_data[5]);
		party.setLootScale(_data[6] ? 2.0 : 1.0);
		party.getFlags().set("IsCaravan", true);
		party.getFlags().set("IsRandomlySpawned", true);

		if (this.World.Assets.m.IsBrigand)
		{
			party.setVisibleInFogOfWar(true);
			party.setImportant(true);
			party.setDiscovered(true);
		}

		if (start.getProduce().len() == 0) start.updateProduce();
	
		local produce = 3
		if(this.LegendsMod.Configs().LegendWorldEconomyEnabled())
		{
			produce = this.Math.max(3, 3 + this.Math.round(0.025 * resources));
		}

		for( local j = 0; j < produce; j = ++j )
		{
			party.addToInventory(this.MSU.Array.getRandom(start.getProduce()));
		}

		party.getLoot().Money = this.Math.rand(0, 100);
		party.getLoot().ArmorParts = this.Math.rand(0, 10);
		party.getLoot().Medicine = this.Math.rand(0, 10);
		party.getLoot().Ammo = this.Math.rand(0, 25);

		if(this.LegendsMod.Configs().LegendWorldEconomyEnabled())
		{
			local investment = this.Math.max(1, this.Math.round(0.033 * resources));
			start.setResources(this.Math.max(10, start.getResources() - investment));
			party.setResources(investment);

			local r = this.Math.rand(1,3);
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

				local item = this.Const.World.Common.pickItem(items)
				party.addToInventory(item);
			}
		}
		else
		{
			local supplies = ["bread_item", "roots_and_berries_item", "dried_fruits_item", "ground_grains_item"];
			party.addToInventory("supplies/" + this.MSU.Array.getRandom(supplies));
		}

		local c = party.getController();
		c.getBehavior(this.Const.World.AI.Behavior.ID.Attack).setEnabled(false);
		c.getBehavior(this.Const.World.AI.Behavior.ID.Flee).setEnabled(false);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(destination.getTile());
		move.setRoadsOnly(true);
		local unload = this.new("scripts/ai/world/orders/unload_order");
		local despawn = this.new("scripts/ai/world/orders/despawn_order");
		c.addOrder(move);
		c.addOrder(unload);
		c.addOrder(despawn);

		this.log("Successfully sent a caravan from " + this.Const.UI.getColorized(start.getName(), "#1e468f") + " to " + this.Const.UI.getColorized(destination.getName(), "#1e468f"));
	}

	function onSendMercenaryTo( _data )
	{
		local resources = _data[2];
		local start = this.World.getEntityByID(_data[0]);
		local destination = this.World.getEntityByID(_data[1]);
		local faction =  this.World.FactionManager.getFaction(this.MSU.Array.getRandom(start.getFactions()));
		local party = this.World.spawnEntity("scripts/entity/world/party", start.getTile().Coords);
		party.setPos(this.createVec(party.getPos().X - 50, party.getPos().Y - 50));
		party.setDescription("A free mercenary company travelling the lands and lending their swords to the highest bidder.");
		party.setFootprintType(this.Const.World.FootprintsType.Mercenaries);
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
			party.setFaction(start.getFactionOfType(this.Const.FactionType.Settlement).getID());
		}

		this.Const.World.Common.assignTroops(party, this.Const.World.Spawn[_data[3]], resources);
		party.getLoot().Money = this.Math.rand(300, 600);
		party.getLoot().ArmorParts = this.Math.rand(0, 25);
		party.getLoot().Medicine = this.Math.rand(0, 10);
		party.getLoot().Ammo = this.Math.rand(0, 50);

		if (_data[3] == "Assassins")
		{
			party.getSprite("body").setBrush("figure_mercenary_0" + this.Math.rand(1, 2));
		}

		local supplies = ["bread_item", "roots_and_berries_item", "dried_fruits_item", "ground_grains_item"];
		local loots = [
			"silver_bowl_item", "jeweled_crown_item", "ancient_amber_item", "webbed_valuables_item", "looted_valuables_item",
			"white_pearls_item", "rainbow_scale_item", "lindwurm_hoard_item", "silverware_item",
		];
		party.addToInventory("supplies/" + this.MSU.Array.getRandom(supplies));
		party.addToInventory("loot/" + this.MSU.Array.getRandom(loots));

		local c = party.getController();
		local wait1 = this.new("scripts/ai/world/orders/wait_order");
		wait1.setTime(this.Math.rand(5, 7) * 1.0);
		local move = this.new("scripts/ai/world/orders/move_order");
		move.setDestination(destination.getTile());
		move.setRoadsOnly(false);
		local wait2 = this.new("scripts/ai/world/orders/wait_order");
		wait2.setTime(this.Math.rand(10, 60) * 1.0);
		local mercenary = this.new("scripts/ai/world/orders/mercenary_order");
		mercenary.setSettlement(destination);
		c.addOrder(wait1);
		c.addOrder(move);
		c.addOrder(wait2);
		c.addOrder(mercenary);

		while (true)
		{
			local name = this.Const.Strings.MercenaryCompanyNames[this.Math.rand(0, this.Const.Strings.MercenaryCompanyNames.len() - 1)];

			if (name == this.World.Assets.getName())
			{
				continue;
			}

			local abort = false;

			foreach( p in this.World.EntityManager.m.Mercenaries )
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
			local banner = this.Const.PlayerBanners[this.Math.rand(0, this.Const.PlayerBanners.len() - 1)];

			if (banner == this.World.Assets.getBanner())
			{
				continue;
			}

			local abort = false;

			foreach( p in this.World.EntityManager.m.Mercenaries )
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

		this.World.EntityManager.m.Mercenaries.push(this.WeakTableRef(party));
		this.log("Successfully sent a mercenary company from " + this.Const.UI.getColorized(start.getName(), "#1e468f") + " to " + this.Const.UI.getColorized(destination.getName(), "#1e468f"));
	}

	function convertToUIData()
	{
		local result = {};
		result.Assets <- ::Woditor.Helper.convertAssetsToUIData();
		result.Avatar <- ::Woditor.Helper.convertAvatarToUIData(this);
		result.Factions <- ::Woditor.Helper.convertFactionsToUIData();
		result.Settlements <- ::Woditor.Helper.convertSettlementsToUIData();
		result.Locations <- ::Woditor.Helper.convertLocationsToUIData();
		result.Filter <- ::Woditor.Helper.convertToUIFilterData(result.Factions);
		result.Scenario <- ::Woditor.Helper.convertScenariosToUIData();
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

	function buildAttachedLocation(_settlement, _script, _additionalDistance = 0, _mustBeNearRoad = false, _clearTile = true)
	{
		local terrain = [
			this.Const.World.TerrainType.Plains,
			this.Const.World.TerrainType.Swamp,
			this.Const.World.TerrainType.Hills,
			this.Const.World.TerrainType.Forest,
			this.Const.World.TerrainType.SnowyForest,
			this.Const.World.TerrainType.LeaveForest,
			this.Const.World.TerrainType.AutumnForest,
			this.Const.World.TerrainType.Mountains,
			this.Const.World.TerrainType.Snow,
			this.Const.World.TerrainType.Badlands,
			this.Const.World.TerrainType.Tundra,
			this.Const.World.TerrainType.Steppe,
			this.Const.World.TerrainType.Desert,
			this.Const.World.TerrainType.Oasis,
		];
		local tries = 0;
		local myTile = _settlement.getTile();
		local entity;

		while (tries++ < 1000)
		{
			local x = this.Math.rand(myTile.SquareCoords.X - 2 - _additionalDistance, myTile.SquareCoords.X + 2 + _additionalDistance);
			local y = this.Math.rand(myTile.SquareCoords.Y - 2 - _additionalDistance, myTile.SquareCoords.Y + 2 + _additionalDistance);

			if (!this.World.isValidTileSquare(x, y))
			{
				continue;
			}

			local tile = this.World.getTileSquare(x, y);

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
				local navSettings = this.World.getNavigator().createSettings();
				navSettings.ActionPointCosts = this.Const.World.TerrainTypeNavCost_Flat;
				local path = this.World.getNavigator().findPath(myTile, tile, navSettings, 0);

				if (path.isEmpty())
				{
					continue;
				}
			}

			if (_clearTile)
			{
				tile.clearAllBut(this.Const.World.DetailType.Shore);
			}
			else
			{
				tile.clear(this.Const.World.DetailType.NotCompatibleWithRoad);
			}

			entity = this.World.spawnLocation(_script, tile.Coords);
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

	function log(_text)
	{
		this.m.JSHandle.asyncCall("printLog", _text);
	}

};

