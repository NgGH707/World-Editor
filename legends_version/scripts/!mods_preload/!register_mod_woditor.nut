::Woditor <- {
	ID = "mod_world_editor_legends",
	Version = "3.0.2",
	Name = "NgGH's Hard Work"
};

// register CSS
::mods_registerCSS("world_editor_screen.css");
::mods_registerCSS("world_map_editor_module.css");
::mods_registerCSS("control/world_editor_controls.css");
::mods_registerCSS("child/world_editor_factions.css");
::mods_registerCSS("child/world_editor_contracts.css");
::mods_registerCSS("child/world_editor_settlements.css");
::mods_registerCSS("child/world_editor_locations.css");
::mods_registerCSS("child/world_editor_popup_dialogs.css");

// register JS
::mods_registerJS("world_editor_screen.js");
::mods_registerJS("world_map_editor_module.js");
::mods_registerJS("control/world_editor_controls.js");
::mods_registerJS("child/world_editor_factions.js");
::mods_registerJS("child/world_editor_contracts.js");
::mods_registerJS("child/world_editor_settlements.js");
::mods_registerJS("child/world_editor_locations.js");
::mods_registerJS("child/world_editor_units.js");
::mods_registerJS("child/world_editor_popup_dialogs.js");

// register hooks
::mods_registerMod(::Woditor.ID, ::Woditor.Version, "NgGH's Hard Work");
::mods_queue(::Woditor.ID, "mod_legends,>mod_legends_PTR", function()
{	
	::Woditor.Mod <- ::MSU.Class.Mod(::Woditor.ID, ::Woditor.Version, "Woditor");
	::Woditor.addKeybinds();
	::Woditor.hookWorldScreen();
	::Woditor.hookWorldState();
	::Woditor.hookAssetsManager();
	::Woditor.hookFollowers();
	::Woditor.hookTooltips();
	::Woditor.hookScenarios();
	::Woditor.hookFaction();
	::Woditor.hookContracts();
	::Woditor.hookBuildings();
	::Woditor.hookParty();
	::Woditor.hookLocation();
	::Woditor.hookSettlement();
	::Woditor.hookAttachedLocation();
	::Woditor.createLib();
	::Woditor.processWoditorLib();

	if (::mods_getRegisteredMod("mod_item_spawner") == null)
	{
		::Woditor.processItemList();
	}
});
