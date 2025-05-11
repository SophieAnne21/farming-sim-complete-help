extends Node2D

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                 = $fade/AnimationPlayer
@onready var toTown               = $toTown
@onready var toFarmhouse          = $toFarmhouse
@onready var enterPromptFarmhouse = $EnterPrompt/EnterPromptFarmhouse
@onready var music                = $Music
@onready var body                 = $Farmer
@onready var overlay              = $UI/DayNightOverlay
@onready var inventory            = $UI/UI

# ─── CLOCK REFERENCES ──────────────────────────────────────────────────────────
@onready var date_label : Label     = $UI/DateLabel
@onready var clock_label: Label     = $UI/ClockLabel
@onready var clock_bg    : ColorRect = $UI/ColorRect

# ─── SPAWN MARKERS ─────────────────────────────────────────────────────────────
@onready var spawn_from_town_marker       : Marker2D = $SpawnPoints/SpawnFromTown
@onready var new_game_marker              : Marker2D = $SpawnPoints/NewSpawn
@onready var spawn_from_farmhouse_marker : Marker2D = $SpawnPoints/SpawnFromFarmhouse

# ─── INPUT ACTIONS ─────────────────────────────────────────────────────────────
const TOGGLE_MENU : String = "toggle_menu"
const TOGGLE_INV  : String = "toggle_inventory"

# ─── DAY & MONTH STATE ─────────────────────────────────────────────────────────
var day: int = 1
var month: int = 1
var days_in_month := [28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28, 28]

# ─── SCENE DESTINATIONS ─────────────────────────────────────────────────────────
var current_destination: String = ""
var destinations := {
	"toTown":      "res://scenes/town_map.tscn",
	"toFarmhouse": "res://scenes/farmhouse_interior.tscn",
	"toFarm" :     "res://scenes/farm.tscn"
}

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	set_process(true)
	# Use Global singleton for persistent clock and state
	Global.load_game()
	await get_tree().process_frame
	call_deferred("_position_player_at_spawn")

	fade.play("fade_to_normal")
	overlay.color.a = 255

	update_date_label()
	print("🗓 New day: Month %d, Day %d" % [month, day])

# ─── MAIN LOOP ─────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# Toggle inventory display
	if Input.is_action_just_pressed(TOGGLE_INV) and inventory:
		inventory.visible = not inventory.visible

	# Advance the global clock
	Global._process(delta)

	update_day_night_overlay()
	update_clock()

	# Handle day rollover at end of cycle
	var END_HOUR = Global.START_HOUR + Global.CYCLE_HOURS
	if Global.global_display_in_game_time >= END_HOUR:
		Global.global_display_in_game_time = Global.START_HOUR
		day += 1
		if day > days_in_month[month - 1]:
			day = 1
			month = month % 12 + 1
		change_season()
		update_date_label()
	

	# Exit action
	if Input.is_action_just_pressed("exit"):
		_save_and_exit()

	# Scene entry action
	if current_destination != "" and Input.is_action_just_pressed("enter_door"):
		if destinations.has(current_destination):
			await transition_with_fade(destinations[current_destination])
		else:
			printerr("🚨 Invalid destination key:", current_destination)
		current_destination = ""

# ─── WINDOW & EXIT HANDLING ────────────────────────────────────────────────────
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		_save_before_quit()

func _save_and_exit() -> void:
	_save_before_quit()
	get_tree().quit()

func _save_before_quit() -> void:
	if body:
		Global.player_position = body.global_position
		print("💾 Saving player position:", Global.player_position)
	else:
		print("❌ Player body not found; using last known position.")

	save_game()
	Global.save_game()

# ─── SCENE TRANSITIONS ─────────────────────────────────────────────────────────
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
		Global.spawn_from = "fromFarm"
		print("✅ Setting spawn_from to 'fromFarm'")
		await transition_with_fade(destinations["toTown"])

