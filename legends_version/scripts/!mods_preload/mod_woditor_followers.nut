::Woditor.hookFollowers <- function ()
{
	::mods_hookExactClass("retinue/followers/bounty_hunter_follower", function( obj )
	{
		obj.onUpdate = function()
		{
			this.World.Assets.m.ChampionChanceAdditional += 3;
		};
	});

	::mods_hookExactClass("retinue/followers/quartermaster_follower", function( obj )
	{
		obj.onUpdate = function()
		{
			this.World.Assets.m.AmmoMaxAdditional += 100;
			this.World.Assets.m.MedicineMaxAdditional  += 50;
			this.World.Assets.m.ArmorPartsMaxAdditional += 50;
		};
	});

	::mods_hookExactClass("retinue/followers/cook_follower", function( obj )
	{
		obj.onUpdate = function()
		{
			this.World.Assets.m.FoodAdditionalDays += 4;
		};
	});


	::mods_hookExactClass("retinue/followers/lookout_follower", function( obj )
	{
		obj.onUpdate = function()
		{
			this.World.Assets.m.VisionRadiusMult *= 1.25;
			this.World.Assets.m.IsShowingExtendedFootprints = true;
		};
	});

	::mods_hookExactClass("retinue/followers/negotiator_follower", function( obj )
	{
		obj.onUpdate = function()
		{
			this.World.Assets.m.NegotiationAnnoyanceMult *= 0.5;
			this.World.Assets.m.AdvancePaymentCap = this.Math.min(0.95, this.World.Assets.m.AdvancePaymentCap + 0.25);

			if (this.World.Assets.getOrigin().getID() == "scenario.sato_escaped_slaves") 
			{
				this.World.Assets.m.RelationDecayGoodMult *= 1.05;
				this.World.Assets.m.RelationDecayBadMult *= 0.95;
			} 
			else 
			{
				this.World.Assets.m.RelationDecayGoodMult *= 0.9;
				this.World.Assets.m.RelationDecayBadMult *= 1.1;
			}
		};

		obj.onNewDay = function() {};
	});

	delete ::Woditor.hookFollowers;
}