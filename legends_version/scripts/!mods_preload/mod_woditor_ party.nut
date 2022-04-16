::Woditor.hookParty <- function ()
{
	::mods_hookExactClass("entity/world/party", function ( obj )
	{
		obj.getUIImagePath <- function()
		{
			return "ui/images/undiscovered_opponent.png";
			//return "ui/attached_locations/" + this.m.Sprite + ".png";
		};
	});

	::mods_hookExactClass("entity/world/player_party", function ( obj )
	{
		local ws_getStrength = obj.getStrength;
		obj.getStrength = function()
		{
			local mult = this.World.Flags.has("DifficultyMult") ? this.World.Flags.getAsFloat("DifficultyMult") : 1.0;
			return ws_getStrength() * mult;
		}
		obj.forceRecalculateStashModifier <- function()
		{
			local s = this.Const.LegendMod.MaxResources[this.World.Assets.getEconomicDifficulty()].Stash
			s += this.World.Assets.getOrigin().getStashModifier();
			s += this.World.Retinue.getInventoryUpgrades() * 27;

			foreach( bro in this.World.getPlayerRoster().getAll())
			{
				s += bro.getStashModifier();
			}

			if (s != this.Stash.getCapacity())
			{
				this.Stash.resize(s);
			}
			
			return s;
		}
	});

	delete ::Woditor.hookParty;
}