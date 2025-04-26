extends Node2D

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                 = $fade/AnimationPlayer
@onready var toTown               = $toTown
@onready var toFarmhouse          = $toFarmhouse
@onready var enterPromptFarmhouse = $CanvasLayer/EnterPromptFarmhouse
@onready var music                = $Music
@onready var pause_menu           = $Farmer/Pause
@onready var body                 = $Farmer
@onready var overlay              = $Farmer/DayNightOverlay
@onready var inventory            = $Farmer/UI

# ─── CLOCK REFERENCES ──────────────────────────────────────────────────────────
@onready var clock_label : Label = $Farmer/ClockContainer/ClockLabel
@onready var clock_bg    : ColorRect = $Farmer/ClockContainer/ColorRect
@onready var date_label  : Label = $Farmer/ClockContainer/DateLabel# if you have a date

# ─── SPAWN MARKERS ─────────────────────────────────────────────────────────────
@onready var spawn_from_town_marker : Marker2D = $SpawnPoints/SpawnFromTown
@onready var new_game_marker        : Marker2D = $SpawnPoints/NewSpawn
@onready var spawn_from_Farmhouse_marker : Marker2D = $SpawnPoints/SpawnFromFarmhouse

# ─── INPUT ACTIONS ────────────────────────────────────────────────────────────
const TOGGLE_MENU : String = "toggle_menu"
const TOGGLE_INV  : String = "toggle_inventory"

# ─── TIME CONSTANTS & STATE ────────────────────────────────────────────────────
const START_HOUR   : float = 6.0
const CYCLE_HOURS  : float = 20.0

var seconds_per_day : float = 7200.0
var time_passed     : float = 0.0
var time_of_day     : float = 0.0

# ─── SCENE DESTINATIONS ────────────────────────────────────────────────────────
var current_destination: String = ""
var destinations := {
	"toTown":      "res://town_map.tscn",
	"toFarmhouse": "res://farmhouse_interior.tscn",
	"toFarm" : "res://farm.tscn" 
}

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	set_process(true)
	print("🔍 DEBUG: Before load_game, Global position =", Global.player_position)
	load_game()
	print("🔍 DEBUG: After load_game, Global position =", Global.player_position)
	
	await get_tree().process_frame
	call_deferred("_position_player_at_spawn")

	# No about_to_quit connect needed — handled by _notification()

	fade.play("fade_to_normal")
	fade.get_parent().get_node("ColorRect").color.a = 255
	pause_menu.visible = false
	inventory.visible  = false

	load_game()

	await get_tree().process_frame
	call_deferred("_position_player_at_spawn")

# ─── PROCESS ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(TOGGLE_MENU):
		pause_menu.visible = not pause_menu.visible
	if Input.is_action_just_pressed(TOGGLE_INV):
		inventory.visible = not inventory.visible
	if pause_menu.visible or inventory.visible:
		return

	time_passed += delta
	time_of_day = fposmod(time_passed / seconds_per_day, 1.0)

	if time_passed >= seconds_per_day:
		force_end_of_day()

	update_day_night_overlay()
	update_clock()

	if Input.is_action_just_pressed("exit"):
		_save_and_exit()

	if current_destination != "" and Input.is_action_just_pressed("enter_door"):
		if destinations.has(current_destination):
			await transition_with_fade(destinations[current_destination])
		else:
			printerr("🚨 Invalid destination key:", current_destination)
		current_destination = ""
		enterPromptFarmhouse.visible = false

# ─── SCENE EXIT HANDLERS ───────────────────────────────────────────────────────
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_before_quit()

func _save_and_exit() -> void:
	_save_before_quit()
	get_tree().quit()

func _save_before_quit() -> void:
	if body != null:
		Global.player_position = body.global_position
		print("💾 Saving player position:", Global.player_position)
	else:
		print("❌ Player body not found — using last known position.")

	save_game()
	Global.save_game()

# ─── SCENE TRANSITION ──────────────────────────────────────────────────────────
func transition_with_fade(scene_path: String) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player != null:
		Global.player_position = player.global_position
	else:
		printerr("❌ Player not found during transition!")

	Global.last_scene = scene_path
	save_game()
	Global.save_game()

	await fade_out_music()
	fade.play("fade_to_black")
	await fade.animation_finished
	get_tree().change_scene_to_file(scene_path)

