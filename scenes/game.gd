extends Node2D
class_name Game

@onready var ui = $UI

@export var current_world: Node2D

const PORT: int = 7000
#const ADDRESS: String = "127.0.0.1"
const ADDRESS: String = "130.61.143.133"

var local_player_character: Player

var connected_peer_ids: Array = []
var multiplayer_peer

var client_id
func _ready():
	#print("loading client...")
	start_client()
	client_id = str(multiplayer.get_unique_id())
	current_world.hide()
	AuthManager.logged_in.connect(_on_logged_in)


## CLIENT
func start_client() -> void:
	multiplayer.connected_to_server.connect(self.connected_to_server)
	multiplayer.server_disconnected.connect(self.disconnected_from_server)
	
	#print("Creating Client...")
	
	# Create CLient
	multiplayer_peer  = ENetMultiplayerPeer.new()
	multiplayer_peer.create_client(ADDRESS, PORT)
	multiplayer_peer.get_host().compress(ENetConnection.COMPRESS_RANGE_CODER)
	multiplayer.multiplayer_peer = multiplayer_peer
	
	client_signals()

func _on_logged_in():
	current_world.show()
	ui.start_game()

# Client Callbacks
func connected_to_server() -> void:
	#pass
	print("Connected to Server!")
func disconnected_from_server() -> void:
	print("Disconnected from Server...")


func add_player_character(username: String):
	var player_character = preload("res://scenes/entities/Player/player.tscn").instantiate()
	player_character.name = username
	current_world.add_child(player_character)
	#print("Successfully added new player character: " + str(username) + "!")
	g.add_player(username)
	
	if username == AuthManager.my_username:
		local_player_character = player_character
		g.me = player_character
		GlobalSignals.give_main_player.emit(local_player_character)
		AuthManager.joined.emit()

@rpc("authority", "call_local", "reliable")
func remove_player(username: String):
	g.remove_player(username)

@rpc("any_peer", "call_local")
func add_newly_connected_player_character(username):
	add_player_character(username)

@rpc("any_peer", "reliable")
func add_previously_connected_player_characters(players: Dictionary):
	for username in players:
		add_player_character(username)
	g.Players = players

@rpc("authority", "call_local", "reliable")
func update_planet_position(planet_name: String, pos: Vector2): g.update_planet_position(planet_name, pos)

@rpc("authority", "call_local", "reliable")
func update_planet_landable(planet_name: String, landable: bool): g.update_planet_landable(planet_name, landable)

@rpc # Only Clients
func add_existing_planets(Planets: Dictionary):
	for i in Planets:
		var planet_name: String = Planets[i]["name"]
		var pos: Vector2 = Planets[i]["global_position"]
		var landable: bool = Planets[i]["landable"]
		var is_safezone: bool = Planets[i]["is_safezone"]
		
		g.add_planet(planet_name, pos, landable, is_safezone)

@rpc
func set_planets_positions(planets_positions: Array):
	current_world.set_planets_positions(planets_positions)


func client_signals():
	g.local_player_position.connect(handle_update_position)
	g.local_player_rotation.connect(handle_update_rotation)
	g.local_player_velocity.connect(handle_update_velocity)
	g.local_player_engine_active.connect(handle_update_engine_active)
	g.player_info.connect(handle_update_player_info)
	
	g.player_shoot.connect(handle_player_shoot)
	g.set_weapon_request.connect(_on_set_weapon_request)


## PLAYERS

func handle_update_position(pos: Vector2): update_player_position.rpc_id(1, AuthManager.my_username, pos)
func handle_update_rotation(rot: float): update_player_rotation.rpc_id(1, AuthManager.my_username, rot)
func handle_update_velocity(vel: Vector2): update_player_velocity.rpc_id(1, AuthManager.my_username, vel)
func handle_update_engine_active(activity: bool): update_player_engine_active.rpc_id(1, AuthManager.my_username, activity)
func handle_update_player_info(player_info: Dictionary): g.set_player_info(player_info)
func handle_player_shoot(index: int): player_shoot.rpc_id(1, AuthManager.my_username, index)

func _on_set_weapon_request(slot: int, weapon_name: String): request_set_weapon.rpc_id(1, slot, weapon_name)
func handle_set_weapon_request(_user_id: int, _slot: int, _weapon_name: String): pass # Only Server

@rpc("any_peer", "call_local", "reliable")
func update_player_nickname(username: String, nick: String): g.update_player_nickname(username, nick)

