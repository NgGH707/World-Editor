this.getroottable().Woditor.hookTooltips <- function ()
{
	::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function( obj ) 
	{
	 	local queryTooltipData = obj.general_queryUIElementTooltipData;
	 	obj.general_queryUIElementTooltipData = function(_entityId, _elementId, _elementOwner)
	 	{
	 		if (_elementOwner != null)
	 		{
	 			if (_elementOwner == "woditor.faction_contracts")
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

				if (_elementId != null)
				{
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
								text = this.Woditor.Backgrounds.Stuff[_elementId].Name
							}
		 				]
		 			}

					if (_elementOwner == "woditor.attached_location")
		 			{
		 				local tooltip = this.Woditor.AttachedLocations.Tooltip[_elementId].world_entity.getTooltip();
		 				
		 				if (_entityId == null)
		 				{
		 					this.Const.AddAttachedLocationHints(tooltip);
		 				}

		 				return tooltip;
		 			}

		 			if (_elementOwner == "woditor.situations" )
		 			{
		 				local tooltip = this.Woditor.Situations.Tooltip[_elementId].getTooltip();
		 				
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
						text = "Bonus chance to the existing chance to loot enemy equipment (armors, weapon, quiver, etc). The chance to loot an equipment of an enemy is based on the durability of said item. With this chance value reaches 100, you are guaranteed to loot enemy equipment. The default value is 0 which means 0%."
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
						text = "Discard the current troops list then use the current template and resources to create a new one. If no template is chosen, it will only discard the troop list."
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
						text = "Choose a template so you can use \'Reroll Troops\' to create a random troop list."
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
						text = "There is some notes i have left in the troop name to identify them. Here is what they stand for:"
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
	
	delete this.Woditor.hookTooltips;
};