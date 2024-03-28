extends Node2D

func _ready() -> void:
	GameManager.connect("bullet_spawned", handle_bullet_spawned)

func handle_bullet_spawned(
	bullet_scene: PackedScene, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: int
	):
	var bullet: Bullet = bullet_scene.instantiate()
	bullet.name = bullet_name
	bullet.global_position = global_pos
	bullet.is_deterministic = is_deterministic
	bullet.direction_speed = direction_speed
	bullet.fall = fall
	bullet.life_time = life_time
	bullet.current_life_time = current_life_time
	bullet.server_timestamp = server_timestamp
	add_child(bullet)
	
	#print(fall)
