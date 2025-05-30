extends EntityState
class_name Idle

func enter():
	super()

	if is_queued_for_deletion():
		return
		
func physics_tick(delta: float) -> void:
	match get_entity_fsm().direction:
		"up":
			get_entity_fsm().animator.play("idle_back")
		"down":
			get_entity_fsm().animator.play("idle_front")
		"left":
			get_entity_fsm().animator.play("idle_side")
			get_entity_fsm().get_entity().visual_node.scale.x = -1
		"right":
			get_entity_fsm().animator.play("idle_side")
			get_entity_fsm().get_entity().visual_node.scale.x = 1
func _on_entered() -> void:
	pass # Replace with function body.
