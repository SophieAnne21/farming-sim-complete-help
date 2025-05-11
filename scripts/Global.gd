# Global.gd
extends Node

# ─── CONSTANTS ────────────────────────────────────────────────────────────────
const START_HOUR: int        = 6       # In-game day starts at 6 AM
const CYCLE_HOURS: float     = 20.0    # Total in-game hours per day (6 AM–2 AM)
const SECONDS_PER_DAY: float = 10800.0 # Real-world seconds for a full day cycle
const MINUTE_STEP: int       = 5       # If you later want to snap display to 5-minute increments

# ─── TIME STATE (consolidated) ────────────────────────────────────────────────
var global_time_passed: float          = 0.0  # Accumulated real-world seconds
var global_time_of_day: float          = 0.0  # Normalized (0.0–1.0) through the day
var global_display_in_game_time: float = START_HOUR
var day_count: int = 1

# ─── CAMERA LIMITS ────────────────────────────────────────────────────────────
var camera_limit_left:  float = 0.0
var camera_limit_right: float = 0.0
var camera_limit_top:   float = 0.0
var camera_limit_bottom: float = 0.0

# ─── UI STATE ─────────────────────────────────────────────────────────────────
var is_inventory_open:  bool = false
var is_pause_menu_open: bool = false

# ─── SAVE/LOAD KEYS & STATE ────────────────────────────────────────────────────
var key:               String   = "SimpleSaveLoad"
var player_position:   Vector2  = Vector2.ZERO
var player_name:       String   = ""            # ⬅ now blank by default
var last_scene:        String   = "res://scenes/farm.tscn"
var cc:                String   = "res://scenes/character_creator.tscn"
var spawn_from:        String   = ""
var current_season_name: String = "Spring"

# ─── Selected Customization ────────────────────────────────────────────────────
var selected_skin:     String = ""
var selected_eyes:     String = ""
var selected_hair:     String = ""
var selected_fullbody: String = "none"
var selected_shirt:    String = ""
var selected_pants:    String = ""
var selected_shoes:    String = ""
var selected_acc:      String = ""

# ─── Color Selections ──────────────────────────────────────────────────────────
var selected_skin_color:     Color = Color(1, 1, 1)
var selected_eyes_color:     Color = Color(1, 1, 1)
var selected_hair_color:     Color = Color(1, 1, 1)
var selected_fullbody_color: Color = Color(1, 1, 1)
var selected_shirt_color:    Color = Color(1, 1, 1)
var selected_pants_color:    Color = Color(1, 1, 1)
var selected_shoes_color:    Color = Color(1, 1, 1)
var selected_acc_color:      Color = Color(1, 1, 1)

# ─── Pastel Color Options ─────────────────────────────────────────────────────
var skin_color_options = [
	Color(1.00, 0.88, 0.79),  # light peach
	Color(0.96, 0.80, 0.69),  # soft beige
	Color(0.82, 0.65, 0.50),  # gentle tan
	Color(0.60, 0.42, 0.33),  # muted brown
	Color(0.42, 0.30, 0.22),  # warm brown
	Color(0.30, 0.22, 0.17)   # deep brown
]

var hair_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.41, 0.71),  # Hot Pink
	Color(1.00, 0.51, 0.67),  # Pepto Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65),  # Cloudy Sky
	Color(0.10, 0.10, 0.10)   # Soft Black
]

var eyes_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.40, 0.63),  # Baby Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65)   # Cloudy Sky
]

var shirt_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.41, 0.71),  # Hot Pink
	Color(1.00, 0.51, 0.67),  # Pepto Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65),  # Cloudy Sky
	Color(0.10, 0.10, 0.10)   # Soft Black
]

var pants_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.41, 0.71),  # Hot Pink
	Color(1.00, 0.51, 0.67),  # Pepto Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65),  # Cloudy Sky
	Color(0.10, 0.10, 0.10)   # Soft Black
]

var shoes_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.41, 0.71),  # Hot Pink
	Color(1.00, 0.51, 0.67),  # Pepto Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65),  # Cloudy Sky
	Color(0.10, 0.10, 0.10)   # Soft Black
]

