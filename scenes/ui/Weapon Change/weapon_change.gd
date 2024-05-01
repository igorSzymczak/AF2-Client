extends Control

@onready var search_bar: LineEdit = %SearchBar
@onready var energy_switch: Button = %EnergyButton
@onready var kinetic_switch: Button = %KineticButton
@onready var corrosive_switch: Button = %CorrosiveButton
@onready var sorting_dropdown: OptionButton = %SortingSwitch
@onready var weapons_section: VBoxContainer = %WeaponsSection
@onready var hotbar_section: HBoxContainer = %HotbarSection
@onready var info_section: HBoxContainer = %InfoSection
@onready var icon_container: VBoxContainer = %IconContainer
@onready var name_label: Label = %WeaponName
@onready var kinetic_label: Label = %Kinetic
@onready var plus1_label: Label = %Plus1
@onready var energy_label: Label = %Energy
@onready var plus2_label: Label = %Plus2
@onready var corrosive_label: Label = %Corrosive
@onready var dmg_label: Label = %DmgStat
@onready var dmg_points_container: Control = %DmgPoints
@onready var rps_label: Label = %RpsStat
@onready var rps_points_container: Control = %RpsPoints
@onready var power_label: Label = %PowerStat
@onready var power_points_container: Control = %PowerPoints
@onready var range_label: Label = %RangeStat
@onready var range_points_container: Control = %RangePoints
@onready var description_label: Label = %Description
@onready var hotbar_label: Label = %HotbarLabel

var weapon_ui_scene: PackedScene = preload("res://scenes/ui/Weapon Element/weapon_element.tscn")

var inventory: Array[WeaponElement] = []
var hotbar: Array[WeaponElement] = []

func _ready():
	
	energy_switch.toggled.connect(highlight_inventory)
	kinetic_switch.toggled.connect(highlight_inventory)
	corrosive_switch.toggled.connect(highlight_inventory)
	search_bar.text_changed.connect(highlight_inventory)

func select_animation(animation_name: String):
	var delta = get_process_delta_time()
	if animation_name == "open":
		GameManager.can_perform_actions = false
		show()
		
		load_weapons(GameManager.PlayerInfo.arsenal)
		load_hotbar(GameManager.PlayerInfo.weapons)
		
	elif animation_name == "close":
		GameManager.can_perform_actions = true
		if selecting and element_a:
			handle_click(element_a, true)
		
		hide()

func load_weapons(weapons: Dictionary):
	
	inventory = []
	for child in weapons_section.get_children():
		child.queue_free()
	
	var found_first_proper := false
	for weapon_name: String in weapons:
		if !GameManager.Weapons.has(weapon_name): return
		
		var weapon: Weapon = GameManager.Weapons[weapon_name].instantiate()
		
		if !found_first_proper:
			show_weapon(weapon)
			found_first_proper = true
		
		var element: WeaponElement = weapon_ui_scene.instantiate()
		
		weapons_section.add_child(element)
		element.weapon_name = weapon.weapon_name
		element.info_shown = true
		element.weapon = weapon
		element.lvl = weapons[weapon_name].lvl
		
		inventory.push_back(element)
		element.button.pressed.connect(handle_click.bind(element, false))
		
		highlight_inventory()

func load_hotbar(weapons: Dictionary):
	
	hotbar = []
	for child in hotbar_section.get_children():
		child.queue_free()
	
	for slot: int in weapons:
		var weapon_name = weapons[slot].name
		if !GameManager.Weapons.has(weapon_name): return
		
		var weapon: Weapon = GameManager.Weapons[weapon_name].instantiate()
		var element: WeaponElement = weapon_ui_scene.instantiate()
		
		hotbar_section.add_child(element)
		element.weapon_name = weapon.weapon_name
		element.info_shown = true
		element.weapon = weapon
		element.lvl = weapons[slot].lvl
		element.set_alignment(BoxContainer.ALIGNMENT_CENTER)
		
		hotbar.push_back(element)
		element.button.pressed.connect(handle_click.bind(element, true))

