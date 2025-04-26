extends Node2D

@onready var name_input = $CreatorScreen/ColorRect/Details/TextEdit
@onready var confirm_button = $CreatorScreen/ColorRect/ConfirmButton

func _ready():
	pass

func _on_confirm_button_pressed() -> void:
	Global.player_name = name_input.text
	print("🖋 Confirm clicked. Input name is:", name_input.text, "typeof:", typeof(name_input.text))

	Global.last_scene = "res://farm.tscn"
	Global.save_game()

	get_tree().change_scene_to_file(Global.last_scene)
