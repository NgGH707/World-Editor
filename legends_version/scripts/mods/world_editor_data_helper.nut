this.world_editor_data_helper <- {
	m = {},
	function convertFactionAllianceToUIData( _data )
	{
		local faction = this.World.FactionManager.getFaction(_data[0]);
		local allies = faction.getAllies();
		local result = {Allies = [], Hostile = []};
		local index = _data[1];
		local data = _data[2];

		foreach(i, fData in  data )
		{
			if (i == index) continue;

			if (allies.find(fData.ID) != null)
			{
				result.Allies.push(i);
			}
			else
			{
				result.Hostile.push(i);
			}
		}

		return result;
	}

	function convertFactionLeadersToUIData( _id )
	{
		local faction = this.World.FactionManager.getFaction(_id);
		local result = [];

		foreach( character in faction.getRoster().getAll() )
		{
			result.push({
				ImagePath = character.getImagePath(),
				ID = character.getID()
			});
		}

		return result;
	}

	function convertBuildingEntriesToUIData( _id )
	{
		local settlement = this.World.getEntityByID(_id);
		local result = [];

		foreach( script in ::Woditor.Buildings.Valid)
		{
			local building = ::Woditor.Buildings.Stuff[script];

			result.push({
				Script = script,
				ID = building.getID(),
				ImagePath = building.m.UIImage + ".png",
				TooltipId = building.m.Tooltip,
			});
		}

		return result;
	}

	function convertAttachedLocationEntriesToUIData( _id )
	{
		local result = [];

		foreach( script in ::Woditor.AttachedLocations.Valid )
		{
			local attached_location = ::Woditor.AttachedLocations.Stuff[script];

			result.push({
				Script = script,
				ID = attached_location.getTypeID(),
				ImagePath = attached_location.getUIImage()
			});
		}

		return result;
	}

	function convertSituationEntriesToUIData( _id )
	{
		local settlement = this.World.getEntityByID(_id);
		local result = [];

		foreach( script in ::Woditor.Situations.Valid )
		{
			local situation = ::Woditor.Situations.Stuff[script];
			if (settlement.hasSituation(situation.getID())) continue;

			result.push({
				Script = script,
				ID = situation.getID(),
				ImagePath = situation.getIcon()
			});
		}

		return result;
	}

	function convertLocationSpriteEntriesToUIData( _id )
	{
		local world_entity = this.World.getEntityByID(_id);
		local body = world_entity.getSprite("body");
		local result = [];
		local valid = [];
		valid.extend(::Woditor.ValidLocationSprites);

		if (body.HasBrush)
		{
			local find = valid.find(body.getBrush().Name);

			if (find != null)
			{
				valid.remove(find);
			}
		}

		foreach (sprite in valid )
		{
			result.push({
				ImagePath = "ui/locations/" + sprite + ".png",
				Sprite = sprite
			});
		}

		return result;
	}

	function convertTroopEntriesToUIData( _data )
	{
		local exclude = _data[0];
		local filter = _data[1];
		local list = clone ::Woditor.ValidTroops[filter];
		local result = [];

		foreach( key in exclude )
		{
			local i = list.find(key);

			if (i != null)
			{
				list.remove(i);
			}
		}

		foreach( key in list )
		{
			local troop = this.Const.World.Spawn.Troops[key];

			result.push({
				Name = ::Woditor.getTroopName(troop),
				Icon = ::Woditor.getTroopIcon(troop),
				Strength = troop.Strength,
				Cost = troop.Cost,
				Key = key,
			})
		}

		return result;
	}

	function convertTroopTemplateToUIData( _type )
	{
		local result = [];

		switch (_type)
		{
		case "caravan":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Caravan") == null) continue;
				result.push(key);
			}
			break;

		case "mercenary":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Company") == null) continue;
				result.push(key);
			}
			result.extend([
				"Mercenaries",
				"BountyHunters",
				"Assassins",
			]);
			break;

		case "bandit":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Bandit") == null) continue;
				result.push(key);
			}
			break;

		case "barbarian":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Barbarian") == null) continue;
				result.push(key);
			}
			break;

		case "goblin":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Goblin") == null) continue;
				result.push(key);
			}
			break;

		case "orc":
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Orc") == null) continue;
				result.push(key);
			}
			break;
	
		default: // all
			foreach(key, value in this.Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				result.push(key);
			}
		}

		return result;
	}

	function convertAvatarToUIData( _screen )
	{
		this.World.Assets.updateLook();
		local result = {};
		local roster = this.World.getTemporaryRoster();
		local player = this.World.State.getPlayer();
		local socket = player.getSprite("base").getBrush().Name;
		local body = player.getSprite("body").getBrush().Name;
		local flip = player.getSprite("body").isFlippedHorizontally();

		// create the model
		roster.clear();
		_screen.m.TemporaryModel = roster.create("scripts/entity/tactical/temp_model");
		_screen.m.TemporaryModel.getSprite("base").setBrush(socket);
		_screen.m.TemporaryModel.getSprite("body").setBrush(body);
		_screen.m.TemporaryModel.setFlipped(flip);
		_screen.m.TemporaryModel.setDirty(true);

		// add avatar data
		result.ImagePath <- _screen.m.TemporaryModel.getImagePath();
		result.IsFlipping <- flip;
		result.Sprites <- [];
		result.SpriteNames <- [];
		result.Sockets <- this.Const.WorldSockets;
		result.SocketIndex <- 0;
		result.Selected <- {
			Row = 0,
			Index = 0,
		};

		foreach (i, row in this.Const.WorldSprites) 
		{
			local index = row.find(body);

			if (index != null)
			{
				result.Selected.Row = i;
				result.Selected.Index = index;
			}

			result.SpriteNames.push(this.Const.WorldSpritesNames[i]);
			result.Sprites.push(row);
		}
		
		local index = this.Const.WorldSockets.find(socket);
		if (index != null) result.SocketIndex = index;
		return result;
	}

	function convertScenariosToUIData()
	{
		local result = {};
		local currentID = this.World.Assets.getOrigin().getID();
		result.Data <- this.Const.ScenarioManager.getDataScenariosForUI()
		result.Selected <- null;

		foreach (i, s in result.Data)
		{
			if (currentID == s.ID)
			{
				result.Selected = i;
				break;
			}
		}

		return result;
	}

	function convertAssetsToUIData()
	{
		local result = {};

		// banners
		result.Banners <- {
			Data = [],
			Selected = null
		};
		result.Banners.Data.push(this.Const.PlayerBanners);
		result.Banners.Data.push(this.Const.NobleBanners);
		result.Banners.Data.push(this.Const.OtherBanner);
		result.Banners.Selected = this.Const.PlayerBanners.find(this.World.Assets.getBanner());

		// roster and difficulty sliders
		result.DifficultyMult <- this.Math.floor(100 * (this.World.Flags.has("DifficultyMult") ? this.World.Flags.getAsFloat("DifficultyMult") : 1.0));
		result.RosterTier <- {
			Max = this.Const.Roster.Tier[this.Const.Roster.Tier.len() - 1],
			//Value = this.World.Flags.has("RosterTier") ? this.World.Flags.getAsInt("RosterTier") : this.World.Assets.getOrigin().getRosterTier(),
			Value = this.World.Assets.getOrigin().getStartingRosterTier()
		};

		// check box configurations
		result.CheckBox <- {
			IsIronman = this.World.Assets.isIronman(),
			IsBleedKiller = this.LegendsMod.Configs().LegendBleedKillerEnabled(),
			IsLocationScaling = this.LegendsMod.Configs().LegendLocationScalingEnabled(),
			IsRecruitScaling = this.LegendsMod.Configs().LegendRecruitScalingEnabled(),
			IsWorldEconomy = this.LegendsMod.Configs().LegendWorldEconomyEnabled(),
			IsBlueprintsVisible = this.LegendsMod.Configs().LegendAllBlueprintsEnabled(),
			IsGender = this.LegendsMod.Configs().LegendGenderLevel(),
			CombatDifficulty = this.World.Assets.getCombatDifficulty(),
			EconomicDifficulty = this.World.Assets.getEconomicDifficulty(),
		};

		// assets stuffs
		result.Name <- this.World.Assets.getName();
		result.BusinessReputation <- this.World.Assets.getBusinessReputation();
		result.MoralReputation <- this.World.Assets.getMoralReputation();
		result.Money <- this.World.Assets.getMoney();
		result.Stash <- this.World.Assets.getStash().getCapacity();
		result.Ammo <- this.World.Assets.getAmmo();
		result.ArmorParts <- this.World.Assets.getArmorParts();
		result.Medicine <- this.World.Assets.getMedicine();
		
		foreach (key in ::Woditor.AssetsProperties.Mult)
		{
			result[key] <- this.Math.floor(this.World.Assets.m[key] * 100);
		}

		foreach (key in ::Woditor.AssetsProperties.Additive)
		{
			result[key] <- this.World.Assets.m[key];
		}

		return result;
	}

	function convertLocationsToUIData()
	{
		local result = [];
		local playerTile = this.World.State.getPlayer().getTile();

		foreach (i, location in this.World.EntityManager.getLocations())
		{
			if (location.isLocationType(this.Const.World.LocationType.AttachedLocation) || location.m.IsBattlesite)
			{
				continue;
			}
			else
			{
				location.onVisibleToPlayer();
			}

			local isUnique = location.isLocationType(this.Const.World.LocationType.Unique);
			local isLair = location.isLocationType(this.Const.World.LocationType.Lair);
			local isPassive = location.isLocationType(this.Const.World.LocationType.Passive);
			local loots = [];

			foreach ( item in location.getLoot().m.Items )
			{
				if (item != null)
				{
					loots.push(this.convertItemToUIData(item, location.getID()));
				}
			}

			result.push({
				Loots = loots,
				ID = location.getID(),
				Type = location.getTypeID(),
				Name = location.getName(),
				Faction = location.getFaction(),
				TooltipId = location.getTooltipId(),
				Banner = location.getUIBanner(),
				ImagePath = location.getUIImage(),
				Resources = location.getResources(),
				Terrain = location.getTerrainImage(),
				Troops = this.convertTroopsToUIData(location),
				NamedItemChance = location.getNameItemChance(),
				Distance = playerTile.getDistanceTo(location.getTile()),
				IsSpawningTroop = location.getDefenderSpawnList() != null,
				Fortification = location.getCombatLocation().Fortification != 0,
				IsPassive = isPassive && !isLair,
				IsCamp =  isLair && !isUnique,
				IsLegendary = isUnique,
			});
		}

		result.sort(this.onSortLocations);
		return result;
	}

	function convertSettlementsToUIData()
	{
		local result = [];
		local playerTile = this.World.State.getPlayer().getTile();

		foreach(i, settlement in this.World.EntityManager.getSettlements())
		{
			local faction;
			local owner;
			local buildings = [];
			local attached_locations = [];
			local situations = [];
			local draftlist = [];
			local find = settlement.getFactionOfType(this.Const.FactionType.Settlement);

			if (find != null)
			{
				faction = find.getID();
			}
			else
			{
				faction = settlement.getFactions()[0];
			}

			owner = settlement.getOwner() != null && !settlement.getOwner().isNull() ? settlement.getOwner().getID() : faction;

			// processing build info
			foreach(i, b in settlement.m.Buildings )
			{
				if (b == null || b.getID() == "building.crowd")
				{
					buildings.push(null);
				}
				else
				{
					buildings.push({
						ID = b.getID(),
						ImagePath = b.m.UIImage + ".png",
						TooltipId = b.m.Tooltip,
					});
				}

				if (buildings.len() == 5)
				{
					break;
				}
			}

			// processing attached location info
			foreach(i, a in settlement.getAttachedLocations() )
			{
				if (a.getTypeID() == "attached_location.harbor")
				{
					continue;
				}

				attached_locations.push({
					ID = a.getTypeID(),
					ImagePath = a.getUIImage(),
				});
			}

			// processing situation info
			foreach( situation in settlement.getSituations() )
			{
				situations.push({
					ID = situation.getID(),
					ImagePath = situation.getIcon()
				});
			}

			// processing draft list
			foreach( draft in settlement.getDraftList() )
			{
				draftlist.push({
					Key = draft,
					ImagePath = ::Woditor.Backgrounds.Stuff[draft].Icon
				})
			}

			result.push({
				ID = settlement.getID(),
				Name = settlement.getName(),
				Size = settlement.getSize(),
				Owner = owner,
				Faction = faction,
				Buildings = buildings,
				Attachments = attached_locations,
				Situations = situations,
				DraftList = draftlist,
				House = settlement.m.HousesTiles.len(),
				HouseMax = settlement.getHouseMax(),
				HouseImage = settlement.getHouseUIImage(),
				Terrain = settlement.getTerrainImage(),
				ImagePath = settlement.getImagePath(),
				Wealth = settlement.getWealth(),
				Resources = settlement.getResources(),
				IsActive = settlement.isActive(),
				IsCoastal = settlement.isCoastal(),
				IsMilitary = settlement.isMilitary(),
				IsSouthern = settlement.isSouthern(),
				IsIsolated = settlement.isIsolatedFromRoads(),
				Distance = playerTile.getDistanceTo(settlement.getTile()),
			});
		}

		result.sort(this.onSortSettlements);
		return result;
	}

	function convertToUIFilterData( _factions )
	{
		local result = {Settlements = [], Locations = []};

		foreach( f in _factions )
		{
			if (!f.NoChangeName)
			{
				if (f.SettlementNum <= 1) continue;

				result.Settlements.push({
					ID = f.ID,
					Num = f.SettlementNum
				});
			}
			else if (f.SettlementNum > 0)
			{
				result.Locations.push({
					ID = f.ID,
					Num = f.SettlementNum
				});
			}
		}

		result.Settlements.sort(this.onSortNum);
		result.Locations.sort(this.onSortNum);
		return result;
	}

	function convertFactionsToUIData()
	{
		local result = [];
		local valid = [
			this.Const.FactionType.OrientalCityState,
			this.Const.FactionType.NobleHouse,
			this.Const.FactionType.Settlement,
			this.Const.FactionType.Player,
		];
		local factions = clone this.World.FactionManager.getFactions(false);
		local factions_southern = [];
		local factions_with_settlement = [];
		local factions_misc = [];

		foreach( f in factions )
		{
			if (f == null)
			{
				continue;
			}

			if (f.getType() == this.Const.FactionType.OrientalCityState)
			{
				factions_southern.push(f);
			}
			else if (valid.find(f.getType()) != null)
			{
				factions_with_settlement.push(f);
			}
			else
			{
				factions_misc.push(f);
			}
		}

		factions_southern.sort(this.onSortFactions);
		factions_with_settlement.sort(this.onSortFactions);
		factions_misc.sort(this.onSortFactions);
		factions = [];
		factions.extend(factions_southern);
		factions.extend(factions_with_settlement);
		factions.extend(factions_misc);

		foreach( f in factions )
		{
			local faction = {
				ID = f.getID(),
				Name = ("getNameOnly" in f) ? f.getNameOnly() : f.getName(),
				Motto = f.getMotto(),
				Relation = f.getPlayerRelationAsText(),
				RelationNum = this.Math.round(f.getPlayerRelation())
				RelationNumSimplified = this.Math.min(this.Const.Strings.Relations.len() - 1, f.getPlayerRelation() / 10),
				FactionFixedRelation = f.isPlayerRelationPermanent(),
				IsNoble = f.getType() == this.Const.FactionType.NobleHouse,
				SettlementNum = f.getSettlements().len(),
			};

			if (valid.find(f.getType()) != null)
			{
				faction.ImagePath <- f.getUIBanner();
				faction.Contracts <- this.getContractsUI(f);
				faction.NoChangeName <- false;
			}
			else
			{
			    faction.ImagePath <- "ui/banners/banner_unknow.png";
			    faction.Contracts <- [];
			    faction.NoChangeName <- true;
			}

			result.push(faction);
		}

		return result;
	}

	function convertItemToUIData( _item, _owner )
	{
		local result = {};
		result.ID <- _item.getInstanceID();
		result.ShowAmount <- _item.isAmountShown();
		result.Amount <- _item.getAmountString();
		result.AmountColor <- _item.getAmountColor();
		result.ImagePath <- "ui/items/" + _item.m.Icon;
		result.Owner <- _owner;
		return result;
	}

	function convertTroopsToUIData( _worldEntity )
	{
		local result = [];

		foreach ( troop in _worldEntity.getTroops() )
		{
			local key = ::Woditor.getTroopKey(troop);
			local isMiniBoss = troop.Variant != 0;
			local i = this.lookForTroop(key, result, isMiniBoss);

			if (i != null)
			{
				++result[i].Num;
			}
			else
			{
				result.push({
					Name = ::Woditor.getTroopName(troop),
					Icon = ::Woditor.getTroopIcon(troop),
					Strength = troop.Strength,
					IsChampion = isMiniBoss,
					Key = key,
					Num = 1,
				});
			}
		}

		result.sort(this.onSortTroop);
		return result;
	}

	function getContractsUI( _faction )
	{
		if (_faction.getType() == this.Const.FactionType.Player)
		{
			return [];
		}

		local contracts = _faction.getContracts();
		local result = [];

		foreach ( c in contracts ) 
		{
			if (c.isActive())
			{
				continue;
			}

			result.push({
				ID = c.getID(),
				Icon = c.getBanner(),
				IsNegotiated = c.isNegotiated(),
				DifficultyIcon = c.getUIDifficultySmall(),
			});
		}

		return result;
	}

	function lookForTroop( _key, _troops, _isMiniboss )
	{
		foreach (i, troop in _troops )
		{
			if (_isMiniboss == troop.IsChampion && troop.Key == _key)
			{
				return i;
			}
		}

		return null;
	}

	function onSortTroop( _t1, _t2 )
	{
		if (_t1.Key < _t2.Key)
		{
			return -1;
		}
		else if (_t1.Key > _t2.Key)
		{
			return 1;
		}
		else
		{
			if (!_t1.IsChampion && _t2.IsChampion)
			{
				return -1;
			}
			else if (_t1.IsChampion && !_t2.IsChampion)
			{
				return 1;
			}
			
			return 0;
		}
	}

	function onSortWithFaction( _f1, _f2 )
	{
		if (_f1.Faction < _f2.Faction)
		{
			return -1;
		}
		else if (_f1.Faction > _f2.Faction)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}

	function onSortNum( _f1, _f2 )
	{
		if (_f1.Num > _f2.Num)
		{
			return -1;
		}
		else if (_f1.Num < _f2.Num)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}

	function onSortLocations( _l1, _l2 )
	{
		if (_l1.Faction < _l2.Faction)
		{
			return -1;
		}
		else if (_l1.Faction > _l2.Faction)
		{
			return 1;
		}
		else
		{
			if (_l1.Distance < _l2.Distance)
			{
				return -1;
			}
			else if (_l1.Distance > _l2.Distance)
			{
				return 1;
			}

			return 0;
		}
	}

	function onSortSettlements( _s1, _s2 )
	{
		if (_s1.Owner < _s2.Owner)
		{
			return -1;
		}
		else if (_s1.Owner > _s2.Owner)
		{
			return 1;
		}
		else
		{
			if (_s1.Distance < _s2.Distance)
			{
				return -1;
			}
			else if (_s1.Distance > _s2.Distance)
			{
				return 1;
			}

			return 0;
		}
	}

	function onSortFactions( _f1, _f2 )
	{
		if (_f1 == null && _f2 == null)
		{
			return 0;
		}

		if (_f1 == null)
		{
			return 1;
		}
		else if (_f2 == null)
		{
			return -1;
		}

		if (_f1.getType() < _f2.getType())
		{
			return -1;
		}
		else if (_f1.getType() > _f2.getType())
		{
			return 1;
		}
		else
		{
			if (_f1.getName() < _f2.getName())
			{
				return -1;
			}
			else if (_f1.getName() > _f2.getName())
			{
				return 1;
			}

			return 0;
		}
	}
};

