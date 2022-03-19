this.getroottable().OriginCustomizer.hookAttachedLocation <- function ()
{
	::mods_hookExactClass("entity/world/attached_location", function( obj ) 
	{
		obj.getUIImage <- function()
		{
			local string = this.m.Sprite;
			local new = string.slice(6);
			return "ui/attached_locations/" + new + ".png";
		};

		obj.getTooltipId <- function()
		{
			return this.m.ID;
		};
	});

	delete this.OriginCustomizer.hookAttachedLocation;
}