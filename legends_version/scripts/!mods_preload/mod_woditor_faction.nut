::Woditor.hookFaction <- function ()
{
	::mods_hookBaseClass("factions/faction", function( obj ) 
	{
		obj = obj[obj.SuperName];
		obj.isPlayerRelationPermanent <- function()
		{
			if (this.getFlags().has("RelationDeterioration"))
			{
				return !this.getFlags().get("RelationDeterioration");
			}

			return !this.m.IsRelationDecaying;
		};
		local ws_normalizeRelation = obj.normalizeRelation;
		obj.normalizeRelation = function()
		{
			if (this.isPlayerRelationPermanent())
			{
				return;
			}

			ws_normalizeRelation();
		}
	});

	delete ::Woditor.hookFaction;
}