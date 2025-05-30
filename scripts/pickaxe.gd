extends EntityState
class_name Pickaxe

func enter() -> void:
	super()

	if is_queued_for_deletion():
		return
	match get_entity_fsm().get_entity().direction:
			"up":
				get_entity_fsm().animator.play("pickaxe_back")
				get_entity_fsm().get_entity().visual_node.visible = false
				get_entity_fsm().get_entity().pickaxe.visible = true
				print("swung pickaxe")
				get_entity_fsm().get_entity()._update_visual_node()
				
			"down":
				get_entity_fsm().animator.play("pickaxe_front")
				get_entity_fsm().get_entity().visual_node.visible = false
				get_entity_fsm().get_entity().pickaxe.visible = true
				print("swung pickaxe")
				get_entity_fsm().get_entity()._update_visual_node()
				
			"left":
				get_entity_fsm().animator.play("pickaxe_left")
				get_entity_fsm().get_entity().visual_node.visible = false
				get_entity_fsm().get_entity().pickaxe.visible = true
				print("swung pickaxe")
				get_entity_fsm().get_entity()._update_visual_node()
				
			"right":
				get_entity_fsm().animator.play("pickaxe_right")
				print("swung pickaxe")

func _on_entered():
	pass # Replace with function body.
