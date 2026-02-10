class_name PropertyContainer extends RefCounted

var SCHEMA: Dictionary[int, Dictionary] = {}
var properties: Dictionary[int, Variant] = {}

signal property_changed(id: int, value: Variant)

func _init(schema: Dictionary):
	SCHEMA = schema
	init_defaults()

func init_defaults():
	for prop: int in SCHEMA.keys():
		properties[prop] = SCHEMA[prop]["default"]

func get_property(prop: int) -> Variant:
	return properties[prop]

func set_property(prop: int, value: Variant) -> void:
	var schema = SCHEMA.get(prop)
	if schema == null:
		push_error("Unknown property: ", prop)
		return
	
	properties[prop] = value
	property_changed.emit(prop, value)

func to_dict() -> Dictionary:
	var data: Dictionary= {}
	for prop: int in properties:
		data[prop] = properties[prop]
	return data

func from_dict(data: Dictionary) -> void:
	for prop: int in data.keys():
		if SCHEMA.has(prop):
			set_property(prop, data[prop])