@rpc("authority", "reliable")
func set_player_position(pos: Vector2): g.emit_signal("set_local_player_position", pos)

@rpc("any_peer", "unreliable")
func update_player_position(username: String, pos: Vector2): g.update_player_position(username, pos)

@rpc("any_peer", "unreliable")
func update_player_rotation(username: String, rot: float): g.update_player_rotation(username, rot)

@rpc("any_peer", "unreliable")
func update_player_velocity(username: String, vel: Vector2): g.update_player_velocity(username, vel)

@rpc("any_peer", "unreliable")
func update_player_engine_active(username: String, activity: bool): g.update_player_engine_active(username, activity)

@rpc("authority", "call_local", "reliable")
func update_player_lvl(username: String, lvl: int): g.update_player_lvl(username, lvl)

@rpc("authority", "call_local", "reliable")
func update_player_max_health(username: String, max_health: float): g.update_player_max_health(username, max_health)

@rpc("authority", "call_local", "reliable")
func update_player_health(username: String, health: float): g.update_player_health(username, health)

@rpc("authority", "call_local", "reliable")
func update_player_armor(username: String, armor: float): g.update_player_armor(username, armor)

@rpc("authority", "call_local", "reliable")
func update_player_max_shield(username: String, max_shield: float): g.update_player_max_shield(username, max_shield)

@rpc("authority", "call_local", "reliable")
func update_player_shield(username: String, shield: float): g.update_player_shield(username, shield)

@rpc("authority", "call_local", "reliable")
func update_player_shield_regen(username: String, shield_regen: float): g.update_player_shield_regen(username, shield_regen)

@rpc("authority", "call_local", "reliable")
func update_player_alive(username: String, alive: bool): g.update_player_alive(username, alive)

@rpc("authority", "call_local", "reliable")
func update_player_monitorable(username: String, monitorable: bool): g.update_player_monitorable(username, monitorable)

@rpc("authority", "call_local", "reliable")
func update_player_ship_name(username: String, ship_name: String): g.update_player_ship_name(username, ship_name)

@rpc("authority", "call_local", "reliable")
func player_death_args(death_args: Dictionary):
	g.emit_signal("death_args", death_args)

@rpc("authority", "call_remote", "reliable")
func send_player_info(player_info: Dictionary):
	g.player_info.emit(player_info)

@rpc("any_peer", "call_remote", "reliable")
func player_shoot(player_name: String, index: int):
	g.handle_player_shoot(player_name, index)

@rpc("any_peer", "call_remote", "reliable")
func request_set_weapon(slot: int, weapon_name: String):
	handle_set_weapon_request(multiplayer.get_remote_sender_id(), slot, weapon_name)

## WEAPONS & BULLETS


func handle_weapon_fired(shooter_name: String, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary):
	fire_weapon.rpc_id(1, shooter_name, weapon_name, weapon_args, bullet_args)

@rpc("any_peer", "reliable")
func fire_weapon(shooter_name: String, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary):
	g.fire_weapon(shooter_name, weapon_name, current_world, weapon_args, bullet_args)

@rpc("any_peer", "call_remote", "reliable")
func spawn_bullet_on_client(
	bullet_path: String, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: int
):
	g.add_bullet(
		bullet_path, bullet_name,
		global_pos, is_deterministic,
		direction_speed, fall,
		life_time, current_life_time,
		server_timestamp
	)
	
@rpc("any_peer", "call_remote", "unreliable")
func update_bullet_position(bullet_name: String, pos: Vector2):
	g.update_bullet_position(bullet_name, pos)

@rpc("any_peer", "call_local", "unreliable")
func bullet_freed(bullet_name: String):
	g.remove_bullet(bullet_name)

@rpc("any_peer", "call_remote", "unreliable")
func update_bullet_is_deterministic(bullet_name: String, is_deterministic: bool):
	g.update_bullet_is_deterministic(bullet_name, is_deterministic)


## SPAWNERS


@rpc
func add_existing_spawners(Spawners: Dictionary):
	handle_add_spawners(Spawners)

func handle_add_spawners(Spawners: Dictionary):
	for i in Spawners:
		g.add_spawner(Spawners[i])
		create_spawner(Spawners[i].id)

# Client
func create_spawner(id: int):
	var spawner = preload("res://scenes/objects/Spawners/spawner.tscn").instantiate()
	spawner.name = str(id)
	
	var spawner_data = g.Spawners[id]
	current_world.add_child(spawner)
	spawner.global_position = spawner_data["global_position"]
	spawner.sprite.rotation = spawner_data["rotation"]

