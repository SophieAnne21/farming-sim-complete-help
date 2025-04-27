extends Camera2D

var player: CharacterBody2D
# Tilemap detection for setting limits
@export var tilemap_path: NodePath
@export var tile_size: Vector2 = Vector2(16, 16)  # Customize per game if needed
@export var padding: float = 64.0  # Extra padding inside map edges

@onready var tilemap: TileMapLayer = get_node_or_null(tilemap_path)

func _ready() -> void:
	make_current()
	
	limit_left = Global.camera_limit_left
	limit_right = Global.camera_limit_right
	limit_top = Global.camera_limit_top
	limit_bottom = Global.camera_limit_bottom
	
	var found_node = get_tree().get_first_node_in_group("Player")

	if found_node is CharacterBody2D:
		player = found_node
	else:
		printerr("❌ Found node in 'Player' group is not a CharacterBody2D:", found_node)
		player = null
		
	if player == null:
		printerr("❌ Player not found by Camera2D")
		
	print("🔥 Camera2D _ready running:", self.name)

	if tilemap == null:
		printerr("❌ Tilemap not found at path:", tilemap_path)
		return

	_set_camera_limits()

func _set_camera_limits() -> void:
	var used_rect = tilemap.get_used_rect()

	var map_left = used_rect.position.x * tile_size.x
	var map_top = used_rect.position.y * tile_size.y
	var map_right = (used_rect.position.x + used_rect.size.x) * tile_size.x
	var map_bottom = (used_rect.position.y + used_rect.size.y) * tile_size.y

	var screen_half_width = (get_viewport_rect().size.x / 2) * zoom.x
	var screen_half_height = (get_viewport_rect().size.y / 2) * zoom.y

	
	limit_left = map_left + screen_half_width + padding
	limit_top = map_top + screen_half_height + padding
	limit_right = map_right - screen_half_width - padding
	limit_bottom = map_bottom - screen_half_height - padding

	# Save to Global (optional, if you want)
	Global.camera_limit_left = limit_left
	Global.camera_limit_right = limit_right
	Global.camera_limit_top = limit_top
	Global.camera_limit_bottom = limit_bottom

	print("✅ Camera limits set:", limit_left, limit_top, limit_right, limit_bottom)
	
func _process(_delta: float) -> void:
	if player != null:
		global_position = player.global_position
