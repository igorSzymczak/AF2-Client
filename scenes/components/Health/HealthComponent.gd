extends Node2D
class_name HealthComponent

@export var MAX_SHIELD: float
@export var SHIELD_REGEN_VALUE: float
@export var SHIELD_REGEN_BOOST: float # from arts, upgrades
@export var MAX_HEALTH: float
var health : float
var shield : float

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
	_set_health(MAX_HEALTH)
	_set_shield(MAX_SHIELD)
	healthbar.init_health(health)
	shieldbar.init_shield(shield)

var server_health: float
var server_shield: float
func _process(_delta):
	if !isBoss:
		global_position = parent.global_position
	
	if isPlayer:
		server_health = GameManager.get_player_health(parent.name)
		server_shield = GameManager.get_player_shield(parent.name)
		if parent.IS_MAIN_PLAYER:
			player_signals()
	elif isSpawner:
		server_health = GameManager.get_spawner_health(parent.name.to_int())
		server_shield = GameManager.get_spawner_shield(parent.name.to_int())
	elif isTurret:
		server_health = GameManager.get_turret_health(parent.name.to_int())
		server_shield = GameManager.get_turret_shield(parent.name.to_int())
	elif isEnemy:
		server_health = GameManager.get_enemy_health(parent.name.to_int())
		server_shield = GameManager.get_enemy_shield(parent.name.to_int())
	
	if health != server_health:
		_set_health(server_health)
	if shield != server_shield:
		_set_shield(server_shield)

func _set_health(_new_health):
	health = _new_health
	if health <= 0:
		call_deferred("emit_signal", "health_depleted")
	if healthbar and is_instance_valid(healthbar):
		healthbar._set_health(health)

func _set_shield(_new_shield):
	shield = _new_shield
	if shieldbar and is_instance_valid(shieldbar):
		shieldbar._set_shield(shield)

func player_signals() -> void:
	GlobalSignals.emit_signal("player_health", health)
	GlobalSignals.emit_signal("player_shield", shield)
