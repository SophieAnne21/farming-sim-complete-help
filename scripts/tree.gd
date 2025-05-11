extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# make sure the tree sits at z = canopy_layer_z + its Y
	z_index = 20 + int(global_position.y)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_area_2d_body_entered(body: Node2D) -> void:
	pass # Replace with function body.


func _on_area_2d_body_exited(body: Node2D) -> void:
	pass # Replace with function body.