var acc_color_options = [
	Color(0.71, 0.49, 0.86),  # Soft Lavender
	Color(1.00, 0.41, 0.71),  # Hot Pink
	Color(1.00, 0.51, 0.67),  # Pepto Pink
	Color(1.00, 0.96, 0.31),  # Buttercream Yellow
	Color(0.60, 1.00, 0.60),  # Mint Cream
	Color(0.53, 0.81, 0.92),  # Powder Blue
	Color(1.00, 0.86, 0.73),  # Peach Fuzz
	Color(0.60, 0.40, 0.80),  # Lilac Mist
	Color(0.00, 0.48, 0.65),  # Cloudy Sky
	Color(0.10, 0.10, 0.10)   # Soft Black
]

# ─── Asset Collections ────────────────────────────────────────────────────────
var skin_collection = {
	"white":         preload("res://Cute_Fantasy/Player/characters/char1.png"),
	"dark white":    preload("res://Cute_Fantasy/Player/characters/char2.png"),
	"olive":         preload("res://Cute_Fantasy/Player/characters/char3.png"),
	"dark olive":    preload("res://Cute_Fantasy/Player/characters/char4.png"),
	"light brown":   preload("res://Cute_Fantasy/Player/characters/char5.png"),
	"medium brown":  preload("res://Cute_Fantasy/Player/characters/char6.png"),
	"darkest brown": preload("res://Cute_Fantasy/Player/characters/char7.png"),
	"black":         preload("res://Cute_Fantasy/Player/characters/char8.png")
}

var hair_collection = {
	"none":           null,
	"short bob":      preload("res://Cute_Fantasy/Player/hair/bob .png"),
	"braids":         preload("res://Cute_Fantasy/Player/hair/braids.png"),
	"buzzcut":        preload("res://Cute_Fantasy/Player/hair/buzzcut.png"),
	"curly":          preload("res://Cute_Fantasy/Player/hair/curly.png"),
	"emo":            preload("res://Cute_Fantasy/Player/hair/emo.png"),
	"extra long":     preload("res://Cute_Fantasy/Player/hair/extra_long.png"),
	"french curl":    preload("res://Cute_Fantasy/Player/hair/french_curl.png"),
	"gentleman cut":  preload("res://Cute_Fantasy/Player/hair/gentleman.png"),
	"straight long":  preload("res://Cute_Fantasy/Player/hair/long_straight .png"),
	"ponytail":       preload("res://Cute_Fantasy/Player/hair/ponytail .png"),
	"spacebuns":      preload("res://Cute_Fantasy/Player/hair/spacebuns.png"),
	"wavy":           preload("res://Cute_Fantasy/Player/hair/wavy.png")
}

var full_body_collection = {
	"none":     null,
	"clown":    preload("res://Cute_Fantasy/Player/clothes/clown.png"),
	"dress":    preload("res://Cute_Fantasy/Player/clothes/dress .png"),
	"overalls": preload("res://Cute_Fantasy/Player/clothes/overalls.png"),
	"witch":    preload("res://Cute_Fantasy/Player/clothes/witch.png")
}

var shirt_collection = {
	"basic":  preload("res://Cute_Fantasy/Player/clothes/basic.png"),
	"floral": preload("res://Cute_Fantasy/Player/clothes/floral.png"),
	"stripe": preload("res://Cute_Fantasy/Player/clothes/stripe.png"),
	"suit":   preload("res://Cute_Fantasy/Player/clothes/suit.png")
}

var pants_collection = {
	"pants": preload("res://Cute_Fantasy/Player/clothes/pants.png"),
	"skirt": preload("res://Cute_Fantasy/Player/clothes/skirt.png")
}

var face_collection = {
	"blush":    preload("res://Cute_Fantasy/Player/eyes/blush_all.png"),
	"eyes":     preload("res://Cute_Fantasy/Player/eyes/eyes.png"),
	"lipstick": preload("res://Cute_Fantasy/Player/eyes/lipstick .png")
}

var shoes_collection = {
	"shoes": preload("res://Cute_Fantasy/Player/clothes/shoes.png")
}

var acc_collection = {
	"none":             null,
	"Emerald earrings": preload("res://Cute_Fantasy/Player/acc/earring_emerald.png"),
	"Cowboy hat":       preload("res://Cute_Fantasy/Player/acc/hat_cowboy.png"),
	"Witch hat":        preload("res://Cute_Fantasy/Player/acc/hat_witch.png"),
	"Blue clown mask":  preload("res://Cute_Fantasy/Player/acc/mask_clown_blue.png")
}