func highlight_inventory(_ignore = false):
	
	var energy_toggled: bool = energy_switch.button_pressed
	var kinetic_toggled: bool = kinetic_switch.button_pressed
	var corrosive_toggled: bool = corrosive_switch.button_pressed
	var searched_name: String = search_bar.text
	
	for element: WeaponElement in inventory:
		var weapon: Weapon = element.weapon
		
		var highlight = false
		
		if (
			searched_name.is_empty() and (
				(energy_toggled and weapon.energy) or
				(kinetic_toggled and weapon.kinetic) or
				(corrosive_toggled and weapon.corrosive)
			) or (
				!searched_name.is_empty() and
				String(weapon.weapon_name).to_lower().begins_with(searched_name.to_lower())
			)
		):
			highlight = true
		
		if !highlight:
			element.modulate = Color(0.5, 0.5, 0.5)
		else:
			element.modulate = Color(1,1,1)

func show_weapon(weapon: Weapon):
	info_section.show()
	
	name_label.set_text(weapon.weapon_name)
	dmg_label.set_text(str(weapon.damage))
	rps_label.set_text(str(weapon.rps))
	power_label.set_text(str(weapon.power_cost))
	range_label.set_text(str(weapon.range))
	
	set_points(dmg_points_container, weapon.damage_points)
	set_points(rps_points_container, weapon.rps_points)
	set_points(power_points_container, weapon.power_points)
	set_points(range_points_container, weapon.range_points)
	
	var element: WeaponElement = weapon_ui_scene.instantiate()
	
	icon_container.get_child(0).queue_free()
	
	icon_container.add_child(element)
	element.weapon_name = weapon.weapon_name
	element.info_shown = false
	
	description_label.set_text(weapon.description_long)
	
	set_types(weapon.energy, weapon.kinetic, weapon.corrosive)

var selecting: bool = false
var element_a: WeaponElement
var element_b: WeaponElement

func handle_click(element: WeaponElement, in_hotbar: bool = false):
	if !in_hotbar and !selecting:
		show_weapon(element.weapon)
	
	
	
	# Changing weapons
	
	if in_hotbar and !selecting:
		selecting = true
		element_a = element
		element_a.modulate = Color(0.5, 0.5, 0.5)
		hotbar_label.set_text("Select new weapon or click again to cancel...")
	elif selecting:
		if in_hotbar and element == element_a:
			# Cancel selecting
			selecting = false
			element_a.modulate = Color(1,1,1)
			hotbar_label.set_text("Hotbar")
			element_a = null
			show_weapon(element.weapon)
		elif in_hotbar:
			# Swap weapons in hotbar
			selecting = false
			element_b = element
			
			element_a.modulate = Color(1,1,1)
			
			var index_a = element_a.get_index()
			var index_b = element_b.get_index()
			hotbar_section.move_child(element_a, index_b)
			hotbar_section.move_child(element_b, index_a)
			
			show_weapon(element_b.weapon)
			request_change_weapon(index_a + 1, element_b.weapon.weapon_name)
			request_change_weapon(index_b + 1, element_a.weapon.weapon_name)
			
			element_a = null
			element_b = null
			hotbar_label.set_text("Hotbar")
		elif !in_hotbar:
			# Get Weapon from Arsenal
			selecting = false
			element_b = element
			element_a.modulate = Color(1,1,1)
			
			element_a.weapon_name = element_b.weapon_name
			element_a.lvl = element_b.lvl
			element_a.weapon = element_b.weapon
			element_a.icon_texture = element_b.icon_texture
			element_a.icon_color = element_b.icon_color
			
			show_weapon(element_b.weapon)
			request_change_weapon(element_a.get_index() + 1, element_a.weapon.weapon_name)
			
			element_a = null
			element_b = null
			hotbar_label.set_text("Hotbar")

func set_points(container: Control, amount: int):
	for child: Polygon2D in container.get_children():
		if amount > 0:
			child.color = Color("33a837")
		else:
			child.color = Color("#444444")
		amount -= 1

func set_types(ene: bool, kin: bool, cor: bool):
	energy_label.hide()
	plus1_label.hide()
	kinetic_label.hide()
	plus2_label.hide()
	corrosive_label.hide()
	
	if ene:
		energy_label.show()
		if kin:
			plus1_label.show()
			kinetic_label.show()
		if cor:
			plus2_label.show()
			corrosive_label.show()
	if kin:
		kinetic_label.show()
		if cor:
			plus2_label.show()
			corrosive_label.show()
	if cor:
		corrosive_label.show()

func request_change_weapon(slot: int, weapon_name: String):
	if slot > 0 and slot < 6 and weapon_name in GameManager.Weapons:
		GameManager.set_weapon_request.emit(slot, weapon_name)
