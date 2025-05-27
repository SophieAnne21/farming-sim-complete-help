extends CanvasLayer

@onready var pause_menu = $"."
@onready var pause_manager = $"/root/PauseManager"

func _ready():
	# Connect to the pause manager's signal
	pause_manager.pause_state_changed.connect(_on_pause_state_changed)
	
	# Hide pause menu at start
	pause_menu.hide()

func _input(event):
	# You can handle pause input here or in a separate script
	if event.is_action_pressed("toggle_pause"):
		pause_manager.toggle_pause()

func _on_pause_state_changed(is_paused: bool):
	if is_paused:
		pause_menu.show()
	else:
		pause_menu.hide()

# Connected to Resume button press
func _on_resume_button_pressed():
	pause_menu.hide()

# Connected to Options button press
func _on_options_button_pressed():
	# Show options panel
	# You would implement this based on your game's UI design
	pass

# Connected to Quit button press
func _on_exit_button_pressed():
	get_tree().quit()
