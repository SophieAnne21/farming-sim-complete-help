extends Node2D

@onready var pants_sprite = $PantsSprite

# keys
var pants_keys = []
var current_pants_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

func set_sprite_keys():
	pants_keys = Global.pants_collection.keys()

func update_sprite():
	var current_sprite = pants_keys[current_pants_index]
	pants_sprite.texture = Global.pants_collection[current_sprite]
	pants_sprite.modulate = Global.pants_color_options[current_color_index]  # ✅ fixed!

	Global.selected_pants = current_sprite
	Global.selected_pants_color = Global.pants_color_options[current_color_index]

func _on_collection_button_pressed() -> void:
	current_pants_index = (current_pants_index + 1) % pants_keys.size()
	update_sprite()

func _on_color_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % Global.pants_color_options.size()
	update_sprite()
