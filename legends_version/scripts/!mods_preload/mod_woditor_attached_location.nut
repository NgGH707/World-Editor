::Woditor.hookAttachedLocation <- function ()
{
	::mods_hookExactClass("entity/world/attached_location", function( obj ) 
	{
		obj.getUIImagePath <- function()
		{
			return "ui/attached_locations/" + this.m.Sprite + ".png";
		};
		obj.getTooltipId <- function()
		{
			return this.m.ID;
		};
	});

	delete ::Woditor.hookAttachedLocation;
}