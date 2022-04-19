::Woditor.hookWorldScreen <- function ()
{
	::Woditor.MapEditor <- ::new("scripts/ui/screens/mods/world_map_editor_module");

	::mods_hookNewObject("ui/screens/world/world_screen", function( obj ) 
	{
		obj.m.WorldMapEditorModule <- ::Woditor.MapEditor;
		obj.m.WorldMapEditorModule.connectUI(obj.m.JSHandle);

		obj.getWorldMapEditorModule <- function()
		{
			return this.m.WorldMapEditorModule;
		};

		obj.toggleWorldMapEditorModule <- function()
		{
			if (!this.m.WorldMapEditorModule.isVisible())
			{
				this.m.WorldMapEditorModule.show();
				return true;
			}

			this.m.WorldMapEditorModule.hide();
			return true;
		};

		local ws_isAnimating = obj.isAnimating;
		obj.isAnimating = function()
		{
			local ret = ws_isAnimating();

			if (!ret && this.m.WorldMapEditorModule != null)
			{
				return this.m.WorldMapEditorModule.isAnimating();
			}
			
			return ret;
		};

		local ws_destroy = obj.destroy;
		obj.destroy = function()
		{
			this.m.WorldMapEditorModule.destroy();
			this.m.WorldMapEditorModule = null;
			ws_destroy();
		};
	});

	delete ::Woditor.hookWorldScreen;
}