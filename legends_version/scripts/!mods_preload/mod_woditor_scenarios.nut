this.getroottable().Woditor.hookScenarios <- function ()
{
	::mods_hookExactClass("scenarios/world/starting_scenario", function( obj )
	{
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
			local start = _description.find("events/");
			local end = _description.find(".png");
			return _description.slice(start, end);
		}
		obj.getScenariosForUI = function()
		{
			local ret = [];

			foreach(i, s in this.m.Scenarios )
			{
				if (!s.isValid())
				{
					continue;
				}

				local scenario = {
					ID = s.getID(),
					Name = s.getName(),
					Description = s.getDescription(),
					Difficulty = s.getDifficultyForUI()
				};
				scenario.Image <- this.getOriginImage(scenario.Description);
				ret.push(scenario);
			}

			return ret;
		}
	});

	delete this.Woditor.hookScenarios;
}