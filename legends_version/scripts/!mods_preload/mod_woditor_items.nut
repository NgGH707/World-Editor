::Woditor.hookItems <- function ()
{
	::mods_hookExactClass("items/supplies/money_item", function ( obj )
	{
		local ws_create = obj.create;
		obj.create = function()
		{
			ws_create();
			this.m.Amount = this.Math.rand(100, 200);
		}
	});

	delete ::Woditor.hookItems;
}