class_name HangarMenu extends Control

@onready var menu_width = 350.0
@onready var left_panel = %Left
@onready var right_panel = %Right
@onready var shop_button = %ShopButton
@onready var my_ships_button = %MyShipsButton
@onready var shop_button_underline = %ShopButtonUnderline
@onready var my_ships_button_underline = %MyShipsButtonUnderline
@onready var shop_section = %ShopSection
@onready var shop_container = %ShopContainer
@onready var my_ships_section = %MyShipsSection
@onready var my_ships_container = %MyShipsContainer
@onready var left_hangar_title = %LeftHangarTitle

@onready var ship_info_container = %ShipInfoContainer
@onready var right_hangar_title = %RightHangarTitle
@onready var ship_name_label = %ShipName
@onready var health_amount: Label = %HealthAmount
@onready var health_points: HBoxContainer = %HealthPoints
@onready var armor_amount: Label = %ArmorAmount
@onready var armor_points: HBoxContainer = %ArmorPoints
@onready var shield_amount: Label = %ShieldAmount
@onready var shield_points: HBoxContainer = %ShieldPoints
@onready var shield_regen_amount: Label = %ShieldRegenAmount
@onready var shield_regen_points: HBoxContainer = %ShieldRegenPoints
@onready var buy_button: BetterButton = %BuyButton

@onready var center_ship: ShipComponent = %CenterShip

@onready var default_right_panel_pos_x: float = get_viewport_rect().size.x - menu_width
@onready var current_section: Control = shop_section
@onready var default_section_pos_x: float = 0.0


func _ready():
	left_panel.position.x = -menu_width
	right_panel.position.x = default_right_panel_pos_x + menu_width
	hide()
	center_ship.engine.activate_thruster()

var opened = false
func _process(delta):
	default_right_panel_pos_x = get_viewport_rect().size.x - menu_width
	play_current_animation(delta)

var args: Dictionary
var hangar_name := "Unknown Hangar"
var ships_to_buy : Dictionary
var owned_ships : Dictionary
func set_args(new_args: Dictionary):
	#print(new_args)
	args = new_args
	if !args.is_empty():
		if args.has("name"):
			hangar_name = args.name
		if args.has("ships_to_buy"):
			ships_to_buy = args.ships_to_buy
		if args.has("owned_ships"):
			owned_ships = args.owned_ships
		
		left_hangar_title.set_text(hangar_name)
		right_hangar_title.set_text(hangar_name)

		if !ships_to_buy.is_empty():
			for child in shop_container.get_children():
				shop_container.remove_child(child)
				child.queue_free()
			for ship_name in ships_to_buy:
				var ship_select: ShipSelect = ShipManager.create_ship_select(ship_name)
				shop_container.add_child(ship_select)
				ship_select.pressed.connect(display_ship_info.bind(ship_select.ship_component))
		
		if !owned_ships.is_empty():
			for child in my_ships_container.get_children():
				my_ships_container.remove_child(child)
				child.queue_free()
			for ship_name in owned_ships:
				var ship_select: ShipSelect = ShipManager.create_ship_select(ship_name)
				my_ships_container.add_child(ship_select)
				ship_select.pressed.connect(display_ship_info.bind(ship_select.ship_component))

var current_ship_name := ""
func display_ship_info(ship: ShipComponent):
	if is_instance_valid(ship) and current_ship_name != ship.name:
		current_ship_name = ship.name
		
		var ship_name = ship.ship_name
		var health = ship.health
		var armor = ship.armor
		var shield = ship.shield
		var shield_regen = ship.shield_regen
		
		buy_button.show()
		buy_button.set_disabled(false)
		if current_section == shop_section:
			if owned_ships.has(current_ship_name):
				buy_button.set_disabled(true)
		elif current_section == my_ships_section:
			buy_button.set_text("Select")
		ship_name_label.set_text(ship_name)
		
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
		
		
		GameManager.local_player.set_ship(ship.name)
		GameManager.local_player.engine.activate_thruster()
		

