::Woditor.createLib <- function ()
{
	// fix the broken icon of Sato manhunters (please fix it Sato, don't make me include it in this)
	::Const.EntityIcon[::Const.EntityType.SatoManhunter] = "nomad_02_orientation";
	::Const.EntityIcon[::Const.EntityType.SatoManhunterVeteran] = "nomad_05_orientation";

	// list of attached location really need to be spawned near road
	::Const.NearRoadAttachedLocations <- [
		"scripts/entity/world/attached_location/stone_watchtower_oriental_location",
		"scripts/entity/world/attached_location/wooden_watchtower_location",
		"scripts/entity/world/attached_location/militia_trainingcamp_oriental_location",
		"scripts/entity/world/attached_location/militia_trainingcamp_location",
		"scripts/entity/world/attached_location/stone_watchtower_location",
		"scripts/entity/world/attached_location/fortified_outpost_location",
		"scripts/entity/world/attached_location/wool_spinner_location",
	];

	::Const.RandomTreasure <- [
		"trade/incense_item",
		"trade/dies_item",
		"trade/silk_item",
		"trade/spices_item",
		"trade/furs_item",
		"trade/copper_ingots_item",
		"trade/cloth_rolls_item",
		"trade/salt_item",
		"trade/amber_shards_item",
		"trade/iron_ingots_item",
		"trade/tin_ingots_item",
		"trade/gold_ingots_item",
		"trade/uncut_gems_item",
		"loot/white_pearls_item"
		"loot/silverware_item",
		"loot/silver_bowl_item",
		"loot/signet_ring_item"
		"loot/bone_figurines_item",
		"loot/valuable_furs_item",
		"loot/bead_necklace_item",
		"loot/looted_valuables_item",
		"loot/ancient_gold_coins_item",
		"loot/golden_chalice_item",
		"loot/gemstones_item",
		"loot/jeweled_crown_item",
		"loot/ornate_tome_item",
		"loot/goblin_carved_ivory_iconographs_item",
		"loot/goblin_minted_coins_item",
		"loot/goblin_rank_insignia_item",
	];

	// something to add to the tooltips
	::Const.PercentageNoteString <- " The value is calculated in percentage. The default value is 100 which means 100%."
	::Const.AddContractHints <- function( _tooltips )
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
	::Const.AddAttachedLocationHints <- function( _tooltips )
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
	::Const.AddBuildingHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button.png",
				text = "Change building"
			},
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard building"
			}
		]);
	};
	::Const.AddSituationHints <- function( _tooltips )
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
	::Const.NobleBanners <- [];
	::Const.OtherBanner <- [];
	for (local i = 0; i < 15; ++i)
	{
		if (i < 11)
		{
			::Const.NobleBanners.push("ui/banners/factions/banner_" + (i < 10 ? "0" + i : i) + ".png");
		}

		::Const.OtherBanner.push("ui/banners/factions/banner_" + (i < 10 ? "0" + i : i) + ".png");
	}


	// lib for avatar changer
	::Const.WorldSockets <- [
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
	::Const.WorldSpritesNames <- [
		"Player",
		"Civilian",
		"Noble",
		"Raider",
		"Southern",
		"Undead",
		"Greenskin",
		"Misc"
	];
	::Const.WorldSprites <- [];
	::Const.WorldSprites.push([
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
		::Const.WorldSprites[0].extend([
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
	::Const.WorldSprites.push([
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
	::Const.WorldSprites.push([
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
	::Const.WorldSprites.push([
		"figure_bandit_01",
		"figure_bandit_02",
		"figure_bandit_03",
		"figure_bandit_04",
		"figure_wildman_01",
		"figure_wildman_02",
		"figure_wildman_03",
		"figure_wildman_04",
	]);
	::Const.WorldSprites.push([
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
	::Const.WorldSprites.push([
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
	::Const.WorldSprites.push([
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
	::Const.WorldSprites.push([
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
	::Const.IsOrcs <- [
		this.Const.EntityType.OrcYoung,
		this.Const.EntityType.OrcBerserker,
		this.Const.EntityType.OrcWarrior,
		this.Const.EntityType.OrcWarlord,
		this.Const.EntityType.LegendOrcElite,
		this.Const.EntityType.LegendOrcBehemoth,
	];

	delete ::Woditor.createLib;
}