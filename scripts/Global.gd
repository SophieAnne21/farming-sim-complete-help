extends Node

const START_HOUR: int = 6
const CYCLE_HOURS: float = 20.0 # 6AM to 2AM
const MINUTE_STEP: int = 5 # Snap to every 5 minutes
const SECONDS_PER_DAY: float = 7200.0 # Full 20-hour day = 7200 real-world seconds

var global_time_passed: float = 0.0
var global_time_of_day: float = 0.0
var global_display_in_game_time: float = 6.0  # (or whatever START_HOUR is)

var time_of_day: float = 0.0
var seconds_per_day: float = 7200.0 # or whatever you want
var time_passed: float = 0.0
var start_hour: int = 6 # 6 AM start
var cycle_hours: float = 20.0 # how many in-game hours total per day

# Camera limits across scenes
var camera_limit_left: float = 0.0
var camera_limit_right: float = 0.0
var camera_limit_top: float = 0.0
var camera_limit_bottom: float = 0.0

var is_inventory_open: bool = false
var is_pause_menu_open: bool = false


var key = "SimpleSaveLoad"
var player_position: Vector2 = Vector2(0, 0)
var player_name: String = "Check the Mirror"
var last_scene: String = "res://farm.tscn"
var spawn_from: String = ""

var current_season_name: String = "Spring"


func _ready():
	print("✅ Global.gd ready. Scene tree is active.")
	
func _process(delta: float) -> void:
	time_passed += delta
	time_of_day = time_passed / seconds_per_day
	if time_of_day >= 1.0:
		time_passed = 0.0
		time_of_day = 0.0

# === Selected Customization ===
var selected_skin: String = ""
var selected_eyes: String = ""
var selected_hair: String = ""
var selected_fullbody: String = "none"
var selected_shirt: String = ""
var selected_pants: String = ""
var selected_shoes: String = ""
var selected_acc: String = ""

# === Color Selections ===
var selected_skin_color: Color = Color(1, 1, 1)
var selected_eyes_color: Color = Color(1, 1, 1)
var selected_hair_color: Color = Color(1, 1, 1)
var selected_fullbody_color: Color = Color(1, 1, 1)
var selected_shirt_color: Color = Color(1, 1, 1)
var selected_pants_color: Color = Color(1, 1, 1)
var selected_shoes_color: Color = Color(1, 1, 1)
var selected_acc_color: Color = Color(1, 1, 1)

# === Pastel Color Options ===
var skin_color_options = [
	Color(1.0, 0.88, 0.79),  # light peach
	Color(0.96, 0.80, 0.69), # soft beige
	Color(0.82, 0.65, 0.50), # gentle tan
	Color(0.60, 0.42, 0.33), # muted brown
	Color(0.42, 0.30, 0.22), # warm brown
	Color(0.30, 0.22, 0.17)  # deep brown
]

var hair_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.41, 0.71), #Hot pink
	Color(1.0, 0.51, 0.67), #pepto pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
	Color(0.1, 0.1, 0.1) # soft black
]

var eyes_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.4, 0.63), # Baby Pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
]

var shirt_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.41, 0.71), #Hot pink
	Color(1.0, 0.51, 0.67), #pepto pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
	Color(0.1, 0.1, 0.1) # soft black
]

var pants_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.41, 0.71), #Hot pink
	Color(1.0, 0.51, 0.67), #pepto pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
	Color(0.1, 0.1, 0.1) # soft black
]

var shoes_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.41, 0.71), #Hot pink
	Color(1.0, 0.51, 0.67), #pepto pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
	Color(0.1, 0.1, 0.1) # soft black
]

var acc_color_options = [
	Color(0.71, 0.49, 0.86), # Soft Lavender
	Color(1.0, 0.41, 0.71), #Hot pink
	Color(1.0, 0.51, 0.67), #pepto pink
	Color(1.0, 0.96, 0.31), # Buttercream Yellow
	Color(0.6, 1.0, 0.6), # Mint Cream
	Color(0.53, 0.81, 0.92), # Powder Blue
	Color(1.0, 0.86, 0.73), # Peach Fuzz
	Color(0.6, 0.4, 0.8), # Lilac Mist
	Color(0.0, 0.48, 0.65), # Cloudy Sky
	Color(0.1, 0.1, 0.1) # soft black
]

