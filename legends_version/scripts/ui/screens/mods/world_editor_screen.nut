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
		this.m.Retinue.update();
		this.World.Assets.updateLook();
		this.World.State.updateTopbarAssets();
		if (this.m.StashIsChanged) this.World.State.getPlayer().forceRecalculateStashModifier();
		if (this.m.BannerIsChanged) this.updatePlayerBannerOnAllThings();
		this.m.JSHandle.asyncCall("loadFromData", this.convertToUIData());
	}

	function onGetBuildingEntries( _id )
	{
		return this.Woditor.Helper.convertBuildingEntriesToUIData(_id);
	}

	function onGetAttachedLocationEntries( _id )
	{
		return this.Woditor.Helper.convertAttachedLocationEntriesToUIData(_id);
	}

	function onGetSituationEntries( _id )
	{
		return this.Woditor.Helper.convertSituationEntriesToUIData(_id);
	}

	function onGetTroopEntries( _data )
	{
		return this.Woditor.Helper.convertTroopEntriesToUIData(_data);
	}

	function onGetTroopTemplate( _type )
	{
		return this.Woditor.Helper.convertTroopTemplateToUIData(_type);
	}

	function onCollectAllianceData( _data )
	{
		return this.Woditor.Helper.convertFactionAllianceToUIData(_data);
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

		this.m.JSHandle.asyncCall("updateFactionContracts", this.Woditor.Helper.getContractsUI(faction));
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

	function onChangeActiveStatusOfSettlement( _data )
	{
		this.World.getEntityByID(_data[0]).setActive(_data[1], false);
	}

	function onRefreshSettlementShop( _id )
	{
		this.World.getEntityByID(_id).resetShop();
	}

	function onRefreshSettlementRoster( _id )
	{
		this.World.getEntityByID(_id).resetRoster(true);
	}

	function onAddBuildingToSlot( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		local slot = _data[1];

		if (entity.m.Buildings[slot] != null)
		{
			entity.m.Buildings[slot].m.Settlement = null;
			entity.m.Buildings[slot] = null;
		}

		local building = this.new(_data[2]);
		building.setSettlement(entity);
		entity.m.Buildings[slot] = building;

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
	}

	function onRemoveBuilding( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		local slot = _data[1];
		local id = _data[2];

		if (entity.m.Buildings[slot] == null || entity.m.Buildings[slot].getID() != id) return;

		entity.m.Buildings[slot].m.Settlement = null;
		entity.m.Buildings[slot] = null;
		this.m.JSHandle.asyncCall("updateSettlementBuildingSlot", {
			Slot = _data[1],
			Data = null,
		});
	}

	function onAddAttachedLocationToSlot( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		local nearRoad = this.Const.NearRoadAttachedLocations.find(_data[1]) != null;
		local additionalTile = this.Math.rand(0, 1);
		local attachment = this.buildAttachedLocation(entity, _data[1], additionalTile, nearRoad);
		local tries = 0

		while(attachment == null && tries < 6)
		{
			++additionalTile;
			attachment = this.buildAttachedLocation(entity, _data[1], additionalTile, nearRoad);
		}

		if (attachment == null) return;
		entity.updateProduce();

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
			Data = result,
			IsUpdating = true
		});
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

		if (find == null) return;

		local result = [];
		local remove = entity.getAttachedLocations().remove(find);
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
			Data = result,
			IsUpdating = true
		});
	}

	function onAddSituationToSlot( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		local result = [];

		foreach (script in _data[1])
		{
			local situation = this.new(script);
			entity.addSituation(situation, 7);
		}

		foreach( situation in entity.getSituations() )
		{
			result.push({
				ID = situation.getID(),
				ImagePath = situation.getIcon()
			});
		}
		
		this.m.JSHandle.asyncCall("updateSituationList", {
			Data = result,
			IsUpdating = true
		});
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
			Data = result,
			IsUpdating = true
		});
	}

	function onUpdateResourseValue( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		entity.setResources(_data[1]);

		if (entity.isLocationType(this.Const.World.LocationType.Settlement))
		{
			this.m.JSHandle.asyncCall("updateSettlementWealth", entity.getWealth());
		}
	}

	function onUpdateWealthValue( _data )
	{
		local entity = this.World.getEntityByID(_data[0]);
		local baseLevel = 0.0;

		if (entity.isMilitary()) baseLevel = baseLevel + 50.0;
		if (this.isKindOf(entity, "city_state")) baseLevel = baseLevel + 100;

		switch(entity.getSize())
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
		entity.setResources(resources);
		this.m.JSHandle.asyncCall("updateSettlementResources", resources);
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

	function onSendCaravanTo( _data )
	{
		local resources = _data[2];
		local start = this.World.getEntityByID(_data[0]);
		local destination = this.World.getEntityByID(_data[1]);
		local faction =  this.World.FactionManager.getFaction(this.MSU.Array.getRandom(start.getFactions()));

		if (_data[3].find("Noble") != null && faction.getType() != this.Const.FactionType.NobleHouse)
		{
			_data[3] = "CaravanSouthern";
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
			party.addToInventory(start.getProduce()[this.Math.rand(0, start.getProduce().len() - 1)]);
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
	}

	function convertToUIData()
	{
		local result = {};
		result.Assets <- this.Woditor.Helper.convertAssetsToUIData();
		result.Avatar <- this.Woditor.Helper.convertAvatarToUIData(this);
		result.Factions <- this.Woditor.Helper.convertFactionsToUIData();
		result.Settlements <- this.Woditor.Helper.convertSettlementsToUIData(result.Factions);
		result.Locations <- this.Woditor.Helper.convertLocationsToUIData(result.Factions);
		result.Filter <- this.Woditor.Helper.convertToUIFilterData(result.Factions);
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

	function buildAttachedLocation(_settlement, _script, _additionalDistance = 0, _mustBeNearRoad = false, _clearTile = true)
	{
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

};

