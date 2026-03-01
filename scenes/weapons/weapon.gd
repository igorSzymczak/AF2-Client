class_name Weapon extends Node

enum Property {
	DAMAGE,
	SHOOT_DELAY,
	BULLET_SPREAD,
	BULLET_AMOUNT,
	BULLET_AMOUNT_RNG,
	POWER_USAGE_PER_SHOOT,
	WEAPON_OUTPUTS,
	WEAPON_OUTPUTS_DISTANCE,
	BULLET_SPEED,
	BULLET_SPEED_RNG,
	BULLET_LIFE_TIME,
	BULLET_LIFE_TIME_RNG,
	BULLET_FALL,
	BULLET_PIERCING_AMOUNT,
	BULLET_AOE_RADIUS,
	BULLET_OTHER_ARGS,
	SHOCKWAVE_ANGLE,
	SHOCKWAVE_SCALE_SPEED,
	SHOCKWAVE_TIME_TO_VANISH_SECONDS,
}

@export var weapon_name: String
@export var weapon_type: WeaponManager.Type

@export var kinetic: bool
@export var energy: bool
@export var corrosive: bool

@export_multiline var description_long: String
@export_multiline var description_short: String

func get_ui_element() -> WeaponElement:
	var element: WeaponElement = WeaponElement.new()
	element.weapon_name = weapon_name
	return element