# === Asset Collections ===
var skin_collection = {
	"white": preload("res://Cute_Fantasy/Player/characters/char1.png"),
	"dark white": preload("res://Cute_Fantasy/Player/characters/char2.png"),
	"olive": preload("res://Cute_Fantasy/Player/characters/char3.png"),
	"dark olive": preload("res://Cute_Fantasy/Player/characters/char4.png"),
	"light brown": preload("res://Cute_Fantasy/Player/characters/char5.png"),
	"medium brown": preload("res://Cute_Fantasy/Player/characters/char6.png"),
	"darkest brown": preload("res://Cute_Fantasy/Player/characters/char7.png"),
	"black": preload("res://Cute_Fantasy/Player/characters/char8.png")
}

var hair_collection = {
	"none": null,
	"short bob": preload("res://Cute_Fantasy/Player/hair/bob .png"),
	"braids": preload("res://Cute_Fantasy/Player/hair/braids.png"),
	"buzzcut": preload("res://Cute_Fantasy/Player/hair/buzzcut.png"),
	"curly": preload("res://Cute_Fantasy/Player/hair/curly.png"),
	"emo": preload("res://Cute_Fantasy/Player/hair/emo.png"),
	"extra long": preload("res://Cute_Fantasy/Player/hair/extra_long.png"),
	"extra long skirt cut": preload("res://Cute_Fantasy/Player/hair/extra_long_skirt.png"),
	"french curl": preload("res://Cute_Fantasy/Player/hair/french_curl.png"),
	"gentleman cut": preload("res://Cute_Fantasy/Player/hair/gentleman.png"),
	"straight and long": preload("res://Cute_Fantasy/Player/hair/long_straight .png"),
	"long and straight skirt cut": preload("res://Cute_Fantasy/Player/hair/long_straight_skirt.png"),
	"midiwave": preload("res://Cute_Fantasy/Player/hair/midiwave.png"),
	"ponytail": preload("res://Cute_Fantasy/Player/hair/ponytail .png"),
	"spacebuns": preload("res://Cute_Fantasy/Player/hair/spacebuns.png"),
	"wavy": preload("res://Cute_Fantasy/Player/hair/wavy.png")
}

var full_body_collection = {
	"none": null,
	"clown": preload("res://Cute_Fantasy/Player/clothes/clown.png"),
	"dress": preload("res://Cute_Fantasy/Player/clothes/dress .png"),
	"overalls": preload("res://Cute_Fantasy/Player/clothes/overalls.png"),
	"pumpkin": preload("res://Cute_Fantasy/Player/clothes/pumpkin.png"),
	"spooky": preload("res://Cute_Fantasy/Player/clothes/spooky .png"),
	"witch": preload("res://Cute_Fantasy/Player/clothes/witch.png")
}

var shirt_collection = {
	"basic": preload("res://Cute_Fantasy/Player/clothes/basic.png"),
	"floral": preload("res://Cute_Fantasy/Player/clothes/floral.png"),
	"spaghetti": preload("res://Cute_Fantasy/Player/clothes/spaghetti.png"),
	"sailor": preload("res://Cute_Fantasy/Player/clothes/sailor.png"),
	"sailor_bow": preload("res://Cute_Fantasy/Player/clothes/sailor_bow.png"),
	"skull": preload("res://Cute_Fantasy/Player/clothes/skull.png"),
	"sporty": preload("res://Cute_Fantasy/Player/clothes/sporty.png"),
	"stripe": preload("res://Cute_Fantasy/Player/clothes/stripe.png"),
	"suit": preload("res://Cute_Fantasy/Player/clothes/suit.png")
}

var pants_collection = {
	"pants": preload("res://Cute_Fantasy/Player/clothes/pants.png"),
	"pants_suit": preload("res://Cute_Fantasy/Player/clothes/pants_suit.png"),
	"skirt": preload("res://Cute_Fantasy/Player/clothes/skirt.png")
}

