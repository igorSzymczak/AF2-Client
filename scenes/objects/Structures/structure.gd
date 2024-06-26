extends Area2D
class_name Structure

@export var landable: bool
@export var orbit_time_MS: float
@export var is_shown: bool = true

@export var aura_blue: Node2D
@export var aura_red: Node2D

const time_multiplier: float = 30

@export var is_sun: bool = false
@export var is_shadered: bool = false
@export var local_sun: Structure
@onready var orbit: Structure
@onready var sprite: Sprite2D = $Sprite
@onready var land_area: CollisionShape2D = $LandArea

var is_safezone: bool = false
var safezone: Area2D

@export var poi_type: String = "planet"
	
func get_visibility() -> bool:
	return is_shown
	
func _ready():
	GlobalSignals.emit_signal("setup_poi", self)
	
	set_orbit()
	
	if !is_shown:
		$Sprite.visible = false

func _process(delta: float) -> void:
	set_safezone()
	
	update_server_position()
	update_landable()
	
	self_orbit(delta)
	update_shader(delta)
	handle_landing(delta)

func set_safezone():
	if !is_safezone:
		is_safezone = g.get_planet_is_safezone(name)
		if !is_safezone: return
	if is_instance_valid(safezone): return
	
	safezone = $SafeZone
	
var server_pos := Vector2.ZERO
func update_server_position():
	var temp = g.get_planet_position(name)
	
	if temp != server_pos:
		server_pos = temp
		global_position = server_pos

@onready var server_landable: bool = landable
func update_landable():
	server_landable = g.get_planet_landable(name)
	if server_landable != landable:
		landable = server_landable
		
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
	
	shader_offset += Vector2(angle_to_rotate, 0)
	
	var planet_rotation = sprite.rotation
	var cos_rot = cos(planet_rotation)
	var sin_rot = sin(planet_rotation)

	var rotated_angle_to_sun = Vector2(angle_to_sun.x * cos_rot + angle_to_sun.y * sin_rot,
									-angle_to_sun.x * sin_rot + angle_to_sun.y * cos_rot)

	var light_direction = Vector3(rotated_angle_to_sun.x, rotated_angle_to_sun.y, light_z)

	sprite.material.set_shader_parameter("light_direction", light_direction)
	sprite.material.set_shader_parameter("texture_offset", shader_offset)
	#print()



## LANDING



var structure_data: Dictionary = { "name": name }
func get_structure_data() -> Dictionary: return structure_data
func set_structure_data(data: Dictionary):
	structure_data = data
	if g.me.landed_structure != null:
		GlobalSignals.set_ui_args.emit(data)

func land_player_on(username: String, structure_name: String):
	if structure_name == name:
		var player: Player = g.get_player(username)
		player.land_on(self)

func handle_landing(_delta: float):
	if !Input.is_action_just_pressed("Land"): return
	if !g.can_perform_actions: return
	if !landable: return
	if !g.me: return
	if g.me.landed_structure != null: return
	if !g.me.alive: return
	
	if get_overlapping_bodies().has(g.me):
		request_land.rpc_id(1, AuthManager.my_username, name)

func try_to_land(_username: String, _structure_name: String): pass # Only Server

# from Client to Server
@rpc("any_peer", "call_remote", "reliable")
func request_land(username: String, structure_name: String):
	try_to_land(username, structure_name)

# from Server to Client
@rpc("authority", "call_local", "reliable")
func land_player(username: String, structure_name: String):
	land_player_on(username, structure_name)

@rpc("authority", "call_remote", "reliable")
func update_structure_data(data: Dictionary):
	set_structure_data(data)
