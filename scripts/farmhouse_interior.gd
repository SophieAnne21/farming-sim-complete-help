extends Node2D

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                   = $fade/AnimationPlayer
@onready var spawn_from_farm_marker : Node2D = $SpawnMarker/SpawnFromFarm
@onready var mirror_label           = $toCC/Label

# two separate “entered” flags so they don’t fight each other
var entered_farm = false
var entered_cc   = false

func _ready():
	fade.play("fade_to_normal")

	if Global.spawn_from == "fromFarm":
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.global_position = spawn_from_farm_marker.global_position
	# clear the flag so it only applies once
	Global.spawn_from = ""

func _on_to_farm_body_entered(_body):
	if _body.is_in_group("Player"):
		entered_farm = true

func _on_to_farm_body_exited(_body):
	if _body.is_in_group("Player"):
		entered_farm = false

func _on_to_cc_body_entered(_body):
	if _body.is_in_group("Player"):
		entered_cc = true
		mirror_label.visible = true

func _on_to_cc_body_exited(_body):
	if _body.is_in_group("Player"):
		entered_cc = false
		mirror_label.visible = false

func _process(_delta):
	if entered_farm and Input.is_action_just_pressed("enter_door"):
		_go_to_farmhouse()
	elif entered_cc and Input.is_action_just_pressed("enter_door"):
		_go_to_character_creator()

func _go_to_farmhouse():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.position
	Global.spawn_from = "fromFarmhouse"
	Global.last_scene  = "res://scenes/farm.tscn"
	Global.cc          = "res://scenes/character_creator.tscn"
	Global.save_game()
	get_tree().change_scene_to_file(Global.last_scene)

func _go_to_character_creator():
	var player = get_tree().get_first_node_in_group("Player")
	if player:
		Global.player_position = player.global_position
	Global.last_scene = "res://scenes/farmhouse_interior.tscn"
	Global.spawn_from = "fromMirror"
	get_tree().change_scene_to_file(Global.cc)
