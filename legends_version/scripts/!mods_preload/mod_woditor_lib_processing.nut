::Woditor.processWoditorLib <- function ()
{
	// UI Processing Helper for Woditor
	::Woditor.Helper <- ::new("scripts/mods/world_editor_data_helper");

	// non-player banners
	::Woditor.ValidBannerSprites <- [];
	::Woditor.ValidBannerSprites.extend(::Const.BanditBanners);
	::Woditor.ValidBannerSprites.extend(::Const.BarbarianBanners);
	::Woditor.ValidBannerSprites.extend(::Const.GoblinBanners);
	::Woditor.ValidBannerSprites.extend(::Const.OrcBanners);
	::Woditor.ValidBannerSprites.extend(::Const.ZombieBanners);
	::Woditor.ValidBannerSprites.extend(::Const.UndeadBanners);
	::Woditor.ValidBannerSprites.extend(::Const.NomadBanners);
	::Woditor.ValidBannerSprites.extend(::Const.PlayerBanners);
	::Woditor.ValidBannerSprites.push("banner_deserters");

	for (local i = 1; i < 15; ++i)
	{
		::Woditor.ValidBannerSprites.push("banner_noble_" + (i < 10 ? "0" + i : i));
	}

	// filter valid locations for woditor
	::Woditor.Locations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	::Woditor.SubLocations <- ["Bandit", "Barbarian", "Nomad", "Goblin", "Orc", "Undead", "Cultist", "Legendary", "Misc"];
	::Woditor.SubParties <- ["Caravan", "Noble", "Southern",  "Mercenary", "Bandit", "Barbarian", "Nomad", "Goblin", "Orc", "Necromancer", "Undead", "Misc"],
	::Woditor.SubPartyFactionType <- [[2, 3, 13], [3], [13], [2, 3, 13], [5], [12], [14], [7], [6], [9], [8], [10]];
	::Woditor.PrepareLocationsOnCampaignStart <- function()
	{
		if (::Woditor.Locations.All.len() > 0) return;

		local tile = this.World.getTileSquare(1, 1);
		local locations = ::IO.enumerateFiles("scripts/entity/world/locations/");

		foreach (i, script in locations )
		{
			if (::Const.Invalid.Locations.find(script) != null) continue;

			local location = ::World.spawnLocation(script, tile.Coords);
			local info = {
				Name = location.getName(),
				Type = location.getTypeID(),
				ImagePath = location.getUIImagePath(),
				Description = location.getDescription(),
				Script = script.slice("scripts/entity/world/locations/".len()),
				IsPassive = location.isLocationType(::Const.World.LocationType.Passive) && !location.isLocationType(::Const.World.LocationType.Lair),
				IsCamp =  location.isLocationType(::Const.World.LocationType.Lair) && !location.isLocationType(::Const.World.LocationType.Unique),
				IsLegendary = location.isLocationType(::Const.World.LocationType.Unique),
			};

			::Woditor.Locations.Valid.push(script);
			::Woditor.Locations.All.push(info);
			::Woditor.Locations.Stuff[script] <- info;

			if (!::Woditor.Locations.Tooltip.rawin(location.getTypeID()))
			{
				::Woditor.Locations.Tooltip[location.getTypeID()] <- info;
			}

			location.die();
		}
	}

	::Woditor.Settlements <- {
		All = [],
		Fort = [],
		Village = [],
		CityState = [],
	};
	::Woditor.Settlements.Village.push([]);
	::Woditor.Settlements.Village.push([]);
	::Woditor.Settlements.Village.push([]);
	::Woditor.Settlements.Fort.push([]);
	::Woditor.Settlements.Fort.push([]);
	::Woditor.Settlements.Fort.push([]);
	::Woditor.PrepareSettlementsOnCampaignStart <- function()
	{
		if (::Woditor.Settlements.All.len() > 0) return;

		::Woditor.Settlements.All.extend([
			{
				Name = "Small Village",
				ImagePath = "ui/settlement_sprites/townhall_01.png",
				IsSouthern = false,
				IsVillage = true,
				Size = 0,
			},
			{
				Name = "Village",
				ImagePath = "ui/settlement_sprites/townhall_02.png",
				IsSouthern = false,
				IsVillage = true,
				Size = 1,
			},
			{
				Name = "Town",
				ImagePath = "ui/settlement_sprites/townhall_03.png",
				IsSouthern = false,
				IsVillage = true,
				Size = 2,
			},
			{
				Name = "Fort",
				ImagePath = "ui/settlement_sprites/stronghold_01.png",
				IsSouthern = false,
				IsVillage = false,
				Size = 0,
			},
			{
				Name = "Stronghold",
				ImagePath = "ui/settlement_sprites/stronghold_02.png",
				IsSouthern = false,
				IsVillage = false,
				Size = 1,
			},
			{
				Name = "Citadel",
				ImagePath = "ui/settlement_sprites/stronghold_03.png",
				IsSouthern = false,
				IsVillage = false,
				Size = 2,
			},
			{
				Name = "City-State",
				ImagePath = "ui/settlement_sprites/citystate_01.png",
				IsSouthern = true,
				IsVillage = false,
				Size = 0,
			},
		]);
		
		local settlements = "scripts/entity/world/settlements/";
		foreach ( script in ::IO.enumerateFiles(settlements) )
		{
			if (script.find("/situations/") != null) continue;
			if (script.find("/buildingss/") != null) continue;
			if (script.find("legends_") != null) continue;
			if (::Const.Invalid.Settlements.find(script) != null) continue;

			if (script.find("city_state") != null) 
			{
				::Woditor.Settlements.CityState.push(script);
			}
			else if (script.find("village") != null)
			{
				if (script.find("large_") != null) 
				{
					::Woditor.Settlements.Village[2].push(script);
				}
				else if (script.find("medium_") != null)
				{
					::Woditor.Settlements.Village[1].push(script);
				}
				else
				{
					::Woditor.Settlements.Village[0].push(script);
				}
			}
			else if (script.find("fort") != null)
			{
				if (script.find("large_") != null) 
				{
					::Woditor.Settlements.Fort[2].push(script);
				}
				else if (script.find("medium_") != null)
				{
					::Woditor.Settlements.Fort[1].push(script);
				}
				else
				{
					::Woditor.Settlements.Fort[0].push(script);
				}
			}
		}
	}

	// location sprites
	::Woditor.ValidLocationSprites <- [];
	local locations_directory = "gfx/ui/locations/";
	foreach (i, directory in ::IO.enumerateFiles(locations_directory) )
	{
		::Woditor.ValidLocationSprites.push(directory.slice(locations_directory.len()));
	}

	// party sprites
	::Woditor.ValidPartySprites <- [];
	local parties_directory = "gfx/ui/parties/";
	foreach (i, directory in ::IO.enumerateFiles(parties_directory) )
	{
		::Woditor.ValidPartySprites.push(directory.slice(parties_directory.len()));
	}

	// contracts
	::Woditor.InvalidContracts <- [];
	::Woditor.Contracts <- {};
	::Woditor.PrepareContractsOnCampaignStart <- function()
	{
		if (::Woditor.Contracts.len() > 0) return;
		
		local contracts = ::IO.enumerateFiles("scripts/contracts/contracts/");
		foreach ( script in contracts )
		{
			if (::Const.Invalid.Contracts.find(script) != null) continue;

			local contract = ::new(script);
			::Woditor.Contracts[contract.getType()] <- {
				ChangeObjective = "setDestination" in contract || "setLocation" in contract,
				Name = contract.getName(),
				Script = script,
			};
		}
	};

	// filter valid backgrounds for woditor
	::Woditor.Backgrounds <- {
		Stuff = {},
		Key = [],
	};
	::Woditor.PrepareBackgroundsOnCampaignStart <- function()
	{
		if (::Woditor.Backgrounds.Key.len() > 0) return;

		local prefix = "scripts/skills/backgrounds/";
		local background = ::IO.enumerateFiles(prefix);
		foreach ( script in background )
		{
			if (::Const.Invalid.Backgrounds.find(script) != null) continue;

			local background = ::new(script);
			local string = script.slice(prefix.len());
			::Woditor.Backgrounds.Key.push(string);
			::Woditor.Backgrounds.Stuff[string] <- {
				Name = background.getName(),
				Icon = background.getIcon()
			};
		}
	}


	// filter valid buildings for woditor
	::Woditor.Buildings <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	::Woditor.PrepareBuildingsOnCampaignStart <- function()
	{
		if (::Woditor.Buildings.All.len() > 0) return;

		local buildings = ::IO.enumerateFiles("scripts/entity/world/settlements/buildings/");
		foreach ( script in buildings )
		{
			local building = ::new(script);

			if (::Const.Invalid.Buildings.find(script) == null)
			{
				::Woditor.Buildings.Valid.push(script);
			}

			::Woditor.Buildings.All.push(script);
			::Woditor.Buildings.Stuff[script] <- building;

			if (building.m.Tooltip != null && !::Woditor.Buildings.Tooltip.rawin(building.m.Tooltip))
			{
				::Woditor.Buildings.Tooltip[building.m.Tooltip] <- building;
			}
		}
	};


	// filter valid attached locations for woditor
	::Woditor.AttachedLocations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	::Woditor.PrepareAttachedLocationsOnCampaignStart <- function()
	{
		if (::Woditor.AttachedLocations.All.len() > 0) return;

		local attached_locations = ::IO.enumerateFiles("scripts/entity/world/attached_location/");
		foreach ( script in attached_locations )
		{
			local attached_location = ::new(script);

			if (::Const.Invalid.AttachedLocations.find(script) == null)
			{
				::Woditor.AttachedLocations.Valid.push(script);
			}

			::Woditor.AttachedLocations.All.push(script);
			::Woditor.AttachedLocations.Stuff[script] <- attached_location;

			if (!::Woditor.AttachedLocations.Tooltip.rawin(attached_location.getTypeID()))
			{
				::Woditor.AttachedLocations.Tooltip[attached_location.getTypeID()] <- attached_location;
			}
		}
	}


	// valid situations for woditor
	::Woditor.Situations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	::Woditor.PrepareSituationsOnCampaignStart <- function()
	{
		if (::Woditor.Situations.All.len() > 0) return;

		local situations = ::IO.enumerateFiles("scripts/entity/world/settlements/situations/");
		foreach ( script in situations )
		{
			if (::Const.Invalid.Situations.find(script) == null)
			{
				local situation = ::new(script);
				::Woditor.Situations.Valid.push(script);
				::Woditor.Situations.Stuff[script] <- situation;

				if (!::Woditor.Situations.Tooltip.rawin(situation.getID()))
				{
					::Woditor.Situations.Tooltip[situation.getID()] <- situation;
				}
			}

			::Woditor.Situations.All.push(script);
		}
	}


	::Woditor.sortByName <- function(_a, _b)
	{
	 	if (_a < _b) return -1;
		else if (_a > _b) return 1;
		else return 0;
	};
	::Woditor.TroopTypeFilter <- {
		All = 0,
		Human = 1,
		Undead = 2,
		Greenskin = 3,
		Misc = 4,
		COUNT = 5
	};


	// processing the spawnlist so i can add them as entry to the mod ui
	::Woditor.ValidTroops <- [
		[], // all
		[], // human
		[], // undead
		[], // greenskin
		[], // misc
	];
	::Woditor.TroopKeys <- {};
	::Woditor.TroopNames <- {};
	local cultist = [];
	foreach (key, entry in ::Const.World.Spawn.Troops)
	{
		if (::Const.Invalid.Troops.find(key) != null)
		{
			continue;
		}

		if (!(entry.Script in ::Woditor.TroopKeys))
		{
			::Woditor.TroopKeys[entry.Script] <- key;
			
			// attempting to filter out all entries by enemy type group
			local entity = ::new(entry.Script);
			if (entity.getFlags().has("human"))
			{
				if (key.find("Cultist") != null) // separate Taro Cultist to be a subtype of human
				{
					cultist.push(key);
				}
				else
				{
					::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Human].push(key);
				}
			}
			else if (entity.getFlags().has("undead"))
			{
				::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Undead].push(key);
			}
			else if (entity.getFlags().has("goblin") || ::Const.IsOrcs.find(entity.getType()) != null)
			{
				::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Greenskin].push(key);
			}
			else
			{
				::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Misc].push(key);
			}
		}
		else
		{
			continue;
		}

		local prefix = "";
		local postfix = "";
		local isGhoul = key.find("Ghoul") != null;
		local isSandGolem = key.find("SandGolem") != null;
		local isWeak = entry.Script.slice(entry.Script.len() - 4) == "_low";
		local isBodyGuard = key.find("Bodyguard") != null;
		local hasRanged = key.find("Ranged") != null;
		local hasPolearm = key.find("Polearm") != null;
		local isFrenzied = key == "DirewolfHIGH" || key == "HyenaHIGH";
		local isArmored = key == "ArmoredWardog";
		local isFake = entry.Script.find("bandit_raider_wolf") != null;

		switch (true)
		{
		case isGhoul:
		case isSandGolem:
			if (entry.Script.find("_med") != null) postfix += " (M)";
			else if (entry.Script.find("_high") != null) postfix += " (L)";
			else postfix += " (S)";
			break;

		case isWeak:
			postfix += " (W)";
			break;

		case isBodyGuard:
			postfix += " (B)";
			break;

		case hasRanged:
			postfix += " (R)";
			break;

		case hasPolearm:
			postfix += " (P)";
			break;

		case isFrenzied:
			prefix += "Frenzied ";
			break;

		case isArmored:
			prefix += "Armored ";
			break;

		case isFake:
			prefix += "Faked ";
			break;
		}

		::Woditor.TroopNames[entry.Script] <- prefix + ::Const.Strings.EntityName[entry.ID] + postfix;
	}


	// try my best to sorting the entries, still look a bit chaotic though
	cultist.sort(::Woditor.sortByName);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Human].sort(::Woditor.sortByName);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Undead].sort(::Woditor.sortByName);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Greenskin].sort(::Woditor.sortByName);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Misc].sort(::Woditor.sortByName);


	// add all entry to the all list
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Human].extend(cultist);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All].extend(::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Human]);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All].extend(::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Undead]);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All].extend(::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Greenskin]);
	::Woditor.ValidTroops[::Woditor.TroopTypeFilter.All].extend(::Woditor.ValidTroops[::Woditor.TroopTypeFilter.Misc]);


	// function to assist getting ui data from troop entry from world map location/party
	::Woditor.getTroopKey <- function(_entry)
	{
		return ::Woditor.TroopKeys[_entry.Script];
	};
	::Woditor.getTroopName <- function(_entry)
	{
		return ::Woditor.TroopNames[_entry.Script];
	};
	::Woditor.getTroopIcon <- function(_entry)
	{
		return "ui/orientation/" + ::Const.EntityIcon[_entry.ID] + ".png";
	};


	// Assets Properties that woditor allows to configure
	::Woditor.AssetsProperties <- {
		Mult = [
			"BusinessReputationRate",
			"XPMult",
			"HitpointsPerHourMult",
			"RepairSpeedMult",
			"VisionRadiusMult",
			"FootprintVision",
			"RelationDecayGoodMult",
			"RelationDecayBadMult",
			"NegotiationAnnoyanceMult",
			"ContractPaymentMult",
			"HiringCostMult",
			"TryoutPriceMult",
			"DailyWageMult",
			"TrainingPriceMult",
			"TaxidermistPriceMult",
			"BuyPriceMult",
			"SellPriceMult",
			"BuyPriceTradeMult",
			"SellPriceTradeMult",
			"AdvancePaymentCap",
		],
		Additive = [
			"FoodAdditionalDays",
			"BrothersScaleMax",
			"BrothersScaleMin",
			"RosterSizeAdditionalMax",
			"RosterSizeAdditionalMin",
			"ChampionChanceAdditional",
			"ExtraLootChance",
		]
	};

	delete ::Woditor.processWoditorLib;
}
