extends Node2D

@onready var bullet_manager: Node2D = $BulletManager
@export var planets: Array[Structure]

func get_planets_positions() -> Array:
	var planets_positions: Array = []
	for planet in planets:
		planets_positions.push_back(planet.global_position)
	return planets_positions
		
func set_planets_positions(new_positions: Array):
	var i = 0
	for planet in planets:
		planet.global_position = new_positions[i]
		i += 1
