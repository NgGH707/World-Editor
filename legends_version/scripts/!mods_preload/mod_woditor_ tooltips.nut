this.getroottable().Woditor.hookTooltips <- function ()
{
	::mods_hookNewObjectOnce("ui/screens/tooltip/tooltip_events", function( obj ) 
	{
		local querySettlementStatusEffectTooltip = obj.general_querySettlementStatusEffectTooltipData
		obj.general_querySettlementStatusEffectTooltipData = function( _statusEffectId )
		{
			local tooltip = querySettlementStatusEffectTooltip(_statusEffectId);

			if (tooltip != null)
			{
				return tooltip;
			}
			else
			{
				foreach (settlement in this.World.EntityManager.getSettlements())
				{
					local statusEffect = settlement.getSituationByID(_statusEffectId);

					if (statusEffect != null)
					{
						tooltip = statusEffect.getTooltip();
						this.Const.AddSituationHints(tooltip);
						return tooltip;
					}
				}
			}

			return null;
		};

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

				if (_elementOwner == "woditor.attached_location")
	 			{
	 				local tooltip = this.getAttachedLocationTooltip(_elementId);

	 				if (tooltip != null)
	 				{
	 					this.Const.AddAttachedLocationHints(tooltip);
	 				}

	 				return tooltip;
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

			case "woditor.choosefaction":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Choose Faction"
					},
					{
						id = 2,
						type = "description",
						text = "Let you change to another faction."
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
			}
			
			return null;
		}

		obj.getAttachedLocationTooltip <- function( _elementId )
		{
			switch(_elementId)
			{
			case "attached_location.workshop":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Workshop"
					},
					{
						id = 2,
						type = "description",
						text = "The workshop is proficient in making all kinds of tools and other supplies needed to keep carts and machines working."
					},
				];

			case "attached_location.wool_spinner":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Wool Spinner"
					},
					{
						id = 2,
						type = "description",
						text = "The wool of the sheep herded here is spun into wool and then shipped to the next settlement. Refined wares like these can be quite valuable."
					},
				];

			case "attached_location.wooden_watchtower":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Wooden Watchtower"
					},
					{
						id = 2,
						type = "description",
						text = "A wooden watchtower with a small garrison on watch duty."
					},
				];

			case "attached_location.winery":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Winery"
					},
					{
						id = 2,
						type = "description",
						text = "This winery is surrounded by a large vineyard. The wine produced here is a priced commodity in wealthier circles."
					},
				];

			case "attached_location.wheat_fields":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Wheat Fields"
					},
					{
						id = 2,
						type = "description",
						text = "Golden wheat can be seen glistening in the sun from afar. Many people from the nearby settlement work here, farmhands and daytalers mostly."
					},
				];

			case "attached_location.trapper":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Trapper"
					},
					{
						id = 2,
						type = "description",
						text = "Small huts provide shelter for the trappers living here and setting traps for animals with valuable furs."
					},
				];

			case "attached_location.surface_iron_vein":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Surface Iron Vein"
					},
					{
						id = 2,
						type = "description",
						text = "This surfaced iron vein attracted a small mining camp that is gathering the precious metal. Access to this resource increases the selection of weapons available in the next settlement."
					},
				];

			case "attached_location.surface_copper_vein":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Surface Copper Vein"
					},
					{
						id = 2,
						type = "description",
						text = "A mining camp has been set up to mine a surfaced copper vein and smelt the ore into ingots on the spot."
					},
				];

			case "attached_location.stone_watchtower":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Stone Watchtower"
					},
					{
						id = 2,
						type = "description",
						text = "A stone watchtower occupied by well trained soldiers on guard duty."
					},
				];

			case "attached_location.silk_farm":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Silk Farm"
					},
					{
						id = 2,
						type = "description",
						text = "In these huts the precious silk is spun from cocoons of small insects by secret methods."
					},
				];

			case "attached_location.salt_mine":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Salt Mine"
					},
					{
						id = 2,
						type = "description",
						text = "A mine in which precious rock salt is extracted and shipped off to only the most trustworthy traders."
					},
				];

			case "attached_location.plantation":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Plantation"
					},
					{
						id = 2,
						type = "description",
						text = "All kinds of wonderous spices and herbs are cultivated in this plantation. A small and rare fruitful spot in the barren desert"
					},
				];

			case "attached_location.pig_farm":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Pig Farm"
					},
					{
						id = 2,
						type = "description",
						text = "The smell of this pig farm is just as distinct as the squeeking sounds coming from the muddy pits. The pork chops produced here are usually sold in the nearby settlement."
					},
				];

			case "attached_location.peat_pit":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Peat Pit"
					},
					{
						id = 2,
						type = "description",
						text = "These peat pits produce a valuable fuel source once the peat has been dug up and dried."
					},
				];

			case "attached_location.ore_smelters":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Ore Smelters"
					},
					{
						id = 2,
						type = "description",
						text = "The burning hot ore smelters produce high quality metal ingots used by able weapon smiths to create the most sophisticated of arms."
					},
				];

			case "attached_location.orchard":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Orchard"
					},
					{
						id = 2,
						type = "description",
						text = "Dense rows of trees with ripe fruit frame a small warehouse where everything is stored until offered on local markets."
					},
				];

			case "attached_location.mushroom_grove":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Mushroom Grove"
					},
					{
						id = 2,
						type = "description",
						text = "Hidden in the mud and reed, the expert gatherer can find groves and caves full of precious mushrooms like these."
					},
				];

			case "attached_location.militia_trainingcamp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Militia Barracks"
					},
					{
						id = 2,
						type = "description",
						text = "A large compound of militia barracks. This camp will turn ordinary peasants into somewhat able soldiers that can defend their home and their loved ones."
					},
				];

			case "attached_location.lumber_camp":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Lumber Camp"
					},
					{
						id = 2,
						type = "description",
						text = "This lumber camp is used as a base for lumberjacks on the search for the most precious and durable materials in the nearby woods."
					},
				];

			case "attached_location.leather_tanner":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Leather Tanner"
					},
					{
						id = 2,
						type = "description",
						text = "This leather tanner\'s workshop produces durable leather pieces from hides. The supply of this leather will increase the availability of light armor in the nearest settlement."
					},
				];

			case "attached_location.incense_dryer":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Incense Dryer"
					},
					{
						id = 2,
						type = "description",
						text = "Tree sap is gathered from the surrounding trees and dried in the sun to create valuable incense."
					},
				];

			case "attached_location.hunters_cabin":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Hunter\'s Cabin"
					},
					{
						id = 2,
						type = "description",
						text = "Hunters take shelter in these small huts while on the hunt. Chopped up game, venison and hides hung up to dry in the sun surround the huts."
					},
				];

			case "attached_location.herbalists_grove":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Herbalist\'s Grove"
					},
					{
						id = 2,
						type = "description",
						text = "In this remote grove the knowing herbalist collects all kinds of medicinal plants and roots."
					},
				];

			case "attached_location.gold_mine":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Gold Mine"
					},
					{
						id = 2,
						type = "description",
						text = "A deep mine build atop a gold ore vein. This rare metal has a tendency to bring out the worst in people."
					},
				];

			case "attached_location.goat_herd":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Goat Pens"
					},
					{
						id = 2,
						type = "description",
						text = "The goats held here are mainly used for their milk which is then turned into cheese to make it more durable."
					},
				];

			case "attached_location.gem_mine":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Gem Mine"
					},
					{
						id = 2,
						type = "description",
						text = "The shiny gems found in this mine are usually brought directly to the next settlement in well-guarded caravans for further refinement."
					},
				];

			case "attached_location.gatherers_hut":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Gatherer\'s Hut"
					},
					{
						id = 2,
						type = "description",
						text = "Even in sparse environments an experienced gatherer can find berries, roots and other edible things. Although not the most delicious, it can still keep a man fed."
					},
				];

			case "attached_location.fortified_outpost":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Barracks"
					},
					{
						id = 2,
						type = "description",
						text = "Large barracks housing a host of professional soldiers."
					},
				];

			case "attached_location.fletchers_hut":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Arrow Maker\'s Shed"
					},
					{
						id = 2,
						type = "description",
						text = "The arrow makers in these sheds produce all kinds of ranged ammunition which they then sell at the nearest settlement."
					},
				];

			case "attached_location.fishing_huts":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Fishing Huts"
					},
					{
						id = 2,
						type = "description",
						text = "A small group of huts surrounded by nets, spears, hooks and other fishing equipment. The smell from baskets of fish guts travels quite a distance."
					},
				];

			case "attached_location.dye_maker":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Dye Maker"
					},
					{
						id = 2,
						type = "description",
						text = "This dye maker creates precious dies from all kinds of ingredients. The recipes for these expensive goods are well-kept secrets."
					},
				];

			case "attached_location.brewery":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Brewery"
					},
					{
						id = 2,
						type = "description",
						text = "This brewery produces large quantities of beer for both local taverns and traders."
					},
				];

			case "attached_location.blast_furnace":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Blast Furnace"
					},
					{
						id = 2,
						type = "description",
						text = "The blast furnace produces the blazing temperatures needed to make the most durable of metal alloys. Handy armorsmiths will use these alloys to create sturdy armor in the nearest settlement."
					},
				];

			case "attached_location.beekeeper":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Beekeeper"
					},
					{
						id = 2,
						type = "description",
						text = "Surrounded by humming bees, these small huts are home to beekeepers. The honey they produce is a precious ingredient to sweeten pastries and other foods."
					},
				];

			case "attached_location.amber_collector":
		       	return [
					{
						id = 1,
						type = "title",
						text = "Amber Collector"
					},
					{
						id = 2,
						type = "description",
						text = "The collectors living in these huts search for valuable amber shards along the shore."
					},
				];
			}

			return null;
		}
	});
	
	delete this.Woditor.hookTooltips;
};