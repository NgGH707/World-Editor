this.getroottable().OriginCustomizer.hookLocation <- function ()
{
	::mods_hookExactClass("entity/world/location", function( obj ) 
	{
		obj.getUIImage <- function()
		{
			local body = this.getSprite("body");

			if (body.HasBrush)
			{
				local string = body.getBrush().Name;
				local new = string.slice(6);
				return "ui/locations/" + new + ".png";
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

	delete this.OriginCustomizer.hookLocation;
}