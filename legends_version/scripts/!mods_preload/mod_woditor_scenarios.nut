::Woditor.hookScenarios <- function ()
{
	::mods_hookBaseClass("scenarios/world/starting_scenario", function( obj )
	{
		obj = obj[obj.SuperName];
		obj.isDroppedAsLoot = function( _item )
		{
			return this.Math.rand(1, 100) <= this.World.Assets.m.EquipmentLootChance;
		};
		obj.getStashModifier = function()
		{
			return this.m.StashModifier + this.World.Flags.getAsInt("StashModifier");
		};
		obj.getStartingRosterTier = function()
		{
			if (this.World.Flags.has("RosterTier"))
			{
				return this.World.Flags.getAsInt("RosterTier");
			}

			return this.m.StartingRosterTier;
		}
		obj.getRosterTierMax = function()
		{
			if (this.World.Flags.has("RosterTier"))
			{
				local tier = this.World.Flags.getAsInt("RosterTier");
				return tier > this.m.RosterTierMax ? tier : this.m.RosterTierMax;
			}

			return this.m.RosterTierMax;
		}
	});
	::mods_hookExactClass("scenarios/world/raiders_scenario", function( obj )
	{
		obj.isDroppedAsLoot = function( _item )
		{
			return this.starting_scenario.isDroppedAsLoot(_item);
		};
		obj.onInit <- function()
		{
			this.starting_scenario.onInit();
			this.World.Assets.m.EquipmentLootChance += 15;
		};
	});

	::mods_hookNewObjectOnce("scenarios/scenario_manager", function ( obj )
	{	
		obj.getOriginImage <- function( _description )
		{
			local start = _description.find("ui/events/");
			if (start == null) return null;
			local end = _description.find(".png");
			return _description.slice(start, end + 4);
		}
		obj.getDataScenariosForUI <- function()
		{
			local ret = [];

			foreach(i, s in this.m.Scenarios )
			{
				if (!s.isValid() || s.getID() == "scenario.random")
				{
					continue;
				}

				local scenario = {
					ID = s.getID(),
					Name = s.getName(),
					Image = this.getOriginImage(s.getDescription()),
					Description = s.getDescription(),
					Difficulty = s.getDifficultyForUI()
				};
				ret.push(scenario);
			}

			return ret;
		}
	});

	delete ::Woditor.hookScenarios;
}