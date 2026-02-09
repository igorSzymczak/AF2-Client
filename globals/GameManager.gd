extends Node

enum TIMESTEP {
	LOW = 50,        # 20 tps   (Bullets, positions)
	MEDIUM = 100,    # 10 tps   (Rotations)
	HIGH = 200,      # 5  tps
	QUARTER = 250,   # 4  tps
	HALF = 500,      # 2  tps
	FULL = 1000,     # 1  tps   (Planets)
}

enum ENTITY_TYPE {
	PLAYER,
	ENEMY,
	SPAWNER,
	TURRET,
	BOSS
}

var me: Player

var PlayerInfo: Dictionary = {}

var update_time = 50

var Planets: Dictionary = {}

var Players: Dictionary[int, Dictionary] = {}

var Bullets: Dictionary = {}

var Spawners: Dictionary[int, Dictionary] = {}

var Turrets: Dictionary[int, Dictionary] = {}

var Enemies: Dictionary[int, Dictionary] = {}

var Bosses: Dictionary[int, Dictionary] = {}

var Items: Dictionary = {}

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


func add_player(user_id: int):
	if !Players.has(user_id):
		var player: Player = get_node("/root/Game/World/" + str(user_id))
		Players[user_id] = {
			"node": player,
			"user_id": user_id,
			"nickname": "Player " + str(user_id).substr(0, 3),
			"global_position": player.global_position,
			"rotation": player.rotation,
			"velocity": player.velocity,
			"engine_active": false,
			"health": player.health_component.health,
			"shield": player.health_component.shield,
			"alive": player.alive,
			"ship_name": "NexarCarrier",
			"monitorable": false,
			"lvl": 0,
			"stats": {},
			"speed_boost": false
		}

func remove_player(user_id: int):
	if Players.has(user_id):
		Players.erase(user_id)

func get_player(user_id: int) -> Player:
	if Players.has(user_id):
		return Players[user_id]["node"] as Player
	else:
		return null

signal weapon_fired(shooter_id: int, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary)

func get_player_nickname(user_id: int) -> String:
	if Players.has(user_id):
		return Players[user_id]["nickname"]
	return "Player"
func update_player_nickname(user_id: int, nick: String):
	if Players.has(user_id):
		Players[user_id]["nickname"] = nick

signal local_player_position(pos: Vector2)
signal set_local_player_position(pos: Vector2)
func get_player_position(user_id: int) -> Vector2:
	if Players.has(user_id):
		return Players[user_id]["global_position"]
	return Vector2.ZERO
func update_player_position(user_id: int, pos: Vector2):
	if Players.has(user_id):
		Players[user_id]["global_position"] = pos

signal local_player_rotation(rot: float)
func get_player_rotation(user_id: int) -> float:
	if Players.has(user_id):
		return Players[user_id]["rotation"]
	return 0
func update_player_rotation(user_id: int, rot: float):
	if Players.has(user_id):
		Players[user_id]["rotation"] = rot

signal local_player_velocity(vel: Vector2)
func get_player_velocity(user_id: int) -> Vector2:
	if Players.has(user_id):
		return Players[user_id]["velocity"]
	return Vector2.ZERO
func update_player_velocity(user_id: int, vel: Vector2):
	if Players.has(user_id):
		Players[user_id]["velocity"] = vel

signal local_player_engine_active(activity: bool)
func get_player_engine_active(user_id: int) -> bool:
	if Players.has(user_id):
		return Players[user_id]["engine_active"]
	return false
func update_player_engine_active(user_id: int, activity: bool):
	if Players.has(user_id):
		Players[user_id]["engine_active"] = activity

func get_player_health(user_id: int) -> float:
	if Players.has(user_id):
		return Players[user_id]["health"]
	return 0
func update_player_health(user_id: int, health: float):
	if Players.has(user_id):
		Players[user_id]["health"] = health

func get_player_shield(user_id: int) -> float:
	if Players.has(user_id):
		return Players[user_id]["shield"]
	return 0
func update_player_shield(user_id: int, shield: float):
	if Players.has(user_id):
		Players[user_id]["shield"] = shield

func get_player_alive(user_id: int) -> bool:
	if Players.has(user_id):
		return Players[user_id]["alive"]
	return false
func update_player_alive(user_id: int, alive: bool):
	if Players.has(user_id):
		Players[user_id]["alive"] = alive

func get_player_ship_name(user_id: int) -> String:
	if Players.has(user_id):
		return Players[user_id]["ship_name"]
	return "NexarCarrier"
