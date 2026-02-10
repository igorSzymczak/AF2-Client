extends Node2D
class_name Game

@onready var ui = $UI

@export var current_world: Node2D

const PORT: int = 7000
const ADDRESS: String = "127.0.0.1"
#const ADDRESS: String = "83.29.89.59"
#const ADDRESS: String = "130.61.143.133"

var local_player_character: Player

var connected_peer_ids: Array = []
var multiplayer_peer

var client_id
func _ready():
	g.current_world = current_world
	#print("loading client...")
	start_client()
	client_id = str(multiplayer.get_unique_id())
	AuthManager.my_user_id = client_id
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


func add_player_character(user_id: int):
	var player_character = preload("res://scenes/entities/Player/player.tscn").instantiate()
	player_character.name = str(user_id)
	player_character.gid = user_id
	current_world.add_child(player_character)
	#print("Successfully added new player character: " + str(username) + "!")
	g.add_player(user_id)
	g.Players[user_id]["node"] = player_character
	
	if user_id == AuthManager.my_user_id:
		local_player_character = player_character
		g.me = player_character
		GlobalSignals.give_main_player.emit(local_player_character)
		AuthManager.joined.emit()

@rpc("authority", "call_local", "reliable")
func remove_player(user_id: int):
	g.remove_player(user_id)

@rpc("any_peer", "call_local")
func add_newly_connected_player_character(user_id: int):
	add_player_character(user_id)

@rpc("any_peer", "reliable")
func add_previously_connected_player_characters(players: Dictionary[int, Dictionary]):
	g.Players = players
	for user_id in players:
		add_player_character(user_id)


func client_signals():
	g.local_player_position.connect(handle_update_position)
	g.local_player_rotation.connect(handle_update_rotation)
	g.local_player_velocity.connect(handle_update_velocity)
	g.local_player_engine_active.connect(handle_update_engine_active)
	g.local_player_speed_boost.connect(handle_update_speed_boost)
	g.player_info.connect(handle_update_player_info)
	
	g.player_shoot.connect(handle_player_shoot)
	g.set_weapon_request.connect(_on_set_weapon_request)

## STRUCTURES

@rpc("authority", "call_remote", "reliable")
func update_structure_property(id: int, prop: int, value: Variant):
	handle_client_structure_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_structures(structures: Array[Dictionary]):
	for structure_data: Dictionary in structures:
		handle_client_structure_added(structure_data)

@rpc("authority", "call_remote", "reliable")
func add_structure(structure_data: Dictionary):
	handle_client_structure_added(structure_data)

func handle_client_structure_added(_structure_data: Dictionary):
	g.add_structure(_structure_data)

func handle_client_structure_property_changed(_id: int, _prop: int, _value: Variant):
	g.update_structure_property(_id, _prop, _value)



## PLAYERS

func handle_update_position(pos: Vector2): update_player_position.rpc_id(1, AuthManager.my_user_id, pos)
func handle_update_rotation(rot: float): update_player_rotation.rpc_id(1, AuthManager.my_user_id, rot)
func handle_update_velocity(vel: Vector2): update_player_velocity.rpc_id(1, AuthManager.my_user_id, vel)
func handle_update_engine_active(activity: bool): update_player_engine_active.rpc_id(1, AuthManager.my_user_id, activity)
func handle_update_player_info(player_info: Dictionary): g.set_player_info(player_info)
func handle_player_shoot(index: int): player_shoot.rpc_id(1, AuthManager.my_user_id, index)
func handle_update_speed_boost(activity: bool): update_player_speed_boost.rpc_id(1, AuthManager.my_user_id, activity)

func _on_set_weapon_request(slot: int, weapon_type: WeaponManager.Type): request_set_weapon.rpc_id(1, slot, weapon_type)
func handle_set_weapon_request(_user_id: int, _slot: int, _weapon_type: WeaponManager.Type): pass # Only Server