# ─── Shader Preload ───────────────────────────────────────────────────────────
var pastel_shader := preload("res://shaders/item.gdshader")

func _ready() -> void:
	print("✅ Global.gd ready. Scene tree is active.")
	if pastel_shader:
		print("🔍 Pastel shader loaded.")

func _process(delta: float) -> void:
	# remember previous time for wrap detection
	var prev_time = global_time_passed

	# advance & wrap
	global_time_passed = fposmod(global_time_passed + delta, SECONDS_PER_DAY)
	global_time_of_day = global_time_passed / SECONDS_PER_DAY
	global_display_in_game_time = START_HOUR + global_time_of_day * CYCLE_HOURS

	# if we wrapped back to zero, that means a new day!
	if global_time_passed < prev_time:
		day_count += 1
		print("🌙 New in-game day:", day_count)


# Resets name + customization to blank/defaults
func set_defaults() -> void:
	player_name             = ""
	selected_skin           = ""
	selected_hair           = ""
	selected_eyes           = ""
	selected_fullbody       = "none"
	selected_shirt          = ""
	selected_pants          = ""
	selected_shoes          = ""
	selected_acc            = ""
	selected_skin_color     = Color(1,1,1)
	selected_hair_color     = Color(1,1,1)
	selected_eyes_color     = Color(1,1,1)
	selected_fullbody_color = Color(1,1,1)
	selected_shirt_color    = Color(1,1,1)
	selected_pants_color    = Color(1,1,1)
	selected_shoes_color    = Color(1,1,1)
	selected_acc_color      = Color(1,1,1)

func save_game() -> void:
	var config = ConfigFile.new()
	# Player Data
	config.set_value("Player", "position", player_position)
	config.set_value("Player", "name", player_name)
	config.set_value("Player", "skin", selected_skin)
	config.set_value("Player", "hair", selected_hair)
	config.set_value("Player", "eyes", selected_eyes)
	config.set_value("Player", "fullbody", selected_fullbody)
	config.set_value("Player", "shirt", selected_shirt)
	config.set_value("Player", "pants", selected_pants)
	config.set_value("Player", "shoes", selected_shoes)
	config.set_value("Player", "accessory", selected_acc)
	# Colors
	config.set_value("Colors", "skin", selected_skin_color.to_html())
	config.set_value("Colors", "hair", selected_hair_color.to_html())
	config.set_value("Colors", "eyes", selected_eyes_color.to_html())
	config.set_value("Colors", "fullbody", selected_fullbody_color.to_html())
	config.set_value("Colors", "shirt", selected_shirt_color.to_html())
	config.set_value("Colors", "pants", selected_pants_color.to_html())
	config.set_value("Colors", "shoes", selected_shoes_color.to_html())
	config.set_value("Colors", "accessory", selected_acc_color.to_html())
	# Clock Data
	config.set_value("Clock", "time_passed", global_time_passed)
	config.set_value("Clock", "display_time", global_display_in_game_time)
	# Game State
	config.set_value("State", "last_scene", last_scene)
	var result = config.save_encrypted_pass("user://settings.cfg", key)
	if result == OK:
		print("💾 Game saved successfully!")
	else:
		push_error("Save failed: %s" % result)

