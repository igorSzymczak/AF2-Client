extends Node

var flux: int = 0
var steel: int = 0
var hydrogen_crystals: int = 0
var plasma_fluids: int = 0
var iridium: int = 0

signal flux_changed()
func _handle_set_flux(amount: int):
	flux = amount
	flux_changed.emit()

signal steel_changed()
func _handle_set_steel(amount: int):
	steel = amount
	steel_changed.emit()

signal hydrogen_crystals_changed()
func _handle_set_hydrogen_crystals(amount: int):
	hydrogen_crystals = amount
	hydrogen_crystals_changed.emit()

signal plasma_fluids_changed()
func _handle_set_plasma_fluids(amount: int):
	plasma_fluids = amount
	plasma_fluids_changed.emit()

signal iridium_changed()
func _handle_set_iridium(amount: int):
	iridium = amount
	iridium_changed.emit()

@rpc("authority", "call_remote", "reliable")
func _set_steel(amount: int):
	_handle_set_steel(amount)

@rpc("authority", "call_remote", "reliable")
func _set_flux(amount: int):
	_handle_set_flux(amount)

@rpc("authority", "call_remote", "reliable")
func _set_hydrogen_crystals(amount: int):
	_handle_set_hydrogen_crystals(amount)

@rpc("authority", "call_remote", "reliable")
func _set_plasma_fluids(amount: int):
	_handle_set_plasma_fluids(amount)

@rpc("authority", "call_remote", "reliable")
func _set_iridium(amount: int):
	_handle_set_iridium(amount)

@rpc("authority", "call_remote", "reliable")
func _load_inventory_on_client(inventory: Dictionary):
	_handle_set_steel(inventory.steel)
	_handle_set_hydrogen_crystals(inventory.hydrogen_crystals)
	_handle_set_plasma_fluids(inventory.plasma_fluids)
	_handle_set_iridium(inventory.iridium)
