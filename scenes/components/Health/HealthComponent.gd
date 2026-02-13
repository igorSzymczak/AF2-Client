extends Node2D
class_name HealthComponent

var max_health: int = 1
var health: int = 1 : set = _set_health
var armor: int = 1
var max_shield: int = 1
var shield: int = 1 : set = _set_shield
var shield_regen: int = 1

@onready var parent = get_parent()

@onready var isPlayer: bool = parent is Player
@onready var isEnemy: bool = parent is Actor
@onready var isBoss: bool = parent is CanvasLayer

@onready var healthbar: HealthBar = $HealthBar
@onready var shieldbar: ShieldBar = $ShieldBar

signal health_depleted()

func _ready() -> void:
	if !isBoss:
		global_position = parent.global_position
	
	var stats: Stats = parent.stats

	stats.get_stat(Stats.TYPE.MAX_HEALTH).value_changed.connect(set_max_health)
	stats.get_stat(Stats.TYPE.MAX_SHIELD).value_changed.connect(set_max_shield)
	stats.get_stat(Stats.TYPE.ARMOR).value_changed.connect(set_armor)
	stats.get_stat(Stats.TYPE.SHIELD_REGEN).value_changed.connect(set_shield_regen)
	
	set_max_health(round(stats.get_stat(Stats.TYPE.MAX_HEALTH).value))
	set_max_shield(round(stats.get_stat(Stats.TYPE.MAX_SHIELD).value))
	#_set_health(stats.get_stat(Stats.TYPE.MAX_HEALTH).value)
	#_set_shield(stats.get_stat(Stats.TYPE.MAX_SHIELD).value)

func _process(_delta):
	if !isBoss:
		global_position = parent.global_position

signal health_changed(value: int)
func _set_health(_new_health: int):
	health = _new_health
	if health <= 0:
		call_deferred("emit_signal", "health_depleted")
	if healthbar and is_instance_valid(healthbar):
		healthbar._set_health(health)
	
	health_changed.emit(_new_health)

signal shield_changed(value: int)
func _set_shield(_new_shield: int):
	shield = _new_shield
	if shieldbar and is_instance_valid(shieldbar):
		shieldbar._set_shield(shield)
	
	shield_changed.emit(_new_shield)

func set_max_health(value: int):
	if value == max_health: return
	
	max_health = value
	healthbar.init_health(value)

func set_max_shield(value: int):
	if value == max_shield: return
	
	max_shield = value
	shieldbar.init_shield(value)

func set_armor(value: int):
	if value == armor: return
	
	armor = value

func set_shield_regen(value: int):
	if value == shield_regen: return
	
	shield_regen = value
