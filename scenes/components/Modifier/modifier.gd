class_name Modifier extends Node

enum TYPE {
	FLAT,
	PERCENT,
	MULT
}

enum SOURCE {
	SHIP,
	OTHER
}

var id: String
var stat_type: Stats.TYPE
var type: TYPE
var value: float
var source: SOURCE = SOURCE.OTHER
var perm: float
var duration: float

static func create_modifier(new_id: String, new_stat_type: Stats.TYPE, 
	new_type: TYPE, new_value: float, new_perm: bool = true, 
	new_duration: float = 0.0, new_source: SOURCE = SOURCE.OTHER
) -> Modifier:
	var mod: Modifier = Modifier.new()
	mod.id = new_id
	mod.stat_type = new_stat_type
	mod.type = new_type
	mod.value = new_value
	mod.perm = new_perm
	mod.duration = new_duration
	mod.source = new_source
	return mod
