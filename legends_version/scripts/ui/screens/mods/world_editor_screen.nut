this.world_editor_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		PopupDialogVisible = false,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnClosePressedListener = null,

		// 
		StashCapacityBefore = 0,
	},
	function isVisible()
	{
		return this.m.Visible != null && this.m.Visible == true;
	}

	function isAnimating()
	{
		if (this.m.Animating != null)
		{
			return this.m.Animating == true || this.m.PopupDialogVisible == true;
		}
		else
		{
			return false;
		}
	}

	function setOnConnectedListener( _listener )
	{
		this.m.OnConnectedListener = _listener;
	}

	function setOnDisconnectedListener( _listener )
	{
		this.m.OnDisconnectedListener = _listener;
	}

	function setOnClosePressedListener( _listener )
	{
		this.m.OnClosePressedListener = _listener;
	}

	function clearEventListener()
	{
		this.m.OnConnectedListener = null;
		this.m.OnDisconnectedListener = null;
		this.m.OnClosePressedListener = null;
	}

	function create()
	{
		this.m.Visible = false;
		this.m.Animating = false;
		this.m.PopupDialogVisible = false;
		this.m.JSHandle = this.UI.connect("WorldEditorScreen", this);
	}

	function destroy()
	{
		this.clearEventListener();
		this.m.JSHandle = this.UI.disconnect(this.m.JSHandle);
	}

	function show( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.convertToUIData());
		}
	}

	function hide( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			this.Tooltip.hide();
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation);
		}
	}

	function onScreenConnected()
	{
		if (this.m.OnConnectedListener != null)
		{
			this.m.OnConnectedListener();
		}
	}

	function onScreenDisconnected()
	{
		if (this.m.OnDisconnectedListener != null)
		{
			this.m.OnDisconnectedListener();
		}
	}

	function onScreenShown()
	{
		this.m.Visible = true;
		this.m.Animating = false;
		this.m.PopupDialogVisible = false;
	}

	function onScreenHidden()
	{
		this.m.Visible = false;
		this.m.Animating = false;
		this.m.PopupDialogVisible = false;
	}

	function onScreenAnimating()
	{
		this.m.Animating = true;
	}

	function onPopupDialogIsVisible( _data )
	{
		this.m.PopupDialogVisible = _data[0];
	}

	function onCloseButtonPressed()
	{
		if (this.m.OnClosePressedListener != null)
		{
			this.m.OnClosePressedListener();
		}
	}

	function onGetTroopEntries( _data )
	{
		return this.Woditor.Helper.convertTroopEntriesToUIData(_data);
	}

	function onChangeCompanyName( _name )
	{
		this.World.Assets.m.Name = _name;
	}

	function onChangeFactionName( _data )
	{
		this.World.FactionManager.getFaction(_data[1]).setName(_data[0]);
	}

	function onChangeWorldEntityName( _data )
	{
		this.World.getEntityByID(_data[1]).setName(_data[0]);
	}

	function onUpdateAssetsValue( _data )
	{
		if (_data[0] == "Stash")
		{
			local before = this.m.StashCapacityBefore;
			this.World.Flags.set("StashModifier", _data[1] - before);
		}
		else
		{
			this.World.Assets.m[_data[0]] = _data[1];
		}
	}

	function onUpdateAssetsPropertyValue( _data )
	{
		local key = _data[0];
		local value = _data[1];
		local baseValue = this.World.Assets.getBaseProperties()[key];
		local isMult = this.Woditor.AssetsProperties.Mult.find(key) != null;
		local isAdditive = this.Woditor.AssetsProperties.Additive.find(key) != null;

		if (isMult) this.World.Flags.set(key, value / baseValue * 100);
		else if (isAdditive) this.World.Flags.set(key, value - baseValue);
		else this.World.Flags.set(key, value);
	}

	function convertToUIData()
	{
		local result = {};
		result.Assets <- this.Woditor.Helper.convertAssetsToUIData();
		result.Factions <- this.Woditor.Helper.convertFactionsToUIData();
		result.Settlements <- this.Woditor.Helper.convertSettlementsToUIData(result.Factions);
		result.Locations <- this.Woditor.Helper.convertLocationsToUIData(result.Factions);
		result.Scenarios <- this.Const.ScenarioManager.getScenariosForUI();
		result.Scenarios.remove(2);
		result.Scenarios.remove(0);

		this.m.StashCapacityBefore = result.Assets.Stash;
		return result;
	}

};

