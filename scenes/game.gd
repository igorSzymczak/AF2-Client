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

func client_signals():
	g.local_player_property_changed.connect(handle_local_player_property_changed)
	g.player_info.connect(handle_update_player_info)
	
	g.player_shoot.connect(handle_player_shoot)
	g.set_weapon_request.connect(_on_set_weapon_request)
	g.requested_toggle_pvp.connect(_on_requested_toggle_pvp)

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

func handle_local_player_property_changed(prop: int, value: Variant):
	update_local_player_property.rpc_id(1, prop, value)

@rpc("any_peer", "call_remote", "reliable")
func update_local_player_property(prop: int, value: Variant):
	server_handle_local_player_property(multiplayer.get_remote_sender_id(), prop, value)

@rpc("authority", "call_remote", "reliable")
func update_player_property(id: int, prop: int, value: Variant):
	handle_client_player_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_players(players: Array[Dictionary]):
	for player_data: Dictionary in players:
		handle_client_player_added(player_data)

@rpc("authority", "call_remote", "reliable")
func add_player(player_data: Dictionary):
	handle_client_player_added(player_data)

@rpc("authority", "call_remote", "reliable")
func remove_player(id: int):
	handle_client_player_removed(id)

func handle_client_player_added(player_data: Dictionary):
	g.add_player(player_data)

func handle_client_player_property_changed(id: int, prop: int, value: Variant):
	g.update_player_property(id, prop, value)

func handle_client_player_removed(id: int):
	g.remove_player(id)

func handle_update_player_info(player_info: Dictionary): g.set_player_info(player_info)
func handle_player_shoot(index: int): player_shoot.rpc_id(1, AuthManager.my_user_id, index)

func _on_set_weapon_request(slot: int, weapon_type: WeaponManager.Type): request_set_weapon.rpc_id(1, slot, weapon_type)
func handle_set_weapon_request(_user_id: int, _slot: int, _weapon_type: WeaponManager.Type): pass # Only Server

func _on_requested_toggle_pvp(value: bool):
	request_toogle_pvp.rpc_id(1, value)

@rpc("authority", "call_remote", "reliable")
func set_player_position(pos: Vector2):
	g.me.global_position = pos
	g.me.velocity = Vector2.ZERO

@rpc("authority", "call_remote", "reliable")
func send_player_info(player_info: Dictionary):
	g.player_info.emit(player_info)

@rpc("any_peer", "call_remote", "reliable")
func player_shoot(user_id: int, index: int):
	g.handle_player_shoot(user_id, index)

@rpc("any_peer", "call_remote", "reliable")
func request_set_weapon(slot: int, weapon_type: WeaponManager.Type):
	handle_set_weapon_request(multiplayer.get_remote_sender_id(), slot, weapon_type)

@rpc("any_peer", "call_remote", "reliable")
func request_toogle_pvp(value: bool):
	_handle_request_toggle_pvp(multiplayer.get_remote_sender_id(), value)

func server_handle_local_player_property(_user_id: int, _prop: int, _value: Variant):
	pass # Only Server

func _handle_request_toggle_pvp(_user_id: int, _value: bool) -> void:
	pass # Only Server

## WEAPONS & BULLETS



@rpc("authority", "call_remote", "reliable")
func update_bullet_property(id: int, prop: int, value: Variant):
	handle_client_bullet_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_bullets(bullets: Array[Dictionary]):
	for bullet_data: Dictionary in bullets:
		handle_client_bullet_added(bullet_data)

@rpc("authority", "call_remote", "reliable")
func add_bullet(bullet_data: Dictionary):
	handle_client_bullet_added(bullet_data)

@rpc("authority", "call_remote", "reliable")
func remove_bullet(id: int):
	handle_client_bullet_removed(id)

func handle_client_bullet_added(bullet_data: Dictionary):
	g.add_bullet(bullet_data)

func handle_client_bullet_property_changed(id: int, prop: int, value: Variant):
	g.update_bullet_property(id, prop, value)

func handle_client_bullet_removed(id: int):
	g.remove_bullet(id)


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


@rpc("authority", "call_remote", "reliable")
func update_spawner_property(id: int, prop: int, value: Variant):
	handle_client_spawner_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_spawners(spawners: Array[Dictionary]):
	for spawner_data: Dictionary in spawners:
		handle_client_spawner_added(spawner_data)

@rpc("authority", "call_remote", "reliable")
func add_spawner(spawner_data: Dictionary):
	handle_client_spawner_added(spawner_data)

@rpc("authority", "call_remote", "reliable")
func remove_spawner(id: int):
	handle_client_spawner_removed(id)


func handle_client_spawner_added(spawner_data: Dictionary):
	g.add_spawner(spawner_data)

func handle_client_spawner_property_changed(id: int, prop: int, value: Variant):
	g.update_spawner_property(id, prop, value)

func handle_client_spawner_removed(id: int):
	g.remove_spawner(id)



## TURRETS



@rpc("authority", "call_remote", "reliable")
func update_turret_property(id: int, prop: int, value: Variant):
	handle_client_turret_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_turrets(turrets: Array[Dictionary]):
	for turret_data: Dictionary in turrets:
		handle_client_turret_added(turret_data)

@rpc("authority", "call_remote", "reliable")
func add_turret(turret_data: Dictionary):
	handle_client_turret_added(turret_data)

@rpc("authority", "call_remote", "reliable")
func remove_turret(id: int):
	handle_client_turret_removed(id)


func handle_client_turret_added(turret_data: Dictionary):
	g.add_turret(turret_data)

func handle_client_turret_property_changed(id: int, prop: int, value: Variant):
	g.update_turret_property(id, prop, value)

func handle_client_turret_removed(id: int):
	g.remove_turret(id)



## ENEMIES



@rpc("authority", "call_remote", "reliable")
func update_actor_property(id: int, prop: int, value: Variant):
	handle_client_actor_property_changed(id, prop, value)

@rpc("authority", "call_remote", "reliable")
func add_existing_actors(actors: Array[Dictionary]):
	for actor_data: Dictionary in actors:
		handle_client_actor_added(actor_data)

@rpc("authority", "call_remote", "reliable")
func add_actor(actor_data: Dictionary):
	handle_client_actor_added(actor_data)

@rpc("authority", "call_remote", "reliable")
func remove_actor(id: int):
	handle_client_actor_removed(id)


func handle_client_actor_added(actor_data: Dictionary):
	g.add_actor(actor_data)

func handle_client_actor_property_changed(id: int, prop: int, value: Variant):
	g.update_actor_property(id, prop, value)

func handle_client_actor_removed(id: int):
	g.remove_turret(id)

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
	
