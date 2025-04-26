extends Node2D

@onready var fade                   = $fade/AnimationPlayer
@onready var toTown                 = $toTown
@onready var toFarmhouse            = $toFarmhouse
@onready var enterPromptFarmhouse   = $CanvasLayer/EnterPromptFarmhouse
@onready var music                  = $Music
@onready var pause_menu             = $Pause
@onready var body                   = $Farmer                             # Reference to player node
@onready var overlay                := $Farmer/Camera2D/DayNightOverlay   # Day/Night overlay
@onready var clock_label            = $Farmer/Camera2D/ClockLabel           # Clock UI label

# ─── CONSTANTS ────────────────────────────────────────────────────────────────
const START_HOUR   : float = 6.0    # 6 AM
const CYCLE_HOURS  : float = 20.0   # from 6 AM → next day 2 AM
const MINUTE_STEP  : int   = 5      # round minutes to nearest 5

# ─── TIME STATE ──────────────────────────────────────────────────────────────
var seconds_per_day : float = 1440.0  # real seconds for the full cycle
var time_passed     : float = 0.0   # real seconds since cycle start
var time_of_day     : float = 0.0   # normalized [0–1) across cycle

# ─── TRANSITION STATE ─────────────────────────────────────────────────────────
var current_destination: String = ""
var destinations := {
	"toTown":      "res://town_map.tscn",
	"toFarmhouse": "res://farmhouse_interior.tscn"
}

func _ready():
	set_process(true)
	fade.play("fade_to_normal")
	fade.get_parent().get_node("ColorRect").color.a = 255
	enterPromptFarmhouse.visible = false
	pause_menu.visible = false

	load_game()  # restore saved clock

func _process(delta: float) -> void:
	# ── advance clock
	time_passed += delta
	time_of_day = fposmod(time_passed / seconds_per_day, 1.0)

	if time_passed >= seconds_per_day:
		force_end_of_day()

	update_day_night_overlay()
	update_clock()

	# ── pause menu toggle
	if Input.is_action_just_pressed("toggle_menu"):
		pause_menu.visible = not pause_menu.visible

	# ── exit
	if Input.is_action_pressed("exit"):
		get_tree().quit()

	# ── door interaction
	if current_destination != "" and Input.is_action_just_pressed("enter_door"):
		if destinations.has(current_destination):
			await transition_with_fade(destinations[current_destination])
		else:
			printerr("🚨 Invalid destination key:", current_destination)
		current_destination = ""
		enterPromptFarmhouse.visible = false

# ── Auto-transition to Town on contact
func _on_to_town_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		Global.spawn_from = "fromFarmhouse"
		await transition_with_fade(destinations["toTown"])

# ── Show prompt for Farmhouse entry
func _on_to_farmhouse_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		current_destination = "toFarmhouse"
		enterPromptFarmhouse.text = "Enter Farmhouse"
		enterPromptFarmhouse.visible = true

func _on_to_farmhouse_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Player") and current_destination == "toFarmhouse":
		current_destination = ""
	enterPromptFarmhouse.visible = false

# ── Fade & change scene
func transition_with_fade(scene_path: String) -> void:
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.position
	else:
		printerr("❌ Player not found during transition!")

	Global.last_scene = scene_path
	save_game()        # persist clock
	Global.save_game() # persist other state

	await fade_out_music()
	fade.play("fade_to_black")
	await fade.animation_finished

	get_tree().change_scene_to_file(scene_path)

# ── Music fade out helper
func fade_out_music():
	if not music or not music.playing:
		return
	var fade_time = 2.0
	var start_volume = music.volume_db
	create_tween().tween_property(music, "volume_db", -80, fade_time).from(start_volume)
	await get_tree().create_timer(fade_time).timeout
	music.stop()

# ── Day/night overlay
func update_day_night_overlay():
	var brightness = sin(time_of_day * PI)
	var alpha = clamp(1.0 - brightness, 0.2, 0.6)
	var color = Color(0, 0, 0, alpha)

	if time_of_day < 0.2 or time_of_day > 0.8:
		color.r += 0.2; color.g += 0.1
	elif time_of_day > 0.4 and time_of_day < 0.6:
		color = Color(0, 0, 0, 0.2)
	elif time_of_day >= 0.6 and time_of_day <= 0.8:
		color.b += 0.2

	overlay.color = color

# ── On-screen clock (HH:MM, 5-minute steps)
func update_clock() -> void:
	# map [0–1) → START_HOUR … START_HOUR+CYCLE_HOURS
	var in_game = START_HOUR + time_of_day * CYCLE_HOURS
	var hour = int(in_game) % 24
	var raw_min = (in_game - int(in_game)) * 60.0
	var minute = int(raw_min / MINUTE_STEP) * MINUTE_STEP
	clock_label.text = str(hour).pad_zeros(2) + ":" + str(minute).pad_zeros(2)

# ── Reset at end of cycle (2 AM)
func force_end_of_day():
	print("🌙 Day ended. Resetting clock.")
	time_passed = 0.0
	time_of_day = 0.0

# ── Persist clock
func save_game() -> void:
	var cfg = ConfigFile.new()
	cfg.set_value("GameState", "time_passed", time_passed)
	if cfg.save_encrypted_pass("user://save.cfg", "YourKey") != OK:
		printerr("❌ Failed to save clock")

func load_game() -> void:
	var cfg = ConfigFile.new()
	if cfg.load_encrypted_pass("user://save.cfg", "YourKey") == OK:
		time_passed = cfg.get_value("GameState", "time_passed", time_passed)
		time_of_day = fposmod(time_passed / seconds_per_day, 1.0)
	else:
		print("⚠️ No saved clock data; starting at 6 AM.")
