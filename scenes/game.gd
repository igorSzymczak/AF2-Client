extends Node2D
class_name Game

@onready var ui = $UI

@export var current_world: Node2D

const PORT: int = 7000
#const ADDRESS: String = "34.141.29.102"
const ADDRESS: String = "127.0.0.1"
const max_clients: int = 3

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
	GameManager.add_player(username)
	
	if username == AuthManager.my_username:
		local_player_character = player_character
		GameManager.local_player = player_character
		GlobalSignals.emit_signal("give_main_player", local_player_character)

@rpc("authority", "call_local", "reliable")
func remove_player(username: String):
	GameManager.remove_player(username)

@rpc("any_peer", "call_local")
func add_newly_connected_player_character(username):
	add_player_character(username)

@rpc("any_peer", "reliable")
func add_previously_connected_player_characters(players: Dictionary):
	for username in players:
		add_player_character(username)
	GameManager.Players = players

@rpc("authority", "call_local", "reliable")
func update_planet_position(planet_name: String, pos: Vector2): GameManager.update_planet_position(planet_name, pos)

@rpc # Only Clients
func add_existing_planets(Planets: Dictionary):
	for i in Planets:
		var planet_name: String = Planets[i]["name"]
		var pos: Vector2 = Planets[i]["global_position"]
		
		GameManager.add_planet(planet_name, pos)

@rpc
func set_planets_positions(planets_positions: Array):
	current_world.set_planets_positions(planets_positions)


func client_signals():
	GameManager.connect("local_player_position", handle_update_position)
	GameManager.connect("local_player_rotation", handle_update_rotation)
	GameManager.connect("local_player_velocity", handle_update_velocity)
	GameManager.connect("local_player_engine_active", handle_update_engine_active)
	GameManager.connect("player_info", handle_update_player_info)
	
	GameManager.connect("player_shoot", handle_player_shoot)
	

## PLAYERS

func handle_update_position(pos: Vector2): update_player_position.rpc_id(1, AuthManager.my_username, pos)
func handle_update_rotation(rot: float): update_player_rotation.rpc_id(1, AuthManager.my_username, rot)
func handle_update_velocity(vel: Vector2): update_player_velocity.rpc_id(1, AuthManager.my_username, vel)
func handle_update_engine_active(activity: bool): update_player_engine_active.rpc_id(1, AuthManager.my_username, activity)
func handle_update_player_info(player_info: Dictionary): GameManager.set_player_info(player_info)
func handle_player_shoot(index: int): player_shoot.rpc_id(1, AuthManager.my_username, index)

@rpc("any_peer", "call_local", "reliable")
func update_player_nickname(username: String, nick: String): GameManager.update_player_nickname(username, nick)

@rpc("authority", "reliable")
func set_player_position(pos: Vector2): GameManager.emit_signal("set_local_player_position", pos)

@rpc("any_peer", "unreliable")
func update_player_position(username: String, pos: Vector2): GameManager.update_player_position(username, pos)

@rpc("any_peer", "unreliable")
func update_player_rotation(username: String, rot: float): GameManager.update_player_rotation(username, rot)

@rpc("any_peer", "unreliable")
func update_player_velocity(username: String, vel: Vector2): GameManager.update_player_velocity(username, vel)

@rpc("any_peer", "unreliable")
func update_player_engine_active(username: String, activity: bool): GameManager.update_player_engine_active(username, activity)

@rpc("authority", "call_local", "reliable")
func update_player_health(username: String, health: float): GameManager.update_player_health(username, health)

@rpc("authority", "call_local", "reliable")
func update_player_shield(username: String, shield: float): GameManager.update_player_shield(username, shield)

@rpc("authority", "call_local", "reliable")
func update_player_alive(username: String, alive: bool): GameManager.update_player_alive(username, alive)

@rpc("authority", "call_local", "reliable")
func update_player_ship_name(username: String, ship_name: String): GameManager.update_player_ship_name(username, ship_name)

@rpc("authority", "call_local", "reliable")
func player_death_args(death_args: Dictionary):
	GameManager.emit_signal("death_args", death_args)

@rpc("authority", "call_remote", "reliable")
func send_player_info(player_info: Dictionary):
	GameManager.player_info.emit(player_info)

@rpc("any_peer", "call_remote", "reliable")
func player_shoot(player_name: String, index: int):
	GameManager.handle_player_shoot(player_name, index)


## WEAPONS & BULLETS


func handle_weapon_fired(shooter_name: String, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary):
	fire_weapon.rpc_id(1, shooter_name, weapon_name, weapon_args, bullet_args)

@rpc("any_peer", "reliable")
func fire_weapon(shooter_name: String, weapon_name: String, weapon_args: Dictionary, bullet_args: Dictionary):
	GameManager.fire_weapon(shooter_name, weapon_name, current_world, weapon_args, bullet_args)

@rpc("any_peer", "call_remote", "reliable")
func spawn_bullet_on_client(
	bullet_path: String, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: int
):
	GameManager.add_bullet(
		bullet_path, bullet_name,
		global_pos, is_deterministic,
		direction_speed, fall,
		life_time, current_life_time,
		server_timestamp
	)
	
@rpc("any_peer", "call_remote", "unreliable")
func update_bullet_position(bullet_name: String, pos: Vector2):
	GameManager.update_bullet_position(bullet_name, pos)

@rpc("any_peer", "call_local", "unreliable")
func bullet_freed(bullet_name: String):
	GameManager.remove_bullet(bullet_name)

@rpc("any_peer", "call_remote", "unreliable")
func update_bullet_is_deterministic(bullet_name: String, is_deterministic: bool):
	GameManager.update_bullet_is_deterministic(bullet_name, is_deterministic)


