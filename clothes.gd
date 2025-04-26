extends Node2D

@onready var clothes_sprite = $EyesSprite

#keys
var clothes_keys = []
var color_keys = []
var current_face_index = 0
var current_color_index = 0

func _ready():
	set_sprite_keys()
	update_sprite()

func set_sprite_keys():
	face_keys = Global.eyes_collection.keys()
	
func update_sprite():
	var current_sprite = face_keys[current_face_index]
	face_sprite.texture = Global.face_collection[current_sprite]
	face_sprite.modulate = Global.face_color_options[current_color_index]
	
	Global.selected_face = current_sprite
	Global.selected_face = Global.face_color_options[current_color_index]
	