@rpc("any_peer", "call_local", "reliable")
func update_player_nickname(user_id: int, nick: String): g.update_player_nickname(user_id, nick)

@rpc("authority", "reliable")
func set_player_position(pos: Vector2): g.emit_signal("set_local_player_position", pos)

@rpc("any_peer", "unreliable")
func update_player_position(user_id: int, pos: Vector2): g.update_player_position(user_id, pos)

@rpc("any_peer", "unreliable")
func update_player_rotation(user_id: int, rot: float): g.update_player_rotation(user_id, rot)

@rpc("any_peer", "unreliable")
func update_player_velocity(user_id: int, vel: Vector2): g.update_player_velocity(user_id, vel)

@rpc("any_peer", "reliable")
func update_player_engine_active(user_id: int, activity: bool): g.update_player_engine_active(user_id, activity)

@rpc("any_peer", "reliable")
func update_player_speed_boost(user_id: int, speed_boost: bool): g.update_player_speed_boost(user_id, speed_boost)

@rpc("authority", "call_local", "reliable")
func update_player_lvl(user_id: int, lvl: int): g.update_player_lvl(user_id, lvl)

@rpc("authority", "call_local", "reliable")
func update_player_health(user_id: int, health: float): g.update_player_health(user_id, health)

@rpc("authority", "call_local", "reliable")
func update_player_shield(user_id: int, shield: float): g.update_player_shield(user_id, shield)

@rpc("authority", "call_local", "reliable")
func update_player_alive(user_id: int, alive: bool): g.update_player_alive(user_id, alive)

@rpc("authority", "call_local", "reliable")
func update_player_monitorable(user_id: int, monitorable: bool): g.update_player_monitorable(user_id, monitorable)

@rpc("authority", "call_local", "reliable")
func update_player_ship_name(user_id: int, ship_name: String): g.update_player_ship_name(user_id, ship_name)

@rpc("authority", "call_remote", "reliable")
func player_death_args(death_args: Dictionary):
	g.emit_signal("death_args", death_args)

@rpc("authority", "call_remote", "reliable")
func send_player_info(player_info: Dictionary):
	g.player_info.emit(player_info)

@rpc("any_peer", "call_remote", "reliable")
func player_shoot(user_id: int, index: int):
	g.handle_player_shoot(user_id, index)

@rpc("any_peer", "call_remote", "reliable")
func request_set_weapon(slot: int, weapon_type: WeaponManager.Type):
	handle_set_weapon_request(multiplayer.get_remote_sender_id(), slot, weapon_type)


## WEAPONS & BULLETS


func handle_weapon_fired(shooter_id: int, weapon_type: WeaponManager.Type, weapon_args: Dictionary, bullet_args: Dictionary):
	fire_weapon.rpc_id(1, shooter_id, weapon_type, weapon_args, bullet_args)

@rpc("any_peer", "reliable")
func fire_weapon(shooter_id: int, weapon_type: WeaponManager.Type, weapon_args: Dictionary, bullet_args: Dictionary):
	g.fire_weapon(shooter_id, weapon_type, current_world, weapon_args, bullet_args)

