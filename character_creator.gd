extends Node2D

# ─── ONREADY FOR CONFIRM ────────────────────────────────────────────────────────
@onready var name_input = $CreatorScreen/ColorRect/Details/TextEdit
@onready var confirm_button = $CreatorScreen/ColorRect/ConfirmButton

# ─── NODE REFERENCES ────────────────────────────────────────────────────────────
@onready var skin_sprite      : Sprite2D = $Skeleton/Skin/SkinSprite
@onready var eyes_sprite      : Sprite2D = $Skeleton/Eyes/EyesSprite
@onready var shirt_sprite     : Sprite2D = $Skeleton/Shirt/ShirtSprite
@onready var pants_sprite     : Sprite2D = $Skeleton/Pants/PantsSprite
@onready var shoes_sprite     : Sprite2D = $Skeleton/Shoes/ShoesSprite
@onready var hair_sprite      : Sprite2D = $Skeleton/Hair/HairSprite
@onready var acc_sprite       : Sprite2D = $Skeleton/Accessories/AccessoriesSprite


#@onready var skin_collect_btn : Button   = $CreatorScreen/Skin/CollectionButton
@onready var skin_color_btn   : Button   = $CreatorScreen/ColorRect/Skin/ColorButton
#@onready var eyes_collect_btn : Button   = $CreatorScreen/Eyes/CollectionButton
@onready var eyes_color_btn   : Button   = $CreatorScreen/ColorRect/Eyes/ColorButton
@onready var hair_collect_btn : Button   = $CreatorScreen/ColorRect/Hair/CollectionButton
@onready var hair_color_btn   : Button   = $CreatorScreen/ColorRect/Hair/ColorButton
@onready var shirt_collect_btn : Button   = $CreatorScreen/ColorRect/Shirt/CollectionButton
@onready var shirt_color_btn   : Button   = $CreatorScreen/ColorRect/Shirt/ColorButton
@onready var pants_collect_btn : Button   = $CreatorScreen/ColorRect/Pants/CollectionButton
@onready var pants_color_btn   : Button   = $CreatorScreen/ColorRect/Pants/ColorButton
@onready var shoes_collect_btn : Button   = $CreatorScreen/ColorRect/Shoes/CollectionButton
#@onready var shoes_color_btn   : Button   = $CreatorScreen/ColorRect/Shoes/ColorButton
@onready var acc_collect_btn : Button   = $CreatorScreen/ColorRect/Accessories/CollectionButton
@onready var acc_color_btn   : Button   = $CreatorScreen/ColorRect/Accessories/ColorButton




# ─── STATE TRACKERS & KEY LISTS ────────────────────────────────────────────────
var skin_idx       : int    = 0
var skin_color_idx : int    = 0
var eyes_idx       : int    = 0
var eyes_color_idx : int    = 0

var skin_keys : Array = []
var eyes_keys : Array = []

# ─── READY ─────────────────────────────────────────────────────────────────────
func _ready() -> void:
	# 1) Build your key-arrays once:
	skin_keys = Global.skin_collection.keys()
	eyes_keys = Global.face_collection.keys()

	# 2) Connect your UI buttons to local handlers:
	#skin_collect_btn.pressed.connect( Callable(self, "_on_skin_collect") )
	skin_color_btn.  pressed.connect( Callable(self, "_on_skin_color") )
	#eyes_collect_btn.pressed.connect( Callable(self, "_on_eyes_collect") )
	eyes_color_btn.  pressed.connect( Callable(self, "_on_eyes_color") )

	# 3) Listen for Global’s color‐changed signals (e.g. on load):
	Global.connect("skin_color_changed", Callable(self, "_apply_skin_color"))
	Global.connect("eyes_color_changed", Callable(self, "_apply_eyes_color"))

	# 4) Initialize previews to their saved or default states:
	_update_skin()
	_update_eyes()

# ─── SKIN HANDLERS & UPDATES ────────────────────────────────────────────────────
func _on_skin_collect() -> void:
	skin_idx = (skin_idx + 1) % skin_keys.size()
	_update_skin()

func _on_skin_color() -> void:
	skin_color_idx = (skin_color_idx + 1) % Global.skin_color_options.size()
	Global.set_skin_color(Global.skin_color_options[skin_color_idx])

func _update_skin() -> void:
	var key = skin_keys[skin_idx]
	skin_sprite.texture = Global.skin_collection[key]
	Global.selected_skin = key
	_apply_skin_color(Global.selected_skin_color)

func _apply_skin_color(color: Color) -> void:
	skin_sprite.modulate = color

# ─── EYES HANDLERS & UPDATES ────────────────────────────────────────────────────
func _on_eyes_collect() -> void:
	eyes_idx = (eyes_idx + 1) % eyes_keys.size()
	_update_eyes()

func _on_eyes_color() -> void:
	eyes_color_idx = (eyes_color_idx + 1) % Global.eyes_color_options.size()
	Global.set_eyes_color(Global.eyes_color_options[eyes_color_idx])

func _update_eyes() -> void:
	var key = eyes_keys[eyes_idx]
	eyes_sprite.texture = Global.face_collection[key]
	Global.selected_eyes = key
	_apply_eyes_color(Global.selected_eyes_color)

func _apply_eyes_color(color: Color) -> void:
	eyes_sprite.modulate = color
	
# ─── HAIR HANDLERS & UPDATES ────────────────────────────────────────────────────

func _on_confirm_button_pressed() -> void:
	Global.player_name = name_input.text
	print("🖋 Confirm clicked. Input name is:", name_input.text, "typeof:", typeof(name_input.text))

	Global.last_scene = "res://farm.tscn"
	Global.save_game()

	get_tree().change_scene_to_file(Global.last_scene)
