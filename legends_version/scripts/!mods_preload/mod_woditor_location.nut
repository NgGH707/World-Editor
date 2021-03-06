::Woditor.hookLocation <- function ()
{
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
		obj.getUIImagePath <- function()
		{
			local body = this.getSprite("body");

			if (body.HasBrush)
			{
				return "ui/locations/" + body.getBrush().Name + ".png";
			}
			
			return "ui/images/undiscovered_opponent.png";
		};
		obj.getUIBanner <- function()
		{
			if (this.m.IsShowingBanner || this.getFlags().get("IsShowingBanner"))
			{
				return "ui/banners/" + this.getBanner() + ".png";
			}
			
			return null;
		};
		obj.getTooltipId <- function()
		{
			return this.getID();
		};
	});

	delete ::Woditor.hookLocation;
}