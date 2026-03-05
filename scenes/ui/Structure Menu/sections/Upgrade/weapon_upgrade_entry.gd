class_name WeaponUpgradeEntry extends Control

@onready var main_margin_container: MarginContainer = %MainMargin
@onready var title_section: HBoxContainer = %TitleSection
@onready var upgrade_section: HBoxContainer = %UpgradeSection

@onready var weapon_element_container: VBoxContainer = %WeaponElementContainer
@onready var weapon_name_label: Label = %WeaponNameLabel
@onready var upgrade_points_container: HBoxContainer = %UpgradePointsContainer

@onready var upgrade_button_1: UpgradeButtonSelect = %UpgradeButton1
@onready var upgrade_button_2: UpgradeButtonSelect = %UpgradeButton2
@onready var upgrade_button_3: UpgradeButtonSelect = %UpgradeButton3

@onready var costs_panel: VBoxContainer = %CostsPanel
@onready var flux_container: HBoxContainer = %Flux
@onready var steel_container: HBoxContainer = %Steel
@onready var hydrogen_crystals_container: HBoxContainer = %HydrogenCrystals
@onready var plasma_fluids_container: HBoxContainer = %PlasmaFluids
@onready var iridium_container: HBoxContainer = %Iridium


@onready var flux_amount: Label = %FluxAmount
@onready var steel_amount: Label = %SteelAmount
@onready var hydrogen_crystals_amount: Label = %HydrogenCrystalsAmount
@onready var plasma_fluids_amount: Label = %PlasmaFluidsAmount
@onready var iridium_amount: Label = %IridiumAmount

@onready var green_reason: Label = %GreenReason
@onready var red_reason: Label = %RedReason
@onready var upgrade_button: BetterButton = %UpgradeButton

@onready var bonuses_container: VBoxContainer = %BonusesContainer

var weapon_element_scene: PackedScene = preload("res://scenes/ui/Weapon Element/weapon_element.tscn")

var weapon_element: WeaponElement
var weapon_type: WeaponManager.Type

var padding: float
var initial_size := Vector2(582, 280)
var upgrade_section_size := Vector2(558, 188)
var weapon: Weapon
var current_lvl: int = 0 
var selected_lvl: int = 0

var costs: Array

func _ready() -> void:
	padding = main_margin_container.get_theme_constant("margin_bottom")
	upgrade_section.hide()
	green_reason.hide()
	red_reason.hide()
	upgrade_button.disabled = true
	
	#var temp_costs: Array[Dictionary] = [
		#{
			#InventoryManager.Currency.STEEL: 500,
			#InventoryManager.Currency.HYDROGEN_CRYSTALS: 250,
		#},
		#{
			#InventoryManager.Currency.STEEL: 750,
			#InventoryManager.Currency.PLASMA_FLUIDS: 250,
		#},
		#{
			#InventoryManager.Currency.STEEL: 1000,
			#InventoryManager.Currency.IRIDIUM: 250,
		#},
	#]
	#
	#init(WeaponManager.Type.CLUSTER_MISSILES, 0, temp_costs)
	
	upgrade_section.hide()
	await RenderingServer.frame_post_draw
	#open()
	show_costs(0)
	upgrade_button.pressed.connect(_on_upgrade_button_pressed)
	
	##await get_tree().create_timer(0.6).timeout

func init(new_weapon_type: WeaponManager.Type, lvl: int, upgrade_costs: Array) -> void:
	_set_weapon(new_weapon_type)
	set_current_lvl(lvl)
	costs = upgrade_costs
	show_bonuses(current_lvl)

func _set_weapon(new_weapon_type: WeaponManager.Type) -> void:
	if weapon_element_container.get_child_count() > 0:
		weapon_element_container.get_child(0).queue_free()
		
	weapon_type = new_weapon_type
	weapon = WeaponManager.get_weapon(weapon_type)
	weapon_name_label.text = weapon.weapon_name
	
	weapon_element = weapon_element_scene.instantiate()
	weapon_element_container.add_child(weapon_element)
	weapon_element.mouse_behavior_recursive = Control.MOUSE_BEHAVIOR_DISABLED
	weapon_element.weapon_name = weapon.weapon_name
	weapon_element.info_shown = false
	weapon_element.button.disabled = true
	weapon_element.button.focus_mode = FOCUS_NONE
	
	clear_bonuses()

func set_current_lvl(value: int, play_sound: bool = false) -> void:
	disable_buttons(value)
	
	var i = current_lvl
	current_lvl = value
	while i < value:
		var point: UpgradePointIcon = upgrade_points_container.get_child(i, true)
		point.selected = true
		if play_sound: SoundManager.play_sound_from_name("Upgrade", g.me.global_position)
		await point.finished_animation
		i += 1

func disable_buttons(lvl: int) -> void:
	upgrade_button_1.disabled = false
	upgrade_button_2.disabled = false
	upgrade_button_3.disabled = false
	
	if lvl >= 3: upgrade_button_3.disabled = true
	if lvl >= 2: upgrade_button_2.disabled = true
	if lvl >= 1: upgrade_button_1.disabled = true
	

func clear_bonuses() -> void:
	for child in bonuses_container.get_children():
		child.queue_free()

#var animating: bool = false
func _on_expand_button_pressed() -> void:
	#if animating:
		#return
	
	if !upgrade_section.visible:
		open()
	else:
		close()

func open() -> void:
	upgrade_section.show()
	#
	#animating = true
	#var tween: Tween = create_tween()
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(size_control, "size", initial_size, 0.5)
	#
	#var tween2: Tween = create_tween()
	#tween2.set_trans(Tween.TRANS_CUBIC)
	#tween2.tween_property(self, "size", initial_size, 0.5)
	#
	#await tween.finished
	#animating = false
	
