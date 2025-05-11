# CharacterCreator.gd
extends Node2D

# ─── ONREADY FOR INPUT & CONFIRM ───────────────────────────────────────────────
@onready var name_input       : LineEdit = $CreatorScreen/ColorRect/Details/LineEdit
@onready var confirm_button   : Button   = $CreatorScreen/ColorRect/ConfirmButton

# ─── SPRITE PREVIEWS ───────────────────────────────────────────────────────────
@onready var skin_sprite      : Sprite2D = $Skeleton/Skin/SkinSprite
@onready var eyes_sprite      : Sprite2D = $Skeleton/Eyes/EyesSprite
@onready var hair_sprite      : Sprite2D = $Skeleton/Hair/HairSprite
@onready var shirt_sprite     : Sprite2D = $Skeleton/Shirt/ShirtSprite
@onready var pants_sprite     : Sprite2D = $Skeleton/Pants/PantsSprite
@onready var shoes_sprite     : Sprite2D = $Skeleton/Shoes/ShoesSprite
@onready var acc_sprite       : Sprite2D = $Skeleton/Accessories/AccessoriesSprite

# ─── COLLECTION & COLOR BUTTONS ─────────────────────────────────────────────────
@onready var skin_color_btn   : Button   = $CreatorScreen/ColorRect/Skin/ColorButton

@onready var eyes_color_btn   : Button   = $CreatorScreen/ColorRect/Eyes/ColorButton

@onready var hair_collect_btn : Button   = $CreatorScreen/ColorRect/Hair/CollectionButton
@onready var hair_color_btn   : Button   = $CreatorScreen/ColorRect/Hair/ColorButton

@onready var shirt_collect_btn: Button   = $CreatorScreen/ColorRect/Shirt/CollectionButton
@onready var shirt_color_btn  : Button   = $CreatorScreen/ColorRect/Shirt/ColorButton

@onready var pants_collect_btn: Button   = $CreatorScreen/ColorRect/Pants/CollectionButton
@onready var pants_color_btn  : Button   = $CreatorScreen/ColorRect/Pants/ColorButton

@onready var shoes_collect_btn: Button   = $CreatorScreen/ColorRect/Shoes/CollectionButton

@onready var acc_collect_btn  : Button   = $CreatorScreen/ColorRect/Accessories/CollectionButton
@onready var acc_color_btn    : Button   = $CreatorScreen/ColorRect/Accessories/ColorButton

# ─── STATE TRACKERS & KEY LISTS ────────────────────────────────────────────────
var skin_keys      : Array = []
var eyes_keys      : Array = []
var hair_keys      : Array = []
var shirt_keys     : Array = []
var pants_keys     : Array = []
var shoes_keys     : Array = []
var acc_keys       : Array = []

var skin_idx       : int = 0
var skin_color_idx : int = 0
var eyes_idx       : int = 0
var eyes_color_idx : int = 0
var hair_idx       : int = 0
var hair_color_idx : int = 0
var shirt_idx      : int = 0
var shirt_color_idx: int = 0
var pants_idx      : int = 0
var pants_color_idx: int = 0
var shoes_idx      : int = 0
var shoes_color_idx: int = 0
var acc_idx        : int = 0
var acc_color_idx  : int = 0

# local copy of spawn context
var _spawn_context : String = ""

