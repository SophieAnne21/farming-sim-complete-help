extends Control

@onready var save_button = $BoxContainer/SaveButton
@onready var exit_button = $BoxContainer/ExitButton

func _ready() -> void:
	hide()
	$CharacterPortrait.update_portrait_from_global()

func _on_save_button_pressed() -> void:
	print("Save button pressed!")

	var player = get_tree().get_first_node_in_group("Player")
	if player:
		print("Player found!")
		print("Actual live player position:", player.global_position)
		Global.player_position = player.global_position
	else:
		print("No player found in 'Player' group!")

	print("Global.player_position BEFORE saving:", Global.player_position)
	Global.save_game()


func _on_exit_button_pressed() -> void:
	print("Exit button pressed!")
	get_tree().quit()
	
func open_inventory():
	visible = true
	Global.is_inventory_open = true

func close_inventory():
	visible = false
	Global.is_inventory_open = false
