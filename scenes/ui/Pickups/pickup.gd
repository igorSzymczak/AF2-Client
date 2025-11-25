class_name Pickup extends HBoxContainer

@export var code: int : set = set_code
@export var amount: int : set = set_amount

@onready var texture_rect: TextureRect = $TextureRect
@onready var label: Label = $Label

func set_code(new_code: int) -> void:
	code = new_code
	texture_rect.texture = load(Item.get_texture_path_by_code(code))

func set_amount(new_amount: int) -> void:
	amount = new_amount
	var item: Item = ItemManager.ITEM_SCENES[code].instantiate()
	label.text = str("+ ", amount, " ", item.display_name)
