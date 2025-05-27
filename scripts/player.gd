extends CharacterBody2D

# UI control nodes (popups)
# Visual nodes
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


@onready var animated_sprite  : AnimationPlayer = $AnimationPlayer

@export var speed              : float   = 100.0
@export var bridge_tilemap     : TileMap
@export var bridge_y_threshold : float   = 100.0

var direction: String = "down"

func _ready():
	print("Player.gd ready. Global position before:", Global.player_position)
	tools.visible = false
	pickaxe.visible = false
	fishing.visible = false
	axe.visible = false
	sword.visible = false
	watering.visible = false
	block.visible = false
	hoe.visible = false
	
	# Set player to loaded saved position
	global_position = Global.player_position
	print("Player final position after loading:", global_position)
	var root = get_tree().get_current_scene()


	# Wait one frame so all other _ready() calls finish
	await get_tree().process_frame

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


func _physics_process(_delta: float) -> void:
	if Global.is_game_paused():
		velocity = Vector2.ZERO
	else:
		var input_dir = Vector2(
			Input.get_action_strength("right") - Input.get_action_strength("left"),
			Input.get_action_strength("down")  - Input.get_action_strength("up")
		)
		if input_dir != Vector2.ZERO:
			input_dir = input_dir.normalized()
			velocity = input_dir * speed
			_update_run_animation(input_dir)

			if abs(input_dir.x) > abs(input_dir.y):
				direction = "right" if input_dir.x > 0 else "left"
			else:
				direction = "down" if input_dir.y > 0 else "up"
		else:
			velocity = Vector2.ZERO
			_play_idle_animation()
	move_and_slide()


func _update_run_animation(input_dir: Vector2) -> void:
	if abs(input_dir.x) > abs(input_dir.y):
		animated_sprite.play("run_side")
		if input_dir.x < 0:
			visual_node.scale.x = -1
		else:
			visual_node.scale.x = 1
	else:
		if input_dir.y < 0:
			animated_sprite.play("run_back")
		else:
			animated_sprite.play("run_front")

func _play_idle_animation() -> void:
	tools.visible = false
	pickaxe.visible = false
	fishing.visible = false
	axe.visible = false
	sword.visible = false
	watering.visible = false
	block.visible = false
	hoe.visible = false
	
	match direction:
		"up":
			animated_sprite.play("idle_back")
		"down":
			animated_sprite.play("idle_front")
		"left":
			animated_sprite.play("idle_side")
			visual_node.scale.x = -1
		"right":
			animated_sprite.play("idle_side")
			visual_node.scale.x = 1
			
func _update_tool_animation() -> void:
	tools.visible = false
	if Input.is_action_just_pressed("pickaxe"):
		match direction:
			"up":
				animated_sprite.play("pickaxe_back")
				pickaxe.visible = true
			"down":
				animated_sprite.play("pickaxe_front")
				pickaxe.visible = true
			"left":
				animated_sprite.play("pickaxe_left")
				pickaxe.visible = true
			"right":
				animated_sprite.play("pickaxe_right")
				pickaxe.visible = true
	if Input.is_action_just_pressed("axe"):
		match direction:
			"up":
				animated_sprite.play("axe_back")
				tools.visible = true
			"down":
				animated_sprite.play("axe_front")
			"left":
				animated_sprite.play("axe_left")
			"right":
				animated_sprite.play("axe_right")

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
