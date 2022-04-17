::Woditor.hookParty <- function ()
{
	::mods_hookExactClass("entity/world/party", function ( obj )
	{
		obj.setBanner <- function( _banner )
		{
			if (this.hasSprite("banner"))
			{
				this.getSprite("banner").setBrush(_banner);
			}
		};
		obj.getUIImagePath <- function()
		{
			local sprite = this.getSprite("body");

			if (sprite.HasBrush)
			{
				return "ui/parties/" + sprite.getBrush().Name + ".png";
			}
			
			return "ui/images/undiscovered_opponent.png";
		};
		obj.getTerrainImage <- function()
		{
			return "ui/" + this.Const.World.TerrainTacticalImage[this.getTile().TacticalType] + (!this.World.getTime().IsDaytime ? "_night.png" : ".png");
		};
		obj.getTooltipId <- function()
		{
			return this.getID();
		};
		obj.getUIBanner <- function()
		{
			local sprite = this.getSprite("banner");

			if (sprite.HasBrush)
			{
				return "ui/banners/" + sprite.getBrush().Name + ".png";
			}
			
			return null;
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