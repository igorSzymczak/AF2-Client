extends Node

enum Currency {
	FLUX,
	STEEL,
	HYDROGEN_CRYSTALS,
	PLASMA_FLUIDS,
	IRIDIUM,
}

func get_currency_texture_path(currency: Currency) -> String:
	match currency:
		Currency.FLUX: return "res://assets/ui/inventory/flux.png"
		Currency.STEEL: return "res://assets/ui/inventory/steel.png"
		Currency.HYDROGEN_CRYSTALS: return "res://assets/ui/inventory/hydrogen_crystals.png"
		Currency.PLASMA_FLUIDS: return "res://assets/ui/inventory/plasma_fluids.png"
		Currency.IRIDIUM: return "res://assets/ui/inventory/iridium.png"
	return "res://assets/ui/inventory/flux.png"

func get_currency_display_name(currency: Currency) -> String:
	match currency:
		Currency.FLUX: return "Flux"
		Currency.STEEL: return "Steel"
		Currency.HYDROGEN_CRYSTALS: return "Hydrogen Crystals"
		Currency.PLASMA_FLUIDS: return "Plasma Fluids"
		Currency.IRIDIUM: return "Iridium"
	return "Flux"

var currencies: Dictionary[Currency, int] = {
	Currency.FLUX: 0,
	Currency.STEEL: 0,
	Currency.HYDROGEN_CRYSTALS: 0,
	Currency.PLASMA_FLUIDS: 0,
	Currency.IRIDIUM: 0,
}

var flux: int = 0
var steel: int = 0
var hydrogen_crystals: int = 0
var plasma_fluids: int = 0
var iridium: int = 0

var cargo: Dictionary[Item.Code, int] = {}

func try_eject_cargo(_user_id: int) -> void:
	pass # Only Server
func try_recycle_cargo(_user_id: int, _cargo_to_recycle: Dictionary[int, int]) -> void:
	pass # Only Server

func get_currency(currency: Currency) -> int:
	return currencies[currency]

signal currency_changed(currency: Currency, value: int)
func _handle_set_currency(currency: Currency, value: int):
	if value == currencies[currency]: return
	currencies[currency] = value
	currency_changed.emit(currency, value)


signal cargo_changed()
func _handle_set_cargo(new_cargo: Dictionary[int, int]):
	cargo = new_cargo as Dictionary[Item.Code, int]
	cargo_changed.emit()

signal item_changed(code: int, previous_amount, new_amount: int)
func _handle_set_item(code: int, amount: int):
	if !cargo.has(code):
		cargo[code] = 0
	var old_amount: int = cargo[code]
	cargo[code] = amount
	item_changed.emit(code, old_amount, amount)

signal recycled_currencies(recycled_currencies: Dictionary[Currency, int])
func _handle_curriencies_recycled_gained(currencies_gained: Dictionary[int, int]):
	recycled_currencies.emit(currencies_gained as Dictionary[Currency, int])

@rpc("authority", "call_remote", "reliable")
func _set_currency(currency: int, value: int):
	_handle_set_currency(currency, value)

@rpc("authority", "call_remote", "reliable")
func _load_currencies_on_client(new_currencies: Dictionary):
	for currency: Currency in new_currencies:
		_handle_set_currency(currency, new_currencies[currency])

@rpc("authority", "call_remote", "reliable")
func _set_cargo(new_cargo: Dictionary[int, int]):
	_handle_set_cargo(new_cargo)

@rpc("authority", "call_remote", "reliable")
func _set_item(code: int, value: int):
	_handle_set_item(code, value)

@rpc("any_peer", "call_remote", "reliable")
func request_eject_cargo():
	try_eject_cargo(multiplayer.get_remote_sender_id())

@rpc("any_peer", "call_remote", "reliable")
func request_recycle_cargo(cargo_to_recycle: Dictionary[int, int]):
	try_recycle_cargo(multiplayer.get_remote_sender_id(), cargo_to_recycle)

@rpc("authority", "call_remote", "reliable")
func send_recycled_currency(currencies_gained: Dictionary[int, int]):
	_handle_curriencies_recycled_gained(currencies_gained)
