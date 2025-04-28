extends Node2D

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                 = $fade/AnimationPlayer
@onready var toTown               = $toTown
@onready var toFarmhouse          = $toFarmhouse
@onready var enterPromptFarmhouse = $CanvasLayer/EnterPromptFarmhouse
@onready var music                = $Music
@onready var body                 = $Farmer
@onready var overlay              = $CanvasLayer2/DayNightOverlay
@onready var inventory            = $CanvasLayer2/UI

# ─── CLOCK REFERENCES ──────────────────────────────────────────────────────────
@onready var clock_label : Label = $CanvasLayer2/ClockContainer/ClockLabel
@onready var clock_bg    : ColorRect = $CanvasLayer2/ClockContainer/ColorRect

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

var day: int = 1
var month: int = 1
var days_in_month := [28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28]

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

	fade.play("fade_to_normal")
	fade.get_parent().get_node("ColorRect").color.a = 255


	load_game()

	await get_tree().process_frame
	call_deferred("_position_player_at_spawn")

	update_date_label()  # 🛠 ADD THIS LINE HERE!


# ─── PROCESS ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if Input.is_action_just_pressed(TOGGLE_INV):
		inventory.visible = not inventory.visible
	if inventory.visible:
		return
	
	Global.global_time_passed += delta
	Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta

	update_day_night_overlay()
	update_clock()

	# 🔥 Day rollover if past 2:00 AM
	if Global.global_display_in_game_time >= 26.0:
		Global.global_display_in_game_time = 6.0
		day += 1
		if day > days_in_month[month - 1]:
			day = 1
			month += 1
			if month > 12:
				month = 1
		change_season()
		update_date_label()
		print("🗓 New day started! It's now day", day, "of month", month)

	
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
	if player:
		Global.player_position = player.global_position
	else:
		printerr("❌ Player not found during transition!")

	Global.last_scene = scene_path
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

	if Global.spawn_from == "fromFarmhouse":
		var target = spawn_from_Farmhouse_marker.global_position
		body.global_position = target
		Global.player_position = target
		save_game()
		Global.save_game()
		Global.spawn_from = ""
		print("✔️ RETURN from Farmhouse at:", target)
		return
		
	# If no special spawn, use last saved player position
	body.global_position = Global.player_position
	print("↩️ Loaded saved player position:", Global.player_position)
	Global.spawn_from = ""


# ─── CLOCK HELPERS ─────────────────────────────────────────────────────────────
func update_day_night_overlay() -> void:
	if overlay == null:
		return
	
	var clock_hour = Global.global_display_in_game_time
	if clock_hour >= 24.0:
		clock_hour -= 24.0
	
	var overlay_color: Color
	
	# Dawn (6 AM - 8 AM)
	if clock_hour >= 6 and clock_hour < 8:
		var t = (clock_hour - 6) / 2.0
		overlay_color = Color(0.05, 0.05, 0.1, 0.5).lerp(Color(0, 0, 0, 0.1), t)
	# Day (8 AM - 18 PM)
	elif clock_hour >= 8 and clock_hour < 18:
		overlay_color = Color(0, 0, 0, 0.1)
	# Dusk (6 PM - 8 PM)
	elif clock_hour >= 18 and clock_hour < 20:
		var t = (clock_hour - 18) / 2.0
		overlay_color = Color(0, 0, 0, 0.1).lerp(Color(0.05, 0.05, 0.1, 0.4), t)
	# Night (8 PM - 6 AM)
	else:
		if clock_hour >= 20:
			var t = (clock_hour - 20) / 10.0 if clock_hour >= 20 else (clock_hour + 4) / 10.0
			overlay_color = Color(0.05, 0.05, 0.1, 0.4).lerp(Color(0, 0, 0, 0.7), t)

	overlay.color = overlay_color


func update_clock() -> void:
	var hour = int(Global.global_display_in_game_time) % 24
	var minutes_float = (Global.global_display_in_game_time - int(Global.global_display_in_game_time)) * 60.0

	var minute = int(minutes_float / Global.MINUTE_STEP) * Global.MINUTE_STEP

	var am_pm = "am"
	if hour >= 12:
		am_pm = "pm"
	if hour > 12:
		hour -= 12
	if hour == 0:
		hour = 12

	clock_label.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2) + " " + am_pm

func force_end_of_day() -> void:
	print("🌙 Day ended. Resetting clock.")
	time_passed = 0.0
	time_of_day = 0.0

func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("clock", "Global.global_time_passed", Global.global_time_passed)
	config.set_value("clock", "Global.global_display_in_game_time", Global.global_display_in_game_time)

	# Save the player position if available
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.global_position
	else:
		print("❌ No player found to update position!")

	# Save encrypted
	config.save_encrypted_pass("user://save.cfg", "SimpleSaveLoad")  # <<< encrypted version now
	

func load_game() -> void:
	var cfg = ConfigFile.new()
	if cfg.load_encrypted_pass("user://save.cfg", "SimpleSaveLoad") == OK:  # <<< encrypted load now
		time_passed = cfg.get_value("clock", "Global.global_time_passed", time_passed)
		time_of_day = fposmod(time_passed / seconds_per_day, 1.0)
	else:
		print("⚠️ No saved clock data found.")
		Global.spawn_from = "newGame"
		
func change_season() -> void:
	# You can add your seasonal layer visibility logic here later
	print("🌱 Season changed (placeholder)!")

func update_date_label() -> void:
	# Update the UI label for the current date
	if has_node("CanvasLayer2/ClockContainer/DateLabel"):
		$CanvasLayer2/ClockContainer/DateLabel.text = "%s %d" % [Global.current_season_name, day]