func _ready() -> void:
	# ─── LOAD SAVED DATA ─────────────────────────────────────────────────────────
	if Global.load_game():
		print("🗂️ Loaded existing save")
	else:
		print("🚀 No save file; starting fresh")

	# ─── CACHE HOW WE GOT HERE ────────────────────────────────────────────────────
	_spawn_context = Global.spawn_from

	# ─── HANDLE NEW GAME vs MIRROR RETURN ────────────────────────────────────────
	if _spawn_context == "newGame":
		Global.set_defaults()
	elif _spawn_context == "fromMirror":
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.global_position = Global.player_position

	# ─── INIT UI FIELDS FROM GLOBAL ──────────────────────────────────────────────
	name_input.text = Global.player_name

	# ─── BUILD KEY LISTS ─────────────────────────────────────────────────────────
	skin_keys  = Global.skin_collection.keys()
	eyes_keys  = Global.face_collection.keys()
	hair_keys  = Global.hair_collection.keys()
	shirt_keys = Global.shirt_collection.keys()
	pants_keys = Global.pants_collection.keys()
	shoes_keys = Global.shoes_collection.keys()
	acc_keys   = Global.acc_collection.keys()

	# ─── DEBUG: DUMP AVAILABLE KEYS & SAVED VALUES ───────────────────────────────
	print("Available skin_keys:  ", skin_keys)
	print("Available eyes_keys:  ", eyes_keys)
	print("Available hair_keys:  ", hair_keys)
	print("Available shirt_keys: ", shirt_keys)
	print("Available pants_keys: ", pants_keys)
	print("Available shoes_keys:", shoes_keys)
	print("Available acc_keys:   ", acc_keys)

	print("🔍 Saved name:        ", Global.player_name)
	print("🔍 Saved skin:        '", Global.selected_skin,    "'")
	print("🔍 Saved skin col:    ", Global.selected_skin_color)
	print("🔍 Saved hair:        '", Global.selected_hair,    "'")
	print("🔍 Saved hair col:    ", Global.selected_hair_color)
	print("🔍 Saved eyes:        '", Global.selected_eyes,    "'")
	print("🔍 Saved eyes col:    ", Global.selected_eyes_color)
	print("🔍 Saved shirt:       '", Global.selected_shirt,   "'")
	print("🔍 Saved shirt col:   ", Global.selected_shirt_color)
	print("🔍 Saved pants:       '", Global.selected_pants,   "'")
	print("🔍 Saved pants col:   ", Global.selected_pants_color)
	print("🔍 Saved shoes:       '", Global.selected_shoes,   "'")
	print("🔍 Saved shoes col:   ", Global.selected_shoes_color)
	print("🔍 Saved acc:         '", Global.selected_acc,     "'")
	print("🔍 Saved acc col:     ", Global.selected_acc_color)

	# ─── COMPUTE INDICES BASED ON SAVED VALUES ───────────────────────────────────
	skin_idx        = max(skin_keys.find(Global.selected_skin),               0)
	skin_color_idx  = max(Global.skin_color_options.find(Global.selected_skin_color), 0)
	eyes_idx        = max(eyes_keys.find(Global.selected_eyes),               0)
	eyes_color_idx  = max(Global.eyes_color_options.find(Global.selected_eyes_color), 0)
	hair_idx        = max(hair_keys.find(Global.selected_hair),               0)
	hair_color_idx  = max(Global.hair_color_options.find(Global.selected_hair_color), 0)
	shirt_idx       = max(shirt_keys.find(Global.selected_shirt),             0)
	shirt_color_idx = max(Global.shirt_color_options.find(Global.selected_shirt_color), 0)
	pants_idx       = max(pants_keys.find(Global.selected_pants),             0)
	pants_color_idx = max(Global.pants_color_options.find(Global.selected_pants_color), 0)
	shoes_idx       = max(shoes_keys.find(Global.selected_shoes),             0)
	shoes_color_idx = max(Global.shoes_color_options.find(Global.selected_shoes_color), 0)
	acc_idx         = max(acc_keys.find(Global.selected_acc),                 0)
	acc_color_idx   = max(Global.acc_color_options.find(Global.selected_acc_color), 0)

	# ─── UPDATE ALL PREVIEWS ─────────────────────────────────────────────────────
	_update_skin()
	_update_eyes()
	_update_hair()
	_update_shirt()
	_update_pants()
	_update_shoes()
	_update_acc()


# ─── HANDLERS & UPDATES ────────────────────────────────────────────────────────

func _on_skin_collect() -> void:
	skin_idx = (skin_idx + 1) % skin_keys.size()
	_update_skin()

func _on_skin_color() -> void:
	skin_color_idx = (skin_color_idx + 1) % Global.skin_color_options.size()
	Global.selected_skin_color = Global.skin_color_options[skin_color_idx]
	_apply_skin_color()

func _update_skin() -> void:
	var key = skin_keys[skin_idx]
	skin_sprite.texture = Global.skin_collection[key]
	Global.selected_skin = key
	_apply_skin_color()

func _apply_skin_color() -> void:
	skin_sprite.modulate = Global.selected_skin_color

func _on_eyes_collect() -> void:
	eyes_idx = (eyes_idx + 1) % eyes_keys.size()
	_update_eyes()

