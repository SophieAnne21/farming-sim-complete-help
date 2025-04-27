extends Camera2D

@onready var tilemap = $"../../SeasonLayers" # Change to your town grass/road tilemap node

func _ready() -> void:
	make_current()

	if tilemap and tilemap.tile_set:
		var used_rect = tilemap.get_used_rect()
		var tile_size = tilemap.tile_set.tile_size

		var map_left   = used_rect.position.x * tile_size.x
		var map_top    = used_rect.position.y * tile_size.y
		var map_right  = (used_rect.position.x + used_rect.size.x) * tile_size.x
		var map_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y

		Global.camera_limit_left = map_left
		Global.camera_limit_right = map_right
		Global.camera_limit_top = map_top
		Global.camera_limit_bottom = map_bottom

		limit_left   = map_left
		limit_top    = map_top
		limit_right  = map_right
		limit_bottom = map_bottom

		print("✅ Town Camera set limits:", limit_left, limit_top, limit_right, limit_bottom)
	else:
		print("❌ Town Camera: No valid tilemap found!")
