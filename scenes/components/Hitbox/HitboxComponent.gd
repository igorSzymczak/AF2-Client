extends Area2D
class_name HitboxComponent

@export var health_component : HealthComponent
var team: int
var parent
func _ready() -> void:
	pass
	#parent = get_parent()

func set_health_component(component):
	health_component = component

func damage(attack: Attack):
	if is_instance_valid(health_component):
		health_component.damage(attack)
	
	# enemies get triggered after being hit 
	if parent is Actor:
		parent.engage(attack.shooter)
	
	# spawners trigger their minions
	if parent is Spawner:
		parent.engage_minions(attack.shooter)

func get_team() -> int:
	return team
