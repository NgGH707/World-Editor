::Woditor.addKeybinds <- function ()
{
	::Woditor.Mod.Keybinds.addSQKeybind("OpenWoditorScreen", "ctrl+tab", ::MSU.Key.State.World,
	function(){
		return this.toggleWorldEditorScreen();
	}, "Open Woditor screen");

	::Woditor.Mod.Keybinds.addSQKeybind("OpenMapEditorScreen", "ctrl+m", ::MSU.Key.State.World,
	function(){
		return this.m.WorldScreen.toggleWorldMapEditorModule();
	}, "Open Map Editor");

	::Woditor.Mod.Keybinds.addSQKeybind("SelectEntity", "n", ::MSU.Key.State.World,
	function(){
		if (!this.m.WorldScreen.getWorldMapEditorModule().isVisible())
			return;
		if (this.m.LastEntityHovered != null)
		{
        	this.m.WorldScreen.getWorldMapEditorModule().select(this.m.LastEntityHovered);
        	return true;
        }
	}, "Select entity");

	::Woditor.Mod.Keybinds.addSQKeybind("MoveEntity", "m", ::MSU.Key.State.World,
	function(){
		if (!this.m.WorldScreen.getWorldMapEditorModule().isVisible())
			return;
		if (this.m.LastTileHovered != null && this.m.WorldScreen.getWorldMapEditorModule().isSelectedEntity())
		{
			this.m.WorldScreen.getWorldMapEditorModule().move(this.m.LastTileHovered);
			return true;
		}
	}, "Move selected entity");


	::Woditor.Mod.Keybinds.addSQKeybind("KillEntity", "k", ::MSU.Key.State.World,
	function(){
		if (!this.m.WorldScreen.getWorldMapEditorModule().isVisible())
			return;
		if (this.m.WorldScreen.getWorldMapEditorModule().isSelectedEntity())
		{
			this.m.WorldScreen.getWorldMapEditorModule().discard();
			return true;
		}
	}, "Kill entity");

	::Woditor.Mod.Keybinds.addSQKeybind("JumpToTile", "j", ::MSU.Key.State.World,
	function(){
		if (!this.m.WorldScreen.getWorldMapEditorModule().isVisible())
			return;
		if (this.m.LastTileHovered != null)
		{
			local tilePos = this.m.LastTileHovered.Pos;
    		::World.State.getPlayer().setPos(tilePos);
    		::World.setPlayerPos(tilePos);
    		return true;
		}
	}, "Jump to tile");

	::Woditor.Mod.Keybinds.addSQKeybind("SpawnEntity", "h", ::MSU.Key.State.World,
	function(){
		if (!this.m.WorldScreen.getWorldMapEditorModule().isVisible())
			return;
		if (this.m.LastTileHovered != null && this.m.WorldScreen.getWorldMapEditorModule().isSpawningMode())
		{
			this.m.WorldScreen.getWorldMapEditorModule().spawn(this.m.LastTileHovered);
			return true;
		}
	}, "Spawn entity");

	delete ::Woditor.addKeybinds;
}
