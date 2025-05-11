extends Node2D

@onready var shoes_sprite = $ShoesSprite

#keys
var shoes_keys = []
var color_keys = []
var current_shoes_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

func set_sprite_keys():
	shoes_keys = Global.shoes_collection.keys()
	
func update_sprite():
	var current_sprite = shoes_keys[current_shoes_index]
	shoes_sprite.texture = Global.shoes_collection[current_sprite]
	shoes_sprite.modulate = Global.shirt_color_options[current_color_index]
	
	Global.selected_shoes = current_sprite
	Global.selected_shoes_color = Global.shoes_color_options[current_color_index]


func _on_collection_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % Global.shoes_color_options.size()
	update_sprite()
