::Woditor.hookContracts <- function ()
{
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

	// change the name so player can differentiate them 
	::mods_hookExactClass("contracts/contracts/conquer_holy_site_southern_contract", function( obj ) 
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Name = "Conquer Holy Site (Southern)";
		}
	});
	::mods_hookExactClass("contracts/contracts/defend_holy_site_southern_contract", function( obj ) 
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Name = "Defend Holy Site (Southern)";
		}
	});
	::mods_hookExactClass("contracts/contracts/defend_settlement_bandits_contract", function( obj ) 
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Name = "Defend Settlement (Bandits)";
		}
	});
	::mods_hookExactClass("contracts/contracts/defend_settlement_greenskins_contract", function( obj ) 
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Name = "Defend Settlement (Greenskins)";
		}
	});
	::mods_hookExactClass("contracts/contracts/roaming_beasts_desert_contract", function( obj ) 
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Name = "Hunting Desert Beasts";
		}
	});

	delete ::Woditor.hookContracts;
}