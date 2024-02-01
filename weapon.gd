extends Node2D
class_name Weapon

@export var bullet_scene : PackedScene

@onready var cooldown: Timer = $Cooldown
@onready var bullet_spawn: Marker2D = $BulletSpawn
@onready var bullet_direction: Marker2D = $BulletDirection

signal weapon_fired(bullet: Bullet, position: Vector2, direction: Vector2)

func shoot():
	if cooldown.is_stopped():
		var bullet = bullet_scene.instantiate()
		var direction = -(bullet_spawn.global_position-bullet_direction.global_position).normalized()
		emit_signal("weapon_fired", bullet, bullet_spawn.global_position, direction)
		cooldown.start()
