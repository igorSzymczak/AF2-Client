extends Control

@onready var menu_width = 350.0
@onready var left_panel = %Left
@onready var main_section = %Main
@onready var ships_section = %Ships
@onready var recycling_section = %Recycling
@onready var weapon_factory_section = %WeaponFactory
@onready var main_structure_title = %MainStructureTitle

@onready var ships_right_panel = %ShipsRight
@onready var my_ships_container = %MyShipsContainer
@onready var ships_left_structure_title = %ShipsLeftStructureTitle
@onready var ships_right_structure_title = %ShipsRightStructureTitle
@onready var ship_info_container = %ShipInfoContainer
@onready var ship_name_label = %ShipName
@onready var health_amount: Label = %HealthAmount
@onready var health_points: HBoxContainer = %HealthPoints
@onready var armor_amount: Label = %ArmorAmount
@onready var armor_points: HBoxContainer = %ArmorPoints
@onready var shield_amount: Label = %ShieldAmount
@onready var shield_points: HBoxContainer = %ShieldPoints
@onready var shield_regen_amount: Label = %ShieldRegenAmount
@onready var shield_regen_points: HBoxContainer = %ShieldRegenPoints
@onready var select_button: BetterButton = %SelectButton

@onready var recycling_button: BetterButton = %RecyclingButton
@onready var weapon_factory_button: BetterButton = %WeaponFactoryButton

@onready var default_right_panel_pos_x: float = get_viewport_rect().size.x - menu_width
@onready var current_section: Control = main_section
@onready var default_section_pos_x: float = 0.0

@onready var weapon_factory_right_panel: Control = %WeaponFactoryRightPanel

func _ready():
	position.x = -menu_width

func _process(delta):
	play_current_animation(delta)

var args: Dictionary
var structure_name := "Unknown Structure"
var owned_ships : Array[ShipManager.ShipType]
func set_args(new_args: Dictionary):
	if !new_args.is_empty():
		args = new_args
		structure_name = g.me.landed_structure.structure_name
		setup_structure_name()
		if args.has("owned_ships") and owned_ships != args.owned_ships:
			owned_ships = args.owned_ships
			setup_ships_section()

var animation_finished = true
var selected_animation = null
func select_animation(animation_name: String):
	if animation_name == "open":
		selected_animation = "open"
		animation_finished = false
		land_ship_type = g.me.ship.ship_type
		show()
		current_section.hide()
		current_section = main_section
		current_section.show()
		hide_or_show_recycling_button()
		hide_or_show_weapon_factory_button()
	elif animation_name == "close":
		selected_animation = "close"
		animation_finished = false
		weapon_factory_right_panel.slide_out()
		ships_right_panel.slide_out()
	elif animation_name == "ships":
		if current_section != ships_section and animation_finished:
			selected_animation = "ships"
			animation_finished = false
			ships_right_panel.slide_in()
	elif animation_name == "recycling":
		if current_section != recycling_section and animation_finished:
			selected_animation = "recycling"
			animation_finished = false
			recycling_section.load_cargo()
	elif animation_name == "weapon_factory":
		if current_section != weapon_factory_section and animation_finished:
			selected_animation = "weapon_factory"
			animation_finished = false
			weapon_factory_section.load_weapons(args)
	
	elif animation_name == "main":
		if current_section != main_section and animation_finished:
			selected_animation = "main"
			animation_finished = false
		weapon_factory_right_panel.slide_out()
		ships_right_panel.slide_out()

func play_current_animation(delta: float):
	if !animation_finished:
		if selected_animation == "open":
			position.x = lerpf(position.x, 0.0, delta * 10)
			if position.x >= -1:
				position.x = 0
				animation_finished = true
		elif selected_animation == "close":
			if !visible: return
			position.x = lerpf(position.x, -menu_width, delta * 10)
			if position.x <= -menu_width + 1:
				position.x = - menu_width
				animation_finished = true
				hide()
		elif selected_animation == "ships":
			hide_current_and_show(delta, ships_section)
		elif selected_animation == "recycling":
			hide_current_and_show(delta, recycling_section)
		elif selected_animation == "weapon_factory":
			hide_current_and_show(delta, weapon_factory_section)
		elif selected_animation == "main":
			hide_current_and_show(delta, main_section)