@rpc("authority", "call_local", "unreliable")
func update_spawner_position(id: int, pos: Vector2): g.update_spawner_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_spawner_rotation(id: int, rot: float): g.update_spawner_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_spawner_max_health(id: int, max_health: float): g.update_spawner_max_health(id, max_health)

@rpc("authority", "call_local", "reliable")
func update_spawner_health(id: int, health: float): g.update_spawner_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_spawner_max_shield(id: int, max_shield: float): g.update_spawner_max_shield(id, max_shield)

@rpc("authority", "call_local", "reliable")
func update_spawner_shield(id: int, shield: float): g.update_spawner_shield(id, shield)

@rpc("authority", "call_local", "unreliable")
func update_spawner_eye_position(id: int, pos: Vector2): g.update_spawner_eye_position(id, pos)

@rpc("authority", "call_local", "reliable")
func update_spawner_eye_trigger(id: int, trigger: bool): g.update_spawner_eye_trigger(id, trigger)

@rpc("authority", "call_local", "reliable")
func update_spawner_active(id: int, active: bool): g.update_spawner_active(id, active)


## TURRETS


@rpc
func add_existing_turrets(Turrets: Dictionary):
	handle_add_turrets(Turrets)

func handle_add_turrets(Turrets: Dictionary):
	for i in Turrets:
		var turret = Turrets[i]
		g.add_turret(turret)
		create_turret(turret.id)

@rpc("authority", "call_local", "reliable")
func add_turret(turret: Dictionary):
	g.add_turret(turret)
	
	# Only on Client
	create_turret(turret.id)

@rpc("authority", "call_local", "reliable")
func remove_turret(id: int):
	g.remove_turret(id)


func create_turret(id: int):
	var turret = preload("res://scenes/objects/Spawners/Turrets/turret.tscn").instantiate()
	turret.name = str(id)
	
	var turret_data = g.Turrets[id]
	turret.global_position = turret_data["global_position"]
	turret.rotation = turret_data["rotation"]
	
	current_world.add_child(turret)

@rpc("authority", "call_local", "reliable")
func update_turret_position(id: int, pos: Vector2): g.update_turret_position(id, pos)

@rpc("authority", "call_local", "reliable")
func update_turret_rotation(id: int, rot: float): g.update_turret_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_turret_max_health(id: int, max_health: float): g.update_turret_max_health(id, max_health)

@rpc("authority", "call_local", "reliable")
func update_turret_health(id: int, health: float): g.update_turret_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_turret_max_shield(id: int, max_shield: float): g.update_turret_max_shield(id, max_shield)

@rpc("authority", "call_local", "reliable")
func update_turret_shield(id: int, shield: float): g.update_turret_shield(id, shield)


## ENEMIES


@rpc
func add_existing_enemies(Enemies: Dictionary):
	handle_add_enemies(Enemies)

func handle_add_enemies(Enemies: Dictionary):
	for i in Enemies:
		var enemy: Dictionary = Enemies[i]
		g.add_enemy(enemy)
		create_enemy(enemy.id)

@rpc("authority", "call_local", "reliable")
func add_enemy(enemy: Dictionary):
	g.add_enemy(enemy)
	
	# Only on Client
	create_enemy(enemy.id)

@rpc("authority", "call_local", "reliable")
func remove_enemy(id: int):
	g.remove_enemy(id)


func create_enemy(id: int):
	var enemy: Actor = preload("res://scenes/entities/Actor/actor.tscn").instantiate()
	enemy.name = str(id)
	
	var enemy_data: Dictionary = g.Enemies[id]
	enemy.global_position = enemy_data.global_position
	enemy.rotation = enemy_data.rotation
	
	current_world.add_child(enemy)

@rpc("authority", "call_local", "unreliable")
func update_enemy_position(id: int, pos: Vector2): g.update_enemy_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_enemy_rotation(id: int, rot: float): g.update_enemy_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_enemy_max_health(id: int, max_health: float): g.update_enemy_max_health(id, max_health)

@rpc("authority", "call_local", "reliable")
func update_enemy_health(id: int, health: float): g.update_enemy_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_enemy_max_shield(id: int, max_shield: float): g.update_enemy_max_shield(id, max_shield)

@rpc("authority", "call_local", "reliable")
func update_enemy_shield(id: int, shield: float): g.update_enemy_shield(id, shield)

@rpc("authority", "call_local", "reliable")
func update_enemy_engine_active(id: int, engine_active: bool): g.update_enemy_engine_active(id, engine_active)
