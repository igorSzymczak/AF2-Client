extends Node

enum TIMESTEP {
	LOW = 50,        # 20 tps   (Bullets, positions)
	MEDIUM = 100,    # 10 tps   (Rotations)
	HIGH = 200,      # 5  tps
	QUARTER = 250,   # 4  tps
	HALF = 500,      # 2  tps
	FULL = 1000,     # 1  tps   (Planets)
}

var local_player: Player

var PlayerInfo: Dictionary = {}

var update_time = 50

var Planets: Dictionary = {}

var Players: Dictionary = {}

var Bullets: Dictionary = {}

var Spawners: Dictionary = {}

var Turrets: Dictionary = {}

var Enemies: Dictionary = {}

var BulletScenes = {
	"res://scenes/weapons/bullet_types/bullet.tscn" = preload("res://scenes/bullets/bullet_types/bullet.tscn"),
	"res://scenes/weapons/bullet_types/bullet_homing.tscn" = preload("res://scenes/bullets/bullet_types/bullet_homing.tscn"),
	"res://scenes/weapons/weapons/ClusterMissiles/missile.tscn" = preload("res://scenes/bullets/bullets/ClusterMissiles/missile.tscn"),
	"res://scenes/weapons/weapons/GatlingLaser/laser.tscn" = preload("res://scenes/bullets/bullets/GatlingLaser/gatling_laser.tscn"),
	"res://scenes/weapons/weapons/Pistol/pistol_round.tscn" = preload("res://scenes/bullets/bullets/Pistol/pistol_round.tscn"),
	"res://scenes/weapons/weapons/Railgun/railgun_bullet.tscn" = preload("res://scenes/bullets/bullets/Railgun/railgun_bullet.tscn"),
	"res://scenes/weapons/weapons/RocketLauncher/rocket.tscn" = preload("res://scenes/bullets/bullets/RocketLauncher/rocket.tscn"),
	"res://scenes/weapons/weapons/Shotgun/shotgun_bullet.tscn" = preload("res://scenes/bullets/bullets/Shotgun/shotgun_bullet.tscn"),
	"res://scenes/weapons/weapons/SniperRifle/high_calliber_round.tscn" = preload("res://scenes/bullets/bullets/SniperRifle/high_calliber_round.tscn"),
	"res://scenes/weapons/weapons/SpawnerLaser/spawner_laser.tscn" = preload("res://scenes/bullets/bullets/SpawnerLaser/spawner_laser.tscn")
}

# Allows or Disallows to use Weapons, Abilities etc. Changed through different Menus
var can_perform_actions = true


## Planets


func add_planet(planet_name: String, pos: Vector2, landable: bool, is_safezone: bool):
	if !Planets.has(planet_name):
		Planets[planet_name] = {
			"name": planet_name,
			"global_position": pos,
			"landable": landable,
			"is_safezone": is_safezone
		}

func get_planet_position(planet_name: String) -> Vector2:
	if Planets.has(planet_name):
		return Planets[planet_name]["global_position"]
	return Vector2.ZERO
func update_planet_position(planet_name: String, pos: Vector2):
	if Planets.has(planet_name):
		Planets[planet_name]["global_position"] = pos

func get_planet_landable(planet_name: String) -> bool:
	if Planets.has(planet_name):
		return Planets[planet_name]["landable"]
	return false
func update_planet_landable(planet_name: String, landable: bool):
	if Planets.has(planet_name):
		Planets[planet_name]["landable"] = landable

func get_planet_is_safezone(planet_name: String) -> bool:
	if Planets.has(planet_name):
		return Planets[planet_name]["is_safezone"]
	return false

## Players


func add_player(username):
	if !Players.has(username):
		var player: Player = get_node("/root/Game/World/" + username)
		Players[username] = {
			"username": username,
			"nickname": "Player " + player.name.substr(0, 3),
			"global_position": player.global_position,
			"rotation": player.rotation,
			"velocity": player.velocity,
			"engine_active": false,
			"health": player.health_component.MAX_HEALTH,
			"shield": player.health_component.MAX_SHIELD,
			"alive": player.alive,
			"ship_name": "NexarCarrier",
			"monitorable": false,
		}

func remove_player(username: String):
	if Players.has(username):
		Players.erase(username)

func get_player(username: String):
	if Players.has(username):
		return get_node("/root/Game/World/" + username) as Player
	else:
		return false

signal weapon_fired(shooter_name: String, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary)

func get_player_nickname(username: String) -> String:
	if Players.has(username):
		return Players[username]["nickname"]
	return "Player"
func update_player_nickname(username: String, nick: String):
	if Players.has(username):
		Players[username]["nickname"] = nick

signal local_player_position(pos: Vector2)
signal set_local_player_position(pos: Vector2)
func get_player_position(username: String) -> Vector2:
	if Players.has(username):
		return Players[username]["global_position"]
	return Vector2.ZERO
