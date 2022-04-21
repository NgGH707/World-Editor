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

	function onSortStashItem( _emptyArray )
	{
		return ::Woditor.Helper.convertPlayerStashToUIData(true);
	}

	function onRepairAllStashItem( _emptyArray )
	{
		foreach (i, _item in ::World.Assets.getStash().m.Items)
		{
			if (_item == null) continue;
			_item.setCondition(_item.getConditionMax());
		}

		return ::Woditor.Helper.convertPlayerStashToUIData();
	}

	function onRestockAllStashItem( _emptyArray )
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
		local isDuplicate = _data[0].Index != null;
		local item = ::new(itemScript);
		local stash = ::World.Assets.getStash();
		local sourceItem = isDuplicate ? stash.getItemAtIndex(_data[0].Index).item : null;
		local items = [item];
		local result = [];

		if (_data[1] > 1)
		{
			if (_data[0].CanChangeAmount)
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
					items.push(::new(itemScript));
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

			if (isDuplicate)
			{
				this.duplicateItem(_item, sourceItem);
			}
			else
			{
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
			}
			
			local entry = ::Woditor.Helper.convertItemToUIData(_item, stash.getID());
			entry.Attribute = ::Woditor.Helper.getAdditionInfoFromItem(_item);
			entry.Index <- add;
			result.push(entry);
		}

		return result;
	}

	function onCheckScriptInputThenAddItem( _script )
	{
		local isValidShorten = ::Woditor.ItemsScriptShorten.find(_script) != null;
		local isValid = isValidShorten || ::Woditor.ItemsScript.find(_script) != null;

		if (!isValid) return false;
		
		local prefix = isValidShorten ? "scripts/items/" : "";
		local item = ::new(prefix + _script);
		local add = ::World.Assets.getStash().add(item);

		if (add == null) return true;

		local result = ::Woditor.Helper.convertItemToUIData(item, ::World.Assets.getStash().getID());
		result.Attribute = ::Woditor.Helper.getAdditionInfoFromItem(item);
		result.Index <- add;
		return result;
	}

	function onRerollStats( _index )
	{
		local item = ::World.Assets.getStash().removeByIndex(_index);
		local newItem = ::new(::IO.scriptFilenameByHash(item.ClassNameHash));
		newItem.setName(item.getName());
		newItem.setVariant(item.m.Variant);
		::World.Assets.getStash().insert(newItem, _index);
		local result = ::Woditor.Helper.convertItemToUIData(newItem, ::World.Assets.getStash().getID());
		result.Attribute = ::Woditor.Helper.getAdditionInfoFromItem(newItem);
		result.Index <- _index;
		return result;
	}

	function onRemoveItemFromStash( _index )
	{
		::World.Assets.getStash().removeByIndex(_index);
	}

	function onChangeAmountOfItem( _data )
	{
		::World.Assets.getStash().getItemAtIndex(_data[0]).item.setAmount(_data[1]);
	}

	function onChangeNameOfItem( _data )
	{
		::World.Assets.getStash().getItemAtIndex(_data[0]).item.setName(_data[1]);
	}

	function onChangeAttributeOfItem( _data )
	{
		this.assignNewStatsToItem(_data[1], _data[2], ::World.Assets.getStash().getItemAtIndex(_data[0]).item);
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
			_item.m[_key] = _v * 0.01;
			break;

		default:
			_item.m[_key] = _v;
		}
	}

	function duplicateItem( _cloneItem, _sourceItem , _isUpdateAppearance = true )
	{
		local properties = _sourceItem.m;
		local exclude = ["OldID", "MagicNumber"];
		do
		{
			foreach (key, _v in properties)
			{
				switch (typeof _v)
				{
				case "instance":
				case "object":
					break;

				case "table":
					if (key == "Upgrade") 
					{
						_cloneItem.m.Upgrade = ::new(::IO.scriptFilenameByHash(_v.ClassNameHash));
						_cloneItem.m.Upgrade.setArmor(_cloneItem);
					}
					break;

				case "array":
					if (key == "Upgrades")
					{
						foreach (i, u in _v)
						{
							if (u != null) 
							{
								local item = ::new(::IO.scriptFilenameByHash(u.ClassNameHash));
								this.duplicateItem(item, u, false);
								_cloneItem.m.Upgrades[i] = item;
								_cloneItem.m.Upgrades[i].setArmor(_cloneItem);
							}
						}
					}
					break;
			
				default:
					_cloneItem.m[key] = _v;
				}
			}

			properties = properties.getdelegate();
		}
		while(properties != null)

		if (!_isUpdateAppearance) return;
		_cloneItem.updateVariant();
		_cloneItem.updateAppearance();
	}

};

