this.getroottable().Woditor.hookPlayerParty <- function ()
{
	::mods_hookExactClass("entity/world/player_party", function ( obj )
	{
		local ws_getStrength = obj.getStrength;
		obj.getStrength = function()
		{
			local mult = this.World.Flags.has("DifficultyMult") ? this.World.Flags.getAsFloat("DifficultyMult") : 1.0;
			return ws_getStrength() * mult;
		}
	});

	delete this.Woditor.hookPlayerParty;
}