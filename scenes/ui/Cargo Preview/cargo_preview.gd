extends Control

@onready var items: VBoxContainer = %Items
var pickups: Dictionary[int, Dictionary] = {}
@onready var eject_button: BetterButton = %EjectButton


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in items.get_children():
		child.queue_free()
	InventoryManager.cargo_changed.connect(_handle_cargo_changed)
	InventoryManager.item_changed.connect(_handle_item_changed)
	eject_button.pressed.connect(eject_cargo)

func _handle_item_changed(code: int, _prev: int, new: int) -> void:
	if !pickups.has(code):
		var pickup: Pickup = preload("res://scenes/ui/Pickups/pickup.tscn").instantiate()
		items.add_child(pickup)
		
		pickup.code = code
		pickup.amount = new
		pickups[code] = {
			"pickup": pickup,
			"time_elapsed": 0
		}
	else:
		if new == 0:
			pickups[code].pickup.queue_free()
			pickups.erase(code)
		else:
			var pickup: Pickup = pickups[code].pickup
			pickup.amount = new
			pickups[code].time_elapsed = 0

func _handle_cargo_changed() -> void:
	for code: Item.Code in InventoryManager.cargo:
		var amount: int = InventoryManager.cargo[code]
		_handle_item_changed(code, 0, amount)

func select_animation(animation_name: String):
	if animation_name == "open":
		show()
		g.can_perform_actions = true
		
	elif animation_name == "close":
		hide()

func eject_cargo() -> void:
	InventoryManager.request_eject_cargo.rpc_id(1)
