class_name Stats extends Node

enum TYPE {
	MAX_SHIELD,
	SHIELD_REGEN,
	MAX_HEALTH,
	ARMOR,
	
	DAMAGE_KINETIC,
	DAMAGE_ENERGY,
	DAMAGE_CORROSIVE,
	
	RESISTANCE_KINETIC,
	RESISTANCE_ENERGY,
	RESISTANCE_CORROSIVE,
	
	MAX_POWER,
	SPEED,
	TURN_SPEED,
	
	SPEED_BOOST_DELAY,
	SPEED_BOOST_DURATION,
	SPEED_BOOST_STRENGTH,
	SPEED_BOOST_TURN_SPEED
}

var stats: Dictionary[TYPE, Stat] = {}
var modifiers: Dictionary[String, Modifier]

func get_stat(stat_type: TYPE) -> Stat:
	_create_stat_if_nonexistant(stat_type)
	return stats[stat_type]

func _create_stat_if_nonexistant(stat_type: TYPE) -> void:
	if stats.has(stat_type):
		return
	
	stats[stat_type] = Stat.create_stat(stat_type)
	stats[stat_type].value_changed.emit(stats[stat_type].value)

func add_modifier(mod: Modifier) -> void:
	modifiers[mod.id] = mod

func remove_modifier(id: String) -> void:
	if modifiers.has(id):
		modifiers.erase(id)

func clear_modifiers() -> void:
	if modifiers.keys().size() > 0:
		modifiers.clear()

static func create_default_stats() -> Stats:
	var new_stats: Stats = Stats.new()
	for type: TYPE in StatDefinitions.DEFINITIONS:
		new_stats._create_stat_if_nonexistant(type)
	
	return new_stats
	

func set_stat_value(stat_type: TYPE, value: float) -> void:
	_create_stat_if_nonexistant(stat_type)
	stats[stat_type].value = value
	stats[stat_type].value_changed.emit(value)
