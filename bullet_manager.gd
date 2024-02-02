extends Node2D

func handle_bullet_spawned(bullet: Bullet, pos: Vector2, direction: Vector2, team: int) -> void:
	add_child(bullet)
	bullet.global_position = pos
	bullet.set_direction(direction)
	bullet.team = team
