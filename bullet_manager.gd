extends Node2D

func handle_bullet_spawned(bullet: Bullet, position: Vector2, direction: Vector2, shooter: CharacterBody2D) -> void:
	add_child(bullet)
	bullet.global_position = position
	bullet.set_direction(direction)
	bullet.shooter = shooter
