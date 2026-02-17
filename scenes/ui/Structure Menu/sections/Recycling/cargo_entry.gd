class_name CargoEntry extends MarginContainer

@onready var checkbox: CheckBox = %CheckBox
@onready var texture_rect: TextureRect = %TextureRect
@onready var item_name_label: Label = %ItemName
@onready var amount_label: Label = %Amount
@onready var background: TextureRect = %Background

var item_code: Item.Code
var amount: int
var selected: bool = false

signal toggled(code: Item.Code, amount: int, value: bool)

func init(new_item_code: Item.Code, new_amount: int) -> void:
	item_code = new_item_code
	amount = new_amount
	
	var item: Item = ItemManager.ITEM_SCENES[item_code].instantiate()
	
	item_name_label.text = item.display_name
	amount_label.text = str("x ", amount)
	texture_rect.texture = load(Item.get_texture_path_by_code(item.code))
	
	checkbox.toggled.connect(_on_checkbox_toggled)

func _on_checkbox_toggled(value: bool) -> void:
	selected = value
	background.visible = value
	toggled.emit(item_code, amount, value)
