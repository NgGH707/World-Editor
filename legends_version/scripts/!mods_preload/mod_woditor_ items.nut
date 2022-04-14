::Woditor.hookItems <- function ()
{
	/*::mods_hookExactClass("items/legend_helmets/legend_armor_upgrade", function ( obj )
	{
		obj.getLayerImage <- function()
		{
			switch (this.m.Type)
			{
			case this.Const.Items.ArmorUpgrades.Chain:
				return "layers/layer_1.png";
		
			case this.Const.Items.ArmorUpgrades.Plate:
				return "layers/layer_2.png";
	
			case this.Const.Items.ArmorUpgrades.Tabbard:
				return "layers/layer_3.png";
	
			case this.Const.Items.ArmorUpgrades.Cloak:
				return "layers/layer_4.png";

			case this.Const.Items.ArmorUpgrades.Attachment:
				return "layers/layer_5.png";
			}

			return "";
		}
	});
	::mods_hookExactClass("items/legend_armor/legend_helmet_upgrade", function ( obj )
	{
		obj.getLayerImage <- function()
		{
			switch (this.m.Type)
			{
			case this.Const.Items.HelmetUpgrades.Helm:
				return "layers/layer_1.png";

			case this.Const.Items.HelmetUpgrades.Top:
				return "layers/layer_2.png";

			case this.Const.Items.HelmetUpgrades.Vanity:
				return "layers/layer_3.png";
			}

			return "";
		}
	});*/
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