func fade_out_music() -> void:
	if music == null or not music.playing:
		return
	var fade_time = 2.0
	var tween = create_tween()
	tween.tween_property(music, "volume_db", -80, fade_time)
	await get_tree().create_timer(fade_time).timeout
	music.stop()

# ─── DOOR INTERACTIONS ────────────────────────────────────────────────────────
func _on_to_town_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "fromFarmhouse"
		await transition_with_fade(destinations["toTown"])

func _on_to_farmhouse_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		current_destination = "toFarmhouse"
		enterPromptFarmhouse.text = "Enter Farmhouse"
		enterPromptFarmhouse.visible = true

func _on_to_farmhouse_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Player") and current_destination == "toFarmhouse":
		current_destination = ""
		enterPromptFarmhouse.visible = false

# ─── PLAYER SPAWN ─────────────────────────────────────────────────────────────
func _position_player_at_spawn() -> void:
	print("🔍 spawn_from =", Global.spawn_from)

	if Global.spawn_from == "newGame":
		var target = new_game_marker.global_position
		body.global_position = target
		Global.player_position = target
		save_game()
		Global.save_game()
		Global.spawn_from = ""
		print("✔️ NEW GAME spawn at:", target)
		return

	if Global.spawn_from == "fromTown":
		var target = spawn_from_town_marker.global_position
		body.global_position = target
		Global.player_position = target
		save_game()
		Global.save_game()
		Global.spawn_from = ""
		print("✔️ RETURN from Town at:", target)
		return
		
	if Global.spawn_from == "fromFarm":
			var target = spawn_from_Farmhouse_marker.global_position
			body.global_position = target
			Global.player_position = target
			save_game()
			Global.save_game()
			Global.spawn_from = ""
			print("✔️ RETURN from Farmhouse at:", target)
			return
	body.global_position = Global.player_position
	print("↩️ Loaded saved player position:", Global.player_position)
	Global.spawn_from = ""

# ─── CLOCK HELPERS ─────────────────────────────────────────────────────────────
func update_day_night_overlay() -> void:
	if overlay == null:
		return
	var brightness = sin(time_of_day * PI)
	var alpha = clamp(1.0 - brightness, 0.2, 0.6)
	var color = Color(0, 0, 0, alpha)
	if time_of_day < 0.2 or time_of_day > 0.8:
		color = Color(0.1, 0.07, 0.04, alpha)
	elif time_of_day > 0.4 and time_of_day < 0.6:
		color = Color(0, 0, 0, 0.15)
	elif time_of_day >= 0.6 and time_of_day <= 0.8:
		color.b += 0.2
	overlay.color = color

func update_clock() -> void:
	var in_game = Global.START_HOUR + Global.time_of_day * Global.CYCLE_HOURS
	var hour    = int(in_game) % 24
	var raw_min = (in_game - int(in_game)) * 60.0
	var minute  = int(raw_min / Global.MINUTE_STEP) * Global.MINUTE_STEP
	clock_label.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2)

	# === Now add the color swap
	if hour >= 6 and hour < 18:
	# Daytime
		clock_label.add_theme_color_override("font_color", Color(0,0,0)) # Black text
		date_label.add_theme_color_override("font_color", Color(0,0,0))
	else:
		# Nighttime
		clock_label.add_theme_color_override("font_color", Color(1,1,1)) # White text
		date_label.add_theme_color_override("font_color", Color(1,1,1))


func force_end_of_day() -> void:
	print("🌙 Day ended. Resetting clock.")
	time_passed = 0.0
	time_of_day = 0.0

func save_game() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("GameState", "time_passed", time_passed)
	if cfg.save_encrypted_pass("user://save.cfg", "SimpleSaveLoad") != OK:
		printerr("❌ Failed to save clock")

func load_game() -> void:
	var cfg = ConfigFile.new()
	if cfg.load_encrypted_pass("user://save.cfg", "SimpleSaveLoad") == OK:
		time_passed = cfg.get_value("GameState", "time_passed", time_passed)
		time_of_day = fposmod(time_passed / seconds_per_day, 1.0)
	else:
		print("⚠️ No saved clock data found.")
		Global.spawn_from = "newGame"
