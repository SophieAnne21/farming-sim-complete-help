extends CharacterBody2D
class_name Player

@onready var body            = $Skeleton/body
@onready var hair            = $Skeleton/hair
@onready var eyes            = $Skeleton/eyes
@onready var shirt           = $Skeleton/shirt
@onready var pants           = $Skeleton/pants
@onready var shoes           = $Skeleton/shoes
@onready var accessories     = $Skeleton/accessories
@onready var name_label      = $Label
@onready var animated_sprite = $AnimationPlayer
@onready var visual_node     = $Skeleton

@export var speed: float              = 100.0
@export var bridge_tilemap: TileMap
@export var bridge_y_threshold: float = 100.0  # adjust as needed

var direction = "down"
var last_direction = Vector2.ZERO
var just_spawned = true

func face_away_from_player():
	animated_sprite.play("idle_back")

func _ready():
	# ensure scene tree is ready
	await get_tree().process_frame

	# spawn handling based on last_scene
	var root = get_tree().get_current_scene()
	var spawn_point: Node2D = null
	match Global.last_scene:
		"res://town_map.tscn":
			spawn_point = root.get_node_or_null("SpawnFromTown")
		"res://farmhouse_interior.tscn":
			spawn_point = root.get_node_or_null("SpawnFromFarmhouse")
		"res://farm.tscn":
			spawn_point = root.get_node_or_null("SpawnFromFarm")
		_:
			spawn_point = null

	if spawn_point:
		position = spawn_point.global_position
		print("🌀 Spawned at marker:", spawn_point.name)
	else:
		position = Global.player_position
		print("📍 Loaded saved player position:", position)

	initialize_player()

func _physics_process(_delta: float) -> void:
	handle_input()
	move_and_slide()

func handle_input():
	var input_vector = Vector2.ZERO
	if Input.is_action_pressed("up"):
		input_vector.y -= 1; direction = "up"
	if Input.is_action_pressed("down"):
		input_vector.y += 1; direction = "down"
	if Input.is_action_pressed("left"):
		input_vector.x -= 1; direction = "left"
	if Input.is_action_pressed("right"):
		input_vector.x += 1; direction = "right"

	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
		if abs(input_vector.x) > abs(input_vector.y):
			animated_sprite.play("run_side")
			visual_node.scale.x = -1 if input_vector.x < 0 else 1
		else:
			if input_vector.y < 0:
				animated_sprite.play("run_back")
			else:
				animated_sprite.play("run_front")
	else:
		velocity = Vector2.ZERO
		match direction:
			"up":
				animated_sprite.play("idle_back")
			"down":
				animated_sprite.play("idle_front")
			"left":
				animated_sprite.play("idle_side"); visual_node.scale.x = -1
			"right":
				animated_sprite.play("idle_side"); visual_node.scale.x = 1

func initialize_player():
	# skin
	body.texture = Global.skin_collection.get(Global.selected_skin, Global.skin_collection["white"])
	# hair
	hair.texture = Global.hair_collection.get(Global.selected_hair, Global.hair_collection["buzzcut"])
	# eyes
	eyes.texture = Global.face_collection.get(Global.selected_eyes, Global.face_collection["eyes"])
	# shirt
	shirt.texture = Global.shirt_collection.get(Global.selected_shirt, Global.shirt_collection["basic"])
	# pants
	pants.texture = Global.pants_collection.get(Global.selected_pants, Global.pants_collection["pants"])
	# shoes
	shoes.texture = Global.shoes_collection.get(Global.selected_shoes, Global.shoes_collection["shoes"])
	# accessories (optional)
	accessories.texture = Global.acc_collection.get(Global.selected_acc, null)

	# modulate colors
	body.modulate        = Global.selected_skin_color
	hair.modulate        = Global.selected_hair_color
	eyes.modulate        = Global.selected_eyes_color
	shirt.modulate       = Global.selected_shirt_color
	pants.modulate       = Global.selected_pants_color
	shoes.modulate       = Global.selected_shoes_color
	accessories.modulate = Global.selected_acc_color

	# label
	name_label.text = Global.player_name if Global.player_name != "" else "Check the mirror"
