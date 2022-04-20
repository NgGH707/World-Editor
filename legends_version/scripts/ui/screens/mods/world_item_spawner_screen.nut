this.world_item_spawner_screen <- {
	m = {
		JSHandle = null,
		Visible = null,
		Animating = null,
		PopupDialogVisible = false,
		OnConnectedListener = null,
		OnDisconnectedListener = null,
		OnClosePressedListener = null,
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
		this.m.JSHandle = ::UI.connect("WorldItemsSpawnerScreen", this);
	}

	function destroy()
	{
		this.clearEventListener();
		this.m.JSHandle = ::UI.disconnect(this.m.JSHandle);
	}

	function show( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			::Tooltip.hide();
			this.m.JSHandle.asyncCall("show", this.convertToUIData());
		}
	}

	function hide( _withSlideAnimation = false )
	{
		if (this.m.JSHandle != null)
		{
			::Tooltip.hide();
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
		return ::Woditor.Helper.convertPlayerStashToUIData();
	}

	function onSeachItemBy( _data )
	{
		return ::Woditor.SearchItems(_data[0], _data[1]);
	}

	function onShowAllItems( _filter )
	{
		return ::Woditor.Items[_filter];
	}

	function onDeleteAllStashItem()
	{
		::World.Assets.getStash().clear();	
	}

	function onSortStashItem()
	{
		return ::Woditor.Helper.convertPlayerStashToUIData(true);
	}

	function onRepairAllStashItem()
	{
		foreach (i, _item in ::World.Assets.getStash().m.Items)
		{
			if (_item == null) continue;
			_item.setCondition(_item.getConditionMax());
		}

		return ::Woditor.Helper.convertPlayerStashToUIData();
	}

	function onRestockAllStashItem()
	{
		foreach (i, _item in ::World.Assets.getStash().m.Items)
		{
			if (_item == null) continue;

			if (("setAmount" in _item) && this.m.Amount < 25)
			{
				_item.setAmount(25);

				if (_item.isItemType(::Const.Items.ItemType.Food))
				{
					_item.m.BestBefore = ::Time.getVirtualTimeF() + _item.m.GoodForDays * ::World.getTime().SecondsPerDay;
				}
			}
		}

		return ::Woditor.Helper.convertPlayerStashToUIData();
	}

	function onAddItemToStash( _data )
	{
		local itemScript = ::IO.scriptFilenameByHash(_data[0].ClassName);
		local item = this.new(itemScript);
		local stash = ::World.Assets.getStash();
		local items = [item];
		local result = [];

		if (_data[1] > 1)
		{
			if ("setAmount" in _item)
			{
				if (_data[4])
				{
					item.setAmount(_data[1]);
				}
			}
			else
			{
				for (local i = 1; i < _data[1]; ++i)
				{
					items.push(this.new(itemScript));
				}
			}
		}

		foreach (_item in items)
		{
			local add = stash.add(_item);

			if (add == null)
			{
				break;
			}

			if (_data[0].CanChangeName && _data[2].len() > 0)
			{
				_item.setName(_data[2]);
			}

			if (_data[3].len() > 0)
			{
				foreach (key, v in _data[3])
				{
					this.assignNewStatsToItem(key, v, _item);
				}
			}
			
			local entry = ::Woditor.Helper.convertItemToUIData(_item, stash.getID());
			entry.Attribute = ::Woditor.Helper.getAdditionInfoFromItem(_item);
			entry.Index <- add;
			result.push(entry);
		}

		return result;
	}

	function onRemoveItemFromStash( _index )
	{
		::World.Assets.getStash().removeByIndex(_index);
	}

	function assignNewStatsToItem( _key, _v, _item )
	{
		switch (_key)
		{
		case "ConditionMax":
			_item.m.ConditionMax = _v;
			_item.setCondition(_v);
			break;
		
		/*
		case "StaminaModifier":
		case "MeleeDefense":
		case "RangedDefense":
		case "FatigueOnSkillUse":
		case "RegularDamage":
		case "RegularDamageMax":
		case "ShieldDamage":
		case "ChanceToHitHead":
		case "AdditionalAccuracy":
		case "AmmoMax":
		*/
	
		case "DirectDamageAdd":
		case "ArmorDamageMult":
			_item.m[_key] = _v / 0.01;
			break;

		default:
			_item.m[_key] = _v;
		}
	}

};

