# InteractiveCanopyMap.gd
extends TileMap

# Which tiles (by source ID) should fade when the player walks under them?
@export var interactive_tile_ids: Array[int] = [0]  
@export var fade_alpha: float = 0.5

# remember the last cell we faded so we can restore it
var _last_cell: Vector2i = Vector2i(-1, -1)

func _physics_process(delta: float) -> void:
	var player = get_node("../Player")  # adjust path as needed
	# 1) convert world → local → map coords
	var local_pos = to_local(player.global_position)
	var cell = local_to_map(local_pos)

	if cell != _last_cell:
		# 2) restore the old cell (if it was interactive)
		if _last_cell != Vector2i(-1, -1):
			var old_id = get_cell_source_id(0, _last_cell)
			if old_id in interactive_tile_ids:
				var old_data = get_cell_tile_data(0, _last_cell)
				old_data.modulate = Color(1, 1, 1, 1)

		# 3) fade the new cell (if it’s interactive)
		var new_id = get_cell_source_id(0, cell)
		if new_id in interactive_tile_ids:
			var new_data = get_cell_tile_data(0, cell)
			new_data.modulate = Color(1, 1, 1, fade_alpha)
			# push the player behind this layer
			player.z_index = z_index - 1
		else:
			# no canopy here → reset player draw order however you prefer
			player.z_index = int(player.global_position.y)

		# 4) tell the TileMap to rebuild its mesh *now* so the modulate takes effect
		update_internals()

		_last_cell = cell
