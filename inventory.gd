extends Control

@onready var save_button = $BoxContainer/SaveButton
@onready var exit_button = $BoxContainer/ExitButton

func _ready() -> void:
	$CharacterPortrait.update_portrait_from_global()
	hide()

func _on_save_button_pressed() -> void:
	print("✅ Save button pressed!")
	
	# Find player and save position
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.global_position
		print("📍 Player position saved at:", Global.player_position)
	else:
		print("❌ Player not found in 'Player' group — not saved")
	
	# Save clock variables
	Global.global_time_passed = Global.global_time_passed  # Already updating in _process()
	Global.global_display_in_game_time = Global.global_display_in_game_time  # Same
	
	# Save everything
	Global.save_game()
	print("💾 Game saved successfully! Current clock time:", Global.global_display_in_game_time)



func _on_exit_button_pressed() -> void:
	print("👋 Exit button pressed!")
	get_tree().quit()
