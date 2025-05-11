extends Node2D

@onready var body_sprite       = $Body
@onready var hair_sprite       = $Hair
@onready var eyes_sprite       = $Eyes
@onready var shirt_sprite      = $Shirt
@onready var pants_sprite      = $Pants
@onready var shoes_sprite      = $Shoes
@onready var accessory_sprite  = $Accessory

func update_portrait_from_global() -> void:
	body_sprite.texture = Global.skin_collection.get(Global.selected_skin, null)
	hair_sprite.texture = Global.hair_collection.get(Global.selected_hair, null)
	eyes_sprite.texture = Global.face_collection.get(Global.selected_eyes, null)
	shirt_sprite.texture = Global.shirt_collection.get(Global.selected_shirt, null)
	pants_sprite.texture = Global.pants_collection.get(Global.selected_pants, null)
	shoes_sprite.texture = Global.shoes_collection.get(Global.selected_shoes, null)
	accessory_sprite.texture = Global.acc_collection.get(Global.selected_acc, null)

	# Apply the chosen modulate (color tint) too!
	body_sprite.modulate = Global.selected_skin_color
	hair_sprite.modulate = Global.selected_hair_color
	eyes_sprite.modulate = Global.selected_eyes_color
	shirt_sprite.modulate = Global.selected_shirt_color
	pants_sprite.modulate = Global.selected_pants_color
	shoes_sprite.modulate = Global.selected_shoes_color
	accessory_sprite.modulate = Global.selected_acc_color
