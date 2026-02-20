extends Node

enum Property {
	ARSENAL,
	HOTBAR,
	CURRENT_POWER,
	CURRENT_HOTBAR_SLOT,
}

# Dynamic weapon properties 
enum WeaponProperty {
		WEAPON_TYPE, 		# Only these 2
		LVL,				# Are used for weapons in ARSENAL
	SLOT,
	POWER_USAGE,
	SHOOT_DELAY,
	LAST_SHOT,
	DAMAGE,
	BULLET_AMOUNT_RANGE,
}

var props: Dictionary[Property, Variant] = {
	Property.ARSENAL: {} as Dictionary[WeaponManager.Type, WeaponRuntimeData],
	Property.HOTBAR: {} as Dictionary[int, WeaponRuntimeData],
	Property.CURRENT_POWER: 100.0,
	Property.CURRENT_HOTBAR_SLOT: 1,
}

signal loaded()
signal prop_changed(prop: Property, value: Variant)
signal arsenal_weapon_changed(weapon_type, prop, value)
signal hotbar_weapon_changed(slot, prop, value)

func set_prop(prop: Property, value: Variant) -> void:
	if !props.has(prop):
		return
	
	if props[prop] == value:
		return
	
	props[prop] = value
	prop_changed.emit(prop, value)

func get_prop(prop: Property) -> Variant:
	if props.has(prop):
		return props[prop]
	return null

func to_dict() -> Dictionary:
	var data: Dictionary = {}

	data[int(Property.CURRENT_POWER)] = props[Property.CURRENT_POWER]
	data[int(Property.CURRENT_HOTBAR_SLOT)] = props[Property.CURRENT_HOTBAR_SLOT]

	var arsenal_out: Dictionary = {}
	for weapon_type in props[Property.ARSENAL].keys():
		var weapon: WeaponRuntimeData = props[Property.ARSENAL][weapon_type]
		arsenal_out[int(weapon_type)] = weapon.to_dict()
	
	data[int(Property.ARSENAL)] = arsenal_out

	var hotbar_out: Dictionary = {}
	for slot in props[Property.HOTBAR].keys():
		var weapon: WeaponRuntimeData = props[Property.HOTBAR][slot]
		hotbar_out[int(slot)] = weapon.to_dict()
	
	data[int(Property.HOTBAR)] = hotbar_out

	return data


func from_dict(data: Dictionary) -> void:

	props[Property.CURRENT_POWER] = data.get(int(Property.CURRENT_POWER), 0.0)
	props[Property.CURRENT_HOTBAR_SLOT] = data.get(int(Property.CURRENT_HOTBAR_SLOT), 1)

	props[Property.ARSENAL].clear()
	
	var arsenal_in: Dictionary = data.get(int(Property.ARSENAL), {})
	for weapon_type_int in arsenal_in.keys():
		var weapon := WeaponRuntimeData.new()
		weapon.from_dict(arsenal_in[weapon_type_int])
		
		props[Property.ARSENAL][weapon_type_int] = weapon

	props[Property.HOTBAR].clear()
	
	var hotbar_in: Dictionary = data.get(int(Property.HOTBAR), {})
	for slot_int in hotbar_in.keys():
		var weapon := WeaponRuntimeData.new()
		weapon.from_dict(hotbar_in[slot_int])
		
		props[Property.HOTBAR][slot_int] = weapon
	
	loaded.emit()

func add_arsenal_weapon(weapon_type: WeaponManager.Type, weapon_data: WeaponRuntimeData) -> void:
	props[Property.ARSENAL][weapon_type] = weapon_data
	
	weapon_data.prop_changed.connect(
		func(prop, value):
			arsenal_weapon_changed.emit(weapon_type, prop, value)
	)

func get_arsenal_weapon(weapon_type: WeaponManager.Type) -> WeaponRuntimeData:
	if !props[Property.ARSENAL].has(weapon_type):
		return null
	
	return props[Property.ARSENAL][weapon_type]

func add_hotbar_weapon(slot: int, weapon: WeaponRuntimeData) -> void:
	props[Property.HOTBAR][slot] = weapon
	
	weapon.prop_changed.connect(
		func(prop, value):
			hotbar_weapon_changed.emit(slot, prop, value)
	)

func get_hotbar_weapon(slot: WeaponManager.Type) -> WeaponRuntimeData:
	if !props[Property.HOTBAR].has(slot):
		return null
	
	return props[Property.HOTBAR][slot] as WeaponRuntimeData
