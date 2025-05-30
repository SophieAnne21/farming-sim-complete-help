extends LimboHSM

@export var character : CharacterBody2D

func _ready() -> void:
	initialize(character)
	set_active(true)
