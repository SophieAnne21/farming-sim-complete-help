extends PlayerState

@export var idle_state: UPGState
@onready var to_idle_state: Callable = create_transition(idle_state)

func enter() -> void:
	super()

	if is_queued_for_deletion():
		return
	
	match player.direction:
			Player.Direction.Up:
				player.animator.play("pickaxe_back")
			Player.Direction.Down:
				player.animator.play("pickaxe_front")
			Player.Direction.Left:
				player.animator.play("pickaxe_left")
			Player.Direction.Right:
				player.animator.play("pickaxe_right")
	
	print("swung pickaxe")
	
	player.visual_node.visible = false
	player.pickaxe.visible = true
	player._update_visual_node()
	
	get_tree().create_timer(0.9).timeout.connect(to_idle_state)
