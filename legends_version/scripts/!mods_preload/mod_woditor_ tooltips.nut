::Woditor.hookTooltips <- function()
{
	::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function( obj ) 
	{
		local queryUIItemTooltipData = obj.onQueryUIItemTooltipData;
		obj.onQueryUIItemTooltipData = function( _entityId, _itemId, _itemOwner )
		{
			if (_itemOwner == "woditor.itemspawner")
			{
				local result = this.World.Assets.getStash().getItemByInstanceID(_itemId);

				if (result != null)
				{
					local tooltip = result.item.getTooltip();
					tooltip.extend([
						{
							id = 11,
							type = "hint",
							icon = "ui/icons/mouse_left_button.png",
							text = "Select item"
						},
						{
							id = 11,
							type = "hint",
							icon = "ui/icons/mouse_left_button_ctrl.png",
							text = "Discard item"
						}
					]);
					return tooltip;
				}

				return null;
			}

			if (_itemOwner == "woditor.loot")
			{
				local world_entity = this.World.getEntityByID(_entityId);

				if (world_entity != null)
				{
					local loot = world_entity.getLoot().getItemByInstanceID(_itemId);

					if (loot != null)
					{
						local tooltip = loot.item.getTooltip();
						tooltip.push({
							id = 11,
							type = "hint",
							icon = "ui/icons/mouse_left_button_ctrl.png",
							text = "Discard item"
						});
						return tooltip;
					}
				}

				return null;
			}

			return queryUIItemTooltipData(_entityId, _itemId, _itemOwner);
		};

	 	local queryTooltipData = obj.general_queryUIElementTooltipData;
	 	obj.general_queryUIElementTooltipData = function(_entityId, _elementId, _elementOwner)
	 	{
	 		if (_elementOwner != null)
	 		{
	 			if (_elementOwner == "woditor.faction_contracts")
	 			{
		 			local contract = this.World.Contracts.getContractByID(_elementId);

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
								text = "The employer is [color=#0b0084]" + contract.getCharacter().getName() + "[/color] of [color=#0b0084]" + faction.getName() + "[/color]. Expires in [color=" + this.Const.UI.Color.NegativeValue + "]" + (this.Math.max(1, this.Math.abs(this.Time.getVirtualTimeF() - contract.m.TimeOut) / this.World.getTime().SecondsPerDay)) + "[/color] days."
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

				if (_elementId != null)
				{
					if (_elementOwner == "woditor.searchfilterbutton")
					{
						switch (_elementId)
						{
						case 1:
							return [{
								id = 1,
								type = "title",
								text = "Filter Named/Legendary"
							}];

						case 2:
							return [{
								id = 1,
								type = "title",
								text = "Filter Tool/Ammo/Usable"
							}];

						case 3:
							return [{
								id = 1,
								type = "title",
								text = "Filter Supply"
							}];

						case 4:
							return [{
								id = 1,
								type = "title",
								text = "Filter Crafting/Trading"
							}];

						case 5:
							return [{
								id = 1,
								type = "title",
								text = "Filter Armor"
							}];

						case 6:
							return [{
								id = 1,
								type = "title",
								text = "Filter Helmet"
							}];

						case 7:
							return [{
								id = 1,
								type = "title",
								text = "Filter Weapon"
							}];

						case 8:
							return [{
								id = 1,
								type = "title",
								text = "Filter Shield"
							}];

						case 9:
							return [{
								id = 1,
								type = "title",
								text = "Filter Accessory"
							}];
					
						default:
							return [{
								id = 1,
								type = "title",
								text = "Filter All"
							}];
						}
						return null;
					}

					if (_elementOwner == "woditor.searchresult")
					{
						foreach (item in ::Woditor.Items[::Woditor.ItemFilter.All])
						{
							if (item.ID == _elementId)
							{
								return [
									{
										id = 1,
										type = "title",
										text = item.Name
									},
									{
										id = 10,
										type = "description",
										text = item.Description
									},
									{
										id = 6,
										type = "text",
										text = "ID: [color=#8f1e1e]" + item.ID + "[/color]"
									},
									{
										id = 11,
										type = "hint",
										icon = "ui/icons/mouse_left_button.png",
										text = "Select"
									}
									{
										id = 11,
										type = "hint",
										icon = "ui/icons/mouse_left_button_ctrl.png",
										text = "Add to loot"
									}
								];
							}
						}

						return null;
					}

					if (_elementOwner == "woditor.factionbanner")
					{
				       	return [
							{
								id = 1,
								type = "title",
								text = this.World.FactionManager.getFaction(_elementId).getName()
							},
							{
								id = 10,
								type = "hint",
								icon = "ui/icons/mouse_left_button.png",
								text = "Change to another faction"
							},
						];
					}

					if (_elementOwner == "woditor.draftlist")
		 			{
		 				return [
			 				{
								id = 1,
								type = "title",
								text = ::Woditor.Backgrounds.Stuff[_elementId].Name
							}
		 				]
		 			}

		 			if (_elementOwner == "woditor.world_entity_clickable")
					{
						local world_entity = this.World.getEntityByID(_elementId);

						if (world_entity != null)
						{
							return [
								{
									id = 1,
									type = "title",
									text = world_entity.getName()
								},
								{
									id = 2,
									type = "description",
									text = world_entity.getDescription()
								},
								{
									id = 11,
									type = "hint",
									icon = "ui/icons/mouse_left_button.png",
									text = "Change sprite"
								}
							];
						}

						return null;
					}

		 			if (_elementOwner == "woditor.world_entity")
					{
						local world_entity = this.World.getEntityByID(_elementId);

						if (world_entity != null)
						{
							return [
								{
									id = 1,
									type = "title",
									text = world_entity.getName()
								},
								{
									id = 2,
									type = "description",
									text = world_entity.getDescription()
								},
								{
									id = 11,
									type = "hint",
									icon = "ui/icons/mouse_left_button_ctrl.png",
									text = "Show on map"
								}
							];
						}

						return null;
					}

					if (_elementOwner == "woditor.attached_location")
		 			{
		 				local tooltip = ::Woditor.AttachedLocations.Tooltip[_elementId].world_entity.getTooltip();
		 				
		 				if (_entityId == null)
		 				{
		 					this.Const.AddAttachedLocationHints(tooltip);
		 				}

		 				return tooltip;
		 			}

		 			if (_elementOwner == "woditor.situations" )
		 			{
		 				local tooltip = ::Woditor.Situations.Tooltip[_elementId].getTooltip();
		 				
		 				if (_entityId == null)
		 				{
		 					this.Const.AddSituationHints(tooltip);
		 				}

		 				return tooltip;
		 			}
	 			}
	 		}

			local tooltip = queryTooltipData(_entityId, _elementId, _elementOwner);

			if (tooltip != null)
			{
				if (_elementOwner != null && _elementOwner == "woditor.buildings")
				{
					this.Const.AddBuildingHints(tooltip);
				}

				return tooltip;
			} 

			switch (_elementId) 
			{
			case "woditor.ConditionMax":
				return [{
					id = 1,
					type = "title",
					text = "Maximum Durability"
				}];

			case "woditor.StaminaModifier":
				return [{
					id = 1,
					type = "title",
					text = "Fatigue Penalty"
				}];

			case "woditor.MeleeDefense":
				return [{
					id = 1,
					type = "title",
					text = "Melee Defense"
				}];

			case "woditor.RangedDefense":
				return [{
					id = 1,
					type = "title",
					text = "Ranged Defense"
				}];

			case "woditor.RegularDamage":
				return [{
					id = 1,
					type = "title",
					text = "Minimum Damage"
				}];

			case "woditor.RegularDamageMax":
				return [{
					id = 1,
					type = "title",
					text = "Maximum Damage"
				}];

			case "woditor.ArmorDamageMult":
				return [{
					id = 1,
					type = "title",
					text = "Effectiveness against Armor"
				}];

			case "woditor.DirectDamageAdd":
				return [{
					id = 1,
					type = "title",
					text = "Additional Armor Penetration"
				}];

			case "woditor.ShieldDamage":
				return [{
					id = 1,
					type = "title",
					text = "Shield Damage"
				}];

			case "woditor.ChanceToHitHead":
				return [{
					id = 1,
					type = "title",
					text = "Chance to Hit Head"
				}];

			case "woditor.FatigueOnSkillUse":
				return [{
					id = 1,
					type = "title",
					text = "Fatigue Modifier on Skill Use"
				}];

			case "woditor.AdditionalAccuracy":
				return [{
					id = 1,
					type = "title",
					text = "Additional Chance to Hit"
				}];

			case "woditor.AmmoMax":
				return [{
					id = 1,
					type = "title",
					text = "Maximum Amount of Ammo"
				}];

			case "woditor.deletestashitems":
				return [
					{
						id = 1,
						type = "title",
						text = "Discard All Items"
					},
					{
						id = 2,
						type = "description",
						text = "Clear all items in your stash, make it clean"
					},
				];

			case "woditor.repairallitems":
				return [
					{
						id = 1,
						type = "title",
						text = "Repair All Items"
					},
					{
						id = 2,
						type = "description",
						text = "Restore the condition of all stash items back to its peak condition"
					},
				];

			case "woditor.restockallitems":
				return [
					{
						id = 1,
						type = "title",
						text = "Restock All Items"
					},
					{
						id = 2,
						type = "description",
						text = "Restock all the food back to 25 units and reset their expiration date"
					},
				];

			case "woditor.itemspawneramount":
				return [
					{
						id = 1,
						type = "title",
						text = "Number/Amount"
					},
					{
						id = 2,
						type = "description",
						text = "Shows the number of item you are about to add or duplicate. or just to show the amount of unit of a supply item"
					},
				];

			case "woditor.itemspawnerrerollstats":
				return [
					{
						id = 1,
						type = "title",
						text = "Reroll Stats"
					},
					{
						id = 2,
						type = "description",
						text = "Let you reroll the stats of your named item. Let the RNG god give you another chance"
					},
				];

			case "woditor.searchbutton":
				return [
					{
						id = 1,
						type = "title",
						text = "Search"
					},
					{
						id = 2,
						type = "description",
						text = "Start the search process with the given text input. Remember, the text input must has at least 2 words or it will clear the search result"
					},
				];

			case "woditor.clearsearchbutton":
				return [
					{
						id = 1,
						type = "title",
						text = "Reset Search"
					},
					{
						id = 2,
						type = "description",
						text = "Clear the search result, return it to the blank page."
					},
				];

			case "woditor.worldentitybanner":
				return [
					{
						id = 1,
						type = "title",
						text = "Banner"
					},
					{
						id = 2,
						type = "description",
						text = "The banner of the current world entity"
					},
					{
						id = 11,
						type = "hint",
						icon = "ui/icons/mouse_left_button.png",
						text = "Change banner"
					}
				];

			case "woditor.removecontract":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Discard Contract"
					},
					{
						id = 2,
						type = "description",
						text = "Discard the currently selected contract"
					},
				];

			case "woditor.refreshcontract":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Refresh Contracts"
					},
					{
						id = 2,
						type = "description",
						text = "Discard all current contracts and then attempting to generate new contracts"
					},
				];

			case "woditor.addnewcontract":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Add Contract"
					},
					{
						id = 2,
						type = "description",
						text = "Choose a contract then the game will assign a random faction to it, you can change that contract at will after that"
					},
				];

			case "woditor.contractexpiration":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Time Left"
					},
					{
						id = 2,
						type = "description",
						text = "Displays how many days you have before this contract expires. If you haven\'t this contract before the it expires, the contract will be discarded."
					},
				];

			case "woditor.refreshloot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Reroll " + (_elementOwner != null ? "(chance: " + _elementOwner + "%)" : "")
					},
					{
						id = 2,
						type = "description",
						text = "Refresh the current loot pool. The chance to roll for named items is depending on the Resouces value."
					},
				];

			case "woditor.randomnameditem":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Add Random Named Item"
					},
					{
						id = 2,
						type = "description",
						text = "Randomly pick a named item and add it too the loot pool"
					},
				];

			case "woditor.randomlootitem":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Add Random Treasure Item"
					},
					{
						id = 2,
						type = "description",
						text = "Randomly pick a treasure item and add it too the loot pool"
					},
				];

			case "woditor.housecount":
		       	return [
					{
						id = 1,
						type = "title",
						text = "House"
					},
					{
						id = 2,
						type = "description",
						text = "The number of house tile of the current settlement. The more houses the settlement has the more income resources it gains."
					},
				];

			case "woditor.nofaction":
		       	return [
					{
						id = 1,
						type = "title",
						text = "No Faction"
					},
					{
						id = 2,
						type = "description",
						text = "This entity is not belong to any faction on the world."
					},
				];

			case "woditor.rostertier":
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

			case "woditor.difficultymult":
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

			case "woditor.equipmentloot":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Bonus Chance To Loot Equipment"
					},
					{
						id = 2,
						type = "description",
						text = "Bonus chance to the existing chance to loot enemy equipment (armors, weapon, quiver, etc). The chance to loot an equipment of an enemy is based on the durability of said item. With this chance value reaches 100, you are guaranteed to loot enemy equipment as long as the equipment\'s durability above 25%. The default value is 0 which means 0%."
					},
				];

		    case "woditor.xp":
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
			
		    case "woditor.hiring":
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

			case "woditor.wage":
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

			case "woditor.selling":
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

			case "woditor.buying":
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

			case "woditor.selling_trade":
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

			case "woditor.buying_trade":
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

			case "woditor.loot":
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

			case "woditor.champion":
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

			case "woditor.speed":
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

			case "woditor.contractpayment":
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

			case "woditor.vision":
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

			case "woditor.hp":
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

			case "woditor.repair":
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

			case "woditor.renown":
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

			case "woditor.negotiation":
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

			case "woditor.recruitmin":
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

			case "woditor.recruitmax":
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

			case "woditor.craft":
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

			case "woditor.tryout":
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

			case "woditor.goodrelation":
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

			case "woditor.badrelation":
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

			case "woditor.brotherscalemax":
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

			case "woditor.brotherscalemin":
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

			case "woditor.fooddays":
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

			case "woditor.footprint":
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

			case "woditor.advancepaymentcap":
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

			case "woditor.trainingprice":
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

			case "woditor.choose_origin":
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

			case "woditor.reload_button":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Reload Data"
					},
					{
						id = 2,
						type = "description",
						text = "Reload the data of all tabs, you shouldn\'t use this button too often because most changes will be individually automatical updated."
					},
				];

			case "woditor.reload_leader":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Reroll"
					},
					{
						id = 2,
						type = "description",
						text = "Replace the current leadership figures of the current faction with someone else."
					},
				];

			case "woditor.fixedrelation":
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

			//
			case "woditor.addnewentry":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Add New Entry"
					},
					{
						id = 2,
						type = "description",
						text = "Let you add more entries to the current list."
					},
				];

			case "woditor.removeentry":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Discard"
					},
					{
						id = 2,
						type = "description",
						text = "Remove the selected entry from the list."
					}
				];

			case "woditor.partystrength":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Strength"
					},
					{
						id = 2,
						type = "description",
						text = "Display how strong the game considers these units worth"
					}
				];

			case "woditor.championization":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Become Champion"
					},
					{
						id = 2,
						type = "description",
						text = "Convert a unit into a champion."
					},
				];

			case "woditor.dechampionization":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Return normal"
					},
					{
						id = 2,
						type = "description",
						text = "Convert a champion into a normal unit."
					},
				];

			case "woditor.choosecoords":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Choose Tile"
					},
					{
						id = 2,
						type = "description",
						text = "Show you the world map, after you have hovered your mouse to a desired location, re-open the screen to get the coordinate of the hovered tile so you can start spawning stuff on that tile."
					},
				];

			case "woditor.addrandomtroop":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Add Random Troop"
					},
					{
						id = 2,
						type = "description",
						text = "Automatically pick a random troop either in the current selected template or from master spawn list."
					},
				];

			case "woditor.refreshtroops":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Reroll Troops"
					},
					{
						id = 2,
						type = "description",
						text = "Refresh the current troops list with a given troop template. If no troop template is chosen, the default template will be used. If no default template is found then it does nothing."
					},
				];

			case "woditor.picktrooptemplate":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Choose Troop List Template"
					},
					{
						id = 2,
						type = "description",
						text = "Choose a template so you can use \'Reroll Troops\' to refresh the troop list."
					},
				];

			case "woditor.troopsinfo":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Notes"
					},
					{
						id = 2,
						type = "description",
						text = "[color=#8f1e1e]Please remember that a location/party can only hold 255 units at most, anymore than that can brick your save[/color] .There is some notes i have left in the troop name to identify them. Here is what they stand for:"
					},
					{
						id = 3,
						type = "text",
						text = "([color=#8f1e1e]W[/color]) - [color=#8f1e1e]W[/color]eaken version."
					},
					{
						id = 4,
						type = "text",
						text = "([color=#8f1e1e]B[/color]) - [color=#8f1e1e]B[/color]odyguard."
					},
					{
						id = 5,
						type = "text",
						text = "([color=#8f1e1e]R[/color]) - Equipped with [color=#8f1e1e]R[/color]anged weapon."
					},
					{
						id = 6,
						type = "text",
						text = "([color=#8f1e1e]P[/color]) - Equipped with [color=#8f1e1e]P[/color]olarm."
					},
					{
						id = 7,
						type = "text",
						text = "([color=#8f1e1e]S[/color]) - [color=#8f1e1e]S[/color]mall size."
					},
					{
						id = 8,
						type = "text",
						text = "([color=#8f1e1e]M[/color]) - [color=#8f1e1e]M[/color]edium size."
					},
					{
						id = 9,
						type = "text",
						text = "([color=#8f1e1e]L[/color]) - [color=#8f1e1e]L[/color]arge size."
					},
				];

			case "woditor.distance":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Distance to Player"
					},
					{
						id = 2,
						type = "description",
						text = "Let you know how far this world entity to player position. Also, [color=#8f1e1e]pressing this button will show you the exact location of said world entity on the world map[/color]."
					},
				];

			case "woditor.notaninput":
		       	return [
					{
						id = 2,
						type = "description",
						text = "This is not an input, please stop clicking on it XD."
					},
				];

			case "woditor.basemovementspeed":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Base Movement Speed"
					},
					{
						id = 2,
						type = "description",
						text = "Determine the speed of this unit party on world map. May change due to the penalty of nighttime"
					},
				];

			case "woditor.visibilitymult":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Visibility"
					},
					{
						id = 2,
						type = "description",
						text = "Determine how far or close player party needs to be so you can see this world entity within your field of vision. Bring the value down to 0 will effectively make the entity invisible to player eyes"
					},
				];

			case "woditor.lootscale":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Loot Scale"
					},
					{
						id = 2,
						type = "description",
						text = "Decide the amount of supply (foods, medicine, tool parts, ammo) and crowns after defeating a world map unit. This value may be depending on Resouces value"
					},
				]; 

			case "woditor.isleavingfootprints":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Is Leaving Footprints"
					},
					{
						id = 2,
						type = "description",
						text = "Decide whether the unit party will leave footprints when moving or not."
					},
				];

			case "woditor.islooting":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Is Looting"
					},
					{
						id = 2,
						type = "description",
						text = "Decide whether the AI should prioritize raiding caravans, peasants or even settlements."
					},
				];

			case "woditor.isalwaysattackingplayer":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Is Always Attacking Player"
					},
					{
						id = 2,
						type = "description",
						text = "Decide whether the AI should prioritize attacking player at any cost, even its strength is far weaker than the player."
					},
				];

			case "woditor.isattackablebyai":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Is Attackable By AI"
					},
					{
						id = 2,
						type = "description",
						text = "Decide whether other AI roaming parties can target this party or not. Player can still attack this party."
					},
				];

			case "woditor.issloweratnight":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Is Slower At Night"
					},
					{
						id = 2,
						type = "description",
						text = "Decide whether this party receives a penalty to movement speed when the night comes."
					},
				];
			}
			
			return null;
		}
	});
	
	delete ::Woditor.hookTooltips;
};