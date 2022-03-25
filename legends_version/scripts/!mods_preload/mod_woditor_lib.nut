this.getroottable().Woditor.createLib <- function ()
{
	local gt = this.getroottable();

	// fix the broken icon
	gt.Const.EntityIcon[this.Const.EntityType.SatoManhunter] = "nomad_02_orientation";
	gt.Const.EntityIcon[this.Const.EntityType.SatoManhunterVeteran] = "nomad_05_orientation";


	// something to add to the tooltips
	gt.Const.PercentageNoteString <- " The value is calculated in percentage. The default value is 100 which means 100%."
	gt.Const.AddContractHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 10,
				type = "hint",
				icon = "ui/icons/mouse_left_button.png",
				text = "Open in \'Contracts\' tab"
			},
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard contract"
			}
		]);
	};
	gt.Const.AddAttachedLocationHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard attachment"
			}
		]);
	};
	gt.Const.AddBuildingHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard building"
			}
		]);
	};
	gt.Const.AddSituationHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard situation"
			}
		]);
	};


	// faction banner lib
	gt.Const.NobleBanners <- [];
	gt.Const.OtherBanner <- [];
	for (local i = 0; i < 11; ++i)
	{
		gt.Const.NobleBanners.push("banner_noble_" + (i < 10 ? "0" + i : i));
	}
	for (local i = 0; i < 15; ++i)
	{
		gt.Const.OtherBanner.push("banner_noble_" + (i < 10 ? "0" + i : i));
	}


	// lib for avatar changer
	gt.Const.WorldSockets <- [
		"world_base_01",
		"world_base_02",
		"world_base_03",
		"world_base_05",
		"world_base_07",
		"world_base_08",
		"world_base_09",
		"world_base_10",
		"world_base_11",
		"world_base_12",
		"world_base_13",
		"world_base_14",
	];
	gt.Const.WorldSpritesNames <- [
		"Player",
		"Civilian",
		"Noble",
		"Raider",
		"Southern",
		"Undead",
		"Greenskin",
		"Misc"
	];
	gt.Const.WorldSprites <- [];
	gt.Const.WorldSprites.push([
		"figure_player_01",
		"figure_player_02",
		"figure_player_03",
		"figure_player_04",
		"figure_player_05",
		"figure_player_06",
		"figure_player_07",
		"figure_player_08",
		"figure_player_09",
		"figure_player_10",
		"figure_player_11",
		"figure_player_12",
		"figure_player_13",
		"figure_player_14",
		"figure_player_15",
		"figure_player_16",
		"figure_player_17",
		"figure_player_18",
		"figure_player_crusader",
		"figure_player_ranger",
		"figure_player_beggar",
		"figure_player_legion",
		"figure_player_noble",
		"figure_player_seer",
		"figure_player_warlock",
		"figure_player_trader",
		"figure_player_party",
		"figure_player_vala",
		"figure_player_assassin",
		"figure_player_inquisition",
		"figure_player_druid",
		"figure_player_troupe",
		"figure_player_slave",
	]);
	if (::mods_getRegisteredMod("mod_nggh_magic_concept") != null)
	{
		gt.Const.WorldSprites[0].extend([
			"figure_player_9991",
			"figure_player_9992",
			"figure_player_9993",
			"figure_player_9994",
			"figure_player_9995",
			"figure_player_9996",
			"figure_player_9997",
			"figure_player_9998",
			"figure_player_9999",
		]);
	}
	gt.Const.WorldSprites.push([
		"figure_civilian_01",
		"figure_civilian_02",
		"figure_civilian_03",
		"figure_civilian_04",
		"figure_civilian_05",
		"figure_civilian_06",
		"figure_mercenary_01",
		"figure_mercenary_02",
		"figure_militia_01",
		"figure_militia_02",
	]);
	gt.Const.WorldSprites.push([
		"figure_noble_01",
		"figure_noble_02",
		"figure_noble_03",
		"figure_noble_01_01",
		"figure_noble_01_02",
		"figure_noble_01_03",
		"figure_noble_01_04",
		"figure_noble_01_05",
		"figure_noble_01_06",
		"figure_noble_01_07",
		"figure_noble_01_08",
		"figure_noble_01_09",
		"figure_noble_01_10",
		"figure_noble_02_01",
		"figure_noble_02_02",
		"figure_noble_02_03",
		"figure_noble_02_04",
		"figure_noble_02_05",
		"figure_noble_02_06",
		"figure_noble_02_07",
		"figure_noble_02_08",
		"figure_noble_02_09",
		"figure_noble_02_10",
		"figure_noble_03_01",
		"figure_noble_03_02",
		"figure_noble_03_03",
		"figure_noble_03_04",
		"figure_noble_03_05",
		"figure_noble_03_06",
		"figure_noble_03_07",
		"figure_noble_03_08",
		"figure_noble_03_09",
		"figure_noble_03_10",
	]);
	gt.Const.WorldSprites.push([
		"figure_bandit_01",
		"figure_bandit_02",
		"figure_bandit_03",
		"figure_bandit_04",
		"figure_wildman_01",
		"figure_wildman_02",
		"figure_wildman_03",
		"figure_wildman_04",
	]);
	gt.Const.WorldSprites.push([
		"figure_refugee_01",
		"figure_refugee_02",
		"figure_slave_01",
		"figure_southern_01",
		"figure_southern_01_12",
		"figure_southern_01_13",
		"figure_southern_01_14",
		"figure_southern_02",
		"figure_nomad_01",
		"figure_nomad_02",
		"figure_nomad_03",
		"figure_nomad_04",
		"figure_nomad_05",
	]);
	gt.Const.WorldSprites.push([
		"figure_necromancer_01",
		"figure_necromancer_02",
		"figure_ghost_01",
		"figure_zombie_01",
		"figure_zombie_02",
		"figure_zombie_03",
		"figure_zombie_04",
		"figure_vampire_01",
		"figure_vampire_02",
		"figure_skeleton_01",
		"figure_skeleton_02",
		"figure_skeleton_03",
		"figure_skeleton_04",
		"figure_mummy_01",
	]);
	gt.Const.WorldSprites.push([
		"figure_goblin_01",
		"figure_goblin_02",
		"figure_goblin_03",
		"figure_goblin_04",
		"figure_goblin_05",
		"figure_orc_01",
		"figure_orc_02",
		"figure_orc_03",
		"figure_orc_04",
		"figure_orc_05",
		"figure_orc_06",
	]);
	gt.Const.WorldSprites.push([
		"figure_hexe_01",
		"figure_hexe_leader_01",
		"figure_alp_01",
		"figure_demonalp_01",
		"figure_ghoul_01",
		"figure_ghoul_02",
		"figure_skin_ghoul_01",
		"figure_skin_ghoul_02",
		"figure_golem_01",
		"figure_golem_02",
		"figure_hyena_01",
		"figure_kraken_01",
		"figure_lindwurm_01",
		"figure_stollwurm_01",
		"figure_schrat_01",
		"figure_greenwood_schrat_01",
		"figure_serpent_01",
		"figure_spider_01",
		"figure_redback_spider_01",
		"figure_unhold_01",
		"figure_unhold_02",
		"figure_unhold_03",
		"figure_rock_unhold_01",
		"figure_werewolf_01",
		"figure_white_direwolf_01",
	]);

	// the orc group type
	gt.Const.IsOrcs <- [
		this.Const.EntityType.OrcYoung,
		this.Const.EntityType.OrcBerserker,
		this.Const.EntityType.OrcWarrior,
		this.Const.EntityType.OrcWarlord,
		this.Const.EntityType.LegendOrcElite,
		this.Const.EntityType.LegendOrcBehemoth,
	];
	gt.Woditor.sortByName <- function(_a, _b)
	{
	 	if (_a < _b) return -1;
		else if (_a > _b) return 1;
		else return 0;
	};
	gt.Woditor.TroopTypeFilter <- {
		All = 0,
		Human = 1,
		Undead = 2,
		Greenskin = 3,
		Misc = 4,
		COUNT = 5
	}

	// processing the spawnlist so i can add them as entry to the mod ui
	gt.Woditor.ValidTroops <- [
		[], // all
		[], // human
		[], // undead
		[], // greenskin
		[], // misc
	];
	gt.Woditor.TroopKeys <- {};
	gt.Woditor.TroopNames <- {};

	foreach (key, entry in this.Const.World.Spawn.Troops)
	{
		if (key == "BanditOutrider")
		{
			continue;
		}

		if (!(entry.Script in gt.Woditor.TroopKeys))
		{
			gt.Woditor.TroopKeys[entry.Script] <- key;
			
			// attempting to filter out all entries by enemy type group
			local entity = this.new(entry.Script);
			if (entity.getFlags().has("human"))
			{
				gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Human].push(key);
			}
			else if (entity.getFlags().has("undead"))
			{
				gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Undead].push(key);
			}
			else if (entity.getFlags().has("goblin") || this.Const.IsOrcs.find(entity.getType()) != null)
			{
				gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Greenskin].push(key);
			}
			else
			{
				gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Misc].push(key);
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

		gt.Woditor.TroopNames[entry.Script] <- prefix + gt.Const.Strings.EntityName[entry.ID] + postfix;
	}

	// try my best to sorting the entries, still look a bit chaotic though
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Human].sort(this.Woditor.sortByName);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Undead].sort(this.Woditor.sortByName);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Greenskin].sort(this.Woditor.sortByName);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Misc].sort(this.Woditor.sortByName);

	// add all entry to the all list
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.All].extend(this.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Human]);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.All].extend(this.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Undead]);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.All].extend(this.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Greenskin]);
	gt.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.All].extend(this.Woditor.ValidTroops[this.Woditor.TroopTypeFilter.Misc]);

	// function to assist getting ui data from troop entry from world map location/party
	gt.Woditor.getTroopKey <- function(_entry)
	{
		return this.Woditor.TroopKeys[_entry.Script];
	};
	gt.Woditor.getTroopName <- function(_entry)
	{
		return this.Woditor.TroopNames[_entry.Script];
	};
	gt.Woditor.getTroopIcon <- function(_entry)
	{
		return "ui/orientation/" + this.Const.EntityIcon[_entry.ID] + ".png";
	};

	// UI Processing Helper for Woditor
	gt.Woditor.Helper <- this.new("scripts/mods/world_editor_data_helper");

	// Assets Properties
	gt.Woditor.AssetsProperties <- {
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

	delete this.Woditor.createLib;
}