func load_game() -> bool:
	var config = ConfigFile.new()
	if config.load_encrypted_pass("user://settings.cfg", key) != OK:
		print("📭 No save file found.")
		return false
	# Restore Player Data
	player_position   = config.get_value("Player", "position", Vector2.ZERO)
	player_name       = config.get_value("Player", "name", player_name)
	selected_skin     = config.get_value("Player", "skin", selected_skin)
	selected_hair     = config.get_value("Player", "hair", selected_hair)
	selected_eyes     = config.get_value("Player", "eyes", selected_eyes)
	selected_fullbody = config.get_value("Player", "fullbody", selected_fullbody)
	selected_shirt    = config.get_value("Player", "shirt", selected_shirt)
	selected_pants    = config.get_value("Player", "pants", selected_pants)
	selected_shoes    = config.get_value("Player", "shoes", selected_shoes)
	selected_acc      = config.get_value("Player", "accessory", selected_acc)
	# Restore Colors
	selected_skin_color     = Color(config.get_value("Colors", "skin", selected_skin_color.to_html()))
	selected_hair_color     = Color(config.get_value("Colors", "hair", selected_hair_color.to_html()))
	selected_eyes_color     = Color(config.get_value("Colors", "eyes", selected_eyes_color.to_html()))
	selected_fullbody_color = Color(config.get_value("Colors", "fullbody", selected_fullbody_color.to_html()))
	selected_shirt_color    = Color(config.get_value("Colors", "shirt", selected_shirt_color.to_html()))
	selected_pants_color    = Color(config.get_value("Colors", "pants", selected_pants_color.to_html()))
	selected_shoes_color    = Color(config.get_value("Colors", "shoes", selected_shoes_color.to_html()))
	selected_acc_color      = Color(config.get_value("Colors", "accessory", selected_acc_color.to_html()))
	# Restore Clock
	global_time_passed          = config.get_value("Clock", "time_passed", 0.0)
	global_display_in_game_time = config.get_value("Clock", "display_time", START_HOUR)
	# Restore Scene
	last_scene = config.get_value("State", "last_scene", last_scene)
	print("🔄Loaded player_name:", player_name)
	print("🔄Loaded selected_skin:", selected_skin, "color:", selected_skin_color)
	print("🔄Loaded selected_hair:", selected_hair, "color:", selected_hair_color)
	# (repeat for eyes, shirt, pants, shoes, acc)
	return true

func apply_pastel_shader(sprite: Node, color: Color) -> void:
	if not sprite or not sprite.is_class("Sprite2D"):
		push_error("apply_pastel_shader: target is not a Sprite2D")
		return
	var mat = ShaderMaterial.new()
	mat.shader = pastel_shader
	mat.set_shader_parameter("tint_color", color)
	mat.set_shader_parameter("brightness_boost", 1.5)
	sprite.material = mat

func is_game_paused() -> bool:
	return is_inventory_open or is_pause_menu_open

# ─── START NEW GAME ────────────────────────────────────────────────────────────
func start_new_game() -> void:
	print("🆕 Starting new game…")
	spawn_from                  = "newGame"
	player_position             = Vector2.ZERO
	last_scene                  = "res://scenes/farm.tscn"
	global_time_passed          = 0.0
	global_time_of_day          = 0.0
	global_display_in_game_time = START_HOUR
	set_defaults()  # wipe name & all selected_* fields/colors
	save_game()     # write that blank state immediately

func go_to_scene(path: String) -> void:
	last_scene = path
	save_game()
	get_tree().change_scene_to_file(last_scene)

func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		var player = get_tree().get_first_node_in_group("Player") as CharacterBody2D
		if player:
			player_position = player.global_position
			print("💾 Auto-saving player pos:", player_position)
		save_game()

# Jump the clock to an absolute hour (e.g. 14.5 for 2:30 PM)
func set_time_of_day(hours: float) -> void:
	# clamp so you don’t go outside START_HOUR…START_HOUR+CYCLE_HOURS
	var clamped = clamp(hours, START_HOUR, START_HOUR + CYCLE_HOURS)
	global_display_in_game_time = clamped
	global_time_of_day = (clamped - START_HOUR) / CYCLE_HOURS
	global_time_passed = global_time_of_day * SECONDS_PER_DAY

# Advance the clock by a delta (in hours)
func advance_time(hours_delta: float) -> void:
	var new_hour = global_display_in_game_time + hours_delta
	# wrap manually if you go past the cycle
	if new_hour > START_HOUR + CYCLE_HOURS:
		new_hour = START_HOUR + fposmod(new_hour - START_HOUR, CYCLE_HOURS)
		day_count += 1  # if you want to count a day rollover
	set_time_of_day(new_hour)

func _unhandled_input(event):
	if event.is_action_pressed("debug_time_forward_slow"):
		advance_time(1.0)
		print("⏩ Debug: advanced 1h to", global_display_in_game_time)
	elif event.is_action_pressed("debug_time_forward"):
			advance_time(5.0)
	elif event.is_action_pressed("debug_day_forward"):
		advance_time(20.0)
			
	
