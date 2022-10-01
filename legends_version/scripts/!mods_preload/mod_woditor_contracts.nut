::Woditor.hookContracts <- function ()
{
	::mods_hookNewObject("contracts/contract_manager", function( obj ) 
	{
		obj.getContractByID <- function( _id )
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

		obj.removeContractByID <- function( _id )
		{
			local find;

			foreach (i, c in this.m.Open)
			{
				if (c.getID() == _id)
				{
					find = i;
					break;
				}
			}

			if (find == null) return null;

			local remove = this.m.Open.remove(find);
			this.World.FactionManager.getFaction(remove.getFaction()).removeContract(remove);
			remove.onClear();
			
			if (this.m.LastShown == remove)
			{
				this.m.LastShown = null;
			}

			if (this.World.State.getCurrentTown() != null)
			{
				this.World.State.getTownScreen().updateContracts();
			}

			return remove;
		}

		obj.addContractByForce <- function( _contract )
		{
			_contract.m.ID = this.generateContractID();
			_contract.m.TimeOut += this.World.getTime().SecondsPerDay * (this.Math.rand(0, 200) - 100) * 0.01;

			if (_contract.getFaction() != 0)
			{
				this.World.FactionManager.getFaction(_contract.getFaction()).addContract(_contract);
			}

			this.m.Open.push(_contract);
		}

		local ws_addContract = obj.addContract;
		obj.addContract = function( _contract, _isNewContract = true )
		{
			if (::Woditor.InvalidContracts.find(_contract.getType()) != null)
			{
				return;
			}

			ws_addContract(_contract, _isNewContract);
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