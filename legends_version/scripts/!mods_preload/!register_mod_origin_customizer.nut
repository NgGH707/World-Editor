local version = 3.0;
this.getroottable().OriginCustomizer <- {};
this.getroottable().OriginCustomizer.Version <- version;
this.getroottable().OriginCustomizer.Name <- "mod_origin_customizer_legends";

// register CSS
::mods_registerCSS("origin_customizer_controls.css");
::mods_registerCSS("origin_customizer_screen.css");
::mods_registerCSS("origin_customizer_factions.css");
::mods_registerCSS("origin_customizer_settlements.css");
::mods_registerCSS("origin_customizer_popup_dialogs.css");

// register JS
::mods_registerJS("origin_customizer_controls.js");
::mods_registerJS("origin_customizer_screen.js");
::mods_registerJS("origin_customizer_factions.js");
::mods_registerJS("origin_customizer_settlements.js");
::mods_registerJS("origin_customizer_popup_dialogs.js");

// register hooks
::mods_registerMod(this.OriginCustomizer.Name, version, "NgGH's Hard Work");
::mods_queue(this.OriginCustomizer.Name, "mod_legends,>mod_nggh_assets", function()
{	
	// run hooks
	this.OriginCustomizer.createLib();
	this.OriginCustomizer.hookWorldState();
	this.OriginCustomizer.hookTooltips();
	this.OriginCustomizer.hookScenarios();
	this.OriginCustomizer.hookContracts();
	this.OriginCustomizer.hookBuildings();
	this.OriginCustomizer.hookAttachedLocation();
});
