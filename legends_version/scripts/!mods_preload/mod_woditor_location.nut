::Woditor.hookLocation <- function ()
{
	::mods_hookExactClass("entity/world/settlement", function( obj ) 
	{
		obj.getHouseUIImage <- function()
		{
			return "ui/settlement_sprites/world_houses_0" + this.m.HousesType + "_01.png";
		}
		obj.buildHouse <- function()
		{
			local tile = this.getTile();
			local badTiles = [
				this.Const.World.TerrainType.Impassable,
				this.Const.World.TerrainType.Ocean,
				this.Const.World.TerrainType.Shore,
				this.Const.World.TerrainType.Mountains,
				this.Const.World.TerrainType.Steppe
			];

			for( local i = 0; i < 6; i = ++i )
			{
				if (!tile.hasNextTile(i))
				{
				}
				else
				{
					local nextTile = tile.getNextTile(i);

					if (!nextTile.IsOccupied && badTiles.find(nextTile.Type) == null && !nextTile.HasRoad)
					{
						local v = this.Math.rand(1, 2)
						this.m.HousesTiles.push({
							X = nextTile.SquareCoords.X,
							Y = nextTile.SquareCoords.Y,
							V = v
						});
						nextTile.clear();
						nextTile.IsOccupied = true;
						local d = nextTile.spawnDetail("world_houses_0" + this.m.HousesType + "_0" + v, this.Const.World.ZLevel.Object - 3, this.Const.World.DetailType.Houses);
						d.Scale = 0.85;
						return true;
					}
				}
			}

			return false;
		};
		obj.destroyHouse <- function()
		{
			local find;

			foreach (i, h in this.m.HousesTiles)
			{
				find = i;
				local tile = this.World.getTileSquare(h.X, h.Y);
				tile.clear(this.Const.World.DetailType.Houses);
				tile.IsOccupied = false;
				break;
			}

			if (find != null)
			{
				this.m.HousesTiles.remove(find);
				return true;
			}

			return false;
		};

		obj.getHouseMax <- function()
		{
			local tile = this.getTile();
			local count = 0;
			local badTiles = [
				this.Const.World.TerrainType.Impassable,
				this.Const.World.TerrainType.Ocean,
				this.Const.World.TerrainType.Shore,
				this.Const.World.TerrainType.Mountains,
				this.Const.World.TerrainType.Steppe
			];

			for( local i = 0; i < 6; i = ++i )
			{
				if (!tile.hasNextTile(i))
				{
				}
				else
				{
					local nextTile = tile.getNextTile(i);

					if (badTiles.find(nextTile.Type) == null && !nextTile.HasRoad)
					{
						++count;
					}
				}
			}

			return count;
		}
	});

	::mods_hookExactClass("entity/world/location", function( obj ) 
	{
		obj.getNameItemChance <- function()
		{
			local nearestSettlement = 9000;
			local myTile = this.getTile();

			foreach( s in this.World.EntityManager.getSettlements() )
			{
				local d = myTile.getDistanceTo(s.getTile());

				if (d < nearestSettlement)
				{
					nearestSettlement = d;
				}
			}

			if (this.isLocationType(this.Const.World.LocationType.Unique))
			{
				return 0;
			}

			return this.Math.max(0, (this.getResources() + nearestSettlement * 4) / 5.0 - 37.0);
		};
		obj.getTerrainImage <- function()
		{
			return "ui/" + this.Const.World.TerrainTacticalImage[this.getTile().TacticalType] + (!this.World.getTime().IsDaytime ? "_night.png" : ".png");
		};
		obj.getUIImage <- function()
		{
			local body = this.getSprite("body");

			if (body.HasBrush)
			{
				return "ui/locations/" + body.getBrush().Name + ".png";
			}
			
			return null;
		};
		obj.getUIBanner <- function()
		{
			if (this.m.IsShowingBanner)
			{
				return "ui/banners/" + this.getBanner() + ".png";
			}
			else
			{
				return null;
			}
		};
		obj.getTooltipId <- function()
		{
			return this.getID();
		};
	});

	delete ::Woditor.hookLocation;
}