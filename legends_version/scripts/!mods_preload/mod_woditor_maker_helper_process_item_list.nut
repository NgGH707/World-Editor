::Woditor.processItemList <- function ()
{
	::ModItemSpawner <- {};

	// prevent the mod from letting player without Fangshire DLC to spawn one
	if (!::Const.DLC.Fangshire)
	{
		::Const.Invalid.Items.push("scripts/items/helmets/legendary/fangshire");
	}

	// processing item data, and creating a search function
	::ModItemSpawner.ItemFilter <- {
		All          =  0, //
		Legendary    =  1, //
		Misc         =  1,
		Named        =  2, //
		Usable       =  3, //
		Crafting     =  4, //
		Loot         =  4,
		TradeGood    =  4,
		Supply       =  5, //
		Food         =  5,
		Armor        =  6, //
		Helmet       =  7, //
		MeleeWeapon  =  8, //
		RangedWeapon =  9, //
		Ammo         =  9,
		Shield       = 10, //
		Accessory    = 11, //
		Tool         = 11,
	};
	::ModItemSpawner.ItemFilterKey <- [
		"All",
		"Legendary",
		"Misc",
		"Named",
		"Usable",
		"Crafting",
		"Loot",
		"TradeGood",
		"Supply",
		"Food",
		"Armor",
		"Helmet",
		"MeleeWeapon",
		"RangedWeapon",
		"Ammo",
		"Shield",
		"Accessory",
		"Tool",
	];
	::ModItemSpawner.ItemFilterMax <- 12;
	::ModItemSpawner.Stash <- ::new("scripts/items/stash_container");
	::ModItemSpawner.Stash.setResizable(true);
	::ModItemSpawner.Stash.setID("ModItemSpawner");
	::ModItemSpawner.Items <- [];
	::ModItemSpawner.ItemsImage <- [];
	::ModItemSpawner.ItemsScript <- [];
	::ModItemSpawner.ItemsScriptShorten <- [];

	local items_directory = "gfx/ui/items/";
	foreach (i, directory in ::IO.enumerateFiles(items_directory) )
	{
		::ModItemSpawner.ItemsImage.push(directory.slice(items_directory.len()) + ".png");
	}

	::ModItemSpawner.PrepareItemsListOnCampaignStart <- function( _reset = false )
	{
		if (!_reset && ::ModItemSpawner.Items.len() > 0) return;

		if (!_reset)
		{
			::logInfo("Mod Item Spawner - Starting to process item list...");
		}
		else
		{
			::logInfo("Mod Item Spawner - Recompiling item list...");
		}

		for (local i = 0; i < ::ModItemSpawner.ItemFilterMax; ++i)
		{
			::ModItemSpawner.Items.push([]);
		}

		local prefix = "scripts/items/";
		local isLegendExist = ::mods_getRegisteredMod("mod_legends") != null;
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
			::ModItemSpawner.ItemsScript.push(script);
			::ModItemSpawner.ItemsScriptShorten.push(script.slice(prefix.len()));

			if (::Const.Invalid.Items.find(script) != null) continue;

			local _item = ::new(script);

			if (_item.getID().len() == 0) continue; // items with a blank ID are usually an extended class of item (such as accessory.nut, weapon.nut, etc)

			if (_item.getIcon() == null || _item.getIcon() == "") continue; // items without an inventory icon are usually for non-player only (such as golbin armors, orc armors)

			//if (isLegendExist && (script.find("/items/armor/") != null || script.find("/items/helmets/") != null || script.find("/items/armor_upgrades/") != null)) continue; // to remove non-layer armor if legends mod exists

			if (::ModItemSpawner.ItemsImage.find(_item.getIcon()) == null) continue; // check whether the inventory icon of the item indeed exists or not

			if (_item.m.Name.len() == 0) // item without a name by default can be a named item or something only for non-player
			{
				if (_item.isItemType(::Const.Items.ItemType.Named)) 
				{
					_item.setName(_item.createRandomName()); // if the item is a named item, generate it a name
				}
				else
				{
					continue;
				}
			}

			::ModItemSpawner.Stash.add(_item);
		}
		::ModItemSpawner.Stash.sort(); // easy way to sort all items
		foreach (_item in ::ModItemSpawner.Stash.m.Items)
		{
			// start convert all valid items into data
			local exclude = [];
			local layer = isLegendExist ? getLayerImage(_item) : "";
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
				CanChangeName = ::ModItemSpawner.canChangeName(_item),
				CanChangeAmount = _item.isItemType(::Const.Items.ItemType.Supply) || _item.isItemType(::Const.Items.ItemType.Food),
				CanChangeStats = isNamed,
				ClassName = _item.ClassNameHash,
				Script = ::IO.scriptFilenameByHash(_item.ClassNameHash),
				Owner = ::ModItemSpawner.Stash.getID(),
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
					if (_item.isItemType(::Const.Items.ItemType.Ammo))
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

			foreach (key in ::ModItemSpawner.ItemFilterKey) // distribute data to suitable filter slots
			{
				local filter = ::ModItemSpawner.ItemFilter[key];

				if (key == "All")
				{
					::ModItemSpawner.Items[filter].push(data);
				}
				else if (key == "Misc")
				{
					if (_item.m.ItemType != ::Const.Items.ItemType.Misc)
					{
						continue;
					}

					::ModItemSpawner.Items[filter].push(data);
				}
				else if (_item.isItemType(::Const.Items.ItemType[key]) && exclude.find(filter) == null)
				{
					::ModItemSpawner.Items[filter].push(data);
					exclude.push(filter);
				}
			}
		}

		::logInfo("Mod Item Spawner - Finish processing item list...");
	};
	::ModItemSpawner.canChangeName <- function( _item )
	{
		if (_item.isItemType(::Const.Items.ItemType.Named))
		{
			return true;
		}

		if (::mods_isClass(_item, "wardog_item") != null)
		{
			return true;
		}

		if (::mods_isClass(_item, "warhound_item") != null)
		{
			return true;
		}

		if (::mods_isClass(_item, "wolf_item") != null)
		{
			return true;
		}

		return ::mods_isClass(_item, "accessory_dog") != null;
	};
	::ModItemSpawner.sortItemSearch <- function( _i1, _i2 )
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
	::ModItemSpawner.SearchItems <- function( _text, _filter = 0 )
	{
		_text = _text.tolower();
		local result = [];

		foreach (item in ::ModItemSpawner.Items[_filter])
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

		result.sort(::ModItemSpawner.sortItemSearch);
		return result;
	};

	delete ::Woditor.processItemList;
}
