extends Node2D

func _ready() -> void:
	g.bullet_spawned.connect(handle_bullet_spawned)
	g.shockwave_created.connect(handle_shockwave_created)

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

func handle_shockwave_created(
	_path: String, _name: String,
	pos: Vector2, rot:float,
	speed: float, angle: float,
	time_to_vanish: int, current_time_of_living: int,
	_server_timestamp: int
) -> void:
	var shockwave: ShockWave = g.ShockwaveScenes[_path].instantiate()
	shockwave.name = _name
	shockwave.global_position = pos
	shockwave.rotation = rot
	shockwave.speed = speed
	shockwave.angle = angle
	shockwave.time_to_vanish = time_to_vanish
	shockwave.time_of_living = current_time_of_living
	
	add_child(shockwave)
