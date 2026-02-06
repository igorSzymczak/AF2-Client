class_name Stat extends Node

@export var type: Stats.TYPE

@export var value: float = 0.0

signal value_changed(new_value: float)

static func create_stat(stat_type: Stats.TYPE) -> Stat:
	var stat: Stat = Stat.new()
	stat.type = stat_type
	stat.value = StatDefinitions.get_base(stat_type)
	return stat