## SPAWNERS


@rpc
func add_existing_spawners(Spawners: Dictionary):
	handle_add_spawners(Spawners)

func handle_add_spawners(Spawners: Dictionary):
	for i in Spawners:
		var spawner_name = Spawners[i]["name"]
		var id = Spawners[i]["id"]
		var pos = Spawners[i]["global_position"]
		var rot = Spawners[i]["rotation"]
		var health = Spawners[i]["health"]
		var shield = Spawners[i]["shield"]
		var eye_pos = Spawners[i]["eye_position"]
		var eye_trigger = Spawners[i]["eye_trigger"]
		var active = Spawners[i]["active"]
		GameManager.add_spawner(spawner_name, id, pos, rot, health, shield, eye_pos, eye_trigger, active)
		create_spawner(id)

# Client
func create_spawner(id: int):
	var spawner = preload("res://scenes/objects/Spawners/spawner.tscn").instantiate()
	spawner.name = str(id)
	
	var spawner_data = GameManager.Spawners[id]
	current_world.add_child(spawner)
	spawner.global_position = spawner_data["global_position"]
	spawner.sprite.rotation = spawner_data["rotation"]

@rpc("authority", "call_local", "unreliable")
func update_spawner_position(id: int, pos: Vector2): GameManager.update_spawner_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_spawner_rotation(id: int, rot: float): GameManager.update_spawner_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_spawner_health(id: int, health: float): GameManager.update_spawner_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_spawner_shield(id: int, shield: float): GameManager.update_spawner_shield(id, shield)

@rpc("authority", "call_local", "unreliable")
func update_spawner_eye_position(id: int, pos: Vector2): GameManager.update_spawner_eye_position(id, pos)

@rpc("authority", "call_local", "reliable")
func update_spawner_eye_trigger(id: int, trigger: bool): GameManager.update_spawner_eye_trigger(id, trigger)

@rpc("authority", "call_local", "reliable")
func update_spawner_active(id: int, active: bool): GameManager.update_spawner_active(id, active)


## TURRETS


@rpc
func add_existing_turrets(Turrets: Dictionary):
	handle_add_turrets(Turrets)

func handle_add_turrets(Turrets: Dictionary):
	for i in Turrets:
		var turret_name = Turrets[i]["name"]
		var id = Turrets[i]["id"]
		var pos = Turrets[i]["global_position"]
		var rot = Turrets[i]["rotation"]
		var health = Turrets[i]["health"]
		var shield = Turrets[i]["shield"]
		GameManager.add_turret(turret_name, id, pos, rot, health, shield)
		create_turret(id)

@rpc("authority", "call_local", "reliable")
func add_turret(turret_name: String, id: int, pos: Vector2, rot: float, health: float, shield: float):
	GameManager.add_turret(turret_name, id, pos, rot, health, shield)
	
	# Only on Client
	create_turret(id)

@rpc("authority", "call_local", "reliable")
func remove_turret(id: int):
	GameManager.remove_turret(id)


func create_turret(id: int):
	var turret = preload("res://scenes/objects/Spawners/Turrets/turret.tscn").instantiate()
	turret.name = str(id)
	
	var turret_data = GameManager.Turrets[id]
	turret.global_position = turret_data["global_position"]
	turret.rotation = turret_data["rotation"]
	
	current_world.add_child(turret)

@rpc("authority", "call_local", "reliable")
func update_turret_position(id: int, pos: Vector2): GameManager.update_turret_position(id, pos)

@rpc("authority", "call_local", "reliable")
func update_turret_rotation(id: int, rot: float): GameManager.update_turret_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_turret_health(id: int, health: float): GameManager.update_turret_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_turret_shield(id: int, shield: float): GameManager.update_turret_shield(id, shield)


## ENEMIES


@rpc
func add_existing_enemies(Enemies: Dictionary):
	handle_add_enemies(Enemies)

func handle_add_enemies(Enemies: Dictionary):
	for i in Enemies:
		var enemy_name = Enemies[i]["name"]
		var id = Enemies[i]["id"]
		var pos = Enemies[i]["global_position"]
		var rot = Enemies[i]["rotation"]
		var health = Enemies[i]["health"]
		var shield = Enemies[i]["shield"]
		var engine_active = Enemies[i]["engine_active"]
		GameManager.add_enemy(enemy_name, id, pos, rot, health, shield, engine_active)
		create_enemy(id)

@rpc("authority", "call_local", "reliable")
func add_enemy(enemy_name: String, id: int, pos: Vector2, rot: float, health: float, shield: float, engine_active: bool):
	GameManager.add_enemy(enemy_name, id, pos, rot, health, shield, engine_active)
	
	# Only on Client
	create_enemy(id)

@rpc("authority", "call_local", "reliable")
func remove_enemy(id: int):
	GameManager.remove_enemy(id)


func create_enemy(id: int):
	var enemy = preload("res://scenes/entities/Actor/actor.tscn").instantiate()
	enemy.name = str(id)
	
	var enemy_data = GameManager.Enemies[id]
	enemy.global_position = enemy_data["global_position"]
	enemy.rotation = enemy_data["rotation"]
	
	current_world.add_child(enemy)

@rpc("authority", "call_local", "unreliable")
func update_enemy_position(id: int, pos: Vector2): GameManager.update_enemy_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_enemy_rotation(id: int, rot: float): GameManager.update_enemy_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_enemy_health(id: int, health: float): GameManager.update_enemy_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_enemy_shield(id: int, shield: float): GameManager.update_enemy_shield(id, shield)

@rpc("authority", "call_local", "reliable")
func update_enemy_engine_active(id: int, engine_active: bool): GameManager.update_enemy_engine_active(id, engine_active)
