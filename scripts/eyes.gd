extends Node2D

@onready var face_sprite = $EyesSprite

# keys
var face_keys = []
var current_face_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

func set_sprite_keys():
	face_keys = Global.face_collection.keys()

func update_sprite():
	var current_sprite = face_keys[current_face_index]
	face_sprite.texture = Global.face_collection[current_sprite]
	face_sprite.modulate = Global.eyes_color_options[current_color_index]

	Global.selected_eyes = current_sprite
	Global.selected_eyes_color = Global.eyes_color_options[current_color_index]

func _on_button_pressed() -> void:
	current_color_index = (current_color_index + 1) % Global.eyes_color_options.size()
	update_sprite()
