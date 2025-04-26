extends Node2D

@onready var name_input = $CreatorScreen/ColorRect/Details/TextEdit # Adjust this path to match your scene
@onready var confirm_button = $CreatorScreen/ColorRect/ConfirmButton

func _ready():
	pass
	
func set_defaults():
	Global.player_name = "Farmer"

	Global.selected_skin = "white"
	Global.selected_hair = "buzzcut"
	Global.selected_eyes = "eyes"
	Global.selected_shirt = "basic"
	Global.selected_pants = "pants"
	Global.selected_shoes = "shoes"
	Global.selected_acc = "none"

	Global.selected_skin_color = Color(1, 1, 1)
	Global.selected_hair_color = Color(1, 1, 1)
	Global.selected_eyes_color = Color(1, 1, 1)
	Global.selected_shirt_color = Color(1, 1, 1)
	Global.selected_pants_color = Color(1, 1, 1)
	Global.selected_shoes_color = Color(1, 1, 1)
	Global.selected_acc_color = Color(1, 1, 1)

	# Optional: set colors if needed
	Global.selected_skin_color = get_selected_skin_color()
	Global.selected_hair_color = get_selected_hair_color()
	# etc.
	print("Setting default name to:", Global.player_name)
	
func _on_confirm_button_pressed() -> void:
	Global.player_name = name_input.text
	Global.save_game()
	get_tree().change_scene_to_file("res://farm.tscn")

# Dummy functions – replace with real data access
func get_selected_skin(): return ""
func get_selected_hair(): return ""
func get_selected_shirt(): return ""
func get_selected_pants(): return ""
func get_selected_shoes(): return ""
func get_selected_accessory(): return ""
func get_selected_skin_color(): return ""
func get_selected_hair_color(): return ""
