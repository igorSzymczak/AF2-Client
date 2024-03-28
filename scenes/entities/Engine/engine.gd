extends Node2D
class_name Thruster

@onready var idle = $Idle
@onready var light = $Light
@onready var speeding = $Speeding
@onready var accelerate = $Accelerate
var active: bool = false

func _ready() -> void:
	if idle: idle.emitting = true
	if light: light.emitting = false
	if accelerate: accelerate.emitting = false
	if speeding: speeding.emitting = false

func activate_thruster() -> void:
	active = true
	if accelerate: accelerate.emitting = true
	if speeding: speeding.emitting = true
	if light: light.emitting = true

func deactivate_thruster(velocity: Vector2) -> void:
	active = false
	if velocity.length() <= 75.0:
		if light: light.emitting = false
		if idle: idle.emitting = true
	if accelerate: accelerate.emitting = false
	if speeding: speeding.emitting = false
