extends Node2D
class_name Weapon

@export var bullet_scene : PackedScene

@onready var cooldown: Timer = $Cooldown
@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var bullet_direction: Marker2D = $BulletDirection

var team: int = -1

func initialize(team: int) -> void:
	self.team = team

func shoot():
	if cooldown.is_stopped():
		var bullet = bullet_scene.instantiate()
		var direction = -(bullet_spawn.global_position-bullet_direction.global_position).normalized()
		GlobalSignals.emit_signal("bullet_fired", bullet, bullet_spawn.global_position, direction, team)
		cooldown.start()
