this.getroottable().Woditor.hookFaction <- function ()
{
	::mods_hookExactClass("factions/faction", function( obj ) 
	{
		obj.isPlayerRelationPermanent <- function()
		{
			if (this.getFlags().has("RelationDeterioration"))
			{
				return !this.getFlags().get("RelationDeterioration");
			}

			return !this.m.IsRelationDecaying;
		};
		obj.normalizeRelation = function()
		{
			if (this.isPlayerRelationPermanent())
			{
				return;
			}

			if (this.m.PlayerRelation > 50.0)
			{
				this.setPlayerRelation(this.Math.maxf(50.0, this.m.PlayerRelation - this.m.RelationDecayPerDay * this.World.Assets.m.RelationDecayGoodMult));
			}
			else if (this.m.PlayerRelation < 50.0)
			{
				this.setPlayerRelation(this.Math.minf(50.0, this.m.PlayerRelation + this.m.RelationDecayPerDay * this.World.Assets.m.RelationDecayBadMult));
			}

			if (this.m.PlayerRelationChanges.len() != 0 && this.m.PlayerRelationChanges[this.m.PlayerRelationChanges.len() - 1].Time + this.Const.World.Assets.RelationTimeOut < this.Time.getVirtualTimeF())
			{
				this.m.PlayerRelationChanges.remove(this.m.PlayerRelationChanges.len() - 1);
			}
		}
	});

	delete this.Woditor.hookFaction;
}