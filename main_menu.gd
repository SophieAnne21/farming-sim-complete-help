extends Control

@onready var new_game_button = $NewGameButton
@onready var load_game_button = $LoadGameButton
@onready var settings_button = $SettingsButton
@onready var quit_button = $QuitButton

func _ready() -> void:
	pass  # You can add menu animations or music here if needed

# 🧹 Starts a new game and resets customization
func _on_new_game_button_pressed() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		var err = dir.remove("save.cfg")
		if err != OK:
			printerr("❌ Couldn’t delete save.cfg:", err)
	else:
		printerr("❌ Couldn’t access user:// directory")
				
	Global.set_defaults()  # Reset defaults like name and colors
	# Reset specific customization values (optional if already done in set_defaults)
	Global.selected_skin = ""
	Global.selected_hair = ""
	Global.selected_shirt = ""
	Global.selected_pants = ""
	Global.selected_shoes = ""
	Global.selected_acc = ""

	get_tree().change_scene_to_file("res://character_creator.tscn")

# ✅ Loads save file and switches to saved scene
func _on_load_game_button_pressed():
	if FileAccess.file_exists("user://settings.cfg") and Global.load_game():
		print("✅ Save found. Loading scene:", Global.last_scene)
		get_tree().change_scene_to_file(Global.last_scene)
	else:
		print("⚠️ No save file found. Starting new game.")
		get_tree().change_scene_to_file("res://character_creator.tscn")

func _on_settings_button_pressed():
	var settings_menu = preload("res://SettingsMenu.tscn").instantiate()
	add_child(settings_menu)

func _on_quit_button_pressed() -> void:
	get_tree().quit()
