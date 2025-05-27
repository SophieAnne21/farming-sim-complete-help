extends Node2D

enum Season { SPRING, SUMMER, FALL, WINTER }

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                   = $fade/AnimationPlayer
@onready var spring_layer           = $SeasonLayers/SpringLayer
@onready var summer_layer           = $SeasonLayers/SummerLayer
@onready var fall_layer             = $SeasonLayers/FallLayer
@onready var winter_layer           = $SeasonLayers/WinterLayer
@onready var clock_label            = $UI/HBoxContainer/ClockLabel
@onready var date_label             = $UI/HBoxContainer/DateLabel
@onready var clock_underlay         = $UI/ColorRect
@onready var toFarm                 = $toFarmhouse
@onready var player                 = $Farmer
@onready var overlay                = $UI/DayNightOverlay

@onready var spawn_from_farmhouse_marker = $SpawnPoints/SpawnFromFarmhouse
@onready var spawn_from_town_marker = $SpawnPoints/SpawnFromTown
@onready var inventory              = $UI/Inventory
@onready var music                  = $Music
@onready var enterPromptFarmhouse   = $toFarmhouse/EnterPromptFarmhouse

const TOGGLE_INV = "toggle_inventory"
const season_names = ["Spring", "Summer", "Fall", "Winter"]

var destinations := {
	"fromTown":    "res://scenes/town_map.tscn",
	"toFarm":      "res://scenes/farm.tscn",
	"toFarmhouse": "res://scenes/farmhouse_interior.tscn"
}

var current_destination: String = ""
var day : int = 1
var month : int = 1
var days_in_month = [28, 28, 28, 28]
var _prev_time_passed : float = 0.0

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	Global.load_game()
	process_mode = Node.PROCESS_MODE_ALWAYS
	enterPromptFarmhouse.visible = false
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
	if current_destination != "" and Input.is_action_just_pressed("enter_door"):
		# this now both fades out *and* changes scene
		await transition_with_fade(destinations[current_destination])
		current_destination = ""
		return  # make extra sure we don’t resume any other code

	if !get_tree().paused:
		var prev = _prev_time_passed
		Global._process(delta)
		var curr = Global.global_time_passed
		Global.global_time_of_day = curr / Global.SECONDS_PER_DAY

		update_day_night_overlay()
		Global.global_display_in_game_time += (Global.CYCLE_HOURS / Global.SECONDS_PER_DAY) * delta
		update_clock()

		if curr < prev:
			day += 1
			if day > days_in_month[month - 1]:
				day = 1
				month = month % 4 + 1
			change_season()
			update_date_label()

		_prev_time_passed = curr

# ─── INPUT ─────────────────────────────────────────────────────────────────────
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

# ─── CLOCK / SEASON DISPLAY ────────────────────────────────────────────────────
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

func update_date_label() -> void:
	date_label.text = "%s %d" % [Global.current_season_name, day]

func change_season() -> void:
	spring_layer.visible = false
	summer_layer.visible = false
	fall_layer.visible = false
	winter_layer.visible = false
	spring_layer.z_index = -1
	summer_layer.z_index = -1
	fall_layer.z_index = -1
	winter_layer.z_index = -1
	player.z_index = 0

	match month:
		1: spring_layer.visible = true
		2: summer_layer.visible = true
		3: fall_layer.visible = true
		4: winter_layer.visible = true

	Global.current_season_name = season_names[month - 1]

# ─── DAY/NIGHT OVERLAY ─────────────────────────────────────────────────────────
func update_day_night_overlay() -> void:
	if overlay == null:
		return

	var clock_hour = Global.global_display_in_game_time
	if clock_hour >= 24.0:
		clock_hour -= 24.0

	var overlay_color: Color
	var t: float = 0.0

	if clock_hour >= 6.0 and clock_hour < 8.0:
		t = (clock_hour - 6.0) / 2.0
		overlay_color = Color(0.05, 0.05, 0.1, 0.5).lerp(Color(0, 0, 0, 0.1), t)
	elif clock_hour >= 8.0 and clock_hour < 18.0:
		overlay_color = Color(0, 0, 0, 0.1)
	elif clock_hour >= 18.0 and clock_hour < 20.0:
		t = (clock_hour - 18.0) / 2.0
		overlay_color = Color(0, 0, 0, 0.1).lerp(Color(0.05, 0.05, 0.1, 0.4), t)
	else:
		if clock_hour >= 20.0:
			t = (clock_hour - 20.0) / 10.0
		else:
			t = (clock_hour + 4.0) / 10.0
		overlay_color = Color(0.05, 0.05, 0.1, 0.4).lerp(Color(0, 0, 0, 0.7), t)

	overlay.color = overlay_color

# ─── TRANSITIONS / SPAWNS ──────────────────────────────────────────────────────
func _position_player_at_spawn() -> void:
	if Global.spawn_from == "toFarm":
		var target = spawn_from_town_marker.global_position
		player.global_position = target
		Global.player_position = target
		Global.save_game()
	else:
		player.global_position = Global.player_position
		Global.save_game()
	Global.player_position = player.global_position

func transition_with_fade(_scene_path: String) -> void:
	if player:
		Global.player_position = player.global_position

	fade.play("fade_to_black")
	await fade.animation_finished

	# Do the scene change *here*, before this function returns
	get_tree().change_scene_to_file(_scene_path)


# ─── AREA2D ─────────────────────────────────────────────────────────────────────
func _on_to_town_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "toTown"
		await transition_with_fade("res://scenes/town_map.tscn")

func _on_to_farmhouse_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		current_destination = "toFarmhouse"
		enterPromptFarmhouse.visible = true

func _on_to_farmhouse_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		current_destination = ""
		enterPromptFarmhouse.visible = false

# ─── SAVE ──────────────────────────────────────────────────────────────────────
func save_game() -> void:
	var config = ConfigFile.new()
	config.set_value("clock", "Global.global_time_passed", Global.global_time_passed)
	config.set_value("clock", "Global.global_display_in_game_time", Global.global_display_in_game_time)
	if player:
		Global.player_position = player.global_position
	config.save_encrypted_pass("user://save.cfg", "SimpleSaveLoad")
