::Woditor.hookWorldState <- function ()
{
	::mods_hookNewObjectOnce("states/world_state", function( obj ) 
	{
		local init_ui = obj.onInitUI;
		obj.onInitUI = function()
		{
			init_ui();
			this.m.WorldEditorScreen <- this.new("scripts/ui/screens/mods/world_editor_screen");
			this.m.WorldEditorScreen.setOnClosePressedListener(this.town_screen_main_dialog_module_onLeaveButtonClicked.bindenv(this));
			this.m.WorldItemsSpawnerScreen <- this.new("scripts/ui/screens/mods/world_item_spawner_screen");
			this.m.WorldItemsSpawnerScreen.setOnClosePressedListener(this.town_screen_main_dialog_module_onLeaveButtonClicked.bindenv(this));
			this.initLoadingScreenHandler();
		}

		local destroy_ui = obj.onDestroyUI;
		obj.onDestroyUI = function()
		{
			destroy_ui();
			this.m.WorldEditorScreen.destroy();
			this.m.WorldEditorScreen = null;
			this.m.WorldItemsSpawnerScreen.destroy();
			this.m.WorldItemsSpawnerScreen = null;
		}

		obj.showWorldEditorScreen <- function()
		{
			if (!this.m.WorldEditorScreen.isVisible() && !this.m.WorldEditorScreen.isAnimating())
			{
				this.m.CustomZoom = this.World.getCamera().Zoom;
				this.World.getCamera().zoomTo(1.0, 4.0);
				this.World.Assets.updateBaseProperties();
				this.World.State.updateTopbarAssets();
				this.setAutoPause(true);
				this.m.WorldEditorScreen.show();
				this.m.WorldScreen.hide();
				this.Cursor.setCursor(this.Const.UI.Cursor.Hand);
				this.m.MenuStack.push(function()
				{
					this.World.getCamera().zoomTo(this.m.CustomZoom, 4.0);
					this.m.WorldEditorScreen.hide();
					this.m.WorldScreen.show();
					this.m.Retinue.update();
					this.World.Assets.updateLook();
					this.World.State.updateTopbarAssets();
					this.World.State.getPlayer().updateStrength();
					this.setAutoPause(false);
					this.m.WorldEditorScreen.updateSomeShit();
				}, function()
				{
					return !this.m.WorldEditorScreen.isAnimating();
				});
			}
		}

		obj.showWorldItemsSpawnerScreen <- function()
		{
			if (!this.m.WorldItemsSpawnerScreen.isVisible() && !this.m.WorldItemsSpawnerScreen.isAnimating())
			{
				this.m.CustomZoom = this.World.getCamera().Zoom;
				this.World.getCamera().zoomTo(1.0, 4.0);
				this.setAutoPause(true);
				this.m.WorldItemsSpawnerScreen.show();
				this.m.WorldScreen.hide();
				this.Cursor.setCursor(this.Const.UI.Cursor.Hand);
				this.m.MenuStack.push(function()
				{
					this.World.getCamera().zoomTo(this.m.CustomZoom, 4.0);
					this.m.WorldItemsSpawnerScreen.hide();
					this.m.WorldScreen.show();
					this.setAutoPause(false);
				}, function()
				{
					return !this.m.WorldItemsSpawnerScreen.isAnimating();
				});
			}
		}

		obj.toggleWorldEditorScreen <- function()
		{
			if (this.m.WorldEditorScreen.isVisible())
			{
				this.m.MenuStack.pop();
				return false;
			}
			else
			{
				this.showWorldEditorScreen();
				return true;
			}
		}

		obj.toggleWorldItemsSpawnerScreen <- function()
		{
			if (this.m.WorldItemsSpawnerScreen.isVisible())
			{
				this.m.MenuStack.pop();
				return false;
			}
			else
			{
				this.showWorldItemsSpawnerScreen();
				return true;
			}
		}

		local keyHandler = obj.helper_handleContextualKeyInput;
		obj.helper_handleContextualKeyInput = function(_key)
		{
			if(!keyHandler(_key) && _key.getState() == 0)
			{
				if (_key.getModifier() == 2) // CTRL
				{
					if (_key.getKey() == 23 && this.m.WorldScreen.isVisible()) // M
					{
						return this.m.WorldScreen.toggleWorldMapEditorModule();
					}

					if (!this.m.CharacterScreen.isVisible() && !this.m.WorldTownScreen.isVisible() && !this.m.EventScreen.isVisible() && !this.m.EventScreen.isAnimating())
					{
						if (_key.getKey() == 38)
						{
							return this.toggleWorldEditorScreen();
						}

						if (_key.getKey() == 24)
						{
							return this.toggleWorldItemsSpawnerScreen();
						}
					}
				}
			}

			return true;
		}

		local ws_onSerialize = obj.onSerialize;
		obj.onSerialize <- function( _out )
		{
			this.m.WorldEditorScreen.onSerialize();
			ws_onSerialize(_out);
		}

		local ws_onDeserialize = obj.onDeserialize;
		obj.onDeserialize = function( _in )
		{
			ws_onDeserialize(_in);
			this.m.WorldEditorScreen.onDeserialize();
		}
	});

	delete ::Woditor.hookWorldState;
}