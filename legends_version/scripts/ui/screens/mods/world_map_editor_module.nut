this.world_map_editor_module <- this.inherit("scripts/ui/screens/ui_module", {
	m = {
		PopupDialogVisible = false,
		SeletedWorldEntityID = null,
		SpawnData = null,
		Mode = 0,
	},
	function create()
	{
		this.m.Mode = 0;
		this.m.SpawnData = null;
		this.m.PopupDialogVisible = false;
		this.m.ID = "WorldMapEditorModule";
		this.ui_module.create();
	}

	function destroy()
	{
		this.ui_module.destroy();
		this.m.PopupDialogVisible = false;
		this.m.SpawnData = null;
		this.m.Mode = 0;
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

	function isSelectedEntity()
	{
		return this.m.SeletedWorldEntityID != null;
	}

	function isSpawningMode()
	{
		return this.m.SpawnData != null;
	}

	function show( _withSlideAnimation = true )
	{
		if (!this.isVisible() && !this.isAnimating())
		{
			this.m.PopupDialogVisible = false;
			this.m.JSHandle.asyncCall("show", this.queryLoad());
			::World.Assets.setConsumingAssets(false);
			::World.State.getPlayer().setAttackable(false);
			::World.setFogOfWar(false);
		}
	}

	function hide( _withSlideAnimation = true )
	{
		if (this.isVisible() && !this.isAnimating())
		{
			this.m.PopupDialogVisible = false;
			this.m.JSHandle.asyncCall("hide", _withSlideAnimation);
			::World.Assets.setConsumingAssets(true);
			::World.State.getPlayer().setAttackable(true);
			::World.setFogOfWar(true);
		}
	}

	function onPopupDialogIsVisible( _data )
	{
		this.m.PopupDialogVisible = _data[0];
	}

	function queryLoad()
	{
		local result = {};
		result.Settlements <- clone ::Woditor.Settlements.All;
		result.AttachedLocations <- ::Woditor.Helper.convertAttachedLocationEntriesToUIData();
		result.Locations <- ::Woditor.Helper.convertLocationEntriesToUIData();
		result.Units <- ::Woditor.Helper.convertPartiesEntriesToUIData();
		return result;
	}

	function getSelectedEntity()
	{
		return ::World.getEntityByID(this.m.SeletedWorldEntityID);
	}

	function onRemoveSpawnSelection()
	{
		this.m.Mode = 0;
		this.m.SpawnData = null;
	}

	function onChangeSpawnSelection( _data )
	{
		this.m.Mode = 2;
		this.m.SpawnData = _data[0];
		this.m.SpawnData.EntityType <- _data[1];
		this.m.SeletedWorldEntityID = null;
	}

	function onShowWorldEntityOnMap( _id )
	{
		local world_entity = ::World.getEntityByID(_id);
		if (world_entity == null) return;
		local tile = world_entity.getTile();
		world_entity.setDiscovered(true);
		::World.uncoverFogOfWar(tile.Pos, 500.0);
		::World.getCamera().Zoom = 1.0;
		::World.getCamera().setPos(tile.Pos);
	}

	function select( _worldEntity )
	{
		if (_worldEntity.getID() == ::World.State.getPlayer().getID()) return;

		this.onRemoveSpawnSelection();
		this.m.SeletedWorldEntityID = _worldEntity.getID();
		this.m.JSHandle.asyncCall("selectWorldEntity", {
			ID = _worldEntity.getID(),
			Name = _worldEntity.getName(),
			ImagePath = _worldEntity.getUIImagePath()
		});
	}

	function discard()
	{
		local world_entity = ::World.getEntityByID(this.m.SeletedWorldEntityID);
		if (world_entity == null) return;

		if (world_entity.isLocation())
		{
			world_entity.die();
		}
		else if (world_entity.isParty())
		{
			world_entity.onCombatLost();
		}

		this.m.SeletedWorldEntityID = null;
		this.m.JSHandle.asyncCall("deselectWorldEntity", null);
	}

	function move( _tile )
	{
		local world_entity = ::World.getEntityByID(this.m.SeletedWorldEntityID);
		if (world_entity == null) return;

		world_entity.setPos(_tile.Pos);
	}

	function spawn( _tile )
	{
		if (this.m.SpawnData == null) return;

		if (_tile.IsOccupied) return;

		if (_tile.Type == ::Const.World.TerrainType.Impassable) return;

		if (_tile.Type == ::Const.World.TerrainType.Ocean) return;

		switch (this.m.SpawnData.EntityType)
		{
		case 0:
			this.spawnSettlement(_tile, this.m.SpawnData);
			break;
	
		case 1:
			this.spawnAttachedLocation(_tile, this.m.SpawnData);
			break;

		case 2:
			this.spawnLocation(_tile, this.m.SpawnData);
			break;

		case 3:
			this.spawnUnit(_tile, this.m.SpawnData);
			break;
		}
	}

	function spawnUnit(_tile, _data)
	{
		local factions = ::World.FactionManager.getFactionsOfType(::MSU.Array.getRandom(_data.FactionType));
		local faction = ::MSU.Array.getRandom(factions);
		local party = faction.spawnEntity(_tile, _data.Name, false, ::Const.World.Spawn[_data.Key], ::Math.rand(80, 120) * this.getScaledDifficultyMult() * this.getReputationToDifficultyLightMult());
		local roam = ::new("scripts/ai/world/orders/roam_order");
		roam.setAllTerrainAvailable();
		party.getController().addOrder(roam);
	}

	function spawnLocation(_tile, _data)
	{
		local location = ::World.spawnLocation("scripts/entity/world/locations/" + _data.Script, _tile.Coords);
		location.onSpawned();
		location.setDiscovered(true);
		::World.uncoverFogOfWar(_tile.Pos, 2100);

		if (_data.FactionType != null)
		{
			::World.FactionManager.getFactionOfType(_data.FactionType).addSettlement(location, false);
		}
	}

	function spawnAttachedLocation(_tile, _data)
	{
		local best = 9999;
		local bestSettlement;
		local attachment = ::World.spawnLocation(_data.Script, _tile.Coords);

		foreach (s in ::World.EntityManager.getSettlements())
		{
			local d = s.getTile().getDistanceTo(_tile);

			if (d < best)
			{
				best = d;
				bestSettlement = s;
			}
		}

		attachment.setSettlement(bestSettlement);

		if (attachment.onBuild())
		{
			attachment.setDiscovered(true);
			::World.uncoverFogOfWar(_tile.Pos, 2100);
			bestSettlement.m.AttachedLocations.push(attachment);
			return;
		}
		
		attachment.die();
	}

	function spawnSettlement(_tile, _data)
	{
		local script;

		if (_data.IsSouthern)
		{
			script = ::MSU.Array.getRandom(::Woditor.Settlements.CityState);
		}
		else if (!_data.IsVillage)
		{
			script = ::MSU.Array.getRandom(::Woditor.Settlements.Fort[_data.Size]);
		}
		else
		{
			script = ::MSU.Array.getRandom(::Woditor.Settlements.Village[_data.Size]);
		}

		local best = 9999;
		local bestFaction;
		local factions = ::World.FactionManager.getFactionsOfType(_data.IsSouthern ? ::Const.FactionType.OrientalCityState : ::Const.FactionType.NobleHouse);
		local settlement = ::World.spawnLocation(script, _tile.Coords);
		settlement.setDiscovered(true);
		::World.uncoverFogOfWar(_tile.Pos, 2100);

		foreach (s in ::World.EntityManager.getSettlements())
		{
			if (s.getID == settlement.getID())
			{
				::logInfo("settlement has been added to :World.EntityManager");
				break;
			}
		}

		foreach (f in factions)
		{
			foreach( s in f.m.Settlements )
			{
				local d = s.getTile().getDistanceTo(_tile);

				if (d < best)
				{
					best = d;
					bestFaction = f;
				}
			}
		}

		if (bestFaction != null)
		{
			bestFaction.addSettlement(settlement);
			return;
		}

		::MSU.Array.getRandom(::World.FactionManager.getFactionsOfType(::Const.FactionType.NobleHouse)).addSettlement(settlement);
	}

	function getScaledDifficultyMult()
	{
		local s = ::Math.maxf(0.5, 0.6 * ::Math.pow(0.01 * ::World.State.getPlayer().getStrength(), 0.9));
		local d = ::Math.minf(4.0, s + ::Math.minf(1.0, ::World.getTime().Days * 0.01));
		return d * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()];
	}

	function getReputationToDifficultyLightMult()
	{
		local d = 1.0 + ::Math.minf(2.0, ::World.getTime().Days * 0.014) - 0.1;
		return d * ::Const.Difficulty.EnemyMult[::World.Assets.getCombatDifficulty()];
	}

});