func update_player_position(username: String, pos: Vector2):
	if Players.has(username):
		Players[username]["global_position"] = pos

signal local_player_rotation(rot: float)
func get_player_rotation(username: String) -> float:
	if Players.has(username):
		return Players[username]["rotation"]
	return 0
func update_player_rotation(username: String, rot: float):
	if Players.has(username):
		Players[username]["rotation"] = rot

signal local_player_velocity(vel: Vector2)
func get_player_velocity(username: String) -> Vector2:
	if Players.has(username):
		return Players[username]["velocity"]
	return Vector2.ZERO
func update_player_velocity(username: String, vel: Vector2):
	if Players.has(username):
		Players[username]["velocity"] = vel

signal local_player_engine_active(activity: bool)
func get_player_engine_active(username: String) -> bool:
	if Players.has(username):
		return Players[username]["engine_active"]
	return false
func update_player_engine_active(username: String, activity: bool):
	if Players.has(username):
		Players[username]["engine_active"] = activity

signal player_health(username: String, health: float)
func get_player_health(username: String) -> float:
	if Players.has(username):
		return Players[username]["health"]
	return 0
func update_player_health(username: String, health: float):
	if Players.has(username):
		Players[username]["health"] = health

signal player_shield(username: String, shield: float)
func get_player_shield(username: String) -> float:
	if Players.has(username):
		return Players[username]["shield"]
	return 0
func update_player_shield(username: String, shield: float):
	if Players.has(username):
		Players[username]["shield"] = shield

func get_player_alive(username: String) -> bool:
	if Players.has(username):
		return Players[username]["alive"]
	return false
func update_player_alive(username: String, alive: bool):
	if Players.has(username):
		Players[username]["alive"] = alive

func get_player_ship_name(username: String) -> String:
	if Players.has(username):
		return Players[username]["ship_name"]
	return "NexarCarrier"
func update_player_ship_name(username: String, ship_name: String):
	if Players.has(username):
		Players[username]["ship_name"] = ship_name

func get_player_monitorable(username: String) -> bool:
	if Players.has(username):
		return Players[username]["monitorable"]
	return false
func update_player_monitorable(username: String, monitorable: bool):
	if Players.has(username):
		Players[username]["monitorable"] = monitorable

signal death_args(args: Dictionary)

signal player_info(player_info: Dictionary)
func set_player_info(new_player_info: Dictionary):
	PlayerInfo = new_player_info

signal player_shoot(index: int)


## WEPAONS & BULLETS


@onready var ui = get_node("/root/Game/UI")
func is_mouse_over_menu() -> bool:
	return ui.is_mouse_over_menu()

signal bullet_spawned(
	bullet_scene: PackedScene, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: int
)
func add_bullet(
	bullet_path: String, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: 
):
	if !Bullets.has(bullet_name):
		var bullet_scene: PackedScene = BulletScenes[bullet_path]
		Bullets[bullet_name] = {
			"name": bullet_name,
			"global_position": global_pos,
			"is_deterministic": is_deterministic,
		}
		emit_signal("bullet_spawned",
			bullet_scene, bullet_name,
			global_pos, is_deterministic,
			direction_speed, fall,
			life_time, current_life_time,
			server_timestamp
		)

signal bullet_position(bullet_name: String, pos: Vector2)
func update_bullet_position(bullet_name: String, pos: Vector2):
	if Bullets.has(bullet_name):
		Bullets[bullet_name]["global_position"] = pos
func get_bullet_position(bullet_name: String) -> Vector2:
	if Bullets.has(bullet_name):
		return Bullets[bullet_name]["global_position"]
	return Vector2.ZERO

signal bullet_is_deterministic(bullet_name: String, is_deterministic: bool)
func update_bullet_is_deterministic(bullet_name: String, is_deterministic: bool):
	if Bullets.has(bullet_name):
		Bullets[bullet_name]["is_deterministic"] = is_deterministic
func get_bullet_is_deterministic(bullet_name: String) -> bool:
	if Bullets.has(bullet_name):
		return Bullets[bullet_name]["is_deterministic"]
	return true

signal bullet_freed(bullet_name)
func remove_bullet(bullet_name: String):
	if Bullets.has(bullet_name):
		Bullets.erase(bullet_name)


## Spawners


func add_spawner(spawner: Dictionary):
	var id = spawner.id
	if !Spawners.has(id):
		Spawners[id] = spawner

func update_spawner_position(id: int, pos: Vector2):
	if Spawners.has(id):
		Spawners[id]["global_position"] = pos
func get_spawner_position(id: int) -> Vector2:
	if Spawners.has(id):
		return Spawners[id]["global_position"]
	return Vector2.ZERO

