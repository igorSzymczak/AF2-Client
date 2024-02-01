extends Node2D
class_name HealthComponent

@export var MAX_HEALTH := 100
var health : int

signal health_depleted()

func _ready() -> void:
	health = MAX_HEALTH

func damage(hit: int) -> void:
	health -= hit
	if(health <= 0):
		emit_signal("health_depleted")