func update_player_ship_name(user_id: int, ship_name: String):
	if Players.has(user_id):
		Players[user_id]["ship_name"] = ship_name

func get_player_monitorable(user_id: int) -> bool:
	if Players.has(user_id):
		return Players[user_id]["monitorable"]
	return false
func update_player_monitorable(user_id: int, monitorable: bool):
	if Players.has(user_id):
		Players[user_id]["monitorable"] = monitorable

func get_player_lvl(user_id: int) -> int:
	if Players.has(user_id):
		return Players[user_id]["lvl"]
	return 0
func update_player_lvl(user_id: int, lvl: int):
	if Players.has(user_id):
		Players[user_id]["lvl"] = lvl

func get_player_stats(user_id: int) -> Dictionary[Stats.TYPE, float]:
	if Players.has(user_id):
		return Players[user_id]["stats"]
	return {}
func update_player_stats(user_id: int, stats: Dictionary[Stats.TYPE, float]):
	if Players.has(user_id):
		Players[user_id]["stats"] = stats
		
		var player: Player = Players[user_id]["node"] as Player
		for stat: Stats.TYPE in stats.keys():
			player.stats.set_stat_value(stat, stats[stat])

func get_player_stat(user_id: int, stat_type: Stats.TYPE) -> float:
	if Players.has(user_id) and Players[user_id]["stats"].has(stat_type):
		return Players[user_id]["stats"][stat_type]
	return 0
func update_player_stat(user_id: int, stat_type: Stats.TYPE, value: float):
	if Players.has(user_id):
		Players[user_id]["stats"][stat_type] = value
		
		var player: Player = Players[user_id]["node"] as Player
		player.stats.set_stat_value(stat_type, value)

signal local_player_speed_boost(activity: bool)
func get_player_speed_boost(user_id: int) -> bool:
	if Players.has(user_id):
		return Players[user_id]["speed_boost"]
	return 0
func update_player_speed_boost(user_id: int, speed_boost: bool):
	if Players.has(user_id):
		Players[user_id]["speed_boost"] = speed_boost

signal death_args(args: Dictionary)

signal player_info(player_info: Dictionary)
signal player_info_changed()
func set_player_info(new_player_info: Dictionary):
	var current_weapon: int = PlayerInfo.current_weapon if PlayerInfo.has("current_weapon") else 1
	PlayerInfo = new_player_info
	PlayerInfo.current_weapon = current_weapon
	player_info_changed.emit()

signal player_shoot(index: int)

signal set_weapon_request(slot: int, weapon_name: String)

## WEAPONS & BULLETS


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
	bullet_type: WeaponManager.BulletType, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: 
):
	if !Bullets.has(bullet_name):
		var bullet_scene: PackedScene = WeaponManager.get_bullet_scene(bullet_type)
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

signal shockwave_created(
	_type: WeaponManager.ShockwaveType, _name: String,
	pos: Vector2, rot: float,
	speed: float, angle: float,
	time_to_vanish: float, current_time_of_living: int,
	server_timestamp: int
)


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

func get_spawner_stats(id: int) -> Dictionary[Stats.TYPE, float]:
	if Spawners.has(id):
		return Spawners[id]["stats"]
	return {}
func update_spawner_stats(id: int, stats: Dictionary[Stats.TYPE, float]):
	if Spawners.has(id):
		Spawners[id]["stats"] = stats
		
		var spawner: Spawner = Spawners[id]["node"] as Spawner
		for stat: Stats.TYPE in stats.keys():
			spawner.stats.set_stat_value(stat, stats[stat])

func get_spawner_stat(id: int, stat_type: Stats.TYPE) -> float:
	if Spawners.has(id) and Spawners[id]["stats"].has(stat_type):
		return Spawners[id]["stats"][stat_type]
	return 0
func update_spawner_stat(id: int, stat_type: Stats.TYPE, value: float):
	if Spawners.has(id):
		Spawners[id]["stats"][stat_type] = value
		
		var spawner: Spawner = Spawners[id]["node"] as Spawner
		spawner.stats.set_stat_value(stat_type, value)


## TURRETS


func add_turret(turret: Dictionary):
	var id: int = turret.id
	if !Turrets.has(id):
		Turrets[id] = turret

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

func get_turret_stats(id: int) -> Dictionary[Stats.TYPE, float]:
	if Turrets.has(id):
		return Turrets[id]["stats"]
	return {}
func update_turret_stats(id: int, stats: Dictionary[Stats.TYPE, float]):
	if Turrets.has(id):
		Turrets[id]["stats"] = stats
		
		var turret: SpawnerTurret = Turrets[id]["node"] as SpawnerTurret
		for stat: Stats.TYPE in stats.keys():
			turret.stats.set_stat_value(stat, stats[stat])

