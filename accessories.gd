extends Node2D

@onready var acc_sprite = $AccessoriesSprite

#keys
var acc_keys = []
var color_keys = []
var current_acc_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

func set_sprite_keys():
	acc_keys = Global.acc_collection.keys()
	
func update_sprite():
	var current_sprite = acc_keys[current_acc_index]
	Global.selected_acc = current_sprite
	Global.selected_acc_color = Global.acc_color_options[current_color_index]

	if current_sprite == "none":
		acc_sprite.texture = null
		acc_sprite.modulate = Color(1, 1, 1)  # neutral just in case
	else:
		acc_sprite.texture = Global.acc_collection[current_sprite]
		acc_sprite.modulate = Global.acc_color_options[current_color_index]



func _on_collection_button_pressed() -> void:
	current_acc_index = (current_acc_index + 1) % acc_keys.size()
	update_sprite()


func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % Global.acc_color_options.size()
	update_sprite()
