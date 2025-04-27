extends CanvasLayer


@onready var save_button = $Control/ColorRect/SaveButton
@onready var exit_button = $Control/ColorRect/ExitButton
@onready var main_script = get_tree().get_current_scene()  # adjust to point at your main.gd node

func _ready() -> void:
	hide()  # Start hidden

func _on_save_button_pressed() -> void:
	print("✅ Save button pressed!")
	var player = get_tree().get_first_node_in_group("Player")

	if player:
		Global.player_position = player.position
		Global.save_game()
		print("📍 Player position saved at:", Global.player_position)
	else:
		print("❌ Player not found in 'Player' group — not saved")
		
	main_script.save_game()      # write user://save.cfg with time_passed
	Global.save_game()           # write your other global data
	print("⏱ Saved game at", main_script.clock_label.text)

func _on_exit_button_pressed() -> void:
	print("👋 Exit button pressed!")
	get_tree().quit()


func _on_resume_pressed() -> void:
	hide()
	print("↩️ Returning to game!")
