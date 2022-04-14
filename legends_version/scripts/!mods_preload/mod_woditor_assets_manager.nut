::Woditor.hookAssetsManager <- function ()
{
	::mods_hookNewObject("states/world/asset_manager", function ( obj )
	{	
		obj.m.BaseProperties <- {};
		obj.m.EquipmentLootChance <- 0;
		obj.m.MovementSpeedMult <- 1.0;

		foreach (key in ::Woditor.AssetsProperties.Mult)
		{
			obj.m.BaseProperties[key] <- 1.0;
		}

		foreach (key in ::Woditor.AssetsProperties.Additive)
		{
			obj.m.BaseProperties[key] <- 0;
		}

		local ws_resetToDefaults = obj.resetToDefaults;
		obj.resetToDefaults = function()
		{
			ws_resetToDefaults();

			foreach (key in ::Woditor.AssetsProperties.Mult)
			{
				if (this.World.Flags.has(key)) this.m[key] *= this.World.Flags.getAsFloat(key); 
			}

			foreach (key in ::Woditor.AssetsProperties.Additive)
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
			foreach (key in ::Woditor.AssetsProperties.Mult)
			{
				if (this.World.Flags.has(key)) this.m.BaseProperties[key] = this.m[key] / this.World.Flags.getAsFloat(key);
			}

			foreach (key in ::Woditor.AssetsProperties.Additive)
			{
				this.m.BaseProperties[key] = this.m[key] - this.World.Flags.getAsInt(key);
			}
		}

		local ws_updateLook = obj.updateLook;
		obj.updateLook = function( _updateTo = -1 )
		{
			ws_updateLook();

			if (this.World.Flags.has("AvatarSocket"))
			{
				this.World.State.getPlayer().getSprite("base").setBrush(this.World.Flags.get("AvatarSocket"));
			}

			if (this.World.Flags.has("AvatarSprite"))
			{
				this.World.State.getPlayer().getSprite("body").setBrush(this.World.Flags.get("AvatarSprite"));
			}

			if (this.World.Flags.has("AvatarIsFlippedHorizontally"))
			{
				this.World.State.getPlayer().getSprite("base").setHorizontalFlipping(this.World.Flags.get("AvatarIsFlippedHorizontally"));
				this.World.State.getPlayer().getSprite("body").setHorizontalFlipping(this.World.Flags.get("AvatarIsFlippedHorizontally"));
			}
		};

		/*local ws_getBrothersMax = obj.getBrothersMax;
		obj.getBrothersMax = function()
		{
			if (this.World.Flags.has("RosterTier"))
			{
				return this.Const.Roster.getSizeForTier(this.World.Flags.getAsInt("RosterTier"));
			}
			
			return ws_getBrothersMax();
		}

		local ws_getBrothersMaxInCombat = obj.getBrothersMaxInCombat;
		obj.getBrothersMaxInCombat = function()
		{
			if (this.World.Flags.has("RosterTier"))
			{
				return this.Const.Roster.getInCombatSizeForTier(this.World.Flags.getAsInt("RosterTier"));
			}

			return ws_getBrothersMaxInCombat();
		}*/
	});

	delete ::Woditor.hookAssetsManager;
}