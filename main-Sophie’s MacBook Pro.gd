extends Node2D

@onready var fade = $fade/AnimationPlayer
@onready var toTown = $toTown
@onready var toFarmhouse = $toFarmhouse
@onready var enterPromptFarmhouse = $CanvasLayer/EnterPromptFarmhouse
@onready var music = $Music  # Optional: only if you have background music
@onready var pause_menu = $Pause

var current_destination: String = ""
var destinations := {
	"toTown": "res://town_map.tscn",
	"toFarmhouse": "res://farmhouse_interior.tscn"
}

func _ready():
	set_process(true)
	fade.play("fade_to_normal")
	fade.get_parent().get_node("ColorRect").color.a = 255
	enterPromptFarmhouse.visible = false

func _process(_delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()

	if current_destination != "" and Input.is_action_just_pressed("enter_door"):
		await transition_with_fade(destinations[current_destination])
		current_destination = ""
		enterPromptFarmhouse.visible = false
		
	if Input.is_action_just_pressed("toggle_menu"):
		pause_menu.visible = not pause_menu.visible
		if pause_menu.visible:
			pause_menu.grab_focus()

# Auto-transition to Town
func _on_to_town_body_entered(_body: Node2D) -> void:
	if _body.name == "Player":
		await transition_with_fade(destinations["toTown"])

# Farmhouse requires interaction
func _on_to_farmhouse_body_entered(_body: Node2D) -> void:
	if _body.name == "Player":
		current_destination = "toFarmhouse"
		enterPromptFarmhouse.text = "Enter Farmhouse"
		enterPromptFarmhouse.visible = true

func _on_to_farmhouse_body_exited(_body: Node2D) -> void:
	if _body.name == "Player" and current_destination == "toFarmhouse":
		current_destination = ""
	enterPromptFarmhouse.visible = false

# ✨ Scene transition with save and music fade
func transition_with_fade(scene_path: String) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.position

	Global.last_scene = scene_path
	await fade_out_music()

	fade.play("fade_to_black")
	await fade.animation_finished

	
	print("📍 Saving player position:", Global.player_position)
	get_tree().change_scene_to_file(scene_path)
	Global.save_game()
	
func fade_out_music():
	if not music or not music.playing:
		return
	var fade_time = 2.0
	var start_volume = music.volume_db
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80, fade_time).from(start_volume)
	await get_tree().create_timer(fade_time).timeout
	music.stop()