var face_collection = {
	"blush": preload("res://Cute_Fantasy/Player/eyes/blush_all.png"),
	"eyes": preload("res://Cute_Fantasy/Player/eyes/eyes.png"),
	"lipstick": preload("res://Cute_Fantasy/Player/eyes/lipstick .png")
}

var shoes_collection = {
	"shoes": preload("res://Cute_Fantasy/Player/clothes/shoes.png")
}

var acc_collection = {
	"none": null,
	"Emerald earrings": preload("res://Cute_Fantasy/Player/acc/earring_emerald.png"),
	"Silver emerald earrings": preload("res://Cute_Fantasy/Player/acc/earring_emerald_silver.png"),
	"Red earrings": preload("res://Cute_Fantasy/Player/acc/earring_red.png"),
	"Red and silverearring": preload("res://Cute_Fantasy/Player/acc/earring_red_silver.png"),
	"Cowboy hat": preload("res://Cute_Fantasy/Player/acc/hat_cowboy.png"),
	"Lucky hat": preload("res://Cute_Fantasy/Player/acc/hat_lucky.png"),
	"Pumpkin hat": preload("res://Cute_Fantasy/Player/acc/hat_pumpkin.png"),
	"Purple pumpkin hat": preload("res://Cute_Fantasy/Player/acc/hat_pumpkin_purple.png"),
	"Witch hat": preload("res://Cute_Fantasy/Player/acc/hat_witch.png"),
	"Blue clown mask": preload("res://Cute_Fantasy/Player/acc/mask_clown_blue.png"),
	"Red clown mask": preload("res://Cute_Fantasy/Player/acc/mask_clown_red.png"),
	"Spooky": preload("res://Cute_Fantasy/Player/acc/mask_spooky.png")
}

# === Shader Preloads ===
var pastel_shader := preload("res://scripts/item.gdshader") # <-- adjust path if needed


# === Fallback setup for a new game ===
func set_defaults():
	print("Setting default name to: Check the Mirror")
	player_name = "Check the Mirror"
	selected_skin = "white"
	selected_hair = "buzzcut"
	selected_eyes = "eyes"
	selected_fullbody = "none"
	selected_shirt = "basic"
	selected_pants = "pants"
	selected_shoes = "shoes"
	selected_acc = "none"
	selected_skin_color = Color(1, 1, 1)
	selected_hair_color = Color(1, 1, 1)
	selected_eyes_color = Color(1, 1, 1)
	selected_fullbody_color = Color(1, 1, 1)
	selected_shirt_color = Color(1, 1, 1)
	selected_pants_color = Color(1, 1, 1)
	selected_shoes_color = Color(1, 1, 1)
	selected_acc_color = Color(1, 1, 1)

# === SAVE GAME ===
# === SAVE GAME ===
func save_game() -> void:
	if typeof(player_name) != TYPE_STRING:
		print("🚨 Invalid player name during save! Got:", player_name)
		player_name = "Check the Mirror"

	var config = ConfigFile.new()

	# --- Player Data ---
	config.set_value("Player", "position", player_position)
	config.set_value("Player", "name", player_name)
	config.set_value("Player", "skin", selected_skin)
	config.set_value("Player", "eyes", selected_eyes)
	config.set_value("Player", "hair", selected_hair)
	config.set_value("Player", "fullbody", selected_fullbody)
	config.set_value("Player", "shirt", selected_shirt)
	config.set_value("Player", "pants", selected_pants)
	config.set_value("Player", "shoes", selected_shoes)
	config.set_value("Player", "accessory", selected_acc)

	# --- Player Colors ---
	config.set_value("Colors", "skin", selected_skin_color.to_html())
	config.set_value("Colors", "eyes", selected_eyes_color.to_html())
	config.set_value("Colors", "hair", selected_hair_color.to_html())
	config.set_value("Colors", "fullbody", selected_fullbody_color.to_html())
	config.set_value("Colors", "shirt", selected_shirt_color.to_html())
	config.set_value("Colors", "pants", selected_pants_color.to_html())
	config.set_value("Colors", "shoes", selected_shoes_color.to_html())
	config.set_value("Colors", "accessory", selected_acc_color.to_html())

	# --- Clock Data ---
	config.set_value("Clock", "time_passed", time_passed)
	config.set_value("Clock", "global_display_in_game_time", global_display_in_game_time)

	# --- Game State ---
	config.set_value("State", "last_scene", last_scene)

	# --- Save to File ---
	var result := config.save_encrypted_pass("user://settings.cfg", key)
	if result == OK:
		print("💾 Game saved successfully!")
	else:
		print("❌ Save failed with error code:", result)