func get_turret_stat(id: int, stat_type: Stats.TYPE) -> float:
	if Turrets.has(id) and Turrets[id]["stats"].has(stat_type):
		return Turrets[id]["stats"][stat_type]
	return 0
func update_turret_stat(id: int, stat_type: Stats.TYPE, value: float):
	if Turrets.has(id):
		Turrets[id]["stats"][stat_type] = value
		
		var turret: SpawnerTurret = Turrets[id]["node"] as SpawnerTurret
		turret.stats.set_stat_value(stat_type, value)


## ENEMIES


func add_enemy(enemy: Dictionary):
	var id: int = enemy.id
	if !Enemies.has(id):
		Enemies[id] = enemy

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

func get_enemy_stats(id: int) -> Dictionary[Stats.TYPE, float]:
	if Enemies.has(id):
		return Enemies[id]["stats"]
	return {}
func update_enemy_stats(id: int, stats: Dictionary[Stats.TYPE, float]):
	if Enemies.has(id):
		Enemies[id]["stats"] = stats
		
		var enemy: Actor = Enemies[id]["node"] as Actor
		for stat: Stats.TYPE in stats.keys():
			enemy.stats.set_stat_value(stat, stats[stat])

func get_enemy_stat(id: int, stat_type: Stats.TYPE) -> float:
	if Enemies.has(id) and Enemies[id]["stats"].has(stat_type):
		return Enemies[id]["stats"][stat_type]
	return 0
func update_enemy_stat(id: int, stat_type: Stats.TYPE, value: float):
	if Enemies.has(id):
		Enemies[id]["stats"][stat_type] = value
		
		var enemy: Actor = Enemies[id]["node"] as Actor
		enemy.stats.set_stat_value(stat_type, value)



#		BOSSESS



func add_boss(boss: Dictionary):
	var id: int = boss.id
	if !Bosses.has(id):
		Bosses[id] = boss

func remove_boss(id: int): if Bosses.has(id): Bosses.erase(id)

func update_boss_position(id: int, pos: Vector2):
	if Bosses.has(id):
		Bosses[id]["global_position"] = pos
func get_boss_position(id: int) -> Vector2:
	if Bosses.has(id):
		return Bosses[id]["global_position"]
	return Vector2.ZERO

func update_boss_rotation(id: int, rot: float):
	if Bosses.has(id):
		Bosses[id]["rotation"] = rot
func get_boss_rotation(id: int) -> float:
	if Bosses.has(id):
		return Bosses[id]["rotation"]
	return 0

func get_boss_health(id: int) -> float:
	if Bosses.has(id):
		return Bosses[id]["health"]
	return 0
func update_boss_health(id: int, health: float):
	if Bosses.has(id):
		Bosses[id]["health"] = health

func get_boss_shield(id: int) -> float:
	if Bosses.has(id):
		return Bosses[id]["shield"]
	return 0
func update_boss_shield(id: int, shield: float):
	if Bosses.has(id):
		Bosses[id]["shield"] = shield

func get_boss_engine_active(id: int) -> bool:
	if Bosses.has(id):
		return Bosses[id]["engine_active"]
	return false
func update_boss_engine_active(id: int, engine_active: bool):
	if Bosses.has(id):
		Bosses[id]["engine_active"] = engine_active

func get_boss_stats(id: int) -> Dictionary[Stats.TYPE, float]:
	if Bosses.has(id):
		return Bosses[id]["stats"]
	return {}
func update_boss_stats(id: int, stats: Dictionary[Stats.TYPE, float]):
	if Bosses.has(id):
		Bosses[id]["stats"] = stats
		
		var boss = Bosses[id]["node"]
		for stat: Stats.TYPE in stats.keys():
			boss.stats.set_stat_value(stat, stats[stat])

func get_boss_stat(id: int, stat_type: Stats.TYPE) -> float:
	if Bosses.has(id) and Bosses[id]["stats"].has(stat_type):
		return Bosses[id]["stats"][stat_type]
	return 0
func update_boss_stat(id: int, stat_type: Stats.TYPE, value: float):
	if Bosses.has(id):
		Bosses[id]["stats"][stat_type] = value
		
		var boss = Bosses[id]["node"]
		boss.stats.set_stat_value(stat_type, value)




# 			ITEMS

func add_item(item: Dictionary):
	var id: int = item.id
	if !Items.has(id):
		Items[id] = item

func remove_item(id: int): if Items.has(id): Items.erase(id)
