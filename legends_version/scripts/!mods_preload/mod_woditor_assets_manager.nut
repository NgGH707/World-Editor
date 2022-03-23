this.getroottable().Woditor.hookAssetsManager <- function ()
{
	::mods_hookNewObject("states/world/asset_manager", function ( obj )
	{	
		obj.m.BaseProperties <- {};
		obj.m.EquipmentLootChance <- 0;
		obj.m.MovementSpeedMult <- 1.0;

		foreach (key in this.Woditor.AssetsProperties.Mult)
		{
			obj.m.BaseProperties[key] <- 1.0;
		}

		foreach (key in this.Woditor.AssetsProperties.Additive)
		{
			obj.m.BaseProperties[key] <- 0;
		}

		local ws_resetToDefaults = obj.resetToDefaults;
		obj.resetToDefaults = function()
		{
			ws_resetToDefaults();

			foreach (key in this.Woditor.AssetsProperties.Mult)
			{
				if (this.World.Flags.has(key)) this.m[key] *= this.World.Flags.getAsFloat(key); 
			}

			foreach (key in this.Woditor.AssetsProperties.Additive)
			{
				this.m[key] += this.World.Flags.getAsInt(key);
			}
		}

		obj.getBaseProperties <- function()
		{
			return this.m.BaseProperties;
		}

		obj.updateBaseProperties <- function()
		{
			foreach (key in this.Woditor.AssetsProperties.Mult)
			{
				if (this.World.Flags.has(key)) this.m.BaseProperties[key] = this.m[key] / this.World.Flags.getAsFloat(key);
			}

			foreach (key in this.Woditor.AssetsProperties.Additive)
			{
				this.m.BaseProperties[key] = this.m[key] - this.World.Flags.getAsInt(key);
			}
		}
	});

	delete this.Woditor.hookAssetsManager;
}