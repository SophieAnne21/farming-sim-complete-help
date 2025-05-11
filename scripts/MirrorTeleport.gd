# mirror_teleport.gd
extends Area2D

@export var target_scene:String = "res://scenes/character_creator.tscn"
@export var return_scene:String = "res://scenes/farmhouse_interior.tscn"

@onready var prompt_label:Label = $Label  # the “Press Enter” label

var player_inside: bool = false

func _ready():
	prompt_label.visible = false

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = true
		prompt_label.visible = true

func _on_body_exited(body: Node) -> void:
	if body.is_in_group("Player"):
		player_inside = false
		prompt_label.visible = false

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("enter_door"):
		# remember where they were
		var player = get_tree().get_first_node_in_group("Player")
		if player:
			Global.player_position = player.global_position

		# flag for return
		Global.spawn_from   = "fromMirror"
		Global.last_scene   = return_scene

		# switch into creator (no saving yet)
		get_tree().change_scene_to_file(target_scene)
