extends Area2D
class_name Structure

var gid: int
@export var structure_name: String
var props: PropertyContainer = PropertyContainer.new(g.STRUCTURE_PROPERTY_SCHEMA)

@export var landable: bool
@export var orbit_time_MS: float
@export var is_shown: bool = true

@export var aura_blue: Node2D
@export var aura_red: Node2D

const time_multiplier: float = 30

@export var is_sun: bool = false
@export var is_shadered: bool = false
@export var local_sun: Structure
var orbit: Structure
@onready var sprite: Sprite2D = $Sprite
@onready var land_area: CollisionShape2D = $LandArea

@onready var poi: POI = $PoiComponent

var is_safezone: bool = false
var safezone: Area2D
	
func get_visibility() -> bool:
	return is_shown
	
func _ready():
	set_orbit()
	props.property_changed.connect(_handle_property_changed)
	
	if !is_shown:
		$Sprite.visible = false
	
	await AuthManager.logged_in
	g.current_world.structures.append(self)
	poi.label = structure_name

func _process(delta: float) -> void:
	set_safezone()
	
	self_orbit(delta)
	update_shader(delta)
	handle_landing(delta)

func set_safezone():
	if !is_instance_valid(safezone): return
	
	safezone = $SafeZone

func _handle_property_changed(prop: g.StructureProperty, value: Variant) -> void:
	match prop:
		g.StructureProperty.GID:
			gid = value
		g.StructureProperty.GLOBAL_POSITION:
			global_position = value
		g.StructureProperty.ORBIT_TIME_MS:
			orbit_time_MS = value
		g.StructureProperty.LANDABLE:
			if landable == value:
				return
			landable = value
			update_landable()
		g.StructureProperty.IS_SAFEZONE:
			if is_safezone == value:
				return
			is_safezone = value
			set_safezone()

#var server_pos := Vector2.ZERO
#func update_server_position():
	#var temp = g.get_planet_position(name)
	#
	#if temp != server_pos:
		#server_pos = temp
		#global_position = server_pos

func update_landable():
	if !is_instance_valid(aura_blue) or !is_instance_valid(aura_red):
		return
	
	aura_blue.show()
	aura_red.show()
	
	if landable:
		var blue_tween := create_tween()
		blue_tween.tween_property(aura_blue, "modulate:a", 1, 2)
		
		var red_tween := create_tween()
		red_tween.tween_property(aura_red, "modulate:a", 0, 2)
		
		await get_tree().create_timer(2).timeout
		if landable: aura_red.hide()
		
	elif !landable:
		var blue_tween := create_tween()
		blue_tween.tween_property(aura_blue, "modulate:a", 0, 2)
		
		var red_tween := create_tween()
		red_tween.tween_property(aura_red, "modulate:a", 1, 2)
		
		await get_tree().create_timer(2).timeout
		if landable: aura_blue.hide()

func self_orbit(delta: float) -> void:
	if !orbit:
		return
	
	var angle: float = (2 * PI * delta) *  (1000.0 / (orbit_time_MS * time_multiplier))
	
	global_position = Functions.rotate_point_around_center(global_position, orbit.global_position, angle)

func set_orbit() -> void:
	var parent = get_parent()
	if parent is Structure:
		orbit = parent

var shader_offset = null
var angle_to_rotate = null
func update_shader(delta: float) -> void:
	if !is_shadered or !local_sun:
		return
	
	if angle_to_rotate == null:
		angle_to_rotate = (2.0 / (1.0 / delta)) *  (350.0 / (orbit_time_MS * time_multiplier * 3))
	if shader_offset == null:
		shader_offset = sprite.material.get_shader_parameter("texture_offset")
	
	var distance_to_sun_squared = sprite.global_position.distance_squared_to(local_sun.global_position)
	var t = (distance_to_sun_squared - 100000) / 100000
	var light_z = atan(t) - 1
	
	
	var angle_to_sun = sprite.global_position.direction_to(local_sun.global_position)
	sprite.rotate(angle_to_rotate * -2)
	
	shader_offset += Vector2(angle_to_rotate, 0) * 10.0
	
	var planet_rotation = sprite.rotation
	var cos_rot = cos(planet_rotation)
	var sin_rot = sin(planet_rotation)

	var rotated_angle_to_sun = Vector2(angle_to_sun.x * cos_rot + angle_to_sun.y * sin_rot,
									-angle_to_sun.x * sin_rot + angle_to_sun.y * cos_rot)

	var light_direction = Vector3(rotated_angle_to_sun.x, rotated_angle_to_sun.y, light_z)

	sprite.material.set_shader_parameter("light_direction", light_direction)
	sprite.material.set_shader_parameter("texture_offset", shader_offset)



## LANDING



var structure_data: Dictionary = { "name": name }
func get_structure_data() -> Dictionary: return structure_data
func set_structure_data(data: Dictionary):
	structure_data = data
	if g.me.landed_structure != null:
		GlobalSignals.set_ui_args.emit(data)

func land_player_on(user_id: int, land_structure_name: String):
	if land_structure_name == structure_name:
		var player: Player = g.get_player(user_id)
		if is_instance_valid(player):
			player.land_on(self)
		else:
			push_warning("Player ", user_id, " not found, playerlist: ")
			push_warning(g.Players)

func handle_landing(_delta: float):
	if !Input.is_action_just_pressed("Land"): return
	if !g.can_perform_actions: return
	if !landable: return
	if !g.me: return
	if g.me.landed_structure != null: return
	if !g.me.alive: return
	
	if get_overlapping_bodies().has(g.me):
		print("Landing!")
		request_land.rpc_id(1, AuthManager.my_user_id, structure_name)

func try_to_land(_user_id: int, _structure_name: String): pass # Only Server

# from Client to Server
@rpc("any_peer", "call_remote", "reliable")
func request_land(user_id: int, structures_name: String):
	try_to_land(user_id, structures_name)

# from Server to Clients
@rpc("authority", "call_local", "reliable")
func land_player(user_id: int, structures_name: String):
	land_player_on(user_id, structures_name)

@rpc("authority", "call_remote", "reliable")
func update_structure_data(data: Dictionary):
	set_structure_data(data)
	
@rpc("any_peer", "call_remote", "reliable")
func request_leave_structure(user_id: int):
	try_leave_structure(user_id)

@rpc("authority", "call_local", "reliable")
func leave_structure(user_id: int):
	animate_leave_structure(user_id)

func try_leave_structure(_user_id: int) -> void:
	pass # only server

func animate_leave_structure(user_id: int) -> void:
	var player: Player = g.get_player(user_id)
	if is_instance_valid(player):
		player.animate_leave_structure()
