class_name Beam extends Node2D

var gid: int
var beam_type: WeaponManager.BeamType
var props := PropertyContainer.new(g.BEAM_PROPERTY_SCHEMA)
var distance: float = 1.0
var has_target: bool = false : set = set_has_target

@export var point_amount: int = 10

func _ready() -> void:
	props.property_changed.connect(_on_property_changed)
	#print("Beam ready!")
	server_position = global_position
	server_rotation = rotation
	_on_ready()

func _on_ready() -> void:
	pass

func _on_property_changed(prop: g.BeamProperty, value: Variant) -> void:
	match prop:
		g.BeamProperty.GID:
			gid = value
		g.BeamProperty.BEAM_TYPE:
			beam_type = value
		g.BeamProperty.GLOBAL_POSITION:
			server_position = value
		g.BeamProperty.ANGLE:
			server_rotation = value
		g.BeamProperty.DISTANCE:
			distance = value
			create_beam()
		g.BeamProperty.HAS_TARGET:
			has_target = value
		g.BeamProperty.IS_LOCAL_PLAYER:
			is_local_player = value
			if is_local_player:
				var weapon_data: WeaponRuntimeData = PlayerData.get_current_weapon_data()
				shoot_delay_sec = weapon_data.get_prop(PlayerData.WeaponProperty.SHOOT_DELAY) / 1000.0
				power_cost = weapon_data.get_prop(PlayerData.WeaponProperty.POWER_USAGE)
				
		g.BeamProperty.TIME_FROM_LAST_DAMAGE:
			time_from_last_damage = value
		

var time_from_last_damage: float = 0.0
var is_local_player: bool = false
var shoot_delay_sec: float = 0.0
var power_cost: float = 0.0
func _process(delta: float) -> void:
	if !g.Beams.has(gid):
		_handle_death()
	
	handle_local_player_beam(delta)
	interpolate_data(delta)

func handle_local_player_beam(delta: float) -> void:
	if !is_local_player:
		return
	if !has_target:
		return
	
	#print("cost: ", power_cost)
	#print("Shoot delay sec: ", shoot_delay_sec)
	
	time_from_last_damage += delta
	if time_from_last_damage > shoot_delay_sec:
		time_from_last_damage -= shoot_delay_sec
		PlayerData.take_power(power_cost)

func set_has_target(value: bool) -> void:
	has_target = value

var server_position: Vector2 = Vector2.ZERO
var server_rotation: float = 0.0
func interpolate_data(delta: float) -> void:
	var factor: float = delta * 20.0
	
	global_position = global_position.lerp(server_position, factor)
	rotation = lerp_angle(rotation, server_rotation, factor)

@export var base_line: Line2D
func create_beam() -> void:
	var mid_distance: float = distance / float(point_amount)
	base_line.clear_points()
	base_line.add_point(Vector2(0.0, 0.0))
	base_line.add_point(Vector2(mid_distance / 10.0, 0.0))
	var i: int = 1
	while base_line.points.size() <= point_amount:
		var point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
		base_line.add_point(point_position)
		i+=1
	
	var end_point_position := Vector2(max(10.0, mid_distance * float(i)), 0.0)
	base_line.add_point(end_point_position - Vector2(mid_distance / 10.0, 0.0))
	base_line.add_point(end_point_position)

func _handle_death() -> void:
	
	queue_free()
