class_name WeaponRuntimeData extends RefCounted

signal prop_changed(prop: PlayerData.WeaponProperty, value: Variant)

var props: Dictionary = {}

func set_prop(prop: PlayerData.WeaponProperty, value: Variant) -> void:
	if props.get(prop) == value:
		return
	
	props[prop] = value
	prop_changed.emit(prop, value)

func get_prop(prop: PlayerData.WeaponProperty) -> Variant:
	return props.get(prop)

func to_dict() -> Dictionary:
	var out: Dictionary = {}
	for key in props.keys():
		out[int(key)] = props[key]
	return out

func from_dict(data: Dictionary) -> void:
	for key in data.keys():
		props[key] = data[key]
