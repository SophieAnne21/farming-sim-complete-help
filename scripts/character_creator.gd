# CharacterCreator.gd
extends Node2D

@onready var name_input     : LineEdit = $CreatorScreen/ColorRect/Details/LineEdit
@onready var confirm_button : Button   = $CreatorScreen/ColorRect/ConfirmButton

@onready var skin_sprite  : Sprite2D = $Skeleton/Skin/SkinSprite
@onready var eyes_sprite  : Sprite2D = $Skeleton/Eyes/EyesSprite
@onready var hair_sprite  : Sprite2D = $Skeleton/Hair/HairSprite
@onready var shirt_sprite : Sprite2D = $Skeleton/Shirt/ShirtSprite
@onready var pants_sprite : Sprite2D = $Skeleton/Pants/PantsSprite
@onready var shoes_sprite : Sprite2D = $Skeleton/Shoes/ShoesSprite
@onready var acc_sprite   : Sprite2D = $Skeleton/Accessories/AccessoriesSprite

@onready var skin_collect_btn : Button = $CreatorScreen/ColorRect/Skin/CollectionButton
@onready var skin_color_btn   : Button = $CreatorScreen/ColorRect/Skin/ColorButton
# … similarly for eyes_collect_btn, eyes_color_btn, hair_…, shirt_…, pants_…, shoes_…, acc_…

var skin_keys   : Array = []
var eyes_keys   : Array = []
var hair_keys   : Array = []
var shirt_keys  : Array = []
var pants_keys  : Array = []
var shoes_keys  : Array = []
var acc_keys    : Array = []

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

var _spawn_context : String = ""

func _ready() -> void:
	_spawn_context = Global.spawn_from

	if _spawn_context == "newGame":
		Global.set_defaults()
	elif _spawn_context == "fromMirror":
		var p = get_tree().get_first_node_in_group("Player")
		if p:
			p.global_position = Global.player_position

	# DO NOT clear spawn_from here

	# load name + build key lists
	name_input.text = Global.player_name
	skin_keys  = Global.skin_collection.keys()
	eyes_keys  = Global.face_collection.keys()
	hair_keys  = Global.hair_collection.keys()
	shirt_keys = Global.shirt_collection.keys()
	pants_keys = Global.pants_collection.keys()
	shoes_keys = Global.shoes_collection.keys()
	acc_keys   = Global.acc_collection.keys()

	skin_idx        = max(skin_keys.find(Global.selected_skin), 0)
	skin_color_idx  = max(Global.skin_color_options.find(Global.selected_skin_color), 0)
	eyes_idx        = max(eyes_keys.find(Global.selected_eyes), 0)
	eyes_color_idx  = max(Global.eyes_color_options.find(Global.selected_eyes_color), 0)
	hair_idx        = max(hair_keys.find(Global.selected_hair), 0)
	hair_color_idx  = max(Global.hair_color_options.find(Global.selected_hair_color), 0)
	shirt_idx       = max(shirt_keys.find(Global.selected_shirt), 0)
	shirt_color_idx = max(Global.shirt_color_options.find(Global.selected_shirt_color), 0)
	pants_idx       = max(pants_keys.find(Global.selected_pants), 0)
	pants_color_idx = max(Global.pants_color_options.find(Global.selected_pants_color), 0)
	shoes_idx       = max(shoes_keys.find(Global.selected_shoes), 0)
	shoes_color_idx = max(Global.shoes_color_options.find(Global.selected_shoes_color), 0)
	acc_idx         = max(acc_keys.find(Global.selected_acc), 0)
	acc_color_idx   = max(Global.acc_color_options.find(Global.selected_acc_color), 0)

	_update_skin();  _update_eyes();  _update_hair()
	_update_shirt(); _update_pants(); _update_shoes(); _update_acc()

func _on_skin_collect() -> void:
	skin_idx = (skin_idx + 1) % skin_keys.size(); _update_skin()
func _on_skin_color()   -> void:
	skin_color_idx = (skin_color_idx + 1) % Global.skin_color_options.size()
	Global.selected_skin_color = Global.skin_color_options[skin_color_idx]
	_apply_skin_color()
func _update_skin()     -> void:
	var key = skin_keys[skin_idx]
	skin_sprite.texture = Global.skin_collection[key]
	Global.selected_skin = key
	_apply_skin_color()
func _apply_skin_color()-> void:
	skin_sprite.modulate = Global.selected_skin_color

# … replicate _on_* and _update_* for eyes, hair, shirt, pants, shoes, accessory …

func _on_confirm_button_pressed() -> void:
	Global.player_name = name_input.text
	Global.save_game()
	# now clear and branch
	if _spawn_context == "fromMirror":
		Global.spawn_from = ""
		get_tree().change_scene_to_file(Global.last_scene)
	else:
		Global.spawn_from = ""
		get_tree().change_scene_to_file("res://scenes/farmhouse_interior.tscn")
