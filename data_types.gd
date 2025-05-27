extends Node
class_name DataTypes

@export var current_tool : DataTypes.Tools = DataTypes.Tools.None

enum Tools {
	None,
	Axe,
	Pickaxe,
	Rod,
	Watering,
	Tilling,
	Block,
	Sword
}
