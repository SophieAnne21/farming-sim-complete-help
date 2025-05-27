extends Control

# This script is attached to the PauseMenu control node

func _ready():
	# Ensure that the UI can still function when the game is paused
	process_mode = Node.PROCESS_MODE_WHEN_PAUSED

# Optional animation for the pause menu
func animate_in():
	# Add animations as needed
	# Example: scale from 0 to 1 with a bounce effect
	scale = Vector2.ZERO
	var tween = create_tween()
	tween.tween_property(self, "scale", Vector2.ONE, 0.3).set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)

# Optional fade out animation when unpausing
func animate_out():
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1, 1, 1, 0), 0.2)
	await tween.finished
	self.modulate = Color(1, 1, 1, 1)  # Reset modulate for next time
