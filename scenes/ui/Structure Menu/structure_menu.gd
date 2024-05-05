extends Control

@onready var menu_width = 350.0
@onready var left_panel = %Left
@onready var main_section = %Main
@onready var ships_section = %Ships
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

@onready var default_right_panel_pos_x: float = get_viewport_rect().size.x - menu_width
@onready var current_section: Control = main_section
@onready var default_section_pos_x: float = 0.0
func _ready():
	left_panel.position.x = -menu_width

func _process(delta):
	default_right_panel_pos_x = get_viewport_rect().size.x - menu_width
	play_current_animation(delta)

var args: Dictionary
var structure_name := "Unknown Structure"
var owned_ships : Dictionary
func set_args(new_args: Dictionary):
	if !new_args.is_empty():
		args = new_args
		if args.has("name") and structure_name != args.name:
			structure_name = args.name
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
		land_ship_name = g.me.ship.name
		show()
		current_section.hide()
		current_section = main_section
		current_section.show()
	elif animation_name == "close":
		selected_animation = "close"
		animation_finished = false
	elif animation_name == "ships":
		if current_section != ships_section and animation_finished:
			selected_animation = "ships"
			animation_finished = false
			ships_right_panel.show()
			
	elif animation_name == "main":
		if current_section != main_section and animation_finished:
			selected_animation = "main"
			animation_finished = false

func play_current_animation(delta: float):
	if !animation_finished:
		if selected_animation == "open":
			left_panel.position.x = lerpf(left_panel.position.x, 0.0, delta * 10)
			if left_panel.position.x >= -1:
				left_panel.position.x = 0
				animation_finished = true
		elif selected_animation == "close":
			left_panel.position.x = lerpf(left_panel.position.x, -menu_width, delta * 10)
			if ships_right_panel.visible:
				ships_right_panel.position.x = lerpf(ships_right_panel.position.x, default_right_panel_pos_x + menu_width, delta * 10)
			if left_panel.position.x <= -menu_width + 1:
				left_panel.position.x = - menu_width
				ships_right_panel.position.x = default_right_panel_pos_x + menu_width
				animation_finished = true
				ships_right_panel.hide()
				hide()
		elif selected_animation == "ships":
			ships_right_panel.position.x = lerpf(ships_right_panel.position.x, default_right_panel_pos_x, delta * 10)
			hide_current_and_show(delta, ships_section)
			if ships_right_panel.position.x <= default_right_panel_pos_x + 1 or hide_show_finished == true:
				ships_right_panel.position.x = default_right_panel_pos_x
		elif selected_animation == "main":
			if ships_right_panel.visible:
				ships_right_panel.position.x = lerpf(ships_right_panel.position.x, default_right_panel_pos_x + menu_width, delta * 10)
			hide_current_and_show(delta, main_section)
			if ships_right_panel.position.x >= default_right_panel_pos_x + menu_width - 1 or hide_show_finished == true:
				ships_right_panel.position.x = default_right_panel_pos_x + menu_width

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
		for ship_name in owned_ships:
			var ship_select: ShipSelect = ShipManager.create_ship_select(ship_name)
			my_ships_container.add_child(ship_select)
			ship_select.pressed.connect(display_ship_info.bind(ship_select.ship_component))

var land_ship_name: String
var current_ship_name := ""
func display_ship_info(ship: ShipComponent):
	if is_instance_valid(ship) and current_ship_name != ship.name:
		current_ship_name = ship.name
		
		var ship_name = ship.ship_name
		var health = ship.health
		var armor = ship.armor
		var shield = ship.shield
		var shield_regen = ship.shield_regen
		
		ship_name_label.set_text(ship_name)
		select_button.show()
		select_button.set_disabled(false)
		if current_ship_name == land_ship_name:
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
		
		
		g.me.set_ship(ship.name)
		g.me.engine.activate_thruster()

func _on_select_button_pressed():
	ShipManager.request_select_ship.rpc_id(1, AuthManager.my_username , current_ship_name)

func _on_ships_button_pressed():
	select_animation("ships")

func _on_return_button_pressed():
	select_animation("main")

func _on_exit_button_pressed():
	if g.me.landed_structure != null:
		g.me.request_leave_structure.rpc_id(1, AuthManager.my_username)
		GlobalSignals.set_ui.emit("game")

