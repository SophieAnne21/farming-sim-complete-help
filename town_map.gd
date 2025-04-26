extends Node2D

enum Season { SPRING, SUMMER, FALL, WINTER }

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade               : AnimationPlayer = $fade/AnimationPlayer
@onready var spring_layer       : TileMapLayer    = $SpringLayer
@onready var summer_layer       : TileMapLayer    = $SummerLayer
@onready var fall_layer         : TileMapLayer    = $FallLayer
@onready var winter_layer       : TileMapLayer    = $WinterLayer
@onready var current_date_label : Label           = $Farmer/CanvasLayer2/CurrentDateLabel
@onready var toFarm             : Area2D          = $toFarm
@onready var player             : CharacterBody2D = $Farmer
@onready var overlay            : ColorRect       = $Farmer/CanvasLayer2/DayNightOverlay
@onready var clock_label        : Label           = $Farmer/CanvasLayer2/ClockLabel
@onready var spawn_from_farmhouse_marker: Marker2D = $SpawnPoints/SpawnFromFarmhouse

# ─── DESTINATIONS ─────────────────────────────────────────────────────────────
var destinations := {
	"toFarm": "res://farm.tscn"
}

# ─── CLOCK & CALENDAR ─────────────────────────────────────────────────────────
var current_season      = Season.SPRING
var current_season_name : String = "Spring"
var day                 : int    = 1
var month               : int    = 1
var days_in_month       = [28,28,28,28,28,28,28,28,28,28,28,28]

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	change_season()
	call_deferred("_position_player_at_spawn")
	update_date_label()
	update_clock()
	fade.play("fade_to_normal")

# ─── PROCESS ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	Global.global_time_passed += delta
	Global.global_time_of_day = Global.global_time_passed / Global.SECONDS_PER_DAY

	update_day_night_overlay()

	Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta

	update_clock()

	# Reset day at 2:00 AM
	var real_in_game = Global.START_HOUR + Global.global_time_of_day * Global.CYCLE_HOURS
	if real_in_game >= 26.0:
		Global.global_time_passed = 0.0
		Global.global_time_of_day = 0.0
		Global.global_display_in_game_time = Global.START_HOUR
		next_day()

# ─── CLOCK DISPLAY ─────────────────────────────────────────────────────────────
func update_clock() -> void:
	var hour = int(Global.global_display_in_game_time) % 24
	var minutes_float = (Global.global_display_in_game_time - int(Global.global_display_in_game_time)) * 60.0

	var minute = int(minutes_float / Global.MINUTE_STEP) * Global.MINUTE_STEP

	var am_pm = "AM"
	if hour >= 12:
		am_pm = "PM"
	if hour > 12:
		hour -= 12
	if hour == 0:
		hour = 12

	clock_label.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2) + " " + am_pm

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

func update_date_label() -> void:
	current_date_label.text = "%s (%d)" % [current_season_name, day]

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
	var clock_hour = Global.global_time_of_day * 24.0 + 6
	if clock_hour >= 24:
		clock_hour -= 24

	var overlay_color: Color

	if clock_hour >= 6 and clock_hour < 8:
		var t = (clock_hour - 6) / 2.0
		overlay_color = Color(0.1, 0.07, 0.04, 0.4).lerp(Color(0, 0, 0, 0.1), t)
	elif clock_hour >= 8 and clock_hour < 18:
		overlay_color = Color(0, 0, 0, 0.1)
	elif clock_hour >= 18 and clock_hour < 20:
		var t = (clock_hour - 18) / 2.0
		overlay_color = Color(0, 0, 0, 0.1).lerp(Color(0.05, 0.05, 0.1, 0.3), t)
	else:
		if clock_hour >= 20:
			var t = (clock_hour - 20) / 10.0
			overlay_color = Color(0.05, 0.05, 0.1, 0.3).lerp(Color(0, 0, 0, 0.6), t)
		else:
			var t = (clock_hour + 4) / 10.0
			overlay_color = Color(0.05, 0.05, 0.1, 0.3).lerp(Color(0, 0, 0, 0.6), t)

	overlay.color = overlay_color


# ─── SPAWN HANDLING ────────────────────────────────────────────────────────────
func _position_player_at_spawn() -> void:
	print("🔍 spawn_from =", Global.spawn_from)

	if Global.spawn_from == "fromFarmhouse":
		var target = spawn_from_farmhouse_marker.global_position
		player.global_position = target
		Global.player_position = target
		Global.spawn_from = ""
		Global.save_game()
		return

	Global.spawn_from = ""

# ─── TRANSITIONS ──────────────────────────────────────────────────────────────
func transition_with_fade(scene_path: String) -> void:
	if player != null:
		Global.player_position = player.global_position
	else:
		printerr("❌ Player not found during transition!")

	fade.play("fade_to_black")
	await fade.animation_finished

# ─── AREA2D TRIGGER ────────────────────────────────────────────────────────────
func _on_to_farm_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "fromFarmhouse"
		await transition_with_fade(destinations["toFarm"])
		get_tree().change_scene_to_file("res://farm.tscn")

		print("🌀 Player entered toFarm!")
		
