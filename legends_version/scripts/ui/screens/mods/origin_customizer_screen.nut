this.origin_customizer_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		PopupDialogVisible = false,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnClosePressedListener = null
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
		this.m.JSHandle = this.UI.connect("OriginCustomizerScreen", this);
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

	function convertToUIData()
	{
		local result = {};
		result.Factions <- this.convertFactionsToUIData();
		result.Scenarios <- this.Const.ScenarioManager.getScenariosForUI();
		result.Scenarios.remove(2);
		result.Scenarios.remove(0);
		return result;
	}

	function convertFactionsToUIData()
	{
		local result = [];
		local valid = [
			this.Const.FactionType.OrientalCityState,
			this.Const.FactionType.NobleHouse,
			this.Const.FactionType.Settlement,
			this.Const.FactionType.Player,
		];
		local factions = clone this.World.FactionManager.getFactions(false);
		local factions_southern = [];
		local factions_with_settlement = [];
		local factions_misc = [];

		foreach( f in factions )
		{
			if (f == null)
			{
				continue;
			}

			if (f.getType() == this.Const.FactionType.OrientalCityState)
			{
				factions_southern.push(f);
			}
			else if (valid.find(f.getType()) != null)
			{
				factions_with_settlement.push(f);
			}
			else
			{
				factions_misc.push(f);
			}
		}

		factions_southern.sort(this.onSortFactions);
		factions_with_settlement.sort(this.onSortFactions);
		factions_misc.sort(this.onSortFactions);
		factions = [];
		factions.extend(factions_southern);
		factions.extend(factions_with_settlement);
		factions.extend(factions_misc);

		foreach( f in factions )
		{
			local faction = {
				ID = f.getID(),
				Name = ("getNameOnly" in f) ? f.getNameOnly() : f.getName(),
				Relation = f.getPlayerRelationAsText(),
				RelationNum = this.Math.round(f.getPlayerRelation())
				RelationNumSimplified = this.Math.min(this.Const.Strings.Relations.len() - 1, f.getPlayerRelation() / 10),
				IsHostile = !f.isAlliedWithPlayer(),
				IsFixedRelation = false,
			};

			if (valid.find(f.getType()) != null)
			{
				faction.ImagePath <- f.getUIBanner();
				faction.Contracts <- this.getContractsUI(f);
			}
			else
			{
			    faction.ImagePath <- "ui/banners/banner_unknow.png";
			    faction.Contracts <- [];
			}

			result.push(faction);
		}

		return result;
	}

	function getContractsUI( _faction )
	{
		local contracts = _faction.getContracts();
		local result = [];

		foreach ( c in contracts ) 
		{
			if (c.isActive())
			{
				continue;
			}

			result.push({
				ID = c.getID(),
				Icon = c.getBanner(),
				IsNegotiated = c.isNegotiated(),
				DifficultyIcon = c.getUIDifficultySmall(),
			});
		}

		return result;
	}

	function onSortFactions( _f1, _f2 )
	{
		if (_f1 == null && _f2 == null)
		{
			return 0;
		}

		if (_f1 == null)
		{
			return 1;
		}
		else if (_f2 == null)
		{
			return -1;
		}

		if (_f1.getType() < _f2.getType())
		{
			return -1;
		}
		else if (_f1.getType() > _f2.getType())
		{
			return 1;
		}
		else
		{
			if (_f1.getName() < _f2.getName())
			{
				return -1;
			}
			else if (_f1.getName() > _f2.getName())
			{
				return 1;
			}

			return 0;
		}
	}
};	