func update_spawner_rotation(id: int, rot: float):
	if Spawners.has(id):
		Spawners[id]["rotation"] = rot
func get_spawner_rotation(id: int) -> float:
	if Spawners.has(id):
		return Spawners[id]["rotation"]
	return 0

func get_spawner_health(id: int) -> float:
	if Spawners.has(id):
		return Spawners[id]["health"]
	return 0
func update_spawner_health(id: int, health: float):
	if Spawners.has(id):
		Spawners[id]["health"] = health

func get_spawner_shield(id: int) -> float:
	if Spawners.has(id):
		return Spawners[id]["shield"]
	return 0
func update_spawner_shield(id: int, shield: float):
	if Spawners.has(id):
		Spawners[id]["shield"] = shield

func update_spawner_eye_position(id: int, pos: Vector2):
	if Spawners.has(id):
		Spawners[id]["eye_position"] = pos
func get_spawner_eye_position(id: int) -> Vector2:
	if Spawners.has(id):
		return Spawners[id]["eye_position"]
	return Vector2.ZERO

func update_spawner_eye_trigger(id: int, trigger: bool):
	if Spawners.has(id):
		Spawners[id]["eye_trigger"] = trigger
func get_spawner_eye_trigger(id: int) -> bool:
	if Spawners.has(id):
		return Spawners[id]["eye_trigger"]
	return false

func update_spawner_active(id: int, active: bool):
	if Spawners.has(id):
		Spawners[id]["active"] = active
func get_spawner_active(id: int) -> bool:
	if Spawners.has(id):
		return Spawners[id]["active"]
	return false


## TURRETS


func add_turret(turret_name: String, id: int, global_position: Vector2, rotation: float, health: float, shield: float):
	if !Turrets.has(id):
		Turrets[id] = {
			"name": turret_name,
			"id": id,
			"global_position": global_position,
			"rotation": rotation,
			"health": health,
			"shield": shield
		}

func remove_turret(id: int): if Turrets.has(id): Turrets.erase(id)

func update_turret_position(id: int, pos: Vector2):
	if Turrets.has(id):
		Turrets[id]["global_position"] = pos
func get_turret_position(id: int) -> Vector2:
	if Turrets.has(id):
		return Turrets[id]["global_position"]
	return Vector2.ZERO

func update_turret_rotation(id: int, rot: float):
	if Turrets.has(id):
		Turrets[id]["rotation"] = rot
func get_turret_rotation(id: int) -> float:
	if Turrets.has(id):
		return Turrets[id]["rotation"]
	return 0

func get_turret_health(id: int) -> float:
	if Turrets.has(id):
		return Turrets[id]["health"]
	return 0
func update_turret_health(id: int, health: float):
	if Turrets.has(id):
		Turrets[id]["health"] = health

func get_turret_shield(id: int) -> float:
	if Turrets.has(id):
		return Turrets[id]["shield"]
	return 0
func update_turret_shield(id: int, shield: float):
	if Turrets.has(id):
		Turrets[id]["shield"] = shield


## ENEMIES


func add_enemy(enemy_name: String, id: int, pos: Vector2, rot: float, health: float, shield: float, engine_active: bool):
	if !Enemies.has(id):
		Enemies[id] = {
			"name": enemy_name,
			"id": id,
			"global_position": pos,
			"rotation": rot,
			"health": health,
			"shield": shield,
			"engine_active": engine_active
		}

func remove_enemy(id: int): if Enemies.has(id): Enemies.erase(id)

func update_enemy_position(id: int, pos: Vector2):
	if Enemies.has(id):
		Enemies[id]["global_position"] = pos
func get_enemy_position(id: int) -> Vector2:
	if Enemies.has(id):
		return Enemies[id]["global_position"]
	return Vector2.ZERO

func update_enemy_rotation(id: int, rot: float):
	if Enemies.has(id):
		Enemies[id]["rotation"] = rot
func get_enemy_rotation(id: int) -> float:
	if Enemies.has(id):
		return Enemies[id]["rotation"]
	return 0

func get_enemy_health(id: int) -> float:
	if Enemies.has(id):
		return Enemies[id]["health"]
	return 0
func update_enemy_health(id: int, health: float):
	if Enemies.has(id):
		Enemies[id]["health"] = health

func get_enemy_shield(id: int) -> float:
	if Enemies.has(id):
		return Enemies[id]["shield"]
	return 0
func update_enemy_shield(id: int, shield: float):
	if Enemies.has(id):
		Enemies[id]["shield"] = shield

func get_enemy_engine_active(id: int) -> bool:
	if Enemies.has(id):
		return Enemies[id]["engine_active"]
	return false
func update_enemy_engine_active(id: int, engine_active: bool):
	if Enemies.has(id):
		Enemies[id]["engine_active"] = engine_active
