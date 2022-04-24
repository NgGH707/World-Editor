::Woditor.hookSettlement <- function ()
{
	::mods_hookExactClass("entity/world/settlement", function( obj ) 
	{
                obj.isCoastal = function()
	        {
		        if(this.hasBuilding("building.port")) return true;

                        return this.m.IsCoastal;
	        }

		obj.getUIImagePath <- function()
		{
			return this.getImagePath();
		}
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

	delete ::Woditor.hookSettlement;
}
