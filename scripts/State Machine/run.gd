extends PlayerState

@export var idle_state: UPGState
@export var pickaxe_state: UPGState

func enter() -> void:
	
	if is_queued_for_deletion():
		return
	
	player.on_direction_changed.connect(on_direction_changed)
	player.on_tool_used.connect(on_tool_used)

func exit() -> void:
	
	if player.on_direction_changed.is_connected(on_direction_changed):
		player.on_direction_changed.disconnect(on_direction_changed)
	
	if player.on_tool_used.is_connected(on_tool_used):
		player.on_tool_used.disconnect(on_tool_used)

func physics_tick(delta):

	if Global.is_game_paused():
		return

	var input_dir = player.get_current_input_direction()

	if input_dir == Vector2.ZERO:
		switch_to(idle_state)
		return

	input_dir = input_dir.normalized()
	player.velocity = input_dir * player.speed

	player.move_and_slide()
	
	var new_direction: Player.Direction
	
	if abs(input_dir.x) > abs(input_dir.y):
		new_direction = Player.Direction.Right if input_dir.x > 0 else Player.Direction.Left
	else:
		new_direction = Player.Direction.Down if input_dir.y > 0 else Player.Direction.Up
	
	if new_direction == player.direction:
		on_direction_changed(new_direction)
	else:
		player.direction = new_direction

func on_direction_changed(new_direction: Player.Direction) -> void:
	match new_direction:
		Player.Direction.Up:
			player.animator.play("run_back")
		Player.Direction.Down:
			player.animator.play("run_front")
		Player.Direction.Left:
			player.animator.play("run_side")
			player.visual_node.scale.x = -1
		Player.Direction.Right:
			player.animator.play("run_side")
			player.visual_node.scale.x = 1

func on_tool_used() -> void:
	match player.tool:
		Player.Tool.Pickaxe:
			switch_to(pickaxe_state)
			return
