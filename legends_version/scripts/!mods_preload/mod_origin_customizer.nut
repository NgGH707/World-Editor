local version = 2.0.0;
this.getroottable().OriginCustomizerVersion <- version;
::mods_registerMod("mod_origin_customizer_legends", version, "NgGH's Hard Work");
::mods_registerJS("origin_customizer_screen.js");
::mods_registerCSS("origin_customizer_screen.css");
::mods_queue("mod_origin_customizer_legends", "mod_legends", function()
{	
	::mods_hookNewObjectOnce("states/world_state", function( obj ) 
	{
		local init_ui = ::mods_getMember(obj, "onInitUI");
		obj.onInitUI = function()
		{
			init_ui();
			this.m.OriginCustomizerScreen <- this.new("scripts/ui/screens/origin_customizer_screen");
			this.m.OriginCustomizerScreen.setOnClosePressedListener(this.town_screen_main_dialog_module_onLeaveButtonClicked.bindenv(this));
			this.initLoadingScreenHandler();
		}

		local destroy_ui = ::mods_getMember(obj, "onDestroyUI");
		obj.onDestroyUI = function()
		{
			destroy_ui();
			this.m.OriginCustomizerScreen.destroy();
			this.m.OriginCustomizerScreen = null;
		}

		obj.showOriginCustomizerScreen <- function()
		{
			if (!this.m.OriginCustomizerScreen.isVisible() && !this.m.OriginCustomizerScreen.isAnimating())
			{
				this.m.CustomZoom = this.World.getCamera().Zoom;
				this.World.getCamera().zoomTo(1.0, 4.0);
				this.World.Assets.updateFormation();
				this.setAutoPause(true);
				this.m.OriginCustomizerScreen.show();
				this.m.WorldScreen.hide();
				this.Cursor.setCursor(this.Const.UI.Cursor.Hand);
				this.m.MenuStack.push(function ()
				{
					this.World.getCamera().zoomTo(this.m.CustomZoom, 4.0);
					this.m.OriginCustomizerScreen.hide();
					this.m.WorldScreen.show();
					this.World.Assets.refillAmmo();
					this.updateTopbarAssets();
					this.setAutoPause(false);
				}, function ()
				{
					return !this.m.OriginCustomizerScreen.isAnimating();
				});
			}
		}

		obj.toggleOriginCustomizerScreen <- function()
		{
			if (this.m.OriginCustomizerScreen.isVisible())
			{
				this.m.MenuStack.pop();
			}
			else
			{
				this.showOriginCustomizerScreen();
			}
		}

		local keyHandler = ::mods_getMember(obj, "helper_handleContextualKeyInput");
		obj.helper_handleContextualKeyInput = function(key)
		{
			if(!keyHandler(key) && key.getState() == 0)
			{
				if (key.getModifier() == 2 && key.getKey() == 38)//CTRL + Tab
				{
					if (!this.m.CharacterScreen.isVisible() && !this.m.WorldTownScreen.isVisible() && !this.m.EventScreen.isVisible() && !this.m.EventScreen.isAnimating())
					{
						this.toggleOriginCustomizerScreen();
						return true;
					}
				}
			}
		}
	});

	::mods_hookNewObjectOnce("states/world/asset_manager", function ( obj )
	{
		obj.getBaseAssets <- function()
		{
			this.resetToDefaults();

			if (this.World.Flags.has("UsedOriginCustomizer"))
			{
				local mult = [
					"XPMult",
					"DailyWageMult",
					"HiringCostMult",
					"SellPriceMult",
					"BuyPriceMult",
					"ContractPaymentMult",
					"VisionRadiusMult",
					"HitpointsPerHourMult",
					"RepairSpeedMult",
					"BusinessReputationRate",
					"NegotiationAnnoyanceMult",
				];
				local add = [
					"ExtraLootChance",
					"ChampionChanceAdditional"
				];

				foreach ( key in mult )
				{
					local value = this.World.Flags.getAsFloat(key);

					if (this.World.Flags.has(key))
					{
						local value = this.World.Flags.getAsFloat(key);
						this.m[key] *= value;
					}
				}

				foreach ( key in add )
				{
					local value = this.World.Flags.getAsInt(key);

					if (value != 0)
					{
						this.m[key] += value;
					}
				}

				if (this.World.Flags.has("RosterSizeAdditionalMin"))
				{
					this.m.RosterSizeAdditionalMin += this.World.Flags.getAsInt("RosterSizeAdditionalMin");
					this.m.RosterSizeAdditionalMax += this.World.Flags.getAsInt("RosterSizeAdditionalMin");
				}

				if (this.World.State.getPlayer() != null && this.World.Flags.has("BaseMovementSpeed"))
				{
					this.World.State.getPlayer().m.BaseMovementSpeed = this.World.Flags.getAsInt("BaseMovementSpeed");
				}
			}

			return {
				XPMult = this.m.XPMult,
				DailyWageMult = this.m.DailyWageMult,
				HiringCostMult = this.m.HiringCostMult,
				SellPriceMult = this.m.SellPriceMult,
				BuyPriceMult = this.m.BuyPriceMult,
				ExtraLootChance = this.m.ExtraLootChance,
				ChampionChanceAdditional = this.m.ChampionChanceAdditional,
				ContractPaymentMult = this.m.ContractPaymentMult,
				VisionRadiusMult = this.m.VisionRadiusMult,
				HitpointsPerHourMult = this.m.HitpointsPerHourMult,
				RepairSpeedMult = this.m.RepairSpeedMult,
				BusinessReputationRate = this.m.BusinessReputationRate,
				NegotiationAnnoyanceMult = this.m.NegotiationAnnoyanceMult,
				RosterSizeAdditionalMin = this.Math.min(this.m.RosterSizeAdditionalMin, this.m.RosterSizeAdditionalMax),
				/*FoodConsumptionMult = this.m.FoodConsumptionMult,
				TaxidermistPriceMult = this.m.TaxidermistPriceMult,
				TrainingPriceMult = this.m.TrainingPriceMult,
				TryoutPriceMult = this.m.TryoutPriceMult,
				RelationDecayGoodMult = this.m.RelationDecayGoodMult,
				RelationDecayBadMult = this.m.RelationDecayBadMult,
				AdvancePaymentCap = this.m.AdvancePaymentCap,*/
			};
		}
	});

	::mods_hookNewObject("retinue/retinue_manager", function( obj ) 
	{
		local onDeserialize = ::mods_getMember(obj, "onDeserialize");
		obj.onDeserialize = function( _in )
		{
			onDeserialize(_in);
			this.World.State.updateTopbarAssets();
		}

		local update = ::mods_getMember(obj, "update");
		obj.update = function()
		{
			update();

			if (this.World.Flags.has("UsedOriginCustomizer"))
			{
				local mult = [
					"XPMult",
					"DailyWageMult",
					"HiringCostMult",
					"SellPriceMult",
					"BuyPriceMult",
					"ContractPaymentMult",
					"VisionRadiusMult",
					"HitpointsPerHourMult",
					"RepairSpeedMult",
					"BusinessReputationRate",
					"NegotiationAnnoyanceMult",
				];
				local add = [
					"ExtraLootChance",
					"ChampionChanceAdditional"
				];

				foreach ( key in mult )
				{
					if (this.World.Flags.has(key))
					{
						local value = this.World.Flags.getAsFloat(key);
						this.World.Assets.m[key] *= value;
					}
				}

				foreach ( key in add )
				{
					local value = this.World.Flags.getAsInt(key);

					if (value != 0)
					{
						this.World.Assets.m[key] += value;
					}
				}

				if (this.World.Flags.has("RosterSizeAdditionalMin"))
				{
					this.World.Assets.m.RosterSizeAdditionalMin += this.World.Flags.getAsInt("RosterSizeAdditionalMin");
					this.World.Assets.m.RosterSizeAdditionalMax += this.World.Flags.getAsInt("RosterSizeAdditionalMin");
				}

				if (this.World.State.getPlayer() != null && this.World.Flags.has("BaseMovementSpeed"))
				{
					this.World.State.getPlayer().m.BaseMovementSpeed = this.World.Flags.getAsInt("BaseMovementSpeed");
				}
			}
		}
	});

	::mods_hookBaseClass("scenarios/world/starting_scenario", function(obj) 
	{
	    obj = obj[obj.SuperName];

	    obj.getRosterTier = function()
		{
			if (this.World.Flags.has("RosterTier"))
			{
				return this.World.Flags.getAsInt("RosterTier");
			}

			return this.m.RosterTier;
		}
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

	::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function( obj ) 
	{
	 	local queryTooltipData = ::mods_getMember(obj, "general_queryUIElementTooltipData");
	 	obj.general_queryUIElementTooltipData = function(entityId, elementId, elementOwner)
	 	{
			local tooltip = queryTooltipData(entityId, elementId, elementOwner);
			if(tooltip != null) return tooltip;

			switch (elementId) 
			{
			case "customeorigin.tier":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Roster Tier"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting your company roster size and the amount of brother you can bring in battle, this tier has a different value between different origin."
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 0: [color=" + this.Const.UI.Color.NegativeValue + "]1[/color] brother"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 1: [color=" + this.Const.UI.Color.NegativeValue + "]6[/color] brothers"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 2: [color=" + this.Const.UI.Color.NegativeValue + "]9[/color] brothers"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 3: [color=" + this.Const.UI.Color.NegativeValue + "]13[/color] brothers and [color=" + this.Const.UI.Color.NegativeValue + "]12[/color] in battle"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 4: [color=" + this.Const.UI.Color.NegativeValue + "]19[/color] brothers and [color=" + this.Const.UI.Color.NegativeValue + "]16[/color] in battle"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 5: [color=" + this.Const.UI.Color.NegativeValue + "]21[/color] brothers and [color=" + this.Const.UI.Color.NegativeValue + "]18[/color] in battle"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier 6: [color=" + this.Const.UI.Color.NegativeValue + "]27[/color] brothers and [color=" + this.Const.UI.Color.NegativeValue + "]25[/color] in battle"
					},
				];

		    case "customeorigin.xp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Company XP"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the xp of all brothers. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];
			
		    case "customeorigin.hiring":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Hiring Cost"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the cost to hiring new brother in towns, cities. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.wage":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Daily Wage"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the daily wage of all brothers. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.selling":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Selling Price"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the amount of money you get when selling item to the market. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.buying":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Buying Price"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the price of items in shops, marets. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.loot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Chance To Gain Bonus Loot"
					},
					{
						id = 2,
						type = "description",
						text = "The chance to get an additional loot from beast-type enemy. The default value is 0 which means 0%. The value is calculated in percentage."
					},
				];

			case "customeorigin.champion":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Bonus Chance To Spawn Champion"
					},
					{
						id = 2,
						type = "description",
						text = "The additional chance to turn an enemy into a champion. If you bring this value to 100, you will always find champion enemies in roaming party. If you bring this value to 200, all champion-able enemy will turn into a champion even in a 1 skull contract. The base value is 0 which means 0%.  The value is calculated in percentage."
					},
				];

			case "customeorigin.speed":
		       	return [
					{
						id = 1,
						type = "title",
						text = "World Map Movement Speed"
					},
					{
						id = 2,
						type = "description",
						text = "The base speed of your company on world map without any modifier from background and terrain. The default value is 105."
					},
				];

			case "customeorigin.contractpayment":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Contract Payment"
					},
					{
						id = 2,
						type = "description",
						text = "Affect the reward money of a contract. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.vision":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Vision Radius"
					},
					{
						id = 2,
						type = "description",
						text = "Determine how far your vision allows you to see. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.hp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Hitpoints Recovery Speed"
					},
					{
						id = 2,
						type = "description",
						text = "Determine how fast or slow your injured brothers restore their hitpoints. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.repair":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Repair Speed"
					},
					{
						id = 2,
						type = "description",
						text = "Determine how far your vision allows you to see. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.renown":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Renown"
					},
					{
						id = 2,
						type = "description",
						text = "Determine how much renow you gain or lost. The higher the percentage, the more renown you gain while also causes you to lost more renown when it happens. The default value is 100 which means 100%."
					},
				];

			case "customeorigin.negotiation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Negotiation Annoyance"
					},
					{
						id = 2,
						type = "description",
						text = "Affecting the chance to ask for advance payment, negotiate for higer payment. The higher this percentage the more likely you will fail the negotiate. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.recruit":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Additional Recruit"
					},
					{
						id = 2,
						type = "description",
						text = "Increase the amount of recruit in a town, village, city, ect. The number of this value is equal to number of bonus recruit in towns, villages. The default value is 0 which means no additional recruit to total recruit after the town resets its recruit roster."
					},
				];

			case "customeorigin.accept_banner":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Select This Banner"
					},
					{
						id = 2,
						type = "description",
						text = "Confirm your choice of changing to this banner."
					},
				];

			case "customeorigin.choose_origin":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Change Origin"
					},
					{
						id = 2,
						type = "description",
						text = "Bring you to Origin Selection Menu where you can change your origin."
					},
					{
						id = 7,
						type = "text",
						icon = "ui/tooltips/warning.png",
						text = "Do not change to an origin requires a [color=" + this.Const.UI.Color.NegativeValue + "]Player Character[/color] while your current roster does not have a 'Player Character' brother."
					},
				];
			}
			
			return null;
		}
	});

})
