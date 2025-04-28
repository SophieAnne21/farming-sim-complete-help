extends Button

@onready var item = $TextureRect
@onready var quantity_label = $Label

func update_slot(item_data: Dictionary) -> void:
	icon.texture = item_data["icon"]
	quantity_label.text = str(item_data["quantity"])
