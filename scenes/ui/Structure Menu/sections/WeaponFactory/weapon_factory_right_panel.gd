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
@onready var dmg_arrow: Label = %DmgArrow
@onready var dmg_label_upgraded: Label = %DmgStatUpgraded
@onready var dmg_points_container: Control = %DmgPoints

@onready var rps_label: Label = %RpsStat
@onready var rps_arrow: Label = %RpsArrow
@onready var rps_label_upgraded: Label = %RpsStatUpgraded
@onready var rps_points_container: Control = %RpsPoints

@onready var power_label: Label = %PowerStat
@onready var power_arrow: Label = %PowerArrow
@onready var power_label_upgraded: Label = %PowerStatUpgraded
@onready var power_points_container: Control = %PowerPoints

@onready var range_label: Label = %RangeStat
@onready var range_arrow: Label = %RangeArrow
@onready var range_label_upgraded: Label = %RangeStatUpgraded
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
	set_stats(weapon_type)
	
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

func set_stats(weapon_type: WeaponManager.Type) -> void: 
	var dmg_0: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.DMG, WeaponManager.WeaponDataType.MIN)
	var rps_0: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RPS, WeaponManager.WeaponDataType.MIN)
	var power_0: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.POWER, WeaponManager.WeaponDataType.MIN)
	var range_0: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RANGE, WeaponManager.WeaponDataType.MIN)
	
	var dmg_points_0: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.DMG, WeaponManager.WeaponDataType.POINTS_MIN))
	var rps_points_0: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RPS, WeaponManager.WeaponDataType.POINTS_MIN))
	var power_points_0: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.POWER, WeaponManager.WeaponDataType.POINTS_MIN))
	var range_points_0: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RANGE, WeaponManager.WeaponDataType.POINTS_MIN))
	
	var dmg_max: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.DMG, WeaponManager.WeaponDataType.MAX)
	var rps_max: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RPS, WeaponManager.WeaponDataType.MAX)
	var power_max: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.POWER, WeaponManager.WeaponDataType.MAX)
	var range_max: float = WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RANGE, WeaponManager.WeaponDataType.MAX)
	
	var dmg_points_max: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.DMG, WeaponManager.WeaponDataType.POINTS_MAX))
	var rps_points_max: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RPS, WeaponManager.WeaponDataType.POINTS_MAX))
	var power_points_max: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.POWER, WeaponManager.WeaponDataType.POINTS_MAX))
	var range_points_max: int = roundi(WeaponManager.get_weapon_data(weapon_type, WeaponManager.StatType.RANGE, WeaponManager.WeaponDataType.POINTS_MAX))
	
	dmg_arrow.hide()
	dmg_label_upgraded.hide()
	rps_arrow.hide()
	rps_label_upgraded.hide()
	power_arrow.hide()
	power_label_upgraded.hide()
	range_arrow.hide()
	range_label_upgraded.hide()
	
	dmg_label.set_text(Functions.shorten_number(dmg_0))
	power_label.set_text(Functions.shorten_number(power_0))
	range_label.set_text(Functions.shorten_number(range_0))
	
	if dmg_max != dmg_0:
		dmg_arrow.show()
		dmg_label_upgraded.show()
		dmg_label_upgraded.text = Functions.shorten_number(dmg_max)
	if power_max != power_0:
		power_arrow.show()
		power_label_upgraded.show()
		power_label_upgraded.text = Functions.shorten_number(power_max)
	if range_max != range_0:
		range_arrow.show()
		range_label_upgraded.show()
		range_label_upgraded.text = Functions.shorten_number(range_max)
	
	if rps_0 >= 1:
		rps_label.set_text(Functions.shorten_number(rps_0))
	else:
		var seconds: float = Functions.round_to_dec(1.0 / rps_0, 1)
		rps_label.set_text("1/" + Functions.shorten_number(seconds) + "s")
	
	if rps_max != rps_0:
		rps_arrow.show()
		rps_label_upgraded.show()
		if rps_max >= 1:
			rps_label_upgraded.set_text(Functions.shorten_number(rps_max))
		else:
			var seconds: float = Functions.round_to_dec(1.0 / rps_max, 1)
			rps_label_upgraded.set_text("1/" + Functions.shorten_number(seconds) + "s")
	
	
	set_points(dmg_points_container, dmg_points_0, dmg_points_max)
	set_points(rps_points_container, rps_points_0, rps_points_max)
	set_points(power_points_container, power_points_0, power_points_max)
	set_points(range_points_container, range_points_0, range_points_max)

func set_points(container: Control, base_amount: int, max_amount: int):
	for child: Polygon2D in container.get_children():
		if base_amount > 0:
			child.color = Color("33a837")
		elif max_amount > 0:
			child.color = Color("ffa837")
		else:
			child.color = Color("#444444")
		base_amount -= 1
		max_amount -= 1
		

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
