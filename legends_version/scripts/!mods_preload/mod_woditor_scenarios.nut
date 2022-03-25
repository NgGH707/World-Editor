this.getroottable().Woditor.hookScenarios <- function ()
{
	::mods_hookExactClass("scenarios/world/starting_scenario", function( obj )
	{
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
			if (this.m.RosterTierMax < this.World.Flags.getAsInt("RosterTier"))
			{
				return this.World.Flags.getAsInt("RosterTier");
			}

			return this.m.RosterTierMax;
		}
		obj.isDroppedAsLoot = function( _item )
		{
			return this.Math.rand(1, 100) <= this.World.Assets.m.EquipmentLootChance;
		};
		obj.getStashModifier = function()
		{
			return this.m.StashModifier + this.World.Flags.getAsInt("StashModifier");
		};
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

	delete this.Woditor.hookScenarios;
}