var animation_finished = true
var selected_animation = null
func select_animation(animation_name: String):
	if animation_name == "open":
		selected_animation = "open"
		animation_finished = false
		display_ship_info(GameManager.local_player.ship)
		
	elif animation_name == "close":
		selected_animation = "close"
		animation_finished = false
		
		var tween1 := create_tween()
		tween1.tween_property(shop_button_underline, "position:x", 0, 0.3)
		var tween2 := create_tween()
		tween2.tween_property(my_ships_button_underline, "position:x", -my_ships_button.get_rect().size.x, 0.3)
	elif animation_name == "shop":
		if current_section != shop_section and animation_finished:
			selected_animation = "shop"
			animation_finished = false
			
			var tween1 := create_tween()
			tween1.tween_property(shop_button_underline, "position:x", 0, 0.3)
			var tween2 := create_tween()
			tween2.tween_property(my_ships_button_underline, "position:x", -my_ships_button.get_rect().size.x, 0.3)
	elif animation_name == "my_ships":
		if current_section !=my_ships_section and animation_finished:
			selected_animation = "my_ships"
			animation_finished = false
			
			var tween1 := create_tween()
			tween1.tween_property(my_ships_button_underline, "position:x", 0, 0.3)
			var tween2 := create_tween()
			tween2.tween_property(shop_button_underline, "position:x", shop_button.get_rect().size.x, 0.3)

func play_current_animation(delta: float):
	if !animation_finished:
		if selected_animation == "open":
			show()
			current_section.hide()
			current_section = shop_section
			current_section.show()
			buy_button.hide()
			
			left_panel.position.x = lerpf(left_panel.position.x, 0.0, delta * 5)
			right_panel.position.x = lerpf(right_panel.position.x, default_right_panel_pos_x, delta * 5)
			
			if left_panel.position.x >= -1:
				left_panel.position.x = 0
				right_panel.position.x = default_right_panel_pos_x
				animation_finished = true
		elif selected_animation == "close":
			left_panel.position.x = lerpf(left_panel.position.x, -menu_width, delta * 5)
			right_panel.position.x = lerpf(right_panel.position.x, default_right_panel_pos_x + menu_width, delta * 5)
			
			if left_panel.position.x <= -menu_width + 1:
				left_panel.position.x = -menu_width
				right_panel.position.x = default_right_panel_pos_x + menu_width
				animation_finished = true
				hide()
		elif selected_animation == "shop":
			hide_current_and_show(delta, shop_section)
			
		elif selected_animation == "my_ships":
			hide_current_and_show(delta, my_ships_section)

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
		
		current_section.position.x = lerpf(current_section.position.x, - menu_width, delta * 5)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 5)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 5)
		
		if selected_section.modulate.a >= 0.9:
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
		
		current_section.position.x = lerpf(current_section.position.x, menu_width, delta * 5)
		current_section.modulate.a = lerpf(selected_section.modulate.a, 0.0, delta * 5)
		
		selected_section.modulate.a = lerpf(selected_section.modulate.a, 1.0, delta * 5)
		
		if selected_section.modulate.a >= 0.9:
			animation_finished = true
			hide_show_finished = true
			current_section.position.x = default_section_pos_x
			current_section.hide()
			current_section.modulate.a = 1.0
			selected_section.modulate.a = 1.0
			
			current_section = selected_section

func _on_shop_button_pressed(): select_animation("shop")
func _on_my_ships_button_pressed(): select_animation("my_ships")


func _on_buy_button_pressed():
	if current_section == shop_section:
		ShipManager.request_buy_ship.rpc_id(1, AuthManager.my_username , current_ship_name)
	elif current_section == my_ships_section:
		ShipManager.request_select_ship.rpc_id(1, AuthManager.my_username , current_ship_name)
