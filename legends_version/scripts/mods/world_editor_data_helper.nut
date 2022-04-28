this.world_editor_data_helper <- {
	m = {},
	function getWolrdEntityImagePath( _id )
	{
		return ::World.getEntityByID(_id).getUIImagePath();
	}

	function convertFactionAllianceToUIData( _data )
	{
		local faction = ::World.FactionManager.getFaction(_data[0]);
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
		local faction = ::World.FactionManager.getFaction(_id);
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
		local settlement = ::World.getEntityByID(_id);
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

	function convertLocationEntriesToUIData()
	{
		local result = {};

		foreach( name in ::Woditor.SubLocations )
		{
			result[name] <- [];
		}

		foreach (info in ::Woditor.Locations.All)
		{
			local entry = clone info;

			if (info.Script.find("legendary/") != null)
			{
				entry.FactionType <- null;
				result.Legendary.push(entry);
			}
			else if (info.Script.find("bandit_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Bandits;
				result.Bandit.push(entry);
			}
			else if (info.Script.find("barbarian_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Barbarians;
				result.Barbarian.push(entry);
			}
			else if (info.Script.find("nomad_") != null)
			{
				entry.FactionType <- ::Const.FactionType.OrientalBandits;
				result.Nomad.push(entry);
			}
			else if (info.Script.find("goblin_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Goblins;
				result.Goblin.push(entry);
			}
			else if (info.Script.find("orc_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Orcs;
				result.Orc.push(entry);
			}
			else if (info.Script.find("undead_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Undead;
				result.Undead.push(entry);
			}
			else if (info.Script.find("cultist_") != null)
			{
				entry.FactionType <- ::Const.FactionType.Cultists;
				result.Cultist.push(entry);
			}
			else
			{
				entry.FactionType <- null;
				result.Misc.push(entry);
			}
		}

		return result;
	}

	function convertAttachedLocationEntriesToUIData()
	{
		local result = [];

		foreach( script in ::Woditor.AttachedLocations.Valid )
		{
			local attached_location = ::Woditor.AttachedLocations.Stuff[script];

			result.push({
				Script = script,
				Name = attached_location.getName(),
				ID = attached_location.getTypeID(),
				ImagePath = attached_location.getUIImagePath()
			});
		}

		return result;
	}

	function convertSituationEntriesToUIData( _id )
	{
		local settlement = ::World.getEntityByID(_id);
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

	function convertBannerSpriteEntriesToUIData( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		local banner = world_entity.isParty() ? world_entity.getSprite("banner") : world_entity.getSprite("location_banner");
		local result = [];
		local valid = [];
		valid.extend(::Woditor.ValidBannerSprites);

		if (banner.HasBrush)
		{
			local find = valid.find(banner.getBrush().Name);

			if (find != null)
			{
				valid.remove(find);
			}
		}

		foreach (banner in valid )
		{
			result.push({
				ImagePath = "ui/banners/" + banner + ".png",
				Sprite = banner
			});
		}

		return result;
	}

	function convertUnitSpriteEntriesToUIData( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		local body = world_entity.getSprite("body");
		local result = [];
		local valid = [];
		valid.extend(::Woditor.ValidPartySprites);

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
				ImagePath = "ui/parties/" + sprite + ".png",
				Sprite = sprite
			});
		}

		return result;
	}

	function convertLocationSpriteEntriesToUIData( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
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
			local troop = ::Const.World.Spawn.Troops[key];

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

	function convertPartiesEntriesToUIData()
	{
		local result = {};

		foreach (i, name in ::Woditor.SubParties)
		{
			result[name] <- [];
			local key = name.tolower();
			local party_keys = this.convertTroopTemplateToUIData(key);

			foreach (_key in party_keys)
			{
				local party = ::Const.World.Spawn[_key];
				result[name].push({
					Key = _key,
					Name = party.Name,
					FactionType = ::Woditor.SubPartyFactionType[i],
					ImagePath = ("Body" in party) ? "ui/parties/" + party.Body + ".png" : "ui/images/undiscovered_opponent.png",
				});
			}
		}

		return result;
	}

	function convertTroopTemplateToUIData( _type = null )
	{
		local result = [];

		switch (_type)
		{
		case "caravan":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Caravan") == null) continue;
				result.push(key);
			}
			break;

		case "noble":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Noble") == null || key.find("Caravan") != null) continue;
				result.push(key);
			}
			break;

		case "southern":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Southern") == null || key.find("Caravan") != null) continue;
				result.push(key);
			}
			result.extend([
				"Slaves",
				"NorthernSlaves",
				"Assassins",
				"SatoManhunters"
			]);
			break;

		case "mercenary":
			foreach(key, value in ::Const.World.Spawn)
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
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Bandit") == null) continue;
				result.push(key);
			}
			break;

		case "barbarian":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Barbarian") == null) continue;
				result.push(key);
			}
			break;

		case "nomad":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Nomad") == null) continue;
				result.push(key);
			}
			break;

		case "goblin":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Goblin") == null) continue;
				result.push(key);
			}
			result.push("GreenskinHorde");
			break;

		case "orc":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Orc") == null && key.find("Berserkers") == null) continue;
				result.push(key);
			}
			result.push("GreenskinHorde");
			break;

		case "necromancer":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Zombie") == null && key.find("Ghost") == null && key.find("Necromancer") == null) continue;
				result.push(key);
			}
			break;

		case "undead":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Undead") == null && key.find("Vampire") == null && key.find("Mummi") == null) continue;
				result.push(key);
			}
			break;

		case "beast":
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				if (key.find("Noble") == null || key.find("Southern") != null || key.find("Caravan") != null) continue;
				if (key.find("Undead") != null || key.find("Vampire") != null || key.find("Mummi") || null) continue;
				if (key.find("Zombie") != null || key.find("Ghost") != null || key.find("Necromancer") || null) continue;
				if (key.find("Orc") != null || key.find("Berserkers") != null) continue;
				if (key.find("Goblin") != null) continue;
				if (key.find("Nomad") != null) continue;
				if (key.find("Barbarian") != null) continue;
				if (key.find("Bandit") != null) continue;
				if (key.find("Company") != null) continue;
				result.push(key);
			}
			break;
	
		default: // all
			foreach(key, value in ::Const.World.Spawn)
			{
				if (typeof value != "table") continue;
				result.push(key);
			}
		}

		local exclude = ["Unit", "Troops", "TroopsMap"];

		foreach (key in exclude)
		{
			local find = result.find(key);
			if (find != null) 
			{
				result.remove(find);
			}
		}

		return result;
	}

	function convertAvatarToUIData( _screen )
	{
		::World.Assets.updateLook();
		local result = {};
		local roster = ::World.getTemporaryRoster();
		local player = ::World.State.getPlayer();
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
		result.Sockets <- ::Const.WorldSockets;
		result.SocketIndex <- 0;
		result.Selected <- {
			Row = 0,
			Index = 0,
		};

		foreach (i, row in ::Const.WorldSprites) 
		{
			local index = row.find(body);

			if (index != null)
			{
				result.Selected.Row = i;
				result.Selected.Index = index;
			}

			result.SpriteNames.push(::Const.WorldSpritesNames[i]);
			result.Sprites.push(row);
		}
		
		local index = ::Const.WorldSockets.find(socket);
		if (index != null) result.SocketIndex = index;
		return result;
	}

	function convertScenariosToUIData()
	{
		local result = {};
		local currentID = ::World.Assets.getOrigin().getID();
		result.Data <- ::Const.ScenarioManager.getDataScenariosForUI()
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
		result.Banners.Data.push(::Const.PlayerBanners);
		result.Banners.Data.push(::Const.NobleBanners);
		result.Banners.Data.push(::Const.OtherBanner);
		result.Banners.Selected = ::Const.PlayerBanners.find(::World.Assets.getBanner());

		// roster and difficulty sliders
		result.DifficultyMult <- ::World.Flags.has("DifficultyMult") ? ::World.Flags.getAsInt("DifficultyMult") : 100;
		result.RosterTier <- {
			Max = ::Const.Roster.Tier[::Const.Roster.Tier.len() - 1],
			Value = ::World.Assets.getOrigin().getStartingRosterTier()
		};

		// check box configurations
		result.CheckBox <- {
			IsIronman = ::World.Assets.isIronman(),
			IsBleedKiller = ::LegendsMod.Configs().LegendBleedKillerEnabled(),
			IsLocationScaling = ::LegendsMod.Configs().LegendLocationScalingEnabled(),
			IsRecruitScaling = ::LegendsMod.Configs().LegendRecruitScalingEnabled(),
			IsWorldEconomy = ::LegendsMod.Configs().LegendWorldEconomyEnabled(),
			IsBlueprintsVisible = ::LegendsMod.Configs().LegendAllBlueprintsEnabled(),
			IsGender = ::LegendsMod.Configs().LegendGenderLevel(),
			CombatDifficulty = ::World.Assets.getCombatDifficulty(),
			EconomicDifficulty = ::World.Assets.getEconomicDifficulty(),
		};

		// assets stuffs
		result.Name <- ::World.Assets.getName();
		result.BusinessReputation <- ::World.Assets.getBusinessReputation();
		result.MoralReputation <- ::World.Assets.getMoralReputation();
		result.Money <- ::World.Assets.getMoney();
		result.Stash <- ::World.Assets.getStash().getCapacity();
		result.Ammo <- ::World.Assets.getAmmo();
		result.ArmorParts <- ::World.Assets.getArmorParts();
		result.Medicine <- ::World.Assets.getMedicine();
		result.MovementSpeedMult <- ::Math.floor(::World.Assets.m.MovementSpeedMult * 100);
		result.EquipmentLootChance <- ::World.Assets.m.EquipmentLootChance;
		
		foreach (key in ::Woditor.AssetsProperties.Mult)
		{
			result[key] <- ::Math.floor(::World.Assets.m[key] * 100);
		}

		foreach (key in ::Woditor.AssetsProperties.Additive)
		{
			result[key] <- ::World.Assets.m[key];
		}

		return result;
	}

	function convertUnitsToUIData()
	{
		local result = [];
		local playerTile = ::World.State.getPlayer().getTile();
		local factions = clone ::World.FactionManager.getFactions(false);

		foreach( f in factions )
		{
			if (f == null)
			{
				continue;
			}

			foreach( party in f.getUnits() )
			{
				result.push(this.convertUnitPartyToUIData(party, playerTile));
			}
		}

		foreach( party in ::World.EntityManager.getMercenaries() )
		{
			result.push(this.convertUnitPartyToUIData(party, playerTile));
		}

		result.sort(this.onSortByFactionAndDistance);
		return result;
	}

	function convertLocationsToUIData()
	{
		local result = [];
		local playerTile = ::World.State.getPlayer().getTile();

		foreach (i, location in ::World.EntityManager.getLocations())
		{
			if (location.isLocationType(::Const.World.LocationType.AttachedLocation) || location.m.IsBattlesite)
			{
				continue;
			}
			else
			{
				location.onVisibleToPlayer();
			}

			local isUnique = location.isLocationType(::Const.World.LocationType.Unique);
			local isLair = location.isLocationType(::Const.World.LocationType.Lair);
			local isPassive = location.isLocationType(::Const.World.LocationType.Passive);
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
				Resources = location.getResources(),
				Terrain = location.getTerrainImage(),
				ImagePath = location.getUIImagePath(),
				Troops = this.convertTroopsToUIData(location),
				NamedItemChance = location.getNameItemChance(),
				Distance = playerTile.getDistanceTo(location.getTile()),
				IsSpawningTroop = location.getDefenderSpawnList() != null,
				Fortification = location.getCombatLocation().Fortification != 0,
				IsParty = location.isParty(),
				IsPassive = isPassive && !isLair,
				IsCamp =  isLair && !isUnique,
				IsLegendary = isUnique,
			});
		}

		result.sort(this.onSortByFactionAndDistance);
		return result;
	}

	function convertSettlementsToUIData()
	{
		local result = [];
		local playerTile = ::World.State.getPlayer().getTile();

		foreach(i, settlement in ::World.EntityManager.getSettlements())
		{
			if (settlement.getFactionOfType(::Const.FactionType.Player) != null)
			{
				continue;
			}

			local faction;
			local owner;
			local buildings = [];
			local attached_locations = [];
			local situations = [];
			local draftlist = [];
			local find = settlement.getFactionOfType(::Const.FactionType.Settlement);

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
					ImagePath = a.getUIImagePath(),
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

			/* processing draft list
			foreach( draft in settlement.getDraftList() )
			{
				draftlist.push({
					Key = draft,
					ImagePath = ::Woditor.Backgrounds.Stuff[draft].Icon
				})
			}*/

			result.push({
				ID = settlement.getID(),
				Name = settlement.getName(),
				Size = settlement.getSize(),
				House = settlement.m.HousesTiles.len(),
				HouseMax = settlement.getHouseMax(),
				HouseImage = settlement.getHouseUIImage(),
				Terrain = settlement.getTerrainImage(),
				ImagePath = settlement.getUIImagePath(),
				Wealth = settlement.getWealth(),
				Resources = settlement.getResources(),
				IsActive = settlement.isActive(),
				IsCoastal = settlement.isCoastal(),
				IsMilitary = settlement.isMilitary(),
				IsSouthern = settlement.isSouthern(),
				IsTown = !settlement.isMilitary() && !settlement.isSouthern(),
				IsIsolated = settlement.isIsolatedFromRoads(),
				Distance = playerTile.getDistanceTo(settlement.getTile()),
				Attachments = attached_locations,
				Situations = situations,
				Buildings = buildings,
				//DraftList = draftlist,
				Faction = faction,
				Owner = owner,
			});
		}

		result.sort(this.onSortSettlements);
		return result;
	}

	function convertFactionsToUIData()
	{
		local result = [];
		local valid = [
			::Const.FactionType.OrientalCityState,
			::Const.FactionType.NobleHouse,
			::Const.FactionType.Settlement,
		];
		local factions = clone ::World.FactionManager.getFactions(false);
		local factions_southern = [];
		local factions_with_settlement = [];
		local factions_misc = [];

		foreach( f in factions )
		{
			if (f == null || f.getType() == ::Const.FactionType.Player)
			{
				continue;
			}

			if (f.getType() == ::Const.FactionType.OrientalCityState)
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
				Type = f.getType(),
				Name = ("getNameOnly" in f) ? f.getNameOnly() : f.getName(),
				Motto = f.getMotto(),
				Relation = f.getPlayerRelationAsText(),
				RelationNum = ::Math.round(f.getPlayerRelation())
				RelationNumSimplified = ::Math.min(::Const.Strings.Relations.len() - 1, f.getPlayerRelation() / 10),
				FactionFixedRelation = f.isPlayerRelationPermanent(),
				IsNoble = f.getType() == ::Const.FactionType.NobleHouse,
				SettlementNum = f.getSettlements().len(),
				UnitNum = f.getUnits().len()
			};

			if (valid.find(f.getType()) != null)
			{
				faction.ImagePath <- f.getUIBanner();
				faction.NoChangeName <- false;
			}
			else
			{
			    faction.ImagePath <- "ui/banners/banner_unknow.png";
			    faction.NoChangeName <- true;
			}

			result.push(faction);
		}

		return result;
	}

	function convertContractsToUIData()
	{
		local result = [];

		foreach( contract in ::World.Contracts.getOpenContracts() )
		{
			if (contract.getFaction() == ::Const.FactionType.Player)
			{
				continue;
			}

			local daysLeft = ::Math.max(1, ::Math.abs(::Time.getVirtualTimeF() - contract.m.TimeOut) / ::World.getTime().SecondsPerDay);
			local originID = (contract.getOrigin() != null && !contract.getOrigin().isNull()) ? contract.getOrigin().getID() : null;
			local homeID = (contract.getHome() != null && !contract.getHome().isNull()) ? contract.getHome().getID() : null;
			local employeImagePath = contract.getEmployer() != null ? contract.getEmployer().getImagePath() : null;
			local objective;

			if ("Destination" in contract.m)
			{
				objective = (contract.m.Destination != null && !contract.m.Destination) ? contract.m.Destination.getID() : null;
			}

			if (objective == null && "Location" in contract.m)
			{
				objective = (contract.m.Location != null && !contract.m.Location) ? contract.m.Location.getID() : null;
			}

			result.push({
				ID = contract.getID(),
				Name = contract.getName(),
				Type = contract.getType(),
				Icon = contract.getBanner() + ".png",
				Faction = contract.getFaction(),
				IsNegotiated = contract.isNegotiated(),
				DifficultyIcon = contract.getUIDifficultySmall() + ".png",
				DifficultyMult = ::Math.floor(contract.getDifficultyMult() * 100),
				PaymentMult = ::Math.floor(contract.getPaymentMult() * 100),
				Employer = employeImagePath,
				Objective = objective,
				Expire = daysLeft,
				Origin = originID,
				Home = homeID
			});
		}

		result.sort(this.onSortByFaction);
		return result;
	}

	function convertAvailableContractToUIData( _result )
	{
		foreach (id, v in ::Woditor.Contracts)
		{
			if (::Woditor.InvalidContracts.find(id) != null) continue;
			if (v.ChangeObjective) continue;

			_result.push({
				Type = id,
				Name = v.Name,
				Script = v.Script,
			});
		}

		_result.sort(this.onSortByName);
		return _result;
	}

	function convertInvalidContractsToUIData( _result )
	{
		foreach (id, v in ::Woditor.Contracts)
		{
			_result.InvalidContracts.push({
				Type = id,
				Name = v.Name,
				Script = v.Script,
				IsValid = ::Woditor.InvalidContracts.find(id) == null,
			});
		}

		_result.InvalidContracts.sort(this.onSortByName);
	}

	function convertUnitPartyToUIData( _party , _playerTile )
	{
		return {
			ID = _party.getID(),
			Name = _party.getName(),
			Faction = _party.getFaction(),
			TooltipId = _party.getID(),
			Banner = _party.getUIBanner(),
			Resources = _party.getResources(),
			Terrain = _party.getTerrainImage(),
			ImagePath = _party.getUIImagePath(),
			LootScale = ::Math.floor(_party.m.LootScale * 100),
			VisibilityMult = ::Math.floor(_party.getVisibilityMult() * 100),
			BaseMovementSpeed = ::Math.floor(_party.getBaseMovementSpeed()),
			Troops = this.convertTroopsToUIData(_party),
			Distance = _playerTile.getDistanceTo(_party.getTile()),
			IsAlwaysAttackingPlayer = _party.isAlwaysAttackingPlayer(),
			IsLeavingFootprints = _party.m.IsLeavingFootprints,
			IsAttackableByAI = _party.isAttackableByAI(),
			IsSlowerAtNight = _party.isSlowerAtNight(),
			IsLooting = _party.isLooting(),
			IsCaravan = _party.getFlags().get("IsCaravan"),
			IsQuest = _party.getSprite("selection").Visible,
			IsParty = _party.isParty(),
			IsSpawningTroop = false,
		};
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

	function convertToUIFilterData( _factions )
	{
		local result = {Contracts = [], InvalidContracts = [], Settlements = [], Locations = [], Units = []};

		foreach( f in _factions )
		{
			if (!f.NoChangeName)
			{
				if (f.SettlementNum > 1)
				{
					result.Settlements.push({
						Name = f.Name,
						Search = null,
						Filter = ["Faction", f.ID],
						Num = f.SettlementNum
					});
				}
			}
			else if (f.SettlementNum > 0)
			{
				result.Locations.push({
					Name = f.Name,
					Search = null,
					Filter = ["Faction", f.ID],
					Num = f.SettlementNum
				});
			}

			if (f.UnitNum > 0)
			{
				result.Units.push({
					Name = f.Name,
					Search = null,
					Filter = ["Faction", f.ID],
					Num = f.UnitNum
				});
			}
		}

		result.Settlements.sort(this.onSortNum);
		result.Locations.sort(this.onSortNum);
		result.Units.sort(this.onSortNum);
		this.addDefaultContractFilters(result);
		this.addDefaultSettlementFilters(result);
		this.addDefaultLocationFilters(result);
		this.addDefaultUnitsFilters(result);
		this.convertInvalidContractsToUIData(result);
		return result;
	}

	function addDefaultSettlementFilters( _result )
	{
		_result.Settlements.insert(0, {Name = "City States", Search = null, Filter = ["IsSouthern", true]});
		_result.Settlements.insert(0, {Name = "Strongholds", Search = null, Filter = ["IsMilitary", true]});
		_result.Settlements.insert(0, {Name = "Towns"      , Search = null, Filter = ["IsTown"    , true]});
	}

	function addDefaultLocationFilters( _result )
	{
		_result.Locations.insert(0, {Name = "Legendary", Search = null, Filter = ["IsLegendary", true]});
		_result.Locations.insert(0, {Name = "Camps"    , Search = null, Filter = ["IsCamp"     , true]});
		_result.Locations.push(     {Name = "Misc"     , Search = null, Filter = ["IsPassive"  , true]}); // at the bottom of the list
	}

	function addDefaultUnitsFilters( _result )
	{
		_result.Units.insert(0, {Name = "Quest Target", Search = null, Filter = ["IsQuest", true]});
		_result.Units.insert(0, {Name = "Caravan"     , Search = null, Filter = ["IsCaravan", true]});
	}

	function addDefaultContractFilters( _result )
	{
		_result.Contracts.push({Name = "Settlement"          , Search = ["Faction", "Faction"] , Filter = ["Type", ::Const.FactionType.Settlement]});
		_result.Contracts.push({Name = "Noble"               , Search = ["Faction", "Faction"] , Filter = ["Type", ::Const.FactionType.NobleHouse]});
		_result.Contracts.push({Name = "Southern"            , Search = ["Faction", "Faction"] , Filter = ["Type", ::Const.FactionType.OrientalCityState]});
		_result.Contracts.push({Name = "Legendary Contract"  , Search = null      , Filter = ["Icon", "ui/banners/factions/banner_legend_s.png"]});
		_result.Contracts.push({Name = "Difficulty Easy"     , Search = null      , Filter = ["DifficultyIcon", "ui/icons/difficulty_easy.png"]});
		_result.Contracts.push({Name = "Difficulty Medium"   , Search = null      , Filter = ["DifficultyIcon", "ui/icons/difficulty_medium.png"]});
		_result.Contracts.push({Name = "Difficulty Hard"     , Search = null      , Filter = ["DifficultyIcon", "ui/icons/difficulty_hard.png"]});
		_result.Contracts.push({Name = "Difficulty Legendary", Search = null      , Filter = ["DifficultyIcon", "ui/icons/difficulty_legend.png"]});
	}

	function convertItemToUIData( _item, _owner )
	{
		local result = {};
		result.Owner <- _owner;
		result.Name <- _item.m.Name;
		result.ID <- _item.getInstanceID();
		result.ShowAmount <- _item.isAmountShown();
		result.Amount <- _item.getAmountString();
		result.AmountColor <- _item.getAmountColor();
		result.ImagePath <- "ui/items/" + _item.m.Icon;
		result.ImageOverlayPath <- _item.getIconOverlay();
		result.CanChangeName <- _item.isItemType(::Const.Items.ItemType.Named) || ::mods_isClass(_item, "accessory_dog") != null; //"setName" in _item;
		result.CanChangeAmount <- _item.isItemType(::Const.Items.ItemType.Supply) || _item.isItemType(::Const.Items.ItemType.Food); //"setAmount" in _item;
		result.CanChangeStats <- _item.isItemType(::Const.Items.ItemType.Named);
		result.ClassName <- _item.ClassNameHash;
		result.Attribute <- null;
		return result;
	}

	function getAdditionInfoFromItem( _item )
	{
		local result = {};

		if (_item.isItemType(::Const.Items.ItemType.Named))
		{
			local isShield = _item.isItemType(::Const.Items.ItemType.Shield);
			local isMelee = _item.isItemType(::Const.Items.ItemType.MeleeWeapon);
			local isRanged = _item.isItemType(::Const.Items.ItemType.RangedWeapon);
			local isThrowing = _item.isItemType(::Const.Items.ItemType.Ammo);

			switch (true)
			{
			case isShield:
				result = {
					MeleeDefense = _item.getMeleeDefense(),
					RangedDefense = _item.getRangedDefense(),
					FatigueOnSkillUse = _item.m.FatigueOnSkillUse,
				};
				break;

			case isMelee:
				result = {
					RegularDamage = _item.getDamageMin(),
					RegularDamageMax = _item.getDamageMax(),
					ArmorDamageMult = this.Math.floor(_item.getArmorDamageMult() * 100),
					DirectDamageAdd = this.Math.floor(_item.m.DirectDamageAdd * 100),
					ShieldDamage = _item.m.ShieldDamage,
					ChanceToHitHead = _item.m.ChanceToHitHead,
					FatigueOnSkillUse = _item.m.FatigueOnSkillUse,
				};
				break;

			case isRanged:
				result = {
					RegularDamage = _item.getDamageMin(),
					RegularDamageMax = _item.getDamageMax(),
					ArmorDamageMult = this.Math.floor(_item.getArmorDamageMult() * 100),
					DirectDamageAdd = this.Math.floor(_item.m.DirectDamageAdd * 100),
					ChanceToHitHead = _item.m.ChanceToHitHead,
					FatigueOnSkillUse = _item.m.FatigueOnSkillUse,
					AdditionalAccuracy = _item.getAdditionalAccuracy(),
				};
				break;
		
			default:
				result = {};
			}

			if (isThrowing) result.AmmoMax <- _item.getAmmoMax();
			result.ConditionMax <- _item.getConditionMax();
			result.StaminaModifier <- _item.m.StaminaModifier;
		}

		return result;
	}

	function convertPlayerStashToUIData( _sort = false )
	{
		if (_sort)
		{
			::World.Assets.getStash().sort();
		}

		local result = {};
		result.Slots <- ::World.Assets.getStash().getCapacity();
		result.Stash <- this.convertStashItemsToUIData(::World.Assets.getStash());
		return result;
	}

	function convertStashItemsToUIData( _stash )
	{
		local result = [];
		local id = _stash.getID();

		foreach (i, _item in _stash.m.Items)
		{
			if (_item == null) continue;

			local entry = this.convertItemToUIData(_item, id);
			entry.Attribute = this.getAdditionInfoFromItem(_item);
			entry.Index <- i;
			result.push(entry);
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

	function onSortByName( _f1, _f2 )
	{
		if (_f1.Name < _f2.Name)
		{
			return -1;
		}
		else if (_f1.Name > _f2.Name)
		{
			return 1;
		}
		else
		{
			return 0;
		}
	}

	function onSortByFaction( _f1, _f2 )
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

	function onSortByFactionAndDistance( _l1, _l2 )
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

