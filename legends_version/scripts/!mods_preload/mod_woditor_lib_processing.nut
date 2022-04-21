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

	// filter valid locations for woditor
	::Woditor.Locations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
	};
	::Woditor.PrepareLocationsOnCampaignStart <- function()
	{
		if (::Woditor.Locations.Valid.len() > 0) return;

		local tile = this.World.getTileSquare(1, 1);
		local location = ::IO.enumerateFiles("scripts/entity/world/locations/");

		foreach (i, script in location )
		{
			if (::Const.Invalid.Locations.find(script) != null) continue;

			local location = ::World.spawnLocation(script, tile.Coords);
			local info = {
				Script = script,
				Name = location.getName(),
				Type = location.getTypeID(),
				ImagePath = location.getUIImagePath(),
				Description = location.getDescription(),
				IsPassive = location.isLocationType(::Const.World.LocationType.Passive) && !location.isLocationType(::Const.World.LocationType.Lair),
				IsCamp =  location.isLocationType(::Const.World.LocationType.Lair) && !location.isLocationType(::Const.World.LocationType.Unique),
				IsLegendary = location.isLocationType(::Const.World.LocationType.Unique),
			};

			::Woditor.Locations.Valid.push(script);
			::Woditor.Locations.Stuff[script] <- info;

			if (!(location.getTypeID() in ::Woditor.Locations.Tooltip))
			{
				::Woditor.Locations.Tooltip[location.getTypeID()] <- info;
			}

			location.die();
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
	

	// processing item data, and creating a search function
	::Woditor.ItemFilter <- {
		All       = 0,
		Legendary = 1,
		Named     = 1,
		Ammo      = 2,
		Tool      = 2,
		Usable    = 2,
		Supply    = 3,
		Food      = 3,
		Crafting  = 4,
		Loot      = 4,
		TradeGood = 4,
		Armor     = 5,
		Helmet    = 6,
		Weapon    = 7,
		Shield    = 8,
		Accessory = 9,
	};
	::Woditor.ItemFilterKey <- [
		"All",
		"Legendary",
		"Named",
		"Ammo",
		"Tool",
		"Usable",
		"Supply",
		"Food",
		"Crafting",
		"Loot",
		"TradeGood",
		"Armor",
		"Helmet",
		"Weapon",
		"Shield",
		"Accessory",
	];
	::Woditor.ItemFilterMax <- 10;
	::Woditor.Stash <- ::new("scripts/items/stash_container");
	::Woditor.Stash.setResizable(true);
	::Woditor.Stash.setID("woditor");
	::Woditor.Items <- [];
	::Woditor.PrepareItemsOnCampaignStart <- function()
	{
		if (::Woditor.Items.len() > 0) return;

		for (local i = 0; i < ::Woditor.ItemFilterMax; ++i)
		{
			::Woditor.Items.push([]);
		}

		local prefix = "scripts/items/";
		local items = ::IO.enumerateFiles(prefix);
		local getLayerImage = function( _item )
		{
			if (::mods_isClass(_item, "legend_armor_upgrade") != null)
			{
				switch (_item.m.Type)
				{
				case ::Const.Items.ArmorUpgrades.Chain:
					return "layers/layer_1.png";
			
				case ::Const.Items.ArmorUpgrades.Plate:
					return "layers/layer_2.png";

				case ::Const.Items.ArmorUpgrades.Tabbard:
					return "layers/layer_3.png";

				case ::Const.Items.ArmorUpgrades.Cloak:
					return "layers/layer_4.png";

				case ::Const.Items.ArmorUpgrades.Attachment:
					return "layers/layer_5.png";
				}
			}

			if (::mods_isClass(_item, "legend_helmet_upgrade") != null)
			{
				switch (_item.m.Type)
				{
				case ::Const.Items.HelmetUpgrades.Helm:
					return "layers/layer_1.png";

				case ::Const.Items.HelmetUpgrades.Top:
					return "layers/layer_2.png";

				case ::Const.Items.HelmetUpgrades.Vanity:
					return "layers/layer_3.png";
				}
			}

			return "";
		};
		foreach ( script in items )
		{
			if (::Const.Invalid.Items.find(script) != null) continue;

			local _item = ::new(script);

			if (_item.m.ID.len() == 0) continue;

			if (_item.m.Icon == null || _item.m.Icon == "") continue;

			// fuck it, legends fault for not adding the image of these but still leave the directory
			if (_item.m.Icon == "helmets/icon_southern_veil_07.png" || _item.m.Icon == "helmets/icon_southern_veil_01.png" || _item.m.Icon == "helmets/icon_southern_veil_06.png") continue;

			if (_item.m.Name.len() == 0)
			{
				if (_item.isNamed())
				{
					_item.setName(_item.createRandomName());
				}
				else
				{
					continue;
				}
			}

			::Woditor.Stash.add(_item);
		}
		::Woditor.Stash.sort();
		foreach (_item in ::Woditor.Stash.m.Items)
		{
			local exclude = [];
			local layer = getLayerImage(_item);
			local isNamed = _item.isItemType(::Const.Items.ItemType.Named);
			local data = {
				Index = null,
				ID = _item.m.ID,
				Name = _item.m.Name,
				Description = _item.m.Description,
				ShowAmount = _item.isAmountShown(),
				Amount = _item.getAmountString(),
				AmountColor = _item.getAmountColor(),
				ImagePath = "ui/items/" + _item.m.Icon,
				LayerImagePath = layer,
				ImageOverlayPath = [layer],
				CanChangeName = isNamed || ::mods_isClass(_item, "accessory_dog") != null,
				CanChangeAmount = _item.isItemType(::Const.Items.ItemType.Supply) || _item.isItemType(::Const.Items.ItemType.Food),
				CanChangeStats = isNamed,
				ClassName = _item.ClassNameHash,
				Script = ::IO.scriptFilenameByHash(_item.ClassNameHash),
				Owner = ::Woditor.Stash.getID(),
			};

			if (isNamed)
			{
				local isShield = _item.isItemType(::Const.Items.ItemType.Shield);
				local isMelee = _item.isItemType(::Const.Items.ItemType.MeleeWeapon);
				local isRanged = _item.isItemType(::Const.Items.ItemType.RangedWeapon);

				switch (true)
				{
				case isShield:
					data.Attribute <- {
						MeleeDefense = "-",
						RangedDefense = "-",
						FatigueOnSkillUse = "-",
					};
					break;

				case isMelee:
					data.Attribute <- {
						RegularDamage = "-",
						RegularDamageMax = "-",
						ArmorDamageMult = "-",
						DirectDamageAdd = "-",
						ShieldDamage = "-",
						ChanceToHitHead = "-",
						FatigueOnSkillUse = "-",
					};
					break;

				case isRanged:
					data.Attribute <- {
						RegularDamage = "-",
						RegularDamageMax = "-",
						ArmorDamageMult = "-",
						DirectDamageAdd = "-",
						ChanceToHitHead = "-",
						FatigueOnSkillUse = "-",
						AdditionalAccuracy = "-",
					};
					if (_item.isItemType(this.Const.Items.ItemType.Ammo))
					{
						data.Attribute.AmmoMax <- "-";
					}
					break;
			
				default:
					data.Attribute <- {};
				}

				data.Attribute.ConditionMax <- "-";
				data.Attribute.StaminaModifier <- "-";
			}
			else
			{
				data.Attribute <- null;
			}

			foreach (key in ::Woditor.ItemFilterKey)
			{
				local filter = ::Woditor.ItemFilter[key];

				if (key == "All")
				{
					::Woditor.Items[filter].push(data);
				}
				else if (_item.isItemType(::Const.Items.ItemType[key]) && exclude.find(filter) == null)
				{
					::Woditor.Items[filter].push(data);
					exclude.push(filter);
				}
			}
		}
	};
	::Woditor.sortItemSearch <- function( _i1, _i2 )
	{
		if (_i1.SearchByName && !_i2.SearchByName)
		{
			return -1;
		}
		else if (!_i1.SearchByName && _i2.SearchByName)
		{
			return 1;
		}

		if (_i1.E < _i2.E)
		{
			return -1;
		}
		else if (_i1.E > _i2.E)
		{
			return 1;
		}
		else
		{
			if (_i1.SearchByName)
			{
				if (_i1.Name < _i2.Name)
				{
					return -1;
				}
				else if (_i1.Name > _i2.Name)
				{
					return 1;
				}
			}
			else
			{
				if (_i1.ID < _i2.ID)
				{
					return -1;
				}
				else if (_i1.ID > _i2.ID)
				{
					return 1;
				}
			}

			return 0;
		}
	};
	::Woditor.SearchItems <- function( _text, _filter = 0 )
	{
		_text = _text.tolower();
		local result = [];

		foreach (item in ::Woditor.Items[_filter])
		{
			local string = item.Name.tolower();
			local find = string.find(_text);

			if (find != null)
			{
				local entry = clone item;
				entry.E <- find;
				entry.SearchByName <- true;
				result.push(entry);
				continue;
			}

			string = item.ID.tolower();
			find = string.find(_text);

			if (find != null)
			{
				local entry = clone item;
				entry.E <- find;
				entry.SearchByName <- false;
				result.push(entry);
			}
		}

		result.sort(::Woditor.sortItemSearch);
		return result;
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

			if (building.m.Tooltip != null && !(building.m.Tooltip in ::Woditor.Buildings.Tooltip))
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

			if (!(attached_location.getTypeID() in ::Woditor.AttachedLocations.Tooltip))
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

				if (!(situation.getID() in ::Woditor.Situations.Tooltip))
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
			"MovementSpeedMult",
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
			"MovementSpeedMult",
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
			"EquipmentLootChance"
		]
	};

	delete ::Woditor.processWoditorLib;
}