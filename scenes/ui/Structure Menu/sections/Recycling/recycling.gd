extends Control

@export var animation_index: int = 3

@onready var cargo_container: VBoxContainer = %CargoContainer
@onready var recycle_button: BetterButton = %RecycleButton

var cargo_entries: Array[CargoEntry] = []
var selected_items: Dictionary[Item.Code, int]
var cargo_entry_scene: PackedScene = preload("res://scenes/ui/Structure Menu/sections/Recycling/cargo_entry.tscn")
var currency_entry_scene: PackedScene = preload("res://scenes/ui/Structure Menu/sections/Recycling/currency_entry.tscn")

var gained_currencies: Dictionary[InventoryManager.Currency, int]

func _ready() -> void:
	recycle_button.pressed.connect(_on_recycle_button_pressed)
	InventoryManager.recycled_currencies.connect(_on_recycled_currencies)

var recycling: bool = false
func load_cargo() -> void:
	if recycling:
		return
	# Clear everything
	recycle_button.disabled = true
	cargo_entries.clear()
	clear_cargo_container()
	
	# Generate new entries
	for item_code: Item.Code in InventoryManager.cargo:
		var value: int = InventoryManager.cargo[item_code]
		if value == 0:
			continue
		
		var cargo_entry: CargoEntry = cargo_entry_scene.instantiate()
		cargo_container.add_child(cargo_entry)
		cargo_entries.append(cargo_entry)
		cargo_entry.init(item_code, value)
		
		cargo_entry.toggled.connect(_on_item_toggled)

func _on_item_toggled(item_code: Item.Code, amount: int, value: bool) -> void:
	if value:
		selected_items[item_code] = amount
	else:
		selected_items.erase(item_code)
	
	if selected_items.size() == 0:
		recycle_button.disabled = true
	else:
		recycle_button.disabled = false

func _on_recycle_button_pressed() -> void:
	var station: RecycleStation = g.me.landed_structure
	recycle_button.disabled = true
	recycling = true
	
	for cargo_entry: CargoEntry in cargo_entries:
		var tween: Tween = create_tween()
		var width: float = cargo_entry.get_rect().size.x
		if cargo_entry.selected:
			var new_position: Vector2 = cargo_entry.position + Vector2(width, 0)
			tween.tween_property(cargo_entry, "position", new_position, 1.0)
		else:
			var new_position: Vector2 = cargo_entry.position - Vector2(width, 0)
			tween.tween_property(cargo_entry, "position", new_position, 1.0)
	
	InventoryManager.request_recycle_cargo.rpc_id(1, selected_items)
	
	await get_tree().create_timer(0.5).timeout
	SoundManager.play_sound_from_name("Recycling", g.me.global_position)
	station.animate_progress_bar(100.0, 6.0)
	await get_tree().create_timer(6.0).timeout
	SoundManager.play_sound_from_name("RecyclingEnd", g.me.global_position)
	await get_tree().create_timer(1.0).timeout
	
	clear_cargo_container()
	if gained_currencies.is_empty():
		recycling = false
		return
	
	var currency_index: int = 0
	for currency: InventoryManager.Currency in gained_currencies:
		var entry: CurrencyEntry = currency_entry_scene.instantiate()
		entry.modulate.a = 0.0
		cargo_container.add_child(entry)
		cargo_container.move_child(entry, -1)
		entry.init(currency, gained_currencies[currency])
		var entry_width: float = entry.get_rect().size.x
		var entry_height: float = entry.get_rect().size.y
		
		entry.position.x = entry_width
		entry.position.y = (entry_height + 8) * currency_index
		
		# Animating the entry
		SoundManager.play_sound_from_name("RecyclingNewMaterial", g.me.global_position)
		var position_tween: Tween = create_tween()
		var modulate_tween: Tween = create_tween()
		position_tween.tween_property(entry, "position", Vector2(0, entry.position.y), 0.3)
		modulate_tween.tween_property(entry, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.3)
		await get_tree().create_timer(1.0).timeout
		
		currency_index += 1
	station.animate_progress_bar(0.0, 2.0)
	recycling = false

func _on_recycled_currencies(currencies: Dictionary[InventoryManager.Currency, int]) -> void:
	gained_currencies = currencies
	
func clear_cargo_container() -> void:
	for child: Control in cargo_container.get_children():
		child.queue_free()
	
