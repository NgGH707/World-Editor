this.getroottable().Woditor.hookWorldState <- function ()
{
	::mods_hookNewObjectOnce("states/world_state", function( obj ) 
	{
		local init_ui = obj.onInitUI;
		obj.onInitUI = function()
		{
			init_ui();
			this.m.WorldEditorScreen <- this.new("scripts/ui/screens/mods/world_editor_screen");
			this.m.WorldEditorScreen.setOnClosePressedListener(this.town_screen_main_dialog_module_onLeaveButtonClicked.bindenv(this));
			this.initLoadingScreenHandler();
		}

		local destroy_ui = obj.onDestroyUI;
		obj.onDestroyUI = function()
		{
			destroy_ui();
			this.m.Woditor.destroy();
			this.m.Woditor = null;
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
				}, function()
				{
					return !this.m.WorldEditorScreen.isAnimating();
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

		local keyHandler = obj.helper_handleContextualKeyInput;
		obj.helper_handleContextualKeyInput = function(_key)
		{
			if(!keyHandler(_key) && _key.getState() == 0)
			{
				if (_key.getModifier() == 2 && _key.getKey() == 38) //CTRL + Tab
				{
					if (!this.m.CharacterScreen.isVisible() && !this.m.WorldTownScreen.isVisible() && !this.m.EventScreen.isVisible() && !this.m.EventScreen.isAnimating())
					{
						return this.toggleWorldEditorScreen();
					}
				}
			}
		}
	});

	delete this.Woditor.hookWorldState;
}