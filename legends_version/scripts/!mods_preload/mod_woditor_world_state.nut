this.getroottable().Woditor.hookWorldState <- function ()
{
	::mods_hookNewObjectOnce("states/world_state", function( obj ) 
	{
		local init_ui = ::mods_getMember(obj, "onInitUI");
		obj.onInitUI = function()
		{
			init_ui();
			this.m.WorldEditorScreen <- this.new("scripts/ui/screens/mods/world_editor_screen");
			this.m.WorldEditorScreen.setOnClosePressedListener(this.town_screen_main_dialog_module_onLeaveButtonClicked.bindenv(this));
			this.initLoadingScreenHandler();
		}

		local destroy_ui = ::mods_getMember(obj, "onDestroyUI");
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
				this.World.Assets.updateFormation();
				this.setAutoPause(true);
				this.m.WorldEditorScreen.show();
				this.m.WorldScreen.hide();
				this.Cursor.setCursor(this.Const.UI.Cursor.Hand);
				this.m.MenuStack.push(function ()
				{
					this.World.getCamera().zoomTo(this.m.CustomZoom, 4.0);
					this.m.WorldEditorScreen.hide();
					this.m.WorldScreen.show();
					this.World.Assets.refillAmmo();
					this.updateTopbarAssets();
					this.setAutoPause(false);
				}, function ()
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

		local keyHandler = ::mods_getMember(obj, "helper_handleContextualKeyInput");
		obj.helper_handleContextualKeyInput = function(key)
		{
			if(!keyHandler(key) && key.getState() == 0)
			{
				if (key.getModifier() == 2 && key.getKey() == 38) //CTRL + Tab
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