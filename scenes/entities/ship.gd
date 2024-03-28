extends CharacterBody2D
class_name Ship

# CONSTANTS
const SPEED := 500.0 # ship stat
const MAX_POWER := 150.0 # ship stat
const POWER_REGEN_RATE := 5.0 # 1-10 from slowest to fastest (ship stat)
const TURN_SPEED := 3.0
const DECELERATION_SPEED := (SPEED / 5.0) * 4.0
const DRAG_COEF := 100.0

# BASIC STATS ( 0 - 10 )
@export var SHIP_HEALTH = 5 
@export var SHIP_ARMOR = 5
@export var SHIP_SHIELD = 5
@export var SHIP_SHIELD_REGEN = 5

# ADDITIONAL
@export var SHIP_BONUS_ATTACK_SPEED := 0.0
@export var SHIP_BONUS_KINETIC_DAMAGE_PERCENT := 0.0
@export var SHIP_BONUS_KINETIC_DAMAGE_FLAT := 0.0
@export var SHIP_BONUS_ENERGY_DAMAGE_PERCENT := 0.0
@export var SHIP_BONUS_ENERGY_DAMAGE_FLAT := 0.0
@export var SHIP_BONUS_CORROSIVE_DAMAGE_PERCENT := 0.0
@export var SHIP_BONUS_CORROSIVE_DAMAGE_FLAT := 0.0
@export var SHIP_BONUS_POWER := 0.0
@export var SHIP_BONUS_POWER_REGEN := 0.0
@export var SHIP_BONUS_SPEED := 0.0
@export var SHIP_BONUS_COOLDOWN := 0.0

@onready var health_component = $HealthComponent
@onready var engine: Thruster = $Engine

#func _ready() -> void:
	#health_component

#
#const SPEED := 500.0 # ship stat
#const MAX_POWER := 150.0 # ship stat
#const POWER_REGEN_RATE := 5.0 # 1-10 from slowest to fastest (ship stat)
#const TURN_SPEED := 3.0
#const DECELERATION_SPEED := (SPEED / 5.0) * 4.0
#const DRAG_COEF := 100.0

# Getters

func get_speed() -> float: return SPEED
func get_max_power() -> float: return MAX_POWER
func get_power_regen_rate() -> float: return POWER_REGEN_RATE
func get_turn_speed() -> float: return TURN_SPEED
func get_deceleration_speed() -> float: return DECELERATION_SPEED
func get_drag_coef() -> float: return DRAG_COEF





