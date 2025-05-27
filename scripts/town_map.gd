extends Node2D

enum Season { SPRING, SUMMER, FALL, WINTER }

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                   = $fade/AnimationPlayer
@onready var spring_layer           = $SpringLayer
@onready var summer_layer           = $SummerLayer
@onready var fall_layer             = $FallLayer
@onready var winter_layer           = $WinterLayer
@onready var date_label             = $UI/HBoxContainer/DateLabel
@onready var toFarm                 = $toFarm
@onready var player                 = $Farmer
@onready var overlay                = $UI/DayNightOverlay
@onready var clock_label            = $UI/HBoxContainer/ClockLabel
@onready var spawn_from_farm_marker = $SpawnPoints/SpawnFromFarm
@onready var inventory              = $UI/Inventory
@onready var music                  = $Music

const TOGGLE_MENU : String = "toggle_menu"
const TOGGLE_INV  : String = "toggle_inventory"

const season_names = ["Spring", "Summer", "Fall", "Winter"]

# ─── DESTINATIONS ─────────────────────────────────────────────────────────────
var destinations := {
	"toFarm": "res://scenes/farm.tscn",
	"fromTown": "res://scenes/town_map.tscn"
}
# ─── CLOCK & CALENDAR ─────────────────────────────────────────────────────────
# month now 1–4 maps to seasons
var day           : int    = 1
var month         : int    = 1
var days_in_month = [28, 28, 28, 28]
var _prev_time_passed: float = 0.0

var paused = false

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	Global.load_game()
	process_mode = Node.PROCESS_MODE_ALWAYS
	await get_tree().process_frame
	await get_tree().process_frame

	call_deferred("_position_player_at_spawn")
	_prev_time_passed = Global.global_time_passed

	# Make inventory and UI elements process when paused
	if inventory:
		inventory.process_mode = Node.PROCESS_MODE_ALWAYS
		
	if clock_label:
		clock_label.process_mode = Node.PROCESS_MODE_PAUSABLE
	
	if music:
		music.process_mode = Node.PROCESS_MODE_PAUSABLE

	if inventory:
		inventory.visible = false

	update_date_label()
	update_clock()
	change_season()
	fade.play("fade_to_normal")

# ─── PROCESS ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	update_day_night_overlay()
	Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta
	update_clock()
	
	if !get_tree().paused:
		var prev = _prev_time_passed
		Global._process(delta)
		var curr = Global.global_time_passed
		Global.global_time_of_day = curr / Global.SECONDS_PER_DAY

		update_day_night_overlay()
		Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta
		update_clock()
		
		if curr < prev:
			# New day
			day += 1
			if day > days_in_month[month - 1]:
				# Reset day, advance to next season
				day = 1
				month = month % 4 + 1
			change_season()
			update_date_label()

		_prev_time_passed = curr

# ─── PAUSE STATE ─────────────────────────────────────────────────────────────
func _input(event: InputEvent) -> void:
	if Input.is_action_just_pressed(TOGGLE_INV):
		if inventory.visible:
			inventory.visible = false
			Global.paused = false
			get_tree().paused = false
		else:
			inventory.visible = true
			Global.paused = true
			get_tree().paused = true
			
# ─── CLOCK DISPLAY ─────────────────────────────────────────────────────────────
func update_clock() -> void:
	if clock_label == null:
		return
	var display_time = Global.global_display_in_game_time
	if display_time >= 24.0:
		display_time -= 24.0
	var hour_24 = int(display_time)
	var minute  = int((display_time - hour_24) * 60.0)
	minute = int(minute / float(Global.MINUTE_STEP)) * Global.MINUTE_STEP
	var am_pm: String
	if hour_24 >= 12:
		am_pm = "pm"
	else:
		am_pm = "am"
	var hour_12 = hour_24 % 12
	if hour_12 == 0:
		hour_12 = 12
	clock_label.text = "%02d:%02d %s" % [hour_12, minute, am_pm]

# ─── SEASON HELPERS ────────────────────────────────────────────────────────────
func change_season() -> void:
	# Hide all
	spring_layer.visible = false
	summer_layer.visible = false
	fall_layer.visible   = false
	winter_layer.visible = false

	# Show layer and set global name based on month (1–4)
	if month == 1:
		spring_layer.visible = true
	elif month == 2:
		summer_layer.visible = true
	elif month == 3:
		fall_layer.visible = true
	else:
		winter_layer.visible = true

	Global.current_season_name = season_names[month - 1]
	print("Season changed to:", Global.current_season_name)

func update_date_label() -> void:
	date_label.text = "%s %d" % [Global.current_season_name, day]
	print("update_date_label():", date_label.text)

# ─── DAY/NIGHT OVERLAY ─────────────────────────────────────────────────────────
func update_day_night_overlay() -> void:
	if overlay == null:
		return
	var clock_hour = Global.global_display_in_game_time
	if clock_hour >= 24.0:
		clock_hour -= 24.0

	var overlay_color: Color
	var t: float = 0.0

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

# ─── SPAWN HANDLING & TRANSITIONS ──────────────────────────────────────────────
func _position_player_at_spawn() -> void:
	if Global.spawn_from == "newGame":
		var target = spawn_from_farm_marker.global_position
		player.global_position = target
		Global.player_position = target
		Global.save_game()
	else:
		player.global_position = Global.player_position
	Global.player_position = player.global_position

func transition_with_fade(_scene_path: String) -> void:
	if player:
		Global.player_position = player.global_position

	fade.play("fade_to_black")
	await fade.animation_finished

	get_tree().change_scene_to_file(_scene_path)
	
func _on_to_farm_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "fromTown"
		await transition_with_fade("res://scenes/farm.tscn")

# ─── SAVE GAME ────────────────────────────────────────────────────────────────
func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("clock", "Global.global_time_passed", Global.global_time_passed)
	config.set_value("clock", "Global.global_display_in_game_time", Global.global_display_in_game_time)
	if player:
		Global.player_position = player.global_position
	config.save_encrypted_pass("user://save.cfg", "SimpleSaveLoad")