func _on_eyes_color() -> void:
	eyes_color_idx = (eyes_color_idx + 1) % Global.eyes_color_options.size()
	Global.selected_eyes_color = Global.eyes_color_options[eyes_color_idx]
	_apply_eyes_color()

func _update_eyes() -> void:
	var key = eyes_keys[eyes_idx]
	eyes_sprite.texture = Global.face_collection[key]
	Global.selected_eyes = key
	_apply_eyes_color()

func _apply_eyes_color() -> void:
	eyes_sprite.modulate = Global.selected_eyes_color

func _on_hair_collect() -> void:
	hair_idx = (hair_idx + 1) % hair_keys.size()
	_update_hair()

func _on_hair_color() -> void:
	hair_color_idx = (hair_color_idx + 1) % Global.hair_color_options.size()
	Global.selected_hair_color = Global.hair_color_options[hair_color_idx]
	_apply_hair_color()

func _update_hair() -> void:
	var key = hair_keys[hair_idx]
	hair_sprite.texture = Global.hair_collection[key]
	Global.selected_hair = key
	_apply_hair_color()

func _apply_hair_color() -> void:
	hair_sprite.modulate = Global.selected_hair_color

func _on_shirt_collect() -> void:
	shirt_idx = (shirt_idx + 1) % shirt_keys.size()
	_update_shirt()

func _on_shirt_color() -> void:
	shirt_color_idx = (shirt_color_idx + 1) % Global.shirt_color_options.size()
	Global.selected_shirt_color = Global.shirt_color_options[shirt_color_idx]
	_apply_shirt_color()

func _update_shirt() -> void:
	var key = shirt_keys[shirt_idx]
	shirt_sprite.texture = Global.shirt_collection[key]
	Global.selected_shirt = key
	_apply_shirt_color()

func _apply_shirt_color() -> void:
	shirt_sprite.modulate = Global.selected_shirt_color

func _on_pants_collect() -> void:
	pants_idx = (pants_idx + 1) % pants_keys.size()
	_update_pants()

func _on_pants_color() -> void:
	pants_color_idx = (pants_color_idx + 1) % Global.pants_color_options.size()
	Global.selected_pants_color = Global.pants_color_options[pants_color_idx]
	_apply_pants_color()

func _update_pants() -> void:
	var key = pants_keys[pants_idx]
	pants_sprite.texture = Global.pants_collection[key]
	Global.selected_pants = key
	_apply_pants_color()

func _apply_pants_color() -> void:
	pants_sprite.modulate = Global.selected_pants_color

func _on_shoes_collect() -> void:
	shoes_idx = (shoes_idx + 1) % shoes_keys.size()
	_update_shoes()

func _on_shoes_color() -> void:
	shoes_color_idx = (shoes_color_idx + 1) % Global.shoes_color_options.size()
	Global.selected_shoes_color = Global.shoes_color_options[shoes_color_idx]
	_apply_shoes_color()

func _update_shoes() -> void:
	var key = shoes_keys[shoes_idx]
	shoes_sprite.texture = Global.shoes_collection[key]
	Global.selected_shoes = key
	_apply_shoes_color()

func _apply_shoes_color() -> void:
	shoes_sprite.modulate = Global.selected_shoes_color

func _on_acc_collect() -> void:
	acc_idx = (acc_idx + 1) % acc_keys.size()
	_update_acc()

func _on_acc_color() -> void:
	acc_color_idx = (acc_color_idx + 1) % Global.acc_color_options.size()
	Global.selected_acc_color = Global.acc_color_options[acc_color_idx]
	_apply_acc_color()

func _update_acc() -> void:
	var key = acc_keys[acc_idx]
	acc_sprite.texture = Global.acc_collection[key]
	Global.selected_acc = key
	_apply_acc_color()

func _apply_acc_color() -> void:
	acc_sprite.modulate = Global.selected_acc_color

# ─── CONFIRM & EXIT ─────────────────────────────────────────────────────────────
func _on_confirm_button_pressed() -> void:
	Global.player_name = name_input.text
	Global.save_game()

	# now branch based on how we entered
	if _spawn_context == "fromMirror":
		var target = Global.last_scene
		Global.spawn_from = ""
		get_tree().change_scene_to_file(target)
	else:
		Global.spawn_from = ""
		get_tree().change_scene_to_file("res://scenes/farmhouse_interior.tscn")