func _on_to_farmhouse_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		current_destination = "toFarmhouse"
		enterPromptFarmhouse.visible = true

func _on_to_farmhouse_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		current_destination = ""
		enterPromptFarmhouse.visible = false

# ─── PLAYER SPAWN LOGIC ────────────────────────────────────────────────────────
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
		save_game(); Global.save_game()
		Global.spawn_from = ""
		print("✔️ RETURN from Town at:", target)
		return

	if Global.spawn_from == "fromFarmhouse":
		var target = spawn_from_farmhouse_marker.global_position
		body.global_position = target
		Global.player_position = target
		save_game(); Global.save_game()
		Global.spawn_from = ""
		print("✔️ RETURN from Farmhouse at:", target)
		return

	# Default to last saved position
	body.global_position = Global.player_position
	print("↩️ Loaded saved player position:", Global.player_position)
	Global.spawn_from = ""

# ─── DAY/NIGHT & CLOCK HELPERS ─────────────────────────────────────────────────
func update_day_night_overlay() -> void:
	if overlay == null:
		return
	var clock_hour = Global.global_display_in_game_time
	if clock_hour >= 24.0:
		clock_hour -= 24.0

	var overlay_color: Color
	var t: float
	if clock_hour >= 6 and clock_hour < 8:
		t = (clock_hour - 6) / 2.0
		overlay_color = Color(0.05, 0.05, 0.1, 0.5).lerp(Color(0, 0, 0, 0.1), t)
	elif clock_hour >= 8 and clock_hour < 18:
		overlay_color = Color(0, 0, 0, 0.1)
	elif clock_hour >= 18 and clock_hour < 20:
		t = (clock_hour - 18) / 2.0
		overlay_color = Color(0, 0, 0, 0.1).lerp(Color(0.05, 0.05, 0.1, 0.4), t)
	else:
		if clock_hour >= 20:
			t = (clock_hour - 20) / 10.0
		else:
			t = (clock_hour + 4) / 10.0
		overlay_color = Color(0.05, 0.05, 0.1, 0.4).lerp(Color(0, 0, 0, 0.7), t)

	overlay.color = overlay_color

func update_clock() -> void:
	if clock_label == null:
		return

	var display_time = Global.global_display_in_game_time
	if display_time >= 24.0:
		display_time -= 24.0

	var hour_24 = int(display_time)
	var minute  = int((display_time - hour_24) * 60.0)
	minute = int(minute / float(Global.MINUTE_STEP)) * Global.MINUTE_STEP

	# Explicit if/else instead of ternary
	var am_pm: String
	if hour_24 >= 12:
		am_pm = "pm"
	else:
		am_pm = "am"

	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12

	clock_label.text = "%02d:%02d %s" % [hour_12, minute, am_pm]

func force_end_of_day() -> void:
	print("🌙 Day ended. (Not used)")


# ─── SAVE/LOAD (to refactor next) ───────────────────────────────────────────────
func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("clock", "Global.global_time_passed", Global.global_time_passed)
	config.set_value("clock", "Global.global_display_in_game_time", Global.global_display_in_game_time)
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.global_position
	else:
		print("❌ No player found to update position!")
	config.save_encrypted_pass("user://save.cfg", "SimpleSaveLoad")

func load_game() -> void:
	var cfg = ConfigFile.new()
	if cfg.load_encrypted_pass("user://save.cfg", "SimpleSaveLoad") == OK:
		# Local clock vars remain only until fully refactored
		Global.global_time_passed = cfg.get_value("clock", "Global.global_time_passed", Global.global_time_passed)
		Global.global_time_of_day = fposmod(Global.global_time_passed / Global.global_seconds_per_day, 1.0)
	else:
		print("⚠️ No saved clock data found.")
		Global.spawn_from = "newGame"

func change_season() -> void:
	print("🌱 Season changed (placeholder)!")

func update_date_label() -> void:
	date_label.text = "%s %d" % [Global.current_season_name, Global.day_count]
