extends Camera2D

@onready var tilemap = $"../../SpringLayer/ground" # Adjust path if TileMap isn't one level up

func _ready():
	make_current()  # Set this camera active

	var used_rect = tilemap.get_used_rect()
	var tile_size = tilemap.tile_set.tile_size

	var map_left = used_rect.position.x * tile_size.x
	var map_top = used_rect.position.y * tile_size.y
	var map_right = (used_rect.position.x + used_rect.size.x) * tile_size.x
	var map_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y

	print("Camera2D limits:", map_left, map_top, map_right, map_bottom)

	limit_left = map_left
	limit_top = map_top
	limit_right = map_right
	limit_bottom = map_bottom
