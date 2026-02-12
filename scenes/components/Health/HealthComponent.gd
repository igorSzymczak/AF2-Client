extends Node2D
class_name HealthComponent

var max_health: float = 1.0
var health: float = 1.0 : set = _set_health
var armor: float = 1.0
var max_shield: float = 1.0
var shield: float = 1.0 : set = _set_shield
var shield_regen: float = 1.0

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
	
	set_max_health(stats.get_stat(Stats.TYPE.MAX_HEALTH).value)
	set_max_shield(stats.get_stat(Stats.TYPE.MAX_SHIELD).value)
	#_set_health(stats.get_stat(Stats.TYPE.MAX_HEALTH).value)
	#_set_shield(stats.get_stat(Stats.TYPE.MAX_SHIELD).value)

var server_max_health := 0.0
var server_health := 0.0
var server_armor := 0.0

var server_max_shield := 0.0
var server_shield := 0.0
var server_shield_regen := 0.0

func _process(_delta):
	if !isBoss:
		global_position = parent.global_position
	
	if isPlayer:
		server_health = g.get_player_health(parent.gid)
		server_shield = g.get_player_shield(parent.gid)
	elif isEnemy:
		server_health = g.get_enemy_health(parent.gid)
		server_shield = g.get_enemy_shield(parent.gid)

signal health_changed(value: float)
func _set_health(_new_health: float):
	if health > max_health:
		set_max_health(health)
	health = _new_health
	if health <= 0:
		call_deferred("emit_signal", "health_depleted")
	if healthbar and is_instance_valid(healthbar):
		healthbar._set_health(health)
	
	health_changed.emit(_new_health)

signal shield_changed(value: float)
func _set_shield(_new_shield: float):
	if shield > max_shield:
		set_max_shield(shield)
	shield = _new_shield
	if shieldbar and is_instance_valid(shieldbar):
		shieldbar._set_shield(shield)
	
	shield_changed.emit(_new_shield)

signal max_health_changed(value: float)
func set_max_health(value: float):
	if value == max_health: return
	
	max_health = value
	healthbar.init_health(value)
	
	max_health_changed.emit(value)

signal max_shield_changed(value: float)
func set_max_shield(value: float):
	if value == max_shield: return
	
	max_shield = value
	shieldbar.init_shield(value)
	
	max_shield_changed.emit(value)

signal armor_changed(value: float)
func set_armor(value: float):
	if value == armor: return
	
	armor = value
	armor_changed.emit(value)

signal shield_regen_changed(value: float)
func set_shield_regen(value: float):
	if value == shield_regen: return
	
	shield_regen = value
	shield_regen_changed.emit(value)
