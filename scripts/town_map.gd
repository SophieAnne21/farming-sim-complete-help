extends Node2D

enum Season { SPRING, SUMMER, FALL, WINTER }

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade         = $fade/AnimationPlayer
@onready var spring_layer = $SpringLayer
@onready var summer_layer = $SummerLayer
@onready var fall_layer   = $FallLayer
@onready var winter_layer = $WinterLayer
@onready var date_label = $UI/DateLabel
@onready var toFarm             = $toFarm
@onready var player             = $Farmer
@onready var overlay            = $UI/DayNightOverlay
@onready var clock_label        = $UI/ClockLabel
@onready var spawn_from_farm_marker = $SpawnMarker/SpawnFromFarm
@onready var inventory          = $UI/Inventory
@onready var music              = $Music

const TOGGLE_MENU : String = "toggle_menu"
const TOGGLE_INV  : String = "toggle_inventory"

# ─── DESTINATIONS ─────────────────────────────────────────────────────────────
var destinations := {
	"toFarm": "res://scenes/farm.tscn"
	
}

# ─── CLOCK & CALENDAR ─────────────────────────────────────────────────────────
var current_season      = Season.SPRING
var current_season_name : String = "Spring"
var day                 : int    = 1
var month               : int    = 1
var days_in_month       = [28,28,28,28,28,28,28,28,28,28,28,28]
var _prev_time_passed: float = 0.0

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	Global.load_game()

	await get_tree().process_frame
	await get_tree().process_frame  # (🔥 We double-wait to let Global settle)
	
	print("📍 Marker position:", spawn_from_farm_marker.global_position)
	
	call_deferred("_position_player_at_spawn")
	_prev_time_passed = Global.global_time_passed
	update_date_label()
	print("🗓 New day: Month %d, Day %d" % [month, day])
	update_clock()
	change_season()
	fade.play("fade_to_normal")

# ─── PROCESS ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	# ── Inventory toggle ───────────────────────────────────────────────────────
	if Input.is_action_just_pressed(TOGGLE_INV) and inventory:
		inventory.visible = not inventory.visible

	# ── Advance Global’s clock ─────────────────────────────────────────────────
	var prev = _prev_time_passed
	Global._process(delta)  # updates global_time_passed
	var curr = Global.global_time_passed
	# keep display_of_day in sync
	Global.global_time_of_day = curr / Global.SECONDS_PER_DAY

	# ── Day/night overlay & clock UI ───────────────────────────────────────────
	update_day_night_overlay()

	Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta
	update_clock()

	# ── Detect wrap (new day) ──────────────────────────────────────────────────
	if curr < prev:
		# we’ve just wrapped past the end of the cycle
		day += 1
		if day > days_in_month[month - 1]:
			day = 1
			month = month % 12 + 1
		# always refresh season and date label
		change_season()
		update_date_label()
		print("🗓 New day: Month %d, Day %d" % [month, day])

	# store for next frame’s comparison
	_prev_time_passed = curr

# ─── CLOCK DISPLAY ─────────────────────────────────────────────────────────────
# Example replacement in town_map.gd

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

# ─── SEASON HELPERS ────────────────────────────────────────────────────────────
func change_season() -> void:
	spring_layer.visible = false
	summer_layer.visible = false
	fall_layer.visible   = false
	winter_layer.visible = false

	match current_season:
		Season.SPRING:
			current_season_name = "Spring"; spring_layer.visible = true
		Season.SUMMER:
			current_season_name = "Summer"; summer_layer.visible = true
		Season.FALL:
			current_season_name = "Fall"; fall_layer.visible = true
		Season.WINTER:
			current_season_name = "Winter"; winter_layer.visible = true
			
	match month:
		10, 11, 12:
			Global.current_season_name = "Winter"
		1, 2, 3:
			Global.current_season_name = "Spring"
		4, 5, 6:
			Global.current_season_name = "Summer"
		7, 8, 9:
			Global.current_season_name = "Fall"


func update_date_label() -> void:
	date_label.text = "%s %d" % [Global.current_season_name, Global.day_count]

func next_day() -> void:
	day += 1
	if day > days_in_month[month - 1]:
		day = 1
		month = month % 12 + 1
	change_season()
	update_date_label()
	print("🗓 New day:", current_season_name, day)

# ─── DAY/NIGHT OVERLAY ─────────────────────────────────────────────────────────
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


# ─── SPAWN HANDLING ────────────────────────────────────────────────────────────
func _position_player_at_spawn() -> void:
	print("🔍 spawn_from =", Global.spawn_from)

	if Global.spawn_from == "fromFarm":
		var target = spawn_from_farm_marker.global_position
		player.global_position = target
		Global.player_position = target
		Global.save_game()
	else:
		player.global_position = Global.player_position

	# 🛡️ Update Global player position after clamping
	Global.player_position = player.global_position

	print("📍 Player final clamped position:", player.global_position)
	print("✅ Global player_position after clamping:", Global.player_position)


# ─── TRANSITIONS ──────────────────────────────────────────────────────────────
func transition_with_fade(_scene_path: String) -> void:
	if player != null:
		Global.player_position = player.global_position
	else:
		printerr("❌ Player not found during transition!")

	fade.play("fade_to_black")
	await fade.animation_finished

# ─── AREA2D TRIGGER ────────────────────────────────────────────────────────────
func _on_to_farm_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "fromTown"
		await transition_with_fade("res://scenes/farm.tscn")
		get_tree().change_scene_to_file("res://scenes/farm.tscn")
		print("🌀 Player entered toFarm!")

# ─── SAVE GAME ────────────────────────────────────────────────────────────
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
