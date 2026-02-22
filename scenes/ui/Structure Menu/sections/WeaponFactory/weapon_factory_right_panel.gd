extends Control

@onready var panel_container: PanelContainer = %PanelContainer

@onready var icon_container: VBoxContainer = %IconContainer
@onready var weapon_name_label: Label = %WeaponName

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

@onready var steel_label: Label = %SteelAmount
@onready var flux_label: Label = %FluxAmount
@onready var hydrogen_crystals_label: Label = %HydrogenCrystalsAmount
@onready var plasma_fluids_label: Label = %PlasmaFluidsAmount
@onready var iridium_label: Label = %IridiumAmount

@onready var produce_button: BetterButton = %ProduceButton
@onready var green_reason: Label = %GreenReason
@onready var red_reason: Label = %RedReason



const weapon_ui_scene: PackedScene = preload("res://scenes/ui/Weapon Element/weapon_element.tscn")

func _ready() -> void:
	slide_out()
	#slide_in()
	#
	#var costs: Dictionary[InventoryManager.Currency, int] = {
		#InventoryManager.Currency.FLUX: 1111111,
		#InventoryManager.Currency.STEEL: 2222222,
		#InventoryManager.Currency.HYDROGEN_CRYSTALS: 33,
		#InventoryManager.Currency.PLASMA_FLUIDS: 44444444,
		#InventoryManager.Currency.IRIDIUM: 5555555,
	#}
	#setup(WeaponManager.Type.CLUSTER_MISSILES, costs)

func setup(weapon_type: WeaponManager.Type, costs: Dictionary[InventoryManager.Currency, int]) -> void:
	var weapon: Weapon = WeaponManager.get_weapon(weapon_type)
	
	weapon_name_label.set_text(weapon.weapon_name)
	var element: WeaponElement = weapon_ui_scene.instantiate()
	icon_container.get_child(0).queue_free()
	icon_container.add_child(element)
	element.weapon_name = weapon.weapon_name
	element.info_shown = false
	element.button.disabled = true
	element.button.focus_mode = FOCUS_NONE
	
	set_types(weapon.energy, weapon.kinetic, weapon.corrosive)
	
	dmg_label.set_text(str(weapon.damage))
	rps_label.set_text(str(weapon.rps))
	power_label.set_text(str(weapon.power_cost))
	range_label.set_text(str(weapon.range))
	
	set_points(dmg_points_container, weapon.damage_points)
	set_points(rps_points_container, weapon.rps_points)
	set_points(power_points_container, weapon.power_points)
	set_points(range_points_container, weapon.range_points)
	
	description_label.set_text(weapon.description_long)
	
	set_costs(costs)
	
	green_reason.hide()
	red_reason.hide()
	produce_button.disabled = false
	if PlayerData.get_arsenal_weapon(weapon_type) != null:
		produce_button.disabled = true
		green_reason.show()
		green_reason.text = "Already have it!"
	elif !InventoryManager.can_afford_costs(costs):
		produce_button.disabled = true
		red_reason.show()
		red_reason.text = "Too broke!"

func slide_in() -> void:
	if position == Vector2.ZERO:
		return
	show()
	var width: float = panel_container.get_rect().size.x
	panel_container.position = Vector2(-width, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(panel_container, "position", Vector2.ZERO, 1.0)

func slide_out() -> void:
	var width: float = panel_container.get_rect().size.x
	panel_container.position = Vector2(0.0, 0.0)
	
	var tween: Tween = create_tween()
	tween.set_trans(Tween.TRANS_EXPO)
	tween.tween_property(panel_container, "position", Vector2(-width, 0), 1.0)
	await tween.finished
	hide()

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

func set_costs(costs: Dictionary[InventoryManager.Currency, int]) -> void:
	flux_label.get_parent().hide()
	steel_label.get_parent().hide()
	hydrogen_crystals_label.get_parent().hide()
	plasma_fluids_label.get_parent().hide()
	iridium_label.get_parent().hide()
	
	for currency in costs:
		if currency == InventoryManager.Currency.FLUX:
			flux_label.get_parent().show()
			var amount: int = costs[currency]
			flux_label.text = Functions.shorten_number(amount)
		elif currency == InventoryManager.Currency.STEEL:
			steel_label.get_parent().show()
			var amount: int = costs[currency]
			steel_label.text = Functions.shorten_number(amount)
		elif currency == InventoryManager.Currency.HYDROGEN_CRYSTALS:
			hydrogen_crystals_label.get_parent().show()
			var amount: int = costs[currency]
			hydrogen_crystals_label.text = Functions.shorten_number(amount)
		elif currency == InventoryManager.Currency.PLASMA_FLUIDS:
			plasma_fluids_label.get_parent().show()
			var amount: int = costs[currency]
			plasma_fluids_label.text = Functions.shorten_number(amount)
		elif currency == InventoryManager.Currency.IRIDIUM:
			iridium_label.get_parent().show()
			var amount: int = costs[currency]
			iridium_label.text = Functions.shorten_number(amount)

func _on_produce_button_pressed() -> void:
	produce_button.disabled = true
	green_reason.show()
	green_reason.text = "Bought!"
