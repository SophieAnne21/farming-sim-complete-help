extends CharacterBody2D
class_name Player

#region Misc properties
@export var speed              : float   = 70.0
@export var bridge_y_threshold : float   = 100.0
#endregion

#region Node References
@onready var visual_node      : Node2D          = $Skeleton
@onready var body_sprite      : Sprite2D        = $Skeleton/body
@onready var hair             : Sprite2D        = $Skeleton/hair
@onready var eyes             : Sprite2D        = $Skeleton/eyes
@onready var shirt            : Sprite2D        = $Skeleton/shirt
@onready var pants            : Sprite2D        = $Skeleton/pants
@onready var shoes            : Sprite2D        = $Skeleton/shoes
@onready var accessories      : Sprite2D        = $Skeleton/accessories

@onready var tools            : Node2D          = $tool_skeleton
@onready var pickaxe          : Sprite2D        = $tool_skeleton/body_pick
@onready var fishing          : Sprite2D        = $tool_skeleton/body_fish
@onready var axe              : Sprite2D        = $tool_skeleton/body_axe
@onready var sword            : Sprite2D        = $tool_skeleton/body_sword
@onready var watering         : Sprite2D        = $tool_skeleton/body_water
@onready var block            : Sprite2D        = $tool_skeleton/body_block
@onready var hoe              : Sprite2D        = $tool_skeleton/body_hoe

@onready var name_label       : Label           = $NameLabel
@onready var animator         : AnimationPlayer = $AnimationPlayer

@export var bridge_tilemap     : TileMap
#endregion

#region Tools
enum Tool {
	None,
	Axe,
	Pickaxe,
	Fishing,
	Watering,
	Tilling,
	Block,
	Sword
}

signal on_tool_used
signal on_tool_changed(new_tool: Tool)

@export var tool: Tool = Tool.None:
	get:
		return tool
	set(value):
		if tool == value:
			return
		
		tool = value
		
		on_tool_changed.emit(tool)
#endregion

#region Default & Misc Methods
func _ready():
	print("Player.gd ready. Global position before:", Global.player_position)
	
	# Set player to loaded saved position
	global_position = Global.player_position
	print("Player final position after loading:", global_position)
	var root = get_tree().get_current_scene()

	# Wait one frame so all other _ready() calls finish
	await get_tree().process_frame

	pickaxe.visible = false
	fishing.visible = false
	axe.visible = false
	sword.visible = false
	watering.visible = false
	block.visible = false
	hoe.visible = false

	# ─── SPAWN LOGIC ────────────────────────────────────────────────────────────
	var spawn_point: Marker2D = null
	match Global.spawn_from:
		# farm.tscn
		"fromTown":
			spawn_point = root.get_node_or_null("SpawnPoints/SpawnFromTown") as Marker2D
		"fromFarmhouse":
			spawn_point = root.get_node_or_null("SpawnPoints/SpawnFromFarmhouse") as Marker2D
		"newGame":
			spawn_point = root.get_node_or_null("SpawnPoints/NewSpawn") as Marker2D
		#farmhouse_interior.tscn
		"inFarmhouse":
			spawn_point = root.get_node_or_null("SpawnMarker/SpawnInside") as Marker2D
		"fromMirror":
			spawn_point = root.get_node_or_null("SpawnMarker/SpawnFromMirror") as Marker2D
		#town_map.tscn
		"toTown":
			spawn_point = root.get_node_or_null("SpawnPoints/SpawnFromFarm") as Marker2D
		_:
			spawn_point = null
	print("🌀 loaded spawn:", Global.spawn_from)

	if spawn_point != null and is_instance_valid(spawn_point):
		var target = spawn_point.global_position
		global_position = target
		Global.player_position = target
		Global.save_game()
		print("🌀 Spawned at marker:", spawn_point.name)
	else:
		global_position = Global.player_position
		print("Loaded saved player position:", global_position)
		
	initialize_player()
	print("Player final position:", global_position)

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_echo():
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				if event.is_pressed():
					on_tool_used.emit()

