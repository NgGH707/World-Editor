if (!("Invalid" in ::Const))
{
	::Const.Invalid <- {};
}

local backgrounds = [
	"scripts/skills/backgrounds/character_background",
	"scripts/skills/backgrounds/charmed_beast_background",
	"scripts/skills/backgrounds/charmed_goblin_background",
	"scripts/skills/backgrounds/charmed_human_background",
	"scripts/skills/backgrounds/charmed_human_engineer_background",
	"scripts/skills/backgrounds/charmed_orc_background",
	"scripts/skills/backgrounds/nggh_banshee_background",
	"scripts/skills/backgrounds/nggh_demon_hound_background",
	"scripts/skills/backgrounds/nggh_ghost_background",
	"scripts/skills/backgrounds/nggh_mummy_background",
	"scripts/skills/backgrounds/nggh_skeleton_background",
	"scripts/skills/backgrounds/nggh_skeleton_lich_background", 
	"scripts/skills/backgrounds/nggh_vampire_background",
	"scripts/skills/backgrounds/spider_eggs_background",
	"scripts/skills/backgrounds/hexen_background",
	"scripts/skills/backgrounds/lesser_hexen_background",
	"scripts/skills/backgrounds/luft_background",
	"scripts/skills/backgrounds/mc_mage_background", 
];
// backgrounds
if (!("Backgrounds" in ::Const.Invalid))
{
	::Const.Invalid.Backgrounds <- backgrounds;
}
else
{
	::Const.Invalid.Backgrounds.extend(backgrounds);
}


local buildings = [
	"scripts/entity/world/settlements/buildings/building",
	"scripts/entity/world/settlements/buildings/crowd_building",
	"scripts/entity/world/settlements/buildings/crowd_oriental_building",
	"scripts/entity/world/settlements/buildings/port_oriental_building",
	"scripts/entity/world/settlements/buildings/stronghold_management_building",
	"scripts/entity/world/settlements/buildings/stronghold_storage_building"
];
// buildings
if (!("Buildings" in ::Const.Invalid))
{
	::Const.Invalid.Buildings <- buildings;
}
else
{
	::Const.Invalid.Buildings.extend(buildings);
}


local attached = [
	"scripts/entity/world/attached_location/harbor_location",
	"scripts/entity/world/attached_location/guarded_checkpoint_location",
];
// attached locations
if (!("AttachedLocations" in ::Const.Invalid))
{
	::Const.Invalid.AttachedLocations <- attached;
}
else
{
	::Const.Invalid.AttachedLocations.extend(attached);
}


local situations = [
	"scripts/entity/world/settlements/situations/situation", 
	"scripts/entity/world/settlements/situations/stronghold_well_supplied_ai_situation",
	"scripts/entity/world/settlements/situations/stronghold_well_supplied_situation",
	"scripts/entity/world/settlements/situations/pokebro_center_clickable_situation",
];
// situations
if (!("Situations" in ::Const.Invalid))
{
	::Const.Invalid.Situations <- situations;
}
else
{
	::Const.Invalid.Situations.extend(situations);
}


local troops = ["BanditOutrider"];
// troops
if (!("Troops" in ::Const.Invalid))
{
	::Const.Invalid.Troops <- troops;
}
else
{
	::Const.Invalid.Troops.extend(troops);
}

local items = [
	"scripts/items/ammo/legend_darts",
	"scripts/items/spawns/cart_large_item",
	"scripts/items/spawns/cart_small_item",
	"scripts/items/spawns/donkey_item",
	"scripts/items/helmets/named/italo_norman_helm_named",
	"scripts/items/helmets/named/bascinet_named",
	"scripts/items/helmets/legend_noble_southern_hat",
	"scripts/items/helmets/legend_noble_southern_crown",
	"scripts/items/helmets/legend_noble_floppy_hat",
	"scripts/items/helmets/legend_noble_hat",
	"scripts/items/helmets/legend_noble_hood",
	"scripts/items/helmets/legend_southern_cloth_headress",
	"scripts/items/helmets/legend_jewelry",
	"scripts/items/helmets/legend_headress_coin",
	"scripts/items/helmets/legend_headband_coin",
	"scripts/items/helmets/legend_earings",
	"scripts/items/helmets/ancient/ancient_laurels",
	"scripts/items/helmets/ancient/ancient_lich_headpiece",
	"scripts/items/helmets/barbarians/barbarian_ritual_helmet",
	"scripts/items/helmets/legend_enclave_vanilla_great_bascinet_01",
	"scripts/items/legend_helmets/helmets/legend_ancient_lich_headpiece",
	"scripts/items/legend_helmets/helmets/legend_ancient_laurels",
	"scripts/items/legend_armor/legend_armor_tabard",
	"scripts/items/legend_armor/legend_armor_cloak",
	"scripts/items/armor/ancient/ancient_lich_attire",
	"scripts/items/armor/ancient/ancient_ripped_cloth",
	"scripts/items/armor/ancient/ancient_priest_attire",
	"scripts/items/armor/barbarians/barbarian_ritual_armor",
	"scripts/items/legend_horse_armor/legend_horse_caparison",
	"scripts/items/legend_horse_helmets/legend_horse_bridle",
	"scripts/items/tools/catapult_item",
	"scripts/items/tools/siege_golem_item",
	"scripts/items/corpses/corpse_item",
	"scripts/items/corpses/player_corpse_item",
	"scripts/items/accessory/accessory_spider",
	"scripts/items/accessory/legendary/luck_stone_item",
	"scripts/items/accessory/legendary/vitality_stone_item",
	"scripts/items/helmets/nggh707_headgear",
	"scripts/items/special/scroll_of_unlimited_wisdom_item",
	"scripts/items/weapons/nggh707_skull_of_the_dead",
	"scripts/items/nggh707_item_container",
	"scripts/items/item_container",
	"scripts/items/stash_container",
	"scripts/items/item",
];
// items
if (!("Items" in ::Const.Invalid))
{
	::Const.Invalid.Items <- items;
}
else
{
	::Const.Invalid.Items.extend(items);
}


local contracts = [
	"scripts/contracts/contracts/arena_contract",
	"scripts/contracts/contracts/arena_tournament_contract",
	"scripts/contracts/contracts/tutorial_contract",
	"scripts/contracts/contracts/raid_caravan_contract",
	"scripts/contracts/contracts/stronghold_defeat_assailant_contract",
	"scripts/contracts/contracts/stronghold_find_waterskin_recipe_contract",
	"scripts/contracts/contracts/stronghold_free_mercenaries_contract",
	"scripts/contracts/contracts/stronghold_free_trainer_contract",
	"scripts/contracts/contracts/stronghold_management_contract",
	"scripts/contracts/contracts/travel_together_contract",
];
// contracts
if (!("Contracts" in ::Const.Invalid))
{
	::Const.Invalid.Contracts <- contracts;
}
else
{
	::Const.Invalid.Contracts.extend(contracts);
}



local location = [
	"scripts/entity/world/locations/battlefield_location",
	"scripts/entity/world/locations/legendary/legend_wizard_tower",
];
// locations
if (!("Locations" in ::Const.Invalid))
{
	::Const.Invalid.Locations <- location;
}
else
{
	::Const.Invalid.Locations.extend(location);
}



