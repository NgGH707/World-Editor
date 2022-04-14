::Woditor.processWoditorLib <- function ()
{
	// UI Processing Helper for Woditor
	::Woditor.Helper <- this.new("scripts/mods/world_editor_data_helper");

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
	::Woditor.Stash <- this.new("scripts/items/stash_container");
	::Woditor.Stash.setResizable(true);
	::Woditor.Items <- [];
	for (local i = 0; i < ::Woditor.ItemFilterMax; ++i)
	{
		::Woditor.Items.push([]);
	}
	local prefix = "scripts/items/";
	local items = this.IO.enumerateFiles(prefix);
	local getLayerImage = function( _item )
	{
		if (::mods_isClass(_item, "legend_armor_upgrade") != null)
		{
			switch (_item.m.Type)
			{
			case this.Const.Items.ArmorUpgrades.Chain:
				return "layers/layer_1.png";
		
			case this.Const.Items.ArmorUpgrades.Plate:
				return "layers/layer_2.png";

			case this.Const.Items.ArmorUpgrades.Tabbard:
				return "layers/layer_3.png";

			case this.Const.Items.ArmorUpgrades.Cloak:
				return "layers/layer_4.png";

			case this.Const.Items.ArmorUpgrades.Attachment:
				return "layers/layer_5.png";
			}
		}

		if (::mods_isClass(_item, "legend_helmet_upgrade") != null)
		{
			switch (_item.m.Type)
			{
			case this.Const.Items.HelmetUpgrades.Helm:
				return "layers/layer_1.png";

			case this.Const.Items.HelmetUpgrades.Top:
				return "layers/layer_2.png";

			case this.Const.Items.HelmetUpgrades.Vanity:
				return "layers/layer_3.png";
			}
		}

		return "";
	};
	foreach ( script in items )
	{
		if (::Const.Invalid.Items.find(script) != null) continue;

		local _item = this.new(script);

		if (_item.m.ID.len() == 0) continue;

		if (_item.m.Icon == null || _item.m.Icon == "") continue;

		// fuck it, legends fault for not adding the image of these but still leave the directory
		if (_item.m.Icon == "helmets/icon_southern_veil_07.png" || _item.m.Icon == "helmets/icon_southern_veil_01.png") continue;

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
		local data = {
			ID = _item.m.ID,
			Name = _item.m.Name,
			Description = _item.m.Description,
			ImagePath = "ui/items/" + _item.m.Icon,
			LayerImagePath = getLayerImage(_item),
			Script = this.IO.scriptFilenameByHash(_item.ClassNameHash),
		};

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


	// get all location sprites
	::Woditor.ValidLocationSprites <- [];
	local locations_directory = "gfx/ui/locations/";
	foreach (i, directory in this.IO.enumerateFiles("gfx/ui/locations/") )
	{
		::Woditor.ValidLocationSprites.push(directory.slice(locations_directory.len()));
	}


	// filter valid backgrounds for woditor
	::Woditor.Backgrounds <- {
		Stuff = {},
		Key = [],
	};
	local prefix = "scripts/skills/backgrounds/";
	local background = this.IO.enumerateFiles(prefix);
	foreach ( script in background )
	{
		if (::Const.Invalid.Backgrounds.find(script) != null) continue;

		local background = this.new(script);
		local string = script.slice(prefix.len());
		::Woditor.Backgrounds.Key.push(string);
		::Woditor.Backgrounds.Stuff[string] <- {
			Name = background.getName(),
			Icon = background.getIcon()
		};
	}


	// filter valid buildings for woditor
	::Woditor.Buildings <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	local buildings = this.IO.enumerateFiles("scripts/entity/world/settlements/buildings/");
	foreach ( script in buildings )
	{
		local building = this.new(script);

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


	// filter valid attached locations for woditor
	::Woditor.AttachedLocations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	local attached_locations = this.IO.enumerateFiles("scripts/entity/world/attached_location/");
	foreach ( script in attached_locations )
	{
		local attached_location = this.new(script);

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


	// valid situations for woditor
	::Woditor.Situations <- {
		Tooltip = {},
		Stuff = {},
		Valid = [],
		All = [],
	};
	local situations = this.IO.enumerateFiles("scripts/entity/world/settlements/situations/");
	foreach ( script in situations )
	{
		if (::Const.Invalid.Situations.find(script) == null)
		{
			local situation = this.new(script);
			::Woditor.Situations.Valid.push(script);
			::Woditor.Situations.Stuff[script] <- situation;

			if (!(situation.getID() in ::Woditor.Situations.Tooltip))
			{
				::Woditor.Situations.Tooltip[situation.getID()] <- situation;
			}
		}

		::Woditor.Situations.All.push(script);
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
	foreach (key, entry in this.Const.World.Spawn.Troops)
	{
		if (::Const.Invalid.Troops.find(key) != null)
		{
			continue;
		}

		if (!(entry.Script in ::Woditor.TroopKeys))
		{
			::Woditor.TroopKeys[entry.Script] <- key;
			
			// attempting to filter out all entries by enemy type group
			local entity = this.new(entry.Script);
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
			else if (entity.getFlags().has("goblin") || this.Const.IsOrcs.find(entity.getType()) != null)
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
		return "ui/orientation/" + this.Const.EntityIcon[_entry.ID] + ".png";
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