extends Control

@export var animation_index: int = 1
@export var right_panel: Control

@onready var weapons_container: VBoxContainer = %WeaponsContainer

const weapon_ui_scene: PackedScene = preload("res://scenes/ui/Weapon Element/weapon_element.tscn")
var weapons: Dictionary[WeaponManager.Type, Dictionary] # nested costs -> Dictionary[InventoryManager.Currency, int]


func load_weapons(structure_args: Dictionary) -> void:
	clear_weapons_container()
	currently_chosen_element = null
	
	if !structure_args.keys().has(WeaponFactory.Property.WEAPONS):
		return
	
	weapons = structure_args[WeaponFactory.Property.WEAPONS]
	for weapon_type: WeaponManager.Type in weapons:
		var weapon: Weapon = WeaponManager.get_weapon(weapon_type)
		
		var element: WeaponElement = weapon_ui_scene.instantiate()
		weapons_container.add_child(element)
		element.weapon = weapon
		element.weapon_name = weapon.weapon_name
		element.info_shown = true
		if PlayerData.get_arsenal_weapon(weapon_type) != null:
			element.lvl_label.show()
			element.lvl_label.text = "Bought!"
			element.lvl_label.modulate = Color(0, 1.0, 0.0)
		else:
			element.lvl_label.hide()
		element.button.toggle_mode = true
		element.button.pressed.connect(handle_weapon_clicked.bind(element))

func clear_weapons_container() -> void:
	for child in weapons_container.get_children():
		child.queue_free()

var currently_chosen_element: WeaponElement = null
func handle_weapon_clicked(element: WeaponElement) -> void:
	if currently_chosen_element == null:
		right_panel.slide_in()
	elif currently_chosen_element != null:
		currently_chosen_element.button.button_pressed = false
	currently_chosen_element = element
	
	var costs: Dictionary[InventoryManager.Currency, int] = weapons[element.weapon.weapon_type]
	right_panel.setup(element.weapon.weapon_type, costs)

func _on_produce_button_pressed() -> void:
	var weapon_type: WeaponManager.Type = currently_chosen_element.weapon.weapon_type
	
	currently_chosen_element.lvl_label.show()
	currently_chosen_element.lvl_label.text = "Bought!"
	currently_chosen_element.lvl_label.modulate = Color(0, 1.0, 0.0)
	
	ShipManager.request_buy_weapon.rpc_id(1, weapon_type)
	
