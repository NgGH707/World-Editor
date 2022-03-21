this.getroottable().Woditor.hookAttachedLocation <- function ()
{
	::mods_hookExactClass("entity/world/attached_location", function( obj ) 
	{
		obj.getUIImage <- function()
		{
			local string = this.m.Sprite;
			local find = string.slice(0, 6);

			if (find == "world_")
			{
				return "ui/attached_locations/" + string.slice(6) + ".png";
			}

			return "ui/attached_locations/" + string + ".png";
		};

		obj.getTooltipId <- function()
		{
			return this.m.ID;
		};
	});

	delete this.Woditor.hookAttachedLocation;
}