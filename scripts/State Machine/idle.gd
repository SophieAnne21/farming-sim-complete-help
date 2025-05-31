extends PlayerState

@export var run_state: UPGState
@export var pickaxe_state: UPGState

func enter() -> void:
	super()

	if is_queued_for_deletion():
		return
	
	match player.direction:
		Player.Direction.Up:
			player.animator.play("idle_back")
		Player.Direction.Down:
			player.animator.play("idle_front")
		Player.Direction.Left:
			player.animator.play("idle_side")
			player.visual_node.scale.x = -1
		Player.Direction.Right:
			player.animator.play("idle_side")
			player.visual_node.scale.x = 1
	
	player.on_tool_used.connect(on_tool_used)

func exit() -> void:
	if player.on_tool_used.is_connected(on_tool_used):
		player.on_tool_used.disconnect(on_tool_used)

func physics_tick(delta: float) -> void:
	if player.get_current_input_direction().length() > 0:
		switch_to(run_state)

func on_tool_used() -> void:
	match player.tool:
		Player.Tool.Pickaxe:
			switch_to(pickaxe_state)
			return
