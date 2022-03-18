local version = 3.0;
this.getroottable().OriginCustomizerVersion <- version;
::mods_registerMod("mod_origin_customizer_legends", version, "NgGH's Hard Work");

// register CSS
::mods_registerCSS("origin_customizer_controls.css");
::mods_registerCSS("origin_customizer_screen.css");
::mods_registerCSS("origin_customizer_factions.css");
::mods_registerCSS("origin_customizer_settlements.css");
::mods_registerCSS("origin_customizer_popup_dialogs.css");

// register JS
::mods_registerJS("origin_customizer_controls.js");
::mods_registerJS("origin_customizer_screen.js");
::mods_registerJS("origin_customizer_factions.js");
::mods_registerJS("origin_customizer_settlements.js");
::mods_registerJS("origin_customizer_popup_dialogs.js");

::mods_queue("mod_origin_customizer_legends", "mod_legends,>mod_nggh_assets", function()
{	
	local gt = this.getroottable();
	gt.Const.PercentageNoteString <- " The value is calculated in percentage. The default value is 100 which means 100%."
	gt.Const.AddContractHints <- function( _tooltips )
	{
		_tooltips.extend([
			{
				id = 10,
				type = "hint",
				icon = "ui/icons/mouse_left_button.png",
				text = "Open in \'Contracts\' tab"
			},
			{
				id = 11,
				type = "hint",
				icon = "ui/icons/mouse_left_button_ctrl.png",
				text = "Discard contract"
			}
		]);
	};

	::mods_hookNewObjectOnce("states/world_state", function( obj ) 
	{
		local init_ui = ::mods_getMember(obj, "onInitUI");
		obj.onInitUI = function()
		{
			init_ui();
			this.m.OriginCustomizerScreen <- this.new("scripts/ui/screens/mods/origin_customizer_screen");
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
				return false;
			}
			else
			{
				this.showOriginCustomizerScreen();
				return true;
			}
		}

		local keyHandler = ::mods_getMember(obj, "helper_handleContextualKeyInput");
		obj.helper_handleContextualKeyInput = function(key)
		{
			if(!keyHandler(key) && key.getState() == 0)
			{
				if (key.getModifier() == 2 && key.getKey() == 38) //CTRL + Tab
				{
					if (!this.m.CharacterScreen.isVisible() && !this.m.WorldTownScreen.isVisible() && !this.m.EventScreen.isVisible() && !this.m.EventScreen.isAnimating())
					{
						return this.toggleOriginCustomizerScreen();
					}
				}
			}
		}
	});
/*
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
					"BrothersScaleMax",
				];

				foreach ( key in mult )
				{
					if (this.World.Flags.has(key))
					{
						this.m[key] = this.World.Flags.getAsFloat(key);
					}
				}

				foreach ( key in add )
				{
					local value = this.World.Flags.getAsInt(key);

					if (value != 0)
					{
						this.m[key] = value;
					}
				}

				if (this.World.Flags.has("RosterTier"))
				{
					this.getOrigin().m.StartingRosterTier = this.World.Flags.getAsInt("RosterTier");

					if (this.getOrigin().m.StartingRosterTier > this.getOrigin().m.RosterTierMax)
					{
						this.getOrigin().m.RosterTierMax = this.getOrigin().m.StartingRosterTier;
					}
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

				FoodConsumptionMult = this.m.FoodConsumptionMult,
				AdvancePaymentCap = this.m.AdvancePaymentCap,
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
		};
		obj.getStashModifier = function()
		{
			if (this.World.Flags.has("StashModifier"))
			{
				return this.World.Flags.getAsInt("StashModifier");
			}

			return this.m.StashModifier;
		};
	});

	::mods_hookNewObject("contracts/contract_manager", function ( obj )
	{
		local ws_addContract = obj.addContract;
		obj.addContract = function( _contract, _isNewContract = true )
		{
			local keyName = "disable_" + _contract.getType();

		    if (this.World.Flags.get(keyName))
		    {
		    	return;
		   	}

			ws_addContract(_contract, _isNewContract);
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
		local ws_onNewDay = obj.onNewDay
		obj.onNewDay = function()
		{
			local hasMet = this.World.Flags.get("SpecialEvent_whatever");
			local condition = this.World.getTime().Days >= 150;

			if (!hasMet && condition)
			{
				local ritual = this.World.Events.fire("event.hexe_origin_ritual");
			
				if (ritual)
				{
					this.World.Flags.set("SpecialEvent_whatever", true);
				}
			}
		}


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
	});*/

	::mods_hookNewObject("contracts/contract_manager", function( obj ) 
	{
		obj.getContractsByID <- function( _id )
		{
			foreach( contract in this.m.Open )
			{
				if (contract.getID() == _id)
				{
					return contract;
				}
			}

			return null;
		}
	});

	::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function( obj ) 
	{
	 	local queryTooltipData = ::mods_getMember(obj, "general_queryUIElementTooltipData");
	 	obj.general_queryUIElementTooltipData = function(_entityId, _elementId, _elementOwner)
	 	{
	 		if (_elementOwner != null && _elementOwner == "origincustomizer.faction_contracts")
	 		{
	 			local contract = this.World.Contracts.getContractsByID(_elementId);

				if (contract == null)
				{
					return null;
				}
				else
				{
					local faction = this.World.FactionManager.getFaction(contract.getFaction());
					local ret = [
						{
							id = 1,
							type = "title",
							text = contract.getName()
						},
						{
							id = 2,
							type = "description",
							text = "The employer is [color=#0b0084]" + contract.getCharacter().getName() + "[/color] of [color=#0b0084]" + faction.getName() + "[/color]. Expires in [color=" + this.Const.UI.Color.NegativeValue + "]" + (this.Math.round(this.Math.abs(this.Time.getVirtualTimeF() - contract.m.TimeOut) / this.World.getTime().SecondsPerDay)) + "[/color] days."
						},
						{
							id = 3,
							type = "text",
							icon = "ui/icons/miniboss.png",
							text = "Difficulty Multiplier: [color=" + this.Const.UI.Color.NegativeValue + "]" + (this.Math.floor(contract.getDifficultyMult() * 100) / 100) + "[/color]"
						},
						{
							id = 4,
							type = "text",
							icon = "ui/icons/asset_money.png",
							text = "Payment Multiplier: [color=" + this.Const.UI.Color.NegativeValue + "]" + (this.Math.floor(contract.getPaymentMult() * 100) / 100) + "[/color]"
						},
					];
					this.Const.AddContractHints(ret);
					return ret;
				}
	 		}

			local tooltip = queryTooltipData(_entityId, _elementId, _elementOwner);
			if(tooltip != null) return tooltip;

			switch (_elementId) 
			{
			case "origincustomizer.rostertier":
		       	local ret = [
					{
						id = 1,
						type = "title",
						text = "Starting Roster Tier"
					},
					{
						id = 2,
						type = "description",
						text = "Determines your company default roster tier without considering the bonus tier from reputation, affects the size of your roster and how many brothers can be brought in battle, this tier may have different values in different origins."
					},
				];
				foreach ( tier in this.Const.Roster.Tier )
				{
					ret.push({
						id = 7,
						type = "text",
						icon = "ui/icons/special.png",
						text = "Tier " + tier + ": [color=" + this.Const.UI.Color.NegativeValue + "]" + this.Const.Roster.Size[tier] + "[/color] brother(s) and [color=" + this.Const.UI.Color.NegativeValue + "]" + this.Const.Roster.InCombatSize[tier] + "[/color] brother(s) in battle"
					});
				}
				return ret;

			case "origincustomizer.difficultymult":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Difficulty Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Company strength value is used as a standard to determine the number of troops/defenders in roaming party or in camp. This percentage is used to modify your Company strength so it\'s indirectly change the difficult scaling. Thus, every percentage that is higher than 100 will make the game harder (more enemies) while lowering it will make the game easier (fewer enemies). This is a different value that\'s independent from combat difficulty. The default value is 100 which means 100%."
					},
				];

			case "origincustomizer.equipmentloot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Bonus Chance To Loot Equipment"
					},
					{
						id = 2,
						type = "description",
						text = "Bonus chance to the existing chance to loot enemy equipment (armors, weapon, quiver, etc). The chance to loot an equipment of an enemy is based on the durability of said item. With this chance value reaches 100, you are guaranteed to loot enemy equipment. The default value is 0 which means 0%."
					},
				];

		    case "origincustomizer.xp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Gained XP Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the gained xp of all brothers." + this.Const.PercentageNoteString
					},
				];
			
		    case "origincustomizer.hiring":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Hiring Cost Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the cost to hiring new brothers." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.wage":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Daily Wage Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the daily wage of all brothers." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.selling":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Selling Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the amount of money you get when selling any item." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.buying":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Buying Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the price of all items in shops, markets." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.selling_trade":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Trade Goods Selling Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the amount of money you get when selling any trade goods (e.g. silk, dye, etc)." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.buying_trade":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Trade Goods Buying Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the price of all trade goods (e.g. silk, dye, etc) in shops, markets." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.loot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Chance To Gain Bonus Loot"
					},
					{
						id = 2,
						type = "description",
						text = "The chance to get an additional loot from [color=" + this.Const.UI.Color.NegativeValue + "]beast-type[/color] enemy, this value don\'t affect the chance to loot equipment from enemy. The value is calculated in percentage. The default value is 0 which means 0%."
					},
				];

			case "origincustomizer.champion":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Bonus Chance To Spawn Champion"
					},
					{
						id = 2,
						type = "description",
						text = "The additional chance to turn a champion-able enemy into a champion. If you bring this value to 100, you will always find champion enemies in roaming party. If you bring this value to 200, all champion-able enemy will turn into a champion even in a 1 skull contract. The value is calculated in percentage. The default value is 0 which means 0%."
					},
				];

			case "origincustomizer.speed":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Movement Speed Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the speed of your company on world map without considering any modifier from background or terrain." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.contractpayment":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Contract Payment Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the payment by completing a contract." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.vision":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Vision Radius Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects wide the your vision radius on world map." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.hp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Hitpoints Recovery Speed Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects how fast or slow your injured brothers restore their hitpoints. Does not affect the speed to recover from a status effect injury." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.repair":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Repair Speed Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the speed of repairing your equipment." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.renown":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Renown Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the amount of gained renown or loss renown." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.negotiation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Negotiation Annoyance Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the successful chance to ask for advance payment, negotiate for higher payment. The higher this percentage the more likely you will fail to negotiate." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.recruitmin":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Minimum Additional Recruit"
					},
					{
						id = 2,
						type = "description",
						text = "The minimum number of bonus recruit added to the default number recruit when the town/city/village reset its recruit roster. The higher the number the more recruits can be found in any town. The bonus recruit is a randomly chosen number between the Minimum Additional Recruit and Maximum Additional Recruit."
					},
				];

			case "origincustomizer.recruitmax":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Maximum Additional Recruit"
					},
					{
						id = 2,
						type = "description",
						text = "The maximum number of bonus recruit added to the default number recruit when the town/city/village reset its recruit roster. The higher the number the more recruits can be found in any town. The bonus recruit is a randomly chosen number between the Minimum Additional Recruit and Maximum Additional Recruit"
					},
				];

			case "origincustomizer.craft":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Taxidermist Cost Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the cost to craft an item in Taxidermist." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.tryout":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Tryout Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the fee to tryout a recruit." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.goodrelation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Relation Decay Speed Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects how slow or fast a good relation return to neutral relation. The higher the number the faster the decay speed." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.badrelation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Relation Recovery Speed Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affect how slow or fast a bad relation return to neutral relation. The higher the number the faster the recovery speed." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.brotherscalemax":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Maximum Brothers For Scaling Difficulty"
					},
					{
						id = 2,
						type = "description",
						text = "This value determines the maximum number of brothers are taken to scale difficulty. The default value is your maximum number of brother in battle."
					},
				];

			case "origincustomizer.brotherscalemin":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Minimum Brothers For Scaling Difficulty"
					},
					{
						id = 2,
						type = "description",
						text = "This value determines the minimum number of brothers are taken to scale difficulty."
					},
				];

			case "origincustomizer.fooddays":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Extra Expiration Date"
					},
					{
						id = 2,
						type = "description",
						text = "Increases or decreases the expiration date of food items. The higher the number the longer for your food to spoil. The default value is 0. The value is count in day."
					},
				];

			case "origincustomizer.footprint":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Footprint Vision Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the radius for you to see footprint of roaming party." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.advancepaymentcap":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Advance Payment Cap"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the percentage of contract payment that is paid in advance. Normally the maximum percentage of payment paid in advance is 50%."
					},
				];

			case "origincustomizer.trainingprice":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Training Price Multiplier"
					},
					{
						id = 2,
						type = "description",
						text = "Affects the cost to train a brother in Training Hall." + this.Const.PercentageNoteString
					},
				];

			case "origincustomizer.choose_origin":
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
						text = "Please do not change to an origin requires a [color=" + this.Const.UI.Color.NegativeValue + "]Player Character[/color] while your current roster does not have a 'Player Character' brother."
					},
				];

			case "origincustomizer.save_button":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Save Changes"
					},
					{
						id = 2,
						type = "description",
						text = "Some changes may not automatically save, thus, require you to manually save them by pressing this button or \'Close\' button."
					},
				];

			case "origincustomizer.fixedrelation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Stop Relation Deterioration"
					},
					{
						id = 2,
						type = "description",
						text = "Prevent the relation of the current faction with player from deteriorating or returning back to neutral relation."
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
		"figure_player_crusader",
		"figure_player_ranger",
		"figure_player_beggar",
		"figure_player_legion",
		"figure_player_noble",
		"figure_player_seer",
		"figure_player_warlock",
		"figure_player_trader",
		"figure_player_party",
		"figure_player_vala",
		"figure_player_assassin",
		"figure_player_inquisition",
		"figure_player_druid",
		"figure_player_troupe",
		"figure_player_slave",
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
		"figure_mummy_01",
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
		"figure_hexe_leader_01",
		"figure_alp_01",
		"figure_demonalp_01",
		"figure_ghoul_01",
		"figure_ghoul_02",
		"figure_skin_ghoul_01",
		"figure_skin_ghoul_02",
		"figure_golem_01",
		"figure_golem_02",
		"figure_hyena_01",
		"figure_kraken_01",
		"figure_lindwurm_01",
		"figure_stollwurm_01",
		"figure_schrat_01",
		"figure_greenwood_schrat_01",
		"figure_serpent_01",
		"figure_spider_01",
		"figure_redback_spider_01",
		"figure_unhold_01",
		"figure_unhold_02",
		"figure_unhold_03",
		"figure_rock_unhold_01",
		"figure_werewolf_01",
		"figure_white_direwolf_01",
	]);
});
