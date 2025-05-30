extends UPGFSM
class_name EntityFSM

@onready var animator = $StateMachine/AnimationPlayer
@onready var visual_node: Node2D = $Skeleton

var direction : String = "down"

func get_entity() -> CharacterBody2D:
	return get_parent() as Player
