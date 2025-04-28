extends Control

@onready var music: AudioStreamPlayer = null
@onready var brightness_overlay = get_tree().root.get_node("BrightnessOverlay")
@onready var toggle_music_button = $OptionsContainer/ToggleMusicButton
@onready var brightness_slider = $OptionsContainer/BrightnessSlider

func _ready():
	music = get_tree().get_first_node_in_group("Music")
	if music == null:
		printerr("⚠ No Music node found in scene!")

	brightness_slider.min_value = 0.1
	brightness_slider.max_value = 1.0
	brightness_slider.value = brightness_overlay.modulate.a

func _on_music_pause_play_pressed() -> void:
	if music and music.playing:
		music.stop()
		toggle_music_button.text = "Play Music"
	elif music:
		music.play()
		toggle_music_button.text = "Pause Music"

func _on_brightness_slider_value_changed(value: float) -> void:
	var color = brightness_overlay.modulate
	color.a = value
	brightness_overlay.modulate = color
