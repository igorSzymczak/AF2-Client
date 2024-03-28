extends Node

var global_position: Vector2
var rotation: float
var engine_active: bool = false
var health: int
var shield: int
var main_segment_alive: bool = true

var left_segment_rotation: float
var left_segment_alive: bool = true

var right_segment_rotation: float
var right_segment_alive: bool = true

var max_health: int = -1 # Client
var max_shield: int = -1 # Client


@rpc("authority", "call_local", "unreliable")
func handle_update_position(pos: Vector2):
	global_position = pos

@rpc("authority", "call_local", "unreliable")
func handle_update_rotation(rot: float):
	rotation = rot

@rpc("authority", "call_local", "reliable")
func handle_update_engine_active(activity: bool):
	engine_active = activity

@rpc("authority", "call_local", "reliable")
func handle_update_health(new_health: int):
	health = new_health

@rpc("authority", "call_local", "reliable")
func handle_update_shield(new_shield: int):
	shield = new_shield

@rpc("authority", "call_local", "reliable")
func handle_update_main_segment_alive(alive: bool):
	main_segment_alive = alive


@rpc("authority", "call_local", "unreliable")
func handle_update_left_segment_rotation(rot: float):
	left_segment_rotation = rot

@rpc("authority", "call_local", "reliable")
func handle_update_left_segment_alive(alive: bool):
	left_segment_alive = alive


@rpc("authority", "call_local", "unreliable")
func handle_update_right_segment_rotation(rot: float):
	right_segment_rotation = rot

@rpc("authority", "call_local", "reliable")
func handle_update_right_segment_alive(alive: bool):
	right_segment_alive = alive


@rpc("authority", "call_remote", "reliable")
func load_existing(
	pos: Vector2, rot: float, server_main_segment_alive: bool, 
	server_left_segment_alive: bool, server_right_segment_alive: bool,
	server_max_health: int, server_health: int,
	server_max_shield: int, server_shield: int
):
	global_position = pos
	rotation = rot
	main_segment_alive = server_main_segment_alive
	left_segment_alive = server_left_segment_alive
	right_segment_alive = server_right_segment_alive
	max_health = server_max_health
	health = server_health
	max_shield = server_max_shield
	shield = server_shield
	
	GlobalSignals.boss_max_health.emit(HomerusManager.max_health)
	GlobalSignals.boss_max_shield.emit(HomerusManager.max_shield)
