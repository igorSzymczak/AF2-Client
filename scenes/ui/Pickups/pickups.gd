extends PanelContainer

const TIME_TO_VANISH = 10

@onready var pickups_container: VBoxContainer = %PickupsContainer

var pickups: Dictionary[int, Dictionary] = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for child in pickups_container.get_children():
		child.queue_free()
	visible = false
	
	InventoryManager.item_changed.connect(_handle_item_changed)

func _handle_item_changed(code: int, prev: int, new: int) -> void:
	visible = true
	if !pickups.has(code):
		var pickup: Pickup = preload("res://scenes/ui/Pickups/pickup.tscn").instantiate()
		pickups_container.add_child(pickup)
		
		pickup.code = code
		pickup.amount = new - prev
		pickups[code] = {
			"pickup": pickup,
			"time_elapsed": 0
		}
	else:
		var pickup: Pickup = pickups[code].pickup
		pickup.amount += new - prev
		pickups[code].time_elapsed = 0

func _process(delta: float) -> void:
	for code:int in pickups.keys():
		pickups[code].time_elapsed += delta
		if pickups[code].time_elapsed > TIME_TO_VANISH:
			pickups[code].pickup.queue_free()
			pickups.erase(code)
			if pickups.is_empty():
				visible = false