var hide_show_finished = true
func hide_current_and_show(delta, selected_section: Control):
	if selected_section.animation_index >= current_section.animation_index: 
		# Swipe everything to Left
		if hide_show_finished:
			hide_show_finished = false
			selected_section.show()
			current_section.position.x = default_section_pos_x
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 0.0
		
		current_section.position.x = lerpf(current_section.position.x, - menu_width, delta * 10)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 10)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 10)
		
		if selected_section.modulate.a >= 0.99:
			animation_finished = true
			hide_show_finished = true
			current_section.position.x = default_section_pos_x
			current_section.hide()
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 1.0
			
			current_section = selected_section
			
	elif selected_section.animation_index < current_section.animation_index:
		# Swipe everything to Right
		if hide_show_finished:
			hide_show_finished = false
			selected_section.show()
			current_section.position.x = default_section_pos_x
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 0.0
		
		current_section.position.x = lerpf(current_section.position.x, menu_width, delta * 10)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 10)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 10)
		
		if selected_section.modulate.a >= 0.99:
			animation_finished = true
			hide_show_finished = true
			current_section.position.x = default_section_pos_x
			current_section.hide()
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 1.0
			
			current_section = selected_section


func setup_structure_name():
	main_structure_title.set_text(structure_name)
	ships_left_structure_title.set_text(structure_name)
	ships_right_structure_title.set_text(structure_name)

func setup_ships_section():
	if !owned_ships.is_empty():
		for child in my_ships_container.get_children():
			my_ships_container.remove_child(child)
			child.queue_free()
		
		for ship_type: ShipManager.ShipType in owned_ships:
			var ship_select: ShipSelect = ShipManager.create_ship_select(ship_type)
			my_ships_container.add_child(ship_select)
			ship_select.pressed.connect(display_ship_info.bind(ship_select.ship_component))

var land_ship_type: ShipManager.ShipType
var current_ship_type: ShipManager.ShipType
func display_ship_info(ship: ShipComponent):
	if is_instance_valid(ship) and current_ship_type != ship.ship_type:
		current_ship_type = ship.ship_type
		
		var ship_name = ship.ship_name
		var health = ship.health
		var armor = ship.armor
		var shield = ship.shield
		var shield_regen = ship.shield_regen
		
		ship_name_label.set_text(ship_name)
		select_button.show()
		select_button.set_disabled(false)
		if current_ship_type == land_ship_type:
			select_button.set_disabled(true)
		
		for child in health_points.get_children(): child.show()
		for child in armor_points.get_children(): child.show()
		for child in shield_points.get_children(): child.show()
		for child in shield_regen_points.get_children(): child.show()
		
		health_amount.set_text(str(health))
		armor_amount.set_text(str(armor))
		shield_amount.set_text(str(shield))
		shield_regen_amount.set_text(str(shield_regen))
		
		for child in health_points.get_children():
			if health < 10:
				child.hide()
				health += 1
		
		for child in armor_points.get_children():
			if armor < 10:
				child.hide()
				armor += 1
		
		for child in shield_points.get_children():
			if shield < 10:
				child.hide()
				shield += 1
		
		for child in shield_regen_points.get_children():
			if shield_regen < 10:
				child.hide()
				shield_regen += 1
		
		
		g.me.set_ship(ship.ship_type)
		g.me.engine.activate_thruster()


func hide_or_show_recycling_button() -> void:
	if g.me.landed_structure is RecycleStation:
		recycling_button.show()
	else:
		recycling_button.hide()

func hide_or_show_weapon_factory_button() -> void:
	if g.me.landed_structure is WeaponFactory:
		weapon_factory_button.show()
	else:
		weapon_factory_button.hide()

func _on_select_button_pressed():
	ShipManager.request_select_ship.rpc_id(1, AuthManager.my_username , current_ship_type)

func _on_ships_button_pressed():
	select_animation("ships")

func _on_recycling_button_pressed():
	select_animation("recycling")

func _on_weapon_factory_button_pressed() -> void:
	select_animation("weapon_factory")

func _on_return_button_pressed():
	select_animation("main")

func _on_exit_button_pressed():
	if g.me.landed_structure != null:
		g.me.landed_structure.request_leave_structure.rpc_id(1, g.me.gid)
		GlobalSignals.set_ui.emit("game")
