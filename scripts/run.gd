extends EntityState
class_name Run

@export var idle_state: UPGState

func physics_tick(delta):

	if Global.is_game_paused():
		print(get_path(), " can't move! Game is currently paused.")
		return

	var input_dir = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down")  - Input.get_action_strength("up")
	)

	if input_dir == Vector2.ZERO:
		print(get_path(), " detected no movement input! Swapping to idle.")
		switch_to(idle_state)
		return

	input_dir = input_dir.normalized()
	get_entity_fsm().get_entity().velocity = input_dir * get_entity_fsm().get_entity().speed

	print("Entity velocity set to ", get_entity_fsm().get_entity().velocity)

	get_entity_fsm().get_entity().move_and_slide()

	if abs(input_dir.x) > abs(input_dir.y):
		get_entity_fsm().direction = "right" if input_dir.x > 0 else "left"
	else:
		get_entity_fsm().direction = "down" if input_dir.y > 0 else "up"
