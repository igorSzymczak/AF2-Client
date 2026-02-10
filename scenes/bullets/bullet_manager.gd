class_name BulletManager extends Node2D

func _ready() -> void:
	g.bullet_added.connect(handle_bullet_spawned)
	g.shockwave_created.connect(handle_shockwave_created)

func handle_bullet_spawned(bullet: Bullet):
	add_child(bullet)

func handle_shockwave_created(
	_type: WeaponManager.ShockwaveType, _name: String,
	pos: Vector2, rot:float,
	speed: float, angle: float,
	time_to_vanish: float, current_time_of_living: int,
	_server_timestamp: int
) -> void:
	var shockwave: ShockWave = WeaponManager.get_shockwave(_type)
	shockwave.name = _name
	shockwave.global_position = pos
	shockwave.rotation = rot
	shockwave.speed = speed
	shockwave.angle = angle
	shockwave.time_to_vanish = time_to_vanish
	shockwave.time_of_living = current_time_of_living
	
	add_child(shockwave)
