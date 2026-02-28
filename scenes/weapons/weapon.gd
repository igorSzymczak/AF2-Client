class_name Weapon extends Node

@export var weapon_name: String
@export var weapon_type: WeaponManager.Type

@export var damage: int
@export var damage_max: int

@export var rps : float
@export var rps_max: float

@export var power_cost: int
@export var power_cost_max: int

@export var range: int
@export var range_max: int

@export var lvl_1_bonuses: PackedStringArray
@export var lvl_2_bonuses: PackedStringArray
@export var lvl_3_bonuses: PackedStringArray


## Damage
@export_range(0, 10) var damage_points: int
@export_range(0, 10) var damage_points_max: int
# Damage dealt on single hit on highest LVL
#
# 10	>= 300
# 9		>= 225
# 8		>= 175
# 7		>= 125
# 6		>= 100
# 5		>= 75
# 4		>= 50
# 3		>= 35
# 2		>= 20
# 1		> 0
# 0		0

## RPS (Round Per Second)
@export_range(0, 10) var rps_points: int
@export_range(0, 10) var rps_points_max: int
# Calculated for highest lvl
#
# 10	>= 40
# 9		>= 30
# 8		>= 20
# 7		>= 15
# 6		>= 10
# 5		>= 8
# 4		>= 6
# 3		>= 4
# 2		>= 2
# 1		>= 1
# 0		0

## Power Efficiency
@export_range(0, 10) var power_points: int
@export_range(0, 10) var power_points_max: int
# The less power weapon uses, the more points.
# Efficinecy =  (1 / PowerCost)
#
# 10	infinity (PowerCost = 0)
# 9		>= 1.0
# 8		>= 0.666
# 7		>= 0.5
# 6		>= 0.333
# 5		>= 0.2
# 4		>= 0.1
# 3		>= 0.075
# 2		>= 0.05
# 1		>= 0.025
# 0		>= 0.01

## Shooting Range
@export_range(0, 10) var range_points: int
@export_range(0, 10) var range_points_max: int
# The further attack travels, the more points
# Because screen moves to the mouse,
# test range while having mouse as close to the player as possible
#
# 10	far behind the horizontal screen edge
# 9		2x behind the horizontal screen edge
# 8		to the horizontal edge of screen
# 7		almost to the horizontal edge of screen 
# 6		>= 0.75
# 5		>= 0.66
# 4		>= 0.5
# 3		>= 0.3
# 2		just near player position
# 1		at the player position
# 0		basically no range

@export var kinetic: bool
@export var energy: bool
@export var corrosive: bool

@export_multiline var description_long: String
@export_multiline var description_short: String

func get_ui_element() -> WeaponElement:
	var element: WeaponElement = WeaponElement.new()
	element.weapon_name = weapon_name
	return element