# === LOAD GAME ===
# === LOAD GAME ===
func load_game() -> bool:
	var config = ConfigFile.new()
	var result := config.load_encrypted_pass("user://settings.cfg", key)

	if result != OK:
		print("📭 No save file found or failed to load.")
		return false

	# --- Player Data ---
	if config.has_section_key("Player", "position"):
		var saved_position = config.get_value("Player", "position", Vector2.ZERO)
		if typeof(saved_position) == TYPE_VECTOR2:
			player_position = saved_position
			print("📍 Loaded player position:", player_position)
		else:
			print("❌ Loaded position was invalid:", saved_position)
	else:
		print("⚠️ No saved player position found. Defaulting to (0,0)")

	player_name = config.get_value("Player", "name", "Check the Mirror")
	selected_skin = config.get_value("Player", "skin", "")
	selected_eyes = config.get_value("Player", "eyes", "")
	selected_hair = config.get_value("Player", "hair", "")
	selected_fullbody = config.get_value("Player", "fullbody", "none")
	selected_shirt = config.get_value("Player", "shirt", "")
	selected_pants = config.get_value("Player", "pants", "")
	selected_shoes = config.get_value("Player", "shoes", "")
	selected_acc = config.get_value("Player", "accessory", "")

	# --- Player Colors ---
	selected_skin_color = Color(config.get_value("Colors", "skin", "#ffffff"))
	selected_eyes_color = Color(config.get_value("Colors", "eyes", "#ffffff"))
	selected_hair_color = Color(config.get_value("Colors", "hair", "#ffffff"))
	selected_fullbody_color = Color(config.get_value("Colors", "fullbody", "#ffffff"))
	selected_shirt_color = Color(config.get_value("Colors", "shirt", "#ffffff"))
	selected_pants_color = Color(config.get_value("Colors", "pants", "#ffffff"))
	selected_shoes_color = Color(config.get_value("Colors", "shoes", "#ffffff"))
	selected_acc_color = Color(config.get_value("Colors", "accessory", "#ffffff"))

	# --- Clock Data ---
	time_passed = config.get_value("Clock", "time_passed", 0.0)
	global_display_in_game_time = config.get_value("Clock", "global_display_in_game_time", 6.0)

	# --- Game State ---
	last_scene = config.get_value("State", "last_scene", "res://farm.tscn")

	print("📂 Loaded game state successfully.")
	return true


# === Apply Pastel Shader to a Sprite ===
func apply_pastel_shader(sprite: Node, color: Color) -> void:
	if not sprite or not sprite.is_class("Sprite2D"):
		print("❌ Tried to apply pastel shader to something that's not a Sprite2D:", sprite)
		return

	var pastel_material := ShaderMaterial.new()
	pastel_material.shader = pastel_shader
	pastel_material.set_shader_parameter("tint_color", color)
	sprite.material = pastel_material
	
	
func is_game_paused() -> bool:
	return is_inventory_open or is_pause_menu_open

func start_new_game():
	print("🆕 Starting new game…")
	
	# Reset spawn point and player position
	spawn_from = "newGame"
	player_position = Vector2.ZERO

	# Reset scene path
	last_scene = "res://farm.tscn"

	# Reset time and clock
	global_time_passed = 0.0
	global_time_of_day = 0.0
	global_display_in_game_time = START_HOUR

	# Reset customization and game defaults
	set_defaults()

	# Save the initial state
	save_game()
