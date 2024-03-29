::Woditor.hookWorldState <- function ()
{
	::mods_hookExactClass("states/world_state", function( obj ) 
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
			this.m.WorldEditorScreen.destroy();
			this.m.WorldEditorScreen = null;
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
					this.World.Assets.resetToDefaults();
					this.World.State.updateTopbarAssets();
					this.World.State.getPlayer().updateStrength();
					this.m.WorldEditorScreen.updateSomeShit();
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
		
		local ws_startNewCampaign = obj.startNewCampaign;
		obj.startNewCampaign = function()
		{
			ws_startNewCampaign();
			this.m.WorldEditorScreen.onDeserialize();
		};

		local ws_onSerialize = obj.onSerialize;
		obj.onSerialize = function( _out )
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
