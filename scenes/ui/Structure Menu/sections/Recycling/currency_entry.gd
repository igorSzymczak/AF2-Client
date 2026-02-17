class_name CurrencyEntry extends MarginContainer

@onready var texture_rect: TextureRect = %TextureRect
@onready var currency_name_label: Label = %CurrencyName
@onready var value_label: Label = %Value

var currency: InventoryManager.Currency
var value: int

func init(new_currency: InventoryManager.Currency, new_value: int) -> void:
	currency = new_currency
	value = new_value
	
	currency_name_label.text = InventoryManager.get_currency_display_name(currency)
	value_label.text = str("+ ", Functions.shorten_number(value))
	texture_rect.texture = load(InventoryManager.get_currency_texture_path(currency))
