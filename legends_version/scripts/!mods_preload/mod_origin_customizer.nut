local version = 2.1.1;
this.getroottable().OriginCustomizerVersion <- version;
::mods_registerMod("mod_origin_customizer_legends", version, "NgGH's Hard Work");
::mods_registerJS("origin_customizer_screen.js");
::mods_registerCSS("origin_customizer_screen.css");
::mods_queue("mod_origin_customizer_legends", "mod_legends,>mod_nggh_assets", function()
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
		local updateLook = obj.updateLook;
		obj.updateLook = function( _updateTo = -1 )
		{
			if (this.World.Flags.has("AvatarSprite"))
			{
				if (this.World.State.getPlayer() != null)
				{
					local player = this.World.State.getPlayer();
					local body = this.World.Flags.get("AvatarSprite");
					local socket = this.World.Flags.get("AvatarSocket");
					local flip = this.World.Flags.get("AvatarIsFlippedHorizontally");
					player.getSprite("body").setBrush(body);
					player.getSprite("body").setHorizontalFlipping(flip);
					player.getSprite("base").setBrush(socket);
					player.getSprite("base").setHorizontalFlipping(flip);
					return;
				}
			}

			updateLook(_updateTo);
		}

		local reset = obj.resetToDefaults;
		obj.resetToDefaults = function()
		{
			reset();

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
					"TaxidermistPriceMult",
					"TryoutPriceMult",
					"RelationDecayGoodMult",
					"RelationDecayBadMult",
					"TrainingPriceMult",
				];
				local add = [
					"ExtraLootChance",
					"ChampionChanceAdditional",
					"RosterSizeAdditionalMin",
					"RosterSizeAdditionalMax",
					"FoodAdditionalDays",
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

				if (this.World.Flags.has("RosterTier"))
				{
					this.getOrigin().m.RosterTier = this.World.Flags.getAsInt("RosterTier");
				}

				if (this.World.Flags.has("BrothersScaleMax"))
				{
					this.m.BrothersScaleMax = this.World.Flags.getAsInt("BrothersScaleMax");
				}

				if (this.World.State.getPlayer() != null && this.World.Flags.has("BaseMovementSpeed"))
				{
					this.World.State.getPlayer().m.BaseMovementSpeed = this.World.Flags.getAsInt("BaseMovementSpeed");
				}
			}
		}

		obj.getBaseAssets <- function()
		{
			this.resetToDefaults();

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
				RosterSizeAdditionalMin = this.m.RosterSizeAdditionalMin,
				RosterSizeAdditionalMax = this.m.RosterSizeAdditionalMax
				TaxidermistPriceMult = this.m.TaxidermistPriceMult,
				TryoutPriceMult = this.m.TryoutPriceMult,
				RelationDecayGoodMult = this.m.RelationDecayGoodMult,
				RelationDecayBadMult = this.m.RelationDecayBadMult,
				BrothersScaleMax = this.getBrothersScaleMax(),
				FoodAdditionalDays = this.m.FoodAdditionalDays,
				TrainingPriceMult = this.m.TrainingPriceMult,

				/*FoodConsumptionMult = this.m.FoodConsumptionMult,
				AdvancePaymentCap = this.m.AdvancePaymentCap,*/
			};
		}
	});

	::mods_hookExactClass("entity/world/player_party", function( obj )
	{
		local wc_getStrength = ::mods_getMember(obj, "getStrength");
		obj.getStrength = function()
		{
			this.m.Strength = wc_getStrength();

			if (this.World.Flags.has("PartyStrengthMult"))
			{
				local value = this.World.Flags.getAsFloat("PartyStrengthMult");
				this.m.Strength *= value;
			}

			return this.m.Strength;
		}
	});

	::mods_hookBaseClass("scenarios/world/starting_scenario", function( obj )
	{
		obj = obj[obj.SuperName];
		obj.isDroppedAsLoot = function( _item )
		{
			return this.Math.rand(1, 100) <= this.World.Flags.getAsInt("EquipmentLootChance");
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

	::mods_hookNewObject("retinue/retinue_manager", function( obj )
	{
		local onDeserialize = ::mods_getMember(obj, "onDeserialize");
		obj.onDeserialize = function( _in )
		{
			onDeserialize(_in);
			this.World.State.updateTopbarAssets();
		}
	});

	::mods_hookNewObject("retinue/followers/bounty_hunter_follower", function( obj ) 
	{
		obj.onUpdate = function()
		{
			if ("ChampionChanceAdditional" in this.World.Assets.m)
			{
				this.World.Assets.m.ChampionChanceAdditional += 3;
			}
		}
	});
	::mods_hookNewObject("retinue/followers/cook_follower", function( obj ) 
	{
		obj.onUpdate = function()
		{
			if ("FoodAdditionalDays" in this.World.Assets.m)
			{
				this.World.Assets.m.FoodAdditionalDays += 3;
			}

			if ("HitpointsPerHourMult" in this.World.Assets.m)
			{
				this.World.Assets.m.HitpointsPerHourMult *= 1.33;
			}
		}
	});
	::mods_hookNewObject("retinue/followers/lookout_follower", function( obj ) 
	{
		obj.onUpdate = function()
		{
			if ("VisionRadiusMult" in this.World.Assets.m)
			{
				this.World.Assets.m.VisionRadiusMult *= 1.25;
			}

			if ("IsShowingExtendedFootprints" in this.World.Assets.m)
			{
				this.World.Assets.m.IsShowingExtendedFootprints = true;
			}
		}
	});
	::mods_hookNewObject("retinue/followers/negotiator_follower", function( obj ) 
	{
		obj.onUpdate = function()
		{
			if ("NegotiationAnnoyanceMult" in this.World.Assets.m)
			{
				this.World.Assets.m.NegotiationAnnoyanceMult *= 0.5;
			}

			if ("AdvancePaymentCap" in this.World.Assets.m)
			{
				this.World.Assets.m.AdvancePaymentCap += 0.25;
			}

			if ("RelationDecayGoodMult" in this.World.Assets.m)
			{
				if (this.World.Assets.getOrigin().getID() == "scenario.sato_escaped_slaves")
				{
					this.World.Assets.m.RelationDecayGoodMult *= 1.05;
				}
				else
				{
					this.World.Assets.m.RelationDecayGoodMult *= 0.9;
				}
			}

			if ("RelationDecayBadMult" in this.World.Assets.m)
			{
				if (this.World.Assets.getOrigin().getID() == "scenario.sato_escaped_slaves")
				{
					this.World.Assets.m.RelationDecayBadMult *= 0.95;
				}
				else
				{
					this.World.Assets.m.RelationDecayBadMult *= 1.1;
				}
			}
		}
	});
	::mods_hookNewObject("retinue/followers/quartermaster_follower", function( obj ) 
	{
		obj.onUpdate = function()
		{
			if ("AmmoMaxAdditional" in this.World.Assets.m)
			{
				this.World.Assets.m.AmmoMaxAdditional += 100;
			}

			if ("MedicineMaxAdditional" in this.World.Assets.m)
			{
				this.World.Assets.m.MedicineMaxAdditional += 50;
			}

			if ("ArmorPartsMaxAdditional" in this.World.Assets.m)
			{
				this.World.Assets.m.ArmorPartsMaxAdditional += 50;
			}
		}
	});

	::mods_hookNewObject("ui/screens/world/modules/world_town_screen/town_training_dialog_module", function( obj ) 
	{
		obj.queryRosterInformation = function()
		{
			local settlement = this.World.State.getCurrentTown();
			local brothers = this.World.getPlayerRoster().getAll();
			local roster = [];
			local mult = this.World.Assets.m.TrainingPriceMult;

			foreach( b in brothers )
			{
				if (b.getLevel() >= 11)
				{
					continue;
				}

				if (b.getLevel() >= 7 && this.World.Assets.getOrigin().getID() == "scenario.manhunters" && b.getBackground().getID() == "background.slave")
				{
					continue;
				}

				if (b.getSkills().hasSkill("effects.trained"))
				{
					continue;
				}

				local background = b.getBackground();
				local e = {
					ID = b.getID(),
					Name = b.getName(),
					Level = b.getLevel(),
					ImagePath = b.getImagePath(),
					ImageOffsetX = b.getImageOffsetX(),
					ImageOffsetY = b.getImageOffsetY(),
					BackgroundImagePath = background.getIconColored(),
					BackgroundText = background.getDescription(),
					Training = [],
					Effects = []
				};
				e.Training.push({
					id = 0,
					icon = "skills/status_effect_75.png",
					name = "Sparring Fight",
					tooltip = "world-town-screen.training-dialog-module.Train1",
					price = this.Math.round((80 + 50 * b.getLevel()) * mult)
				});
				e.Training.push({
					id = 1,
					icon = "skills/status_effect_76.png",
					name = "Veteran\'s Lessons",
					tooltip = "world-town-screen.training-dialog-module.Train2",
					price = this.Math.round((100 + 60 * b.getLevel()) * mult)
				});
				e.Training.push({
					id = 2,
					icon = "skills/status_effect_77.png",
					name = "Rigorous Schooling",
					tooltip = "world-town-screen.training-dialog-module.Train3",
					price = this.Math.round((90 + 55 * b.getLevel()) * mult)
				});
				roster.push(e);
			}

			return {
				Title = "Training Hall",
				SubTitle = "Have your company train for combat and learn from veterans",
				Roster = roster,
				Assets = this.m.Parent.queryAssetsInformation()
			};
		}

		obj.onTrain = function( _data )
		{
			local entityID = _data[0];
			local trainingID = _data[1];
			local settlement = this.World.State.getCurrentTown();
			local entity = this.Tactical.getEntityByID(entityID);

			if (entity.getSkills().hasSkill("effects.trained"))
			{
				return null;
			}

			local price = 0;
			local mult = this.World.Assets.m.TrainingPriceMult;
			local effect = this.new("scripts/skills/effects_world/new_trained_effect");

			switch(trainingID)
			{
			case 0:
				price = this.Math.round((80 + 50 * entity.getLevel()) * mult);
				effect.m.Duration = 1;
				effect.m.XPGainMult = 1.5;
				effect.m.Icon = "skills/status_effect_75.png";
				break;

			case 1:
				price = this.Math.round((100 + 60 * entity.getLevel()) * mult);
				effect.m.Duration = 3;
				effect.m.XPGainMult = 1.35;
				effect.m.Icon = "skills/status_effect_76.png";
				break;

			case 2:
				price = this.Math.round((90 + 55 * entity.getLevel()) * mult);
				effect.m.Duration = 5;
				effect.m.XPGainMult = 1.2;
				effect.m.Icon = "skills/status_effect_77.png";
				break;
			}

			this.World.Assets.addMoney(-price);
			entity.getSkills().add(effect);
			local background = entity.getBackground();
			local e = {
				ID = entity.getID(),
				Name = entity.getName(),
				Level = entity.getLevel(),
				ImagePath = entity.getImagePath(),
				ImageOffsetX = entity.getImageOffsetX(),
				ImageOffsetY = entity.getImageOffsetY(),
				BackgroundImagePath = background.getIconColored(),
				BackgroundText = background.getDescription(),
				Training = [],
				Effects = []
			};
			e.Effects.push({
				id = effect.getID(),
				icon = effect.getIcon()
			});
			local r = {
				Entity = e,
				Assets = this.m.Parent.queryAssetsInformation()
			};
			return r;
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

			case "customeorigin.avatarbutton":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Change Avatar Sprite"
					},
					{
						id = 2,
						type = "description",
						text = "Let you change your world map avatar sprite to the one you want."
					},
				];

			case "customeorigin.scaling":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Difficulty Scaling Percentage"
					},
					{
						id = 2,
						type = "description",
						text = "Party strength value is used as a standard to determine the number of troops/defenders in roaming party or in camp. This percentage is used to modify your party strength so it\'s indirectly change the difficult scaling. Thus, every percentage that is higher than 100 will make the game harder (more enemies) while lowering it will make the game easier (fewer enemies). This is a different value that\'s independent from combat difficulty. The default value is 100 which means 100%."
					},
				];

			case "customeorigin.equipmentloot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Bonus Chance To Loot Equipment"
					},
					{
						id = 2,
						type = "description",
						text = "Bonus chance to the existing chance to loot enemy equipment (armors, weapon, quiver, etc). The chance to loot an equipment of an enemy is based on the durability of said item. With this chance value reaches 100%, you are guaranteed to loot enemy equipment. The default value is 0 which means 0%."
					},
				];

		    case "customeorigin.xp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "XP Gained"
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
						text = "The chance to get an additional loot from [color=" + this.Const.UI.Color.NegativeValue + "]beast-type[/color] enemy, this value don\'t affect the chance to loot equipment from enemy. The default value is 0 which means 0%. The value is calculated in percentage."
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
						text = "Renown Gained"
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

			case "customeorigin.recruitmin":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Minimum Recruit"
					},
					{
						id = 2,
						type = "description",
						text = "The minimum amount of bonus recruit in a town, village, city, ect. The number of this value is equal to number of bonus recruit in towns, villages. The default value is 0 which means no additional recruit to total recruit after the town resets its recruit roster."
					},
				];

			case "customeorigin.recruitmax":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Maximum Recruit"
					},
					{
						id = 2,
						type = "description",
						text = "The maximun amount of bonus recruit in a town, village, city, ect. The number of this value is equal to number of bonus recruit in towns, villages. The default value is 0 which means no additional recruit to total recruit after the town resets its recruit roster."
					},
				];

			case "customeorigin.craft":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Taxidermist Cost"
					},
					{
						id = 2,
						type = "description",
						text = "Affect how much money you pay Taxidermist to craft an item. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.tryout":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Tryout Price"
					},
					{
						id = 2,
						type = "description",
						text = "Affect how much money you pay to tryout a recruit. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.badrelation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Relation Decay Speed"
					},
					{
						id = 2,
						type = "description",
						text = "Affect how slow or fast allied/friendly factions return to neutral relation with player. The higher the number the faster the decay speed. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.goodrelation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Relation Recovery Speed"
					},
					{
						id = 2,
						type = "description",
						text = "Affect how slow or fast hostile/unfriendly factions return to neutral relation with player. The higher the number the faster the recovery speed. The default value is 100 which means 100%. The value is calculated in percentage."
					},
				];

			case "customeorigin.brothersscale":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Maximum Brothers For Scaling Difficulty"
					},
					{
						id = 2,
						type = "description",
						text = "This value determine how many brothers are taken in calculating party strength, from party strength the game will use it as standard to spawn enemy. If you have 25 brothers in roster while this value is 12, that means at most only 12 highest level brothers are taken in calculating party strength."
					},
				];

			case "customeorigin.fooddays":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Extra Expiration Date For Food"
					},
					{
						id = 2,
						type = "description",
						text = "Increase or decrease the expiration date of food items. The higher the number the longer time for food to spoil. The default value is 0. The value is in days unit."
					},
				];

			case "customeorigin.trainingprice":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Training Price"
					},
					{
						id = 2,
						type = "description",
						text = "Affect the cost to train a brother in Training Hall building. The default value is 100 which means 100%. The value is calculated in percentage."
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

			case "customeorigin.calculate":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Calculate Party Strength"
					},
					{
						id = 2,
						type = "description",
						text = "Calculating your current party strength based on below settings then displays it on the box above. It also applies below settings without the need to press 'Done' button. Below is the list of what setting affects party strength."
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/plus.png",
						text = "Combat Difficulty"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/plus.png",
						text = "Difficulty Scaling"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/plus.png",
						text = "Maximum Brothers Scaling"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/plus.png",
						text = "Equipment Scaling"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/plus.png",
						text = "Distance Scaling"
					},
				];

			case "customeorigin.partystrength":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Party Strength"
					},
					{
						id = 2,
						type = "description",
						text = "This is the value that determine the difficulty. Combat Difficulty determines the equation to calculate party strength while Difficulty Scaling affect the final result of said equation. The higher you party strength the more enemies you can found."
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Affect the number of roaming party troops"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Affect the number of defenders in a camp"
					},
					{
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Affect possibility to spawn strong enemy"
					},
				];
			}
			
			return null;
		}
	});
	
	local gt = this.getroottable();
	gt.Const.WorldSprites <- [];
	gt.Const.WorldSockets <- [
		"world_base_01",
		"world_base_02",
		"world_base_03",
		"world_base_05",
		"world_base_07",
		"world_base_08",
		"world_base_09",
		"world_base_10",
		"world_base_11",
		"world_base_12",
		"world_base_13",
		"world_base_14",
	];
	gt.Const.WorldSpritesNames <- [
		"Player",
		"Civilian",
		"Noble",
		"Raider",
		"Southern",
		"Undead",
		"Greenskin",
		"Misc"
	];
	gt.Const.WorldSprites.push([
		"figure_player_01",
		"figure_player_02",
		"figure_player_03",
		"figure_player_04",
		"figure_player_05",
		"figure_player_06",
		"figure_player_07",
		"figure_player_08",
		"figure_player_09",
		"figure_player_10",
		"figure_player_11",
		"figure_player_12",
		"figure_player_13",
		"figure_player_14",
		"figure_player_15",
		"figure_player_16",
		"figure_player_17",
		"figure_player_18",
	]);

	if (::mods_getRegisteredMod("mod_nggh_magic_concept") != null)
	{
		gt.Const.WorldSprites[0].extend([
			"figure_player_9991",
			"figure_player_9992",
			"figure_player_9993",
			"figure_player_9994",
			"figure_player_9995",
			"figure_player_9996",
			"figure_player_9997",
			"figure_player_9998",
			"figure_player_9999",
		]);
	}

	gt.Const.WorldSprites.push([
		"figure_civilian_01",
		"figure_civilian_02",
		"figure_civilian_03",
		"figure_civilian_04",
		"figure_civilian_05",
		"figure_civilian_06",
		"figure_mercenary_01",
		"figure_mercenary_02",
		"figure_militia_01",
		"figure_militia_02",
	]);
	gt.Const.WorldSprites.push([
		"figure_noble_01",
		"figure_noble_02",
		"figure_noble_03",
		"figure_noble_01_01",
		"figure_noble_01_02",
		"figure_noble_01_03",
		"figure_noble_01_04",
		"figure_noble_01_05",
		"figure_noble_01_06",
		"figure_noble_01_07",
		"figure_noble_01_08",
		"figure_noble_01_09",
		"figure_noble_01_10",
		"figure_noble_02_01",
		"figure_noble_02_02",
		"figure_noble_02_03",
		"figure_noble_02_04",
		"figure_noble_02_05",
		"figure_noble_02_06",
		"figure_noble_02_07",
		"figure_noble_02_08",
		"figure_noble_02_09",
		"figure_noble_02_10",
		"figure_noble_03_01",
		"figure_noble_03_02",
		"figure_noble_03_03",
		"figure_noble_03_04",
		"figure_noble_03_05",
		"figure_noble_03_06",
		"figure_noble_03_07",
		"figure_noble_03_08",
		"figure_noble_03_09",
		"figure_noble_03_10",
	]);
	gt.Const.WorldSprites.push([
		"figure_bandit_01",
		"figure_bandit_02",
		"figure_bandit_03",
		"figure_bandit_04",
		"figure_wildman_01",
		"figure_wildman_02",
		"figure_wildman_03",
		"figure_wildman_04",
	]);
	gt.Const.WorldSprites.push([
		"figure_refugee_01",
		"figure_refugee_02",
		"figure_slave_01",
		"figure_southern_01",
		"figure_southern_01_12",
		"figure_southern_01_13",
		"figure_southern_01_14",
		"figure_southern_02",
		"figure_nomad_01",
		"figure_nomad_02",
		"figure_nomad_03",
		"figure_nomad_04",
		"figure_nomad_05",
	]);
	gt.Const.WorldSprites.push([
		"figure_necromancer_01",
		"figure_necromancer_02",
		"figure_ghost_01",
		"figure_zombie_01",
		"figure_zombie_02",
		"figure_zombie_03",
		"figure_zombie_04",
		"figure_vampire_01",
		"figure_vampire_02",
		"figure_skeleton_01",
		"figure_skeleton_02",
		"figure_skeleton_03",
		"figure_skeleton_04",
	]);
	gt.Const.WorldSprites.push([
		"figure_goblin_01",
		"figure_goblin_02",
		"figure_goblin_03",
		"figure_goblin_04",
		"figure_goblin_05",
		"figure_orc_01",
		"figure_orc_02",
		"figure_orc_03",
		"figure_orc_04",
		"figure_orc_05",
		"figure_orc_06",
	]);
	gt.Const.WorldSprites.push([
		"figure_hexe_01",
		"figure_alp_01",
		"figure_ghoul_01",
		"figure_ghoul_02",
		"figure_golem_01",
		"figure_golem_02",
		"figure_hyena_01",
		"figure_kraken_01",
		"figure_lindwurm_01",
		"figure_schrat_01",
		"figure_serpent_01",
		"figure_spider_01",
		"figure_unhold_01",
		"figure_unhold_02",
		"figure_unhold_03",
		"figure_werewolf_01",
	]);
});
