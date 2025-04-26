extends Node2D

# ─── NODE REFERENCES ──────────────────────────────────────────────────────────
@onready var fade                   = $fade/AnimationPlayer
@onready var spawn_from_farm_marker : Node2D = $SpawnMarker/SpawnFromFarm

var entered = false

func _ready():
	# play your normal fade-in
	fade.play("fade_to_normal")

	# if we flagged a farm-return, drop player at that marker
	if Global.spawn_from == "fromFarm":
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			player.global_position = spawn_from_farm_marker.global_position

	# clear it so next time we don’t re-teleport
	Global.spawn_from = ""

func _on_to_farm_body_entered(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		entered = true

func _on_to_farm_body_exited(_body: Node2D) -> void:
	if _body.is_in_group("Player"):
		entered = false

func _process(_delta):
	if entered and Input.is_action_just_pressed("enter_door"):
		# save current spot
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			Global.player_position = player.position

		# flag the farm scene: on load it'll read SpawnFromFarm
		Global.spawn_from = "fromFarm"
		Global.last_scene  = "res://farm.tscn"
		Global.save_game()

		get_tree().change_scene_to_file(Global.last_scene)
