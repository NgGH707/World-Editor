this.world_map_editor_module <- this.inherit("scripts/ui/screens/ui_module", {
	m = {},
	function create()
	{
		this.m.ID = "WorldMapEditorModule";
		this.ui_module.create();
	}

	function destroy()
	{
		this.ui_module.destroy();
	}

	function show( _withSlideAnimation = true )
	{
		if (!this.isVisible() && !this.isAnimating())
		{
			this.m.JSHandle.asyncCall("show", this.queryLoad());
		}
	}

	function hide( _withSlideAnimation = true )
	{
		if (this.isVisible() && !this.isAnimating())
		{
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation);
		}
	}

	function queryLoad()
	{
		return null;
	}

});

