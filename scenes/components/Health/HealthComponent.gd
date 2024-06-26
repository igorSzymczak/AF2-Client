extends Node2D
class_name HealthComponent

var max_health: float = 1.0
var health: float = 1.0
var armor: float = 1.0
var max_shield: float = 1.0
var shield: float = 1.0
var shield_regen: float = 1.0

@onready var parent = get_parent()

@onready var isPlayer: bool = parent is Player
@onready var isSpawner: bool = parent is Spawner
@onready var isTurret: bool = parent is SpawnerTurret
@onready var isEnemy: bool = parent is Actor
@onready var isBoss: bool = parent is CanvasLayer

@onready var healthbar: HealthBar = $HealthBar
@onready var shieldbar: ShieldBar = $ShieldBar

signal health_depleted()

func _ready() -> void:
	if !isBoss:
		global_position = parent.global_position
	set_max_health(max_health)
	set_max_shield(max_shield)
	_set_health(max_health)
	_set_shield(max_shield)

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
		server_max_health = g.get_player_max_health(parent.name)
		server_health = g.get_player_health(parent.name)
		server_armor = g.get_player_armor(parent.name)
		server_max_shield = g.get_player_max_shield(parent.name)
		server_shield = g.get_player_shield(parent.name)
		server_shield_regen = g.get_player_shield_regen(parent.name)
	elif isSpawner:
		server_health = g.get_spawner_health(parent.name.to_int())
		server_shield = g.get_spawner_shield(parent.name.to_int())
		server_max_health = g.get_spawner_max_health(parent.name.to_int())
		server_max_shield = g.get_spawner_max_shield(parent.name.to_int())
	elif isTurret:
		server_health = g.get_turret_health(parent.name.to_int())
		server_shield = g.get_turret_shield(parent.name.to_int())
		server_max_health = g.get_turret_max_health(parent.name.to_int())
		server_max_shield = g.get_turret_max_shield(parent.name.to_int())
	elif isEnemy:
		server_health = g.get_enemy_health(parent.name.to_int())
		server_shield = g.get_enemy_shield(parent.name.to_int())
		server_max_health = g.get_enemy_max_health(parent.name.to_int())
		server_max_shield = g.get_enemy_max_shield(parent.name.to_int())
	
	if max_health != server_max_health:
		set_max_health(server_max_health)
	if health != server_health:
		_set_health(server_health)
	if armor != server_armor:
		set_armor(server_armor)
	if max_shield != server_max_shield:
		set_max_shield(server_max_shield)
	if shield != server_shield:
		_set_shield(server_shield)
	if shield_regen != server_shield_regen:
		set_shield_regen(server_shield_regen)
	

signal health_changed(value: float)
func _set_health(_new_health: float):
	health = _new_health
	if health <= 0:
		call_deferred("emit_signal", "health_depleted")
	if healthbar and is_instance_valid(healthbar):
		healthbar._set_health(health)
	
	health_changed.emit(_new_health)

signal shield_changed(value: float)
func _set_shield(_new_shield: float):
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