func _play_tool_animation():
	if Input.is_action_just_pressed("pickaxe"):
		match direction:
			"up":
				visual_node.play("pickaxe_back")
				visual_node.visible = false
				pickaxe.visible = true
				print("swung pickaxe")
				_update_visual_node()
				
			"down":
				visual_node.play("pickaxe_front")
				visual_node.visible = false
				pickaxe.visible = true
				print("swung pickaxe")
				_update_visual_node()
				
			"left":
				visual_node.play("pickaxe_left")
				visual_node.visible = false
				pickaxe.visible = true
				print("swung pickaxe")
				_update_visual_node()
				
			"right":
				visual_node.play("pickaxe_right")
				visual_node.visible = false
				pickaxe.visible = true
				print("swung pickaxe")
				_update_visual_node()
				
		
	if Input.is_action_just_pressed("axe"):
		match direction:
			"up":
				visual_node.play("axe_back")
				visual_node.visible = false
				axe.visible = true
				print("swung axe")
				_update_visual_node()
				
			"down":
				visual_node.play("axe_front")
				visual_node.visible = false
				axe.visible = true
				print("swung axe")
				_update_visual_node()
				
			"left":
				visual_node.play("axe_left")
				visual_node.visible = false
				axe.visible = true
				print("swung axe")
				_update_visual_node()
				
			"right":
				visual_node.play("axe_right")
				visual_node.visible = false
				axe.visible = true
				print("swung axe")
				_update_visual_node()

func _update_visual_node():
	await get_tree().create_timer(1).timeout
	pickaxe.visible = false
	fishing.visible = false
	axe.visible = false
	sword.visible = false
	watering.visible = false
	block.visible = false
	hoe.visible = false
	visual_node.visible = true

func initialize_player() -> void:
	print("shirt node:", shirt, "visible?", shirt.visible, "texture:", shirt.texture)
	
	body_sprite.z_index = 0
	shirt.z_index       = 1
	pants.z_index       = 2
	shoes.z_index       = 3
	accessories.z_index = 4
	hair.z_index        = 5
	eyes.z_index        = 6

	body_sprite.visible = true
	body_sprite.modulate.a = 1.0
	body_sprite.scale = Vector2(1, 1)
	
	body_sprite.texture  = Global.skin_collection.get(Global.selected_skin, Global.skin_collection["white"])
	hair.texture         = Global.hair_collection.get(Global.selected_hair, Global.hair_collection["buzzcut"])
	eyes.texture         = Global.face_collection.get(Global.selected_eyes, Global.face_collection["eyes"])
	shirt.texture        = Global.shirt_collection.get(Global.selected_shirt, Global.shirt_collection["basic"])
	pants.texture        = Global.pants_collection.get(Global.selected_pants, Global.pants_collection["pants"])
	shoes.texture        = Global.shoes_collection.get(Global.selected_shoes, Global.shoes_collection["shoes"])
	accessories.texture  = Global.acc_collection.get(Global.selected_acc, null)

	#body_sprite.modulate = Color(1, 0, 0)
	Global.apply_pastel_shader(body_sprite, Global.selected_skin_color)
	Global.apply_pastel_shader(hair,        Global.selected_hair_color)
	Global.apply_pastel_shader(eyes,        Global.selected_eyes_color)
	Global.apply_pastel_shader(shirt,       Global.selected_shirt_color)
	Global.apply_pastel_shader(pants,       Global.selected_pants_color)
	Global.apply_pastel_shader(shoes,       Global.selected_shoes_color)
	Global.apply_pastel_shader(accessories, Global.selected_acc_color)

	# 3) Set the name label
	
	if name_label != null:
		if Global.player_name != "":
			name_label.text = Global.player_name
		else:
			name_label.text = "Check the mirror"
#endregion

#region Direction
enum Direction {
	Up,
	Down,
	Left,
	Right
}

signal on_direction_changed(new_direction: Direction)

var direction: Direction = Direction.Down:
	get:
		return direction
	set(value):
		if direction == value:
			return
		
		direction = value
		
		on_direction_changed.emit(direction)

func get_current_input_direction() -> Vector2:
	return Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	)
#endregion