func close() -> void:
	#animating = true
	#var tween: Tween = create_tween()
	#tween.set_trans(Tween.TRANS_CUBIC)
	#tween.tween_property(size_control, "size", Vector2(initial_size.x, initial_size.y - upgrade_section_size.y - 4), 0.5)
	#
	#var tween2: Tween = create_tween()
	#tween2.set_trans(Tween.TRANS_CUBIC)
	#tween2.tween_property(self, "size", Vector2(initial_size.x, initial_size.y - upgrade_section_size.y - 4), 0.5)
	#
	#await tween.finished
	#animating = false
	upgrade_section.hide()

func show_bonuses(bonus_lvl: int) -> void:
	if !weapon:
		return
	
	
	clear_bonuses()
	var bonuses: PackedStringArray = WeaponManager.get_weapon_upgrades_info(weapon_type, bonus_lvl)
	if !bonuses:
		return
	
	if bonus_lvl == current_lvl:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "Current upgrades: "
		bonuses_container.add_child(label)
	else:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = "Lvl " + str(bonus_lvl) + " upgrades:"
		bonuses_container.add_child(label)
	
	for bonus: String in bonuses:
		var label := Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		label.text = bonus
		bonuses_container.add_child(label)

func _on_upgrade_button_1_mouse_entered() -> void: show_bonuses(1)
func _on_upgrade_button_2_mouse_entered() -> void: show_bonuses(2)
func _on_upgrade_button_3_mouse_entered() -> void: show_bonuses(3)

func _on_upgrade_button_mouse_exited() -> void:
	if selected_lvl > 0:
		show_bonuses(selected_lvl)
	else:
		show_bonuses(current_lvl)

func _on_upgrade_button_1_pressed() -> void:
	_handle_upgrade_button_pressed(1)

func _on_upgrade_button_2_pressed() -> void:
	_handle_upgrade_button_pressed(2)

func _on_upgrade_button_3_pressed() -> void:
	_handle_upgrade_button_pressed(3)

func _handle_upgrade_button_pressed(index: int) -> void:
	upgrade_button_1.selected = false
	upgrade_button_2.selected = false
	upgrade_button_3.selected = false
	
	if selected_lvl != index:
		if index >= 1: upgrade_button_1.selected = true
		if index >= 2: upgrade_button_2.selected = true
		if index >= 3: upgrade_button_3.selected = true
		selected_lvl = index
		show_bonuses(selected_lvl)
		upgrade_button.disabled = false
	else:
		selected_lvl = 0
		upgrade_button.disabled = true
	
	show_costs(selected_lvl)

func show_costs(lvl: int) -> void:
	if costs.is_empty(): return
	if lvl < 0: return
	if lvl > 3: return
	
	var final_costs := get_final_costs(lvl)
	
	if final_costs.is_empty():
		costs_panel.hide()
	else:
		costs_panel.show()
	
	flux_container.hide()
	steel_container.hide()
	hydrogen_crystals_container.hide()
	plasma_fluids_container.hide()
	iridium_container.hide()
	
	if final_costs.has(InventoryManager.Currency.STEEL):
		steel_container.show()
		steel_amount.text = str(final_costs[InventoryManager.Currency.STEEL])
	if final_costs.has(InventoryManager.Currency.HYDROGEN_CRYSTALS):
		hydrogen_crystals_container.show()
		hydrogen_crystals_amount.text = str(final_costs[InventoryManager.Currency.HYDROGEN_CRYSTALS])
	if final_costs.has(InventoryManager.Currency.PLASMA_FLUIDS):
		plasma_fluids_container.show()
		plasma_fluids_amount.text = str(final_costs[InventoryManager.Currency.PLASMA_FLUIDS])
	if final_costs.has(InventoryManager.Currency.IRIDIUM):
		iridium_container.show()
		iridium_amount.text = str(final_costs[InventoryManager.Currency.IRIDIUM])
	if final_costs.has(InventoryManager.Currency.FLUX):
		flux_container.show()
		flux_amount.text = str(final_costs[InventoryManager.Currency.FLUX])
	
	upgrade_button.disabled = false
	red_reason.hide()
	
	if lvl <= current_lvl:
		upgrade_button.disabled = true
	if lvl > current_lvl:
		if !InventoryManager.can_afford_costs(final_costs):
			red_reason.show()
			red_reason.text = "Can't afford"
			upgrade_button.disabled = true
			return

func get_final_costs(lvl: int) -> Dictionary[InventoryManager.Currency, int]:
	var final_costs: Dictionary[InventoryManager.Currency, int] = {}
	
	var i: int = current_lvl
	while i < min(3, lvl):
		var cost: Dictionary = costs[i]
		for currency in cost.keys():
			if !final_costs.has(currency):
				final_costs[currency] = 0
			final_costs[currency] += cost[currency]
		i+=1
	
	return final_costs

func _on_upgrade_button_pressed() -> void:
	red_reason.hide()
	green_reason.hide()
	
	if selected_lvl == 0:
		return
	if !InventoryManager.can_afford_costs(get_final_costs(selected_lvl)):
		red_reason.show()
		red_reason.text = "Too broke!"
		return
	
	ShipManager.request_upgrade_weapon.rpc_id(1, weapon_type, selected_lvl)
	set_current_lvl(selected_lvl, true)
	upgrade_button.disabled = true
	green_reason.text = "Bought!"
	green_reason.show()
	show_bonuses(selected_lvl)
	selected_lvl = 0
	show_costs(selected_lvl)
