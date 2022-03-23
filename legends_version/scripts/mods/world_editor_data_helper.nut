this.world_editor_data_helper <- {
	m = {},
	function create() {}

	function convertAssetsToUIData()
	{
		local result = {};
		result.Name <- this.World.Assets.getName();
		result.BusinessReputation <- this.World.Assets.getBusinessReputation();
		result.MoralReputation <- this.World.Assets.getMoralReputation();
		result.Money <- this.World.Assets.getMoney();
		result.Stash <- this.World.Assets.getStash().getCapacity();
		result.Ammo <- this.World.Assets.getAmmo();
		result.ArmorParts <- this.World.Assets.getArmorParts();
		result.Medicine <- this.World.Assets.getMedicine();
		
		foreach (key in this.Woditor.AssetsProperties.Mult)
		{
			result[key] <- this.Math.floor(this.World.Assets.m[key] * 100);
		}

		foreach (key in this.Woditor.AssetsProperties.Additive)
		{
			result[key] <- this.World.Assets.m[key];
		}

		return result;
	}

	function convertTroopEntriesToUIData( _data )
	{
		local exclude = _data[0];
		local filter = _data[1];
		local list = clone this.Woditor.ValidTroops[filter];
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
				Name = this.Woditor.getTroopName(troop),
				Icon = this.Woditor.getTroopIcon(troop),
				Strength = troop.Strength,
				Cost = troop.Cost,
				Key = key,
			})
		}

		return result;
	}

	function convertLocationsToUIData( _factions )
	{
		local result = [
			[],
			[],
			[]
		];

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

			local index;

			if (location.isLocationType(this.Const.World.LocationType.Unique))
			{
				index = 1;
			}
			else if (location.isLocationType(this.Const.World.LocationType.Lair))
			{
				index = 0;
			}
			else
			{
				index = 2;
			}

			local loots = [];
			local troops = [];

			foreach ( troop in location.getTroops() )
			{
				local key = this.Woditor.getTroopKey(troop);
				local isMiniBoss = troop.Variant != 0;
				local i = this.lookForTroop(key, troops, isMiniBoss);

				if (i != null)
				{
					++troops[i].Num;
				}
				else
				{
					troops.push({
						Name = this.Woditor.getTroopName(troop),
						Icon = this.Woditor.getTroopIcon(troop),
						Strength = troop.Strength,
						IsChampion = isMiniBoss,
						Key = key,
						Num = 1,
					});
				}
			}

			result[index].push({
				ID = location.getID(),
				Type = location.getTypeID(),
				Name = location.getName(),
				Faction = location.getFaction(),
				TooltipId = location.getTooltipId(),
				Banner = location.getUIBanner(),
				ImagePath = location.getUIImage(),
				Resources = location.getResources(),
				Loots = loots,
				Troops = troops,
			});
		}

		result[0].sort(this.onSortWithFaction);
		result[1].sort(this.onSortName);
		result[2].sort(this.onSortName);
		return result;
	}

	function convertSettlementsToUIData( _factions )
	{
		local result = [];

		foreach(i, settlement in this.World.EntityManager.getSettlements())
		{
			local faction;
			local buildings = [];
			local attached_locations = [];
			local situations = [];
			local owner = settlement.getOwner() != null && !settlement.getOwner().isNull() ? settlement.getOwner().getID() : null;
			local find = settlement.getFactionOfType(this.Const.FactionType.Settlement);

			if (find != null)
			{
				faction = find.getID();
			}
			else
			{
				faction = settlement.getFactions()[0];
			}

			foreach(i, b in settlement.m.Buildings )
			{
				if (b == null)
				{
					buildings.push(null);
				}
				else
				{
					if (b.getID() == "building.crowd" || b.getID() == "building.marketplace")
					{
						continue;
					}

					buildings.push({
						ID = b.getID(),
						ImagePath = b.m.UIImage + ".png",
						TooltipId = b.m.Tooltip,
					});
				}

				if (buildings.len() == 4)
				{
					break;
				}
			}

			foreach( a in settlement.getAttachedLocations() )
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

			foreach( situation in settlement.getSituations() )
			{
				situations.push({
					ID = situation.getID(),
					ImagePath = situation.getIcon()
				});
			}

			result.push({
				ID = settlement.getID(),
				Name = settlement.getName(),
				Size = settlement.getSize(),
				Buildings = buildings,
				Attachments = attached_locations,
				Situations = situations,
				Owner = this.findIdIn(owner, _factions),
				Faction = this.findIdIn(faction, _factions),
				ImagePath = settlement.getImagePath(),
				Wealth = settlement.getWealth(),
				Resources = settlement.getResources(),
				IsCoastal = settlement.isCoastal(),
				IsMilitary = settlement.isMilitary(),
				IsSouthern = settlement.isSouthern(),
			});
		}

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
				Relation = f.getPlayerRelationAsText(),
				RelationNum = this.Math.round(f.getPlayerRelation())
				RelationNumSimplified = this.Math.min(this.Const.Strings.Relations.len() - 1, f.getPlayerRelation() / 10),
				IsHostile = !f.isAlliedWithPlayer(),
				IsFixedRelation = false,
			};

			if (valid.find(f.getType()) != null)
			{
				faction.ImagePath <- f.getUIBanner();
				faction.Contracts <- this.getContractsUI(f);
				faction.NoChangeName <- false;

				if (f.getType() == this.Const.FactionType.Settlement)
				{
					faction.Landlord <- f.getSettlements()[0].getOwner().getUIBanner();
					faction.NoChangeName = true;
				}
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

	function lookForTroop( _key, _troops, _isChampion )
	{
		foreach (i, troop in _troops )
		{
			if (troop.Key == _key && (!_isChampion || troop.IsChampion))
			{
				return i;
			}
		}

		return null;
	}

	function findIdIn( _id, _array )
	{
		if (_id == null)
		{
			return null;
		}

		foreach (i, a in _array )
		{
			if (a.ID == _id)
			{
				return i;
			}
		}

		return null;
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

	function onSortName( _f1, _f2 )
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