@rpc("any_peer", "call_remote", "reliable")
func spawn_bullet_on_client(
	bullet_type: WeaponManager.BulletType, bullet_name: String,
	global_pos: Vector2, is_deterministic: bool,
	direction_speed: Vector2, fall: float,
	life_time: int, current_life_time: int,
	server_timestamp: int
):
	g.add_bullet(
		bullet_type, bullet_name,
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



## SHOCK WAVES


@rpc("any_peer", "call_remote", "reliable")
func spawn_shockwave_on_client(
	shockwave_type: WeaponManager.ShockwaveType, _name: String,
	pos: Vector2, rot: float,
	speed: float, angle: float, 
	time_to_vanish: float, current_time_of_living: int,
	server_timestamp: int
) -> void:
	handle_create_shockwave(shockwave_type, _name, pos, rot, speed, angle, time_to_vanish, current_time_of_living, server_timestamp)

func handle_create_shockwave(shockwave_type: WeaponManager.ShockwaveType, _name: String, pos: Vector2, rot:float, speed: float, angle: float, time_to_vanish: float, current_time_of_living: int,server_timestamp: int) -> void:
		g.shockwave_created.emit(shockwave_type, _name, pos, rot, speed, angle, time_to_vanish, current_time_of_living, server_timestamp)



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
	spawner.gid = id
	
	var spawner_data = g.Spawners[id]
	current_world.add_child(spawner)
	g.Spawners[id]["node"] = spawner
	spawner.global_position = spawner_data["global_position"]
	spawner.sprite.rotation = spawner_data["rotation"]
	var spawner_stats: Dictionary = g.get_spawner_stats(id)
	for stat: Stats.TYPE in spawner_stats.keys():
		spawner.stats.set_stat_value(stat, spawner_stats[stat])

@rpc("authority", "call_local", "unreliable")
func update_spawner_position(id: int, pos: Vector2): g.update_spawner_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_spawner_rotation(id: int, rot: float): g.update_spawner_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_spawner_health(id: int, health: float): g.update_spawner_health(id, health)

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
func add_existing_turrets(Turrets: Dictionary[int, Dictionary]):
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
	turret.gid = id
	
	var turret_data = g.Turrets[id]
	turret.global_position = turret_data["global_position"]
	turret.rotation = turret_data["rotation"]
	
	current_world.add_child(turret)
	g.Turrets[id]["node"] = turret

@rpc("authority", "call_local", "reliable")
func update_turret_position(id: int, pos: Vector2): g.update_turret_position(id, pos)

@rpc("authority", "call_local", "reliable")
func update_turret_rotation(id: int, rot: float): g.update_turret_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_turret_health(id: int, health: float): g.update_turret_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_turret_shield(id: int, shield: float): g.update_turret_shield(id, shield)


## ENEMIES


@rpc
func add_existing_enemies(Enemies: Dictionary[int, Dictionary]):
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
	enemy.gid = id
	
	var enemy_data: Dictionary = g.Enemies[id]
	enemy.global_position = enemy_data.global_position
	enemy.rotation = enemy_data.rotation
	
	current_world.add_child(enemy)
	g.Enemies[id]["node"] = enemy

@rpc("authority", "call_local", "unreliable")
func update_enemy_position(id: int, pos: Vector2): g.update_enemy_position(id, pos)

@rpc("authority", "call_local", "unreliable")
func update_enemy_rotation(id: int, rot: float): g.update_enemy_rotation(id, rot)

@rpc("authority", "call_local", "reliable")
func update_enemy_health(id: int, health: float): g.update_enemy_health(id, health)

@rpc("authority", "call_local", "reliable")
func update_enemy_shield(id: int, shield: float): g.update_enemy_shield(id, shield)

@rpc("authority", "call_local", "reliable")
func update_enemy_engine_active(id: int, engine_active: bool): g.update_enemy_engine_active(id, engine_active)

## ITEMS




@rpc("authority", "call_local", "reliable")
func add_item(item: Dictionary):
	g.add_item(item)
	
	# Only on Client
	create_item(item.id)

@rpc
func add_existing_items(Items: Dictionary):
	handle_add_items(Items)

# Client Functions
func handle_add_items(Items: Dictionary):
	for i in Items:
		var item: Dictionary = Items[i]
		g.add_item(item)
		create_item(item.id)

func create_item(id: int):
	
	var item_data: Dictionary = g.Items[id]
	var item: Item = ItemManager.create_item_scene(
		item_data.type, item_data.code, item_data.display_name,
		item_data.start_position, item_data.target_position
	)
	
	item.name = str(id)
	current_world.add_child(item)
	
