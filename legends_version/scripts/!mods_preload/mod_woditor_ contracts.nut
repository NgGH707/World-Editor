this.getroottable().Woditor.hookContracts <- function ()
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

	delete this.Woditor.hookContracts;
}