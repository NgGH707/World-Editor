this.getroottable().Woditor.hookLocation <- function ()
{
	::mods_hookExactClass("entity/world/location", function( obj ) 
	{
		obj.getUIImage <- function()
		{
			local body = this.getSprite("body");

			if (body.HasBrush)
			{
				local string = body.getBrush().Name;
				local find = string.slice(0, 6);

				if (find == "world_")
				{
					return "ui/locations/" + string.slice(6) + ".png";
				}

				return "ui/locations/" + string + ".png";
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

	delete this.Woditor.hookLocation;
}