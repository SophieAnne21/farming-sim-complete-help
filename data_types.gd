extends Node
class_name DataTypes

@export var current_tool : DataTypes.Tools = DataTypes.Tools.None

enum Tools {
	None,
	Axe,
	Pickaxe,
	Fishing,
	Watering,
	Tilling,
	Block,
	Sword
}

var tool: Tools = Tools.None
