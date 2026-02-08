class_name Weapon extends Node

@export var weapon_name: String
@export var weapon_type: WeaponManager.Type

@export var damage: int
@export var rps : float
@export var power_cost: int
@export var range: int

@export_range(0, 10) var damage_points: int
@export_range(0, 10) var rps_points: int
@export_range(0, 10) var power_points: int

@export_range(0, 10) var range_points: int
@export var kinetic: bool
@export var energy: bool
@export var corrosive: bool

@export_multiline var description_long: String
@export_multiline var description_short: String

func get_ui_element() -> WeaponElement:
	var element: WeaponElement = WeaponElement.new()
	element.weapon_name = weapon_name
	return element
