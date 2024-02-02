extends Node2D
class_name Thruster

@onready var idle = $Idle
@onready var light = $Light
@onready var speeding = $Speeding
@onready var accelerate = $Accelerate

func _ready() -> void:
	idle.emitting = true
	light.emitting = false
	accelerate.emitting = false
	speeding.emitting = false

func activate_thruster() -> void:
	accelerate.emitting = true
	speeding.emitting = true
	light.emitting = true

func deactivate_thruster(velocity: Vector2) -> void:
	if velocity.length() <= 75.0:
		light.emitting = false
		idle.emitting = true
	accelerate.emitting = false
	speeding.emitting = false
