this.temp_model <- this.inherit("scripts/entity/tactical/entity", {
	m = {},
	function getName()
	{
		return "Avatar Model";
	}

	function getDescription()
	{
		return "Am i pretty?";
	}

	function setFlipped( _flip )
	{
		this.getSprite("socket").setHorizontalFlipping(_flip);
		this.getSprite("base").setHorizontalFlipping(_flip);
		this.getSprite("body").setHorizontalFlipping(_flip);
	}

	function onInit()
	{
		this.addSprite("socket");
		this.addSprite("base");
		this.addSprite("body");
	}

	function setDirty( _value )
	{
		this.getSprite("socket").Scale = 1.5;
		this.getSprite("base").Scale = 1.5;
		this.getSprite("body").Scale = 1.5;
		this.m.ContentID = this.Math.rand() + this.Math.rand();
	}